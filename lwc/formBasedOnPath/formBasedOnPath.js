import { LightningElement, api } from 'lwc';
import doSave from '@salesforce/apex/formBasedOnPath.saveData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import StayInTouchSignature from '@salesforce/schema/User.StayInTouchSignature';


export default class FormBasedOnPath extends LightningElement {


	@api recordId;
	@api stepsField;
	@api step;


	
	handleSave(evt){
		console.log("cccccccccccccccccccccccccccccccccccccccc")
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
			console.log("error 23", error)
		})
	}

	showToast(title, msg, variant){
		this.dispatchEvent(new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
		}));
	}
	handleCancelButtons(evt){
		this.template.querySelector('c-flowformlwc').initMehtod();
	}
	handleCancel(evt){
		console.log("llego cancel formBasedOnPath")
		console.log('botonera.step evt ',JSON.parse(JSON.stringify(evt)) );
		/*
		if(evt.detail.refresh){
			let flowForm = this.template.querySelector('c-flowformlwc');
			let botonera = flowForm.querySelector('c-ob-webservice-buttons');
			if(botonera){
				console.log('holaaaaaaa botonera.step ', botonera);
				console.log('botonera.step ', botonera.step, ' flowForm.step ', flowForm.step);
				botonera.step = flowForm.step;
			}
		}
		*/
		
		this.dispatchEvent(new CustomEvent("cancel", {
			detail: evt.detail
        }));
	}
}