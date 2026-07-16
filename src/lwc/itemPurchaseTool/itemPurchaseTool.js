import { LightningElement, api, wire } from 'lwc';

import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';

export default class ItemPurchaseTool extends LightningElement {

    @api recordId;

    account;
    error;

    @wire(getAccountInfo, { accountId: '$recordId' })
    wiredAccount({ data, error }) {

        if (data) {

            this.account = data;
            this.error = undefined;
        }
        else if (error) {

            this.error = error;
            this.account = undefined;
        }
    }
}