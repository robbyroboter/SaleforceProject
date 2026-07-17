import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';
import getItems from '@salesforce/apex/ItemController.getItems';

export default class ItemPurchaseTool extends LightningElement {

    @api recordId;

    account;
    error;
    items = [];

    selectedItem;
    isModalOpen = false;

    cart = [];
    isCartOpen = false;

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


}