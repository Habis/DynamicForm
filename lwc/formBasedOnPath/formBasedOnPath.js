import { LightningElement, api } from 'lwc';
import doSave from '@salesforce/apex/formBasedOnPath.saveData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class FormBasedOnPath extends LightningElement {


	@api recordId;
	@api stepsField;
	@api step;
	
	handleSave(evt){
		console.log(JSON.parse(JSON.stringify(evt.detail)));
		console.log(this.template.querySelector('c-flowformlwc'));

		doSave({jsonData:JSON.stringify(evt.detail.draftValues), pathField : this.stepsField, recId: this.recordId})
		.then(result =>{
			if(result){
				console.log(`result save ${result}`);

				if(result != 'currentStep'){
					this.dispatchEvent(new CustomEvent("cancel", {
						detail: {"cancel" : true, "actualStep" : result}
					}));
				}
				
				this.template.querySelector('c-flowformlwc').initMehtod(result);
				this.showToast('OK', 'Todo OK', 'success');
			}
		})
		.catch(error =>{
			this.showToast('KO', 'Error', 'error');
			console.log("error", error)
		})
	}

	showToast(title, msg, variant){
		this.dispatchEvent(new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
		}));
	}

	handleCancel(evt){
		console.log("llego cancel formBasedOnPath")
		this.dispatchEvent(new CustomEvent("cancel", {
			detail: evt.detail
        }));
	}
}