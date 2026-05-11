import { LightningElement, api } from 'lwc';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

export default class FileUploadInFlow extends LightningElement {
    @api recordId;
    @api uploadedFileNames
    
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.uploadedFileNames = uploadedFiles.map(x=> x.name);

    }
}