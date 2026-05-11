/**
     * @description       : 
     * @author            : Somnath Sharma
     * @group             : 
     * @last modified on  : 07-28-2023
     * @last modified by  : SOMNATH SHARMA
    **/
    import { LightningElement, api } from 'lwc';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import { NavigationMixin } from 'lightning/navigation';

    export default class Headlessaction extends NavigationMixin(LightningElement) {


        /**Implement invoke()
    In your Lightning web component, expose invoke() as a public method. 
    The invoke() method executes every time the quick action is triggered.**/
        @api invoke() {
            console.log("Hi, I'm an action. INVOKE HEADLESS");
            let event = new ShowToastEvent({
                title: 'I am a headless action!',
                message: 'Hi there! Starting...',
            });
            this.dispatchEvent(event);
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__objectPage',
            //     attributes: {
            //         objectApiName: 'Contact',
            //         actionName: 'home',
            //     },
            // });
        }

        connectedCallback() {
            console.log("Connected will not get called ");
            alert('-headless action LWC-I am called when the page loads in normal case, but invoke() will get called when u click on the quick action button');
        }
        renderedCallback() {
            // every change will call me remmember
            //but i will have h1
            alert('renderedcallback called-headless');
        }


    }