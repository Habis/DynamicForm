import { LightningElement, api } from 'lwc';
import getFormInfo from '@salesforce/apex/flowFormController.getInfo';
import getSingleFormInfo from '@salesforce/apex/flowFormController.getSingleInfo';


export default class Flowformlwc extends LightningElement {

	configStepsOrder;
	configInfoJson;
	hiddenRules;
	sobjectType;
	bloqconditions;
	viewOnlyconditions;
	mapsobjsdb;
	actualStep;
	currentStepAux;
	@api stepFieldApiName;
	@api recordId;
	@api stepsField;
	@api formName;
	@api flowName;
	showForm = true;
	res;
	showspinner = true;
	loaded = false;

	@api step

	connectedCallback(){
		console.log(`connectedCallback ${this.recordId} ${this.stepsField} `);
		this.initMehtod();

	}


	@api initMehtod(currentStep){
		console.log('result lasd`fokjasdf');
		this.showspinner = true;
		this.loaded = false;
		console.log('AAAA', this.flowName);
		if(!this.formName){
			console.log('PRIMERO');
			getFormInfo({recordId : this.recordId, flow : this.flowName, stepField : this.stepsField})
			.then(result => {
				console.log('result', result);
				console.log(result.form);
				if(Object.keys(result.form).length > 0){
					this.res = result;
					this.init = true;
					this.hiddenRules = result.hiddenRules;
					this.configInfoJson = result.form;
					this.configStepsOrder = result.stepOrder;
					this.sobjectType = result.mainSobjType;
					this.bloqconditions = result.lstConditionsBloq;
					this.viewOnlyconditions = result.lstConditionsViewOnly;
					this.mapsobjsdb = result.map_sobjects;
					this.showspinner = false;
					this.loaded = true;
				
					if(currentStep == 'currentStep'){
						this.step = this.currentStepAux;
						this.actualStep = this.actualStep;
						console.log('this.currentStepAux ' + this.currentStepAux);
						console.log('this.actualStep ' + this.actualStep);
						//dynamicForm.setActualStep(this.actualStep);

					}else if(currentStep){
						this.step = currentStep;
						this.actualStep = currentStep;
					}else{
						this.step = result.step;
						this.actualStep = result.step;
					}
					console.log('this.step', this.step);
					//obBtns.step = this.step;
					this.dispatchEvent(new CustomEvent("cancel", {
						detail: {"cancel" : false, "refresh" : true}
					}));
				}else{
					this.showForm = false;
				}
			})
			.catch(error => {
				this.error = error;
				console.log(this.error);
			});
		}else{
			console.log('SEGUNDO');
			getSingleFormInfo({recordId : this.recordId, formName : this.formName})
			.then(result => {
				console.log('result', result);
				this.res = result;
				this.init = true;
				this.hiddenRules = result.hiddenRules;
				this.configInfoJson = result.form;
				this.sobjectType = result.mainSobjType;
				this.bloqconditions = result.lstConditionsBloq;
				this.viewOnlyconditions = result.lstConditionsViewOnly;
				this.mapsobjsdb = result.map_sobjects;
				
				this.showspinner = false;
				this.loaded = true;
				this.step = result.step;
				this.actualStep = result.step;				
			
				this.dispatchEvent(new CustomEvent("cancel", {
					detail: {"cancel" : false, "refresh" : true}
				}));

			})
			.catch(error => {
				this.error = error;
				console.log(this.error);
			});
		}
	}


	doCancel(evt){
		console.log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", evt.detail);
		this.currentStepAux = evt.detail.currentStep;
		this.actualStep = evt.detail.actualStep;
		this.initMehtod('currentStep');
		/*this.dispatchEvent(new CustomEvent("cancel", {
			detail: evt.detail
        }));*/
	}

	doSave(evt){
		console.log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ", evt.detail);
		this.actualStep = evt.detail.actualStep;
		this.currentStepAux = evt.detail.currentStep;
		console.log('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')
		this.dispatchEvent(new CustomEvent("save", {
			detail: evt.detail
        }));
	}
}