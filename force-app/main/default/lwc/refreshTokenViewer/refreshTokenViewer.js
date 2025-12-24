/**
 * Calls Apex RefreshTokenFlowImplementationLWC.fetchTop5Aura() and renders results.
 * Robust loading and error handling; exposes computed getters for UI state.
 */
import { LightningElement, track } from 'lwc';
import fetchTop5Aura from '@salesforce/apex/RefreshTokenFlowImplementationLWC.fetchTop5Aura';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RefreshTokenViewer extends LightningElement {
    @track records = null;
    @track errorMessage = '';
    isLoading = false;

    get hasNoData() {
        return !this.isLoading && !this.errorMessage && Array.isArray(this.records) && this.records.length === 0;
    }

    get rawJson() {
        try {
            return this.records ? JSON.stringify(this.records, null, 2) : '';
        } catch (e) {
            return '';
        }
    }

    async handleRefresh() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            const data = await fetchTop5Aura();
            this.records = Array.isArray(data) ? data : [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `Fetched ${this.records.length} record(s).`,
                    variant: 'success'
                })
            );
        } catch (err) {
            this.records = null;
            this.errorMessage = this.normalizeError(err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.errorMessage,
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Normalizes various error shapes returned from wire/imperative Apex calls
     * into a human readable message string for UI/toast.
     */
    normalizeError(err) {
        // Apex errors may have body.message or body.pageErrors
        if (!err) return 'Unknown error';
        if (Array.isArray(err.body)) {
            return err.body.map(e => e.message).join(', ');
        } else if (err.body && typeof err.body.message === 'string') {
            return err.body.message;
        } else if (typeof err.message === 'string') {
            return err.message;
        }
        try {
            return JSON.stringify(err);
        } catch (e) {
            return 'Unexpected error';
        }
    }
}
