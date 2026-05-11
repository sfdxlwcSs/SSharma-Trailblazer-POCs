import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkIn
from '@salesforce/apex/GuestQrScannerController.checkIn';

import ZXING from '@salesforce/resourceUrl/zxingbrowser';

export default class MobileQrTest extends LightningElement {

    codeReader;

    initialized = false;

    scanning = false;

    status = 'Loading...';

    scannedValue = '';

    statusType = 'loading'; // loading, scanning, success, error

    // Computed properties for status indicators
    get isSuccess() {
        return this.statusType === 'success';
    }

    get isError() {
        return this.statusType === 'error';
    }

    get isScanning() {
        return this.statusType === 'scanning';
    }

    get statusClass() {
        const baseClass = 'slds-text-align_center slds-p-around_small';
        if (this.statusType === 'success') {
            return baseClass + ' slds-text-color_success';
        } else if (this.statusType === 'error') {
            return baseClass + ' slds-text-color_error';
        }
        return baseClass;
    }

    renderedCallback() {

        if (this.initialized) {
            return;
        }

        this.initialized = true;

        console.log('STATIC RESOURCE URL => ', ZXING);

        loadScript(this, ZXING)

            .then(() => {

                console.log(
                    'ZXING LOADED SUCCESSFULLY'
                );

                console.log(window.ZXingBrowser);

                if (!window.ZXingBrowser) {

                    this.status =
                        'ZXing object missing';

                    return;
                }

                this.status =
                    'Library Loaded';
                
                this.statusType = 'loading';

                this.startScanner();
            })

            .catch(error => {

                console.error(
                    'LIBRARY LOAD ERROR',
                    error
                );

                this.status =
                    'Library failed';
            });
    }

    async startScanner() {

        try {

            // Prevent multiple scanner instances
            if (this.scanning) {
                return;
            }

            this.scanning = true;

            this.status =
                'Opening Camera';

            const videoElement =
                this.template.querySelector(
                    'video'
                );

            this.codeReader =
                new window.ZXingBrowser
                    .BrowserQRCodeReader();

            const devices =
                await window.ZXingBrowser
                    .BrowserCodeReader
                    .listVideoInputDevices();

            console.log(
                'CAMERA DEVICES => ',
                devices
            );

            if (
                !devices ||
                devices.length === 0
            ) {

                this.status =
                    'No camera found';

                this.scanning = false;

                return;
            }

            // Prefer rear camera
            const backCamera =
                devices.find(device => {

                    const label =
                        device.label
                            ? device.label
                                .toLowerCase()
                            : '';

                    return (
                        label.includes('back') ||
                        label.includes('rear')
                    );
                });

            const selectedDeviceId =
                backCamera
                    ? backCamera.deviceId
                    : devices[0].deviceId;

            console.log(
                'SELECTED DEVICE => ',
                selectedDeviceId
            );

            this.status =
                'Ready to scan QR code';
            
            this.statusType = 'scanning';

            this.codeReader.decodeFromVideoDevice(

                selectedDeviceId,

                videoElement,

                async (result, err) => {

                    if (result) {

                        console.log(
                            'QR RESULT => ',
                            result
                        );

                        const text =
                            result.getText();

                        console.log(
                            'QR TEXT => ',
                            text
                        );

                        this.scannedValue =
                            text;

                        this.status =
                            'Processing Check-In';

                        // Stop scanner
                        this.stopScanner();

                        try {

                            console.log(
                                'CALLING APEX'
                            );

                            const response =
                                await checkIn({

                                    qrValue: text
                                });

                            console.log(
                                'APEX RESPONSE => ',
                                response
                            );

                            this.status =
                                response;
                            
                            // Determine if success or info message
                            if (response.includes('successfully')) {
                                this.statusType = 'success';
                                
                                // Show success toast
                                this.showToast(
                                    'Success',
                                    response,
                                    'success'
                                );
                            } else {
                                this.statusType = 'success'; // Still success for already checked in
                                
                                // Show info toast
                                this.showToast(
                                    'Information',
                                    response,
                                    'info'
                                );
                            }

                            // Mobile vibration
                            if (
                                navigator.vibrate
                            ) {

                                navigator.vibrate(
                                    200
                                );
                            }

                        } catch (apexError) {

                            console.error(
                                'APEX ERROR => ',
                                apexError
                            );

                            let message =
                                'Check-in failed';

                            if (
                                apexError &&
                                apexError.body &&
                                apexError.body
                                    .message
                            ) {

                                message =
                                    apexError.body
                                        .message;
                            }

                            this.status =
                                message;
                            
                            this.statusType = 'error';
                            
                            // Show error toast
                            this.showToast(
                                'Error',
                                message,
                                'error'
                            );
                        }

                        // Restart scanner automatically
                        setTimeout(() => {

                            this.startScanner();

                        }, 2000);
                    }

                    // Ignore continuous scan errors
                    if (err) {

                        // uncomment if debugging needed
                        // console.log(err);
                    }
                }
            );

        } catch (e) {

            console.error(
                'CAMERA ERROR => ',
                e
            );

            this.status =
                'Camera failed';

            this.scanning = false;
        }
    }

    stopScanner() {

        try {

            if (this.codeReader) {

                this.codeReader.reset();
            }

        } catch (e) {

            console.error(
                'STOP ERROR => ',
                e
            );
        }

        this.scanning = false;

        this.status =
            'Scanner stopped';
    }

    /**
     * @description Shows a toast notification
     * @param {String} title - Toast title
     * @param {String} message - Toast message (includes attendee name)
     * @param {String} variant - Toast variant (success, error, info)
     */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    disconnectedCallback() {

        this.stopScanner();
    }
}