import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';
import getItems from '@salesforce/apex/ItemController.getItems';
import checkout from '@salesforce/apex/CheckoutController.checkout';
import isCurrentUserManager from '@salesforce/apex/UserController.isCurrentUserManager';
import updateItemImage from '@salesforce/apex/ItemImageController.updateItemImage';

export default class ItemPurchaseTool extends NavigationMixin(LightningElement) {

    @api recordId;

    account;
    error;
    items = [];

    selectedItem;
    isModalOpen = false;

    cart = [];
    isCartOpen = false;
    isManager = false;
    isCreateModalOpen = false;

    selectedFamily = '';
    selectedType = '';
    searchText = '';

    familyOptions = [
        { label: 'All', value: '' },
        { label: 'Phone', value: 'Phone' },
        { label: 'Laptop', value: 'Laptop' },
        { label: 'Tablet', value: 'Tablet' },
        { label: 'Accessory', value: 'Accessory' }
    ];

    typeOptions = [
        { label: 'All', value: '' },
        { label: 'Electronic', value: 'Electronic' },
        { label: 'Furniture', value: 'Furniture' },
        { label: 'Food', value: 'Food' },
        { label: 'Other', value: 'Other' }
    ];

    @wire(getAccountInfo, { accountId: '$recordId' })
    wiredAccount({ data, error }) {
        if (data) {
            this.account = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.account = undefined;
            console.error(error);
        }
    }

    connectedCallback() {
        this.loadItems();
        this.checkManager();
    }

    loadItems() {
        getItems({
            familyFilter: this.selectedFamily,
            typeFilter: this.selectedType,
            searchText: this.searchText
        })
            .then(result => {
                this.items = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleFamilyChange(event) {
        this.selectedFamily = event.detail.value;
        this.loadItems();
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.loadItems();
    }

    handleSearchChange(event) {
        this.searchText = event.target.value;
        this.loadItems();
    }

    handleDetails(event) {
        const itemId = event.target.dataset.id;

        this.selectedItem = this.items.find(
            item => item.Id === itemId
        );
        if (this.selectedItem) {
            this.isModalOpen = true;
        }
    }

    handleAdd(event) {
        const itemId = event.target.dataset.id;
        const item = this.items.find(
            item => item.Id === itemId
        );

        if (!item) {
            return;
        }
        if (item.AvailableQuantity__c <= 0) {
            this.showToast(
                'Error',
                'Item is out of stock',
                'error'
            );
            return;
        }

        const alreadyAdded = this.cart.find(
            cartItem => cartItem.Id === itemId
        );

        if (alreadyAdded) {

            this.showToast(
                'Info',
                'Item already in cart',
                'info'
            );
            return;
        }
        this.cart = [
            ...this.cart,
            {
                ...item,
                amount: 1
            }
        ];
        this.showToast(
            'Success',
            'Item added to cart',
            'success'
        );
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedItem = undefined;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    get cartTotal() {
        return this.cart.reduce(
            (sum, item) => sum + (item.Price__c * item.amount), 0);
    }

    get cartCount() {
        return this.cart.length;
    }

    openCart() {
        this.isCartOpen = true;
    }

    closeCart() {
        this.isCartOpen = false;
    }

    async handleCheckout() {

        const cartItems = this.cart.map(item => ({
            itemId: item.Id,
            amount: item.amount
        }));

        try {

            const purchaseId = await checkout({
                accountId: this.recordId,
                cartItems: cartItems
            });

            this.showToast(
                'Success',
                'Purchase created',
                'success'
            );

            this.cart = [];
            this.isCartOpen = false;

            this.navigateToPurchase(purchaseId);

        } catch(error) {

            this.showToast(
                'Error',
                error.body.message,
                'error'
            );
        }
    }

    navigateToPurchase(purchaseId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: purchaseId,
                objectApiName: 'Purchase__c',
                actionName: 'view'
            }
        });
    }

    checkManager() {

        isCurrentUserManager()
            .then(result => {
                this.isManager = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

    openCreateItemModal() {
        this.isCreateModalOpen = true;
    }

    closeCreateItemModal() {
        this.isCreateModalOpen = false;
    }

    handleCreateError(event) {
        console.error(
            'CREATE ITEM ERROR:',
            JSON.stringify(event.detail)
        );
    }

    async handleCreateSuccess(event) {

        const itemId = event.detail.id;
        try {
            await updateItemImage({
                itemId: itemId
            });

            this.showToast(
                'Success',
                'Item created with image',
                'success'
            );

        } catch(error) {
            console.error(error);
            this.showToast(
                'Warning',
                'Item created but image was not loaded',
                'warning'
            );
        }

        this.isCreateModalOpen = false;
        await new Promise(resolve => setTimeout(resolve, 1000));
        this.loadItems();
    }
}