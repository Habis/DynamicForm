import { api, LightningElement } from 'lwc';
import getCurrentStep from '@salesforce/apex/ObWebserviceButtonsCtrl_CLS.getStep';
import startContract from '@salesforce/apex/ObWebserviceButtonsCtrl_CLS.startContract';


export default class ObWebserviceButtons extends LightningElement {
    
   	@api step;
	@api stepFields;
	@api recordId;
	evtBtn;

    connectedCallback(){
        console.log('connectedCallback result obWeb ' , this.stepsField);
		if(!this.step){
			getCurrentStep({recordId : this.recordId, stepField : this.stepsField})
			.then(result => {
				console.log('result obWeb', result);
				this.step = result;
			})
			.catch(error => {
				this.error = error;
				console.log(this.error);
			});
		}
	}
	get acceptingDocstBtn(){
		this.evtBtn = 'Accepting docs';
        return this.step == 'Accepting docs';
    }

	get verificationBtn(){
		this.evtBtn = 'Verification';
        return this.step == 'Verification';
    }

	get contractGenBtn(){
		this.evtBtn = 'Creation and Contract Gen';
        return this.step == 'Creation and Contract Gen';
    }

	showAltaAcuerdos(){
		let altaAcuerdos = this.template.querySelector('c-agrement-modal');
		altaAcuerdos.step = this.step;
		console.log('showModal ' , altaAcuerdos );
		altaAcuerdos.openModal();
	}

	contractGen(){

		startContract()
			.then(result => {
				console.log('result startContract', result);
			})
			.catch(error => {
				console.log(error);
			});
	}

    handleExitModal(){
		this.dispatchEvent(new CustomEvent("cancel", {
			detail: {"cancel" : false, "refresh" : true}
		}));
	}

/*
    filterStep(){
        switch (this.stepx){
            case 'New User': this.newUser = true;
        }
    }
    */
}