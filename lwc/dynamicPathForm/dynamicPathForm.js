import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class DynamicPathForm extends LightningElement {

	@api init;
	draftValues = {};
	@api configinfo;
	@api res;
	@api configStepsOrder;
	@api editAllInputs;
	@api hiddenRules;
	@api recordId;
	@api sobjectType;
	@api stepFieldApiName;
	@api bloqconditions;
	@api viewonlyconditions;
	@api mapsobjsdb;
	@api showSpinner;
	mapErrors = {'lstmsgErrors': [] , 'lstmsg': [], 'lststeps': [], 'bloq': false };
	indexErrors = [];
	labelBtnSave = 'Edit';
	config_hiddenFields = {};
	paramsWSConfig = {};
	testArray = {};
	fieldhaveinputs = true;
	showForm = false;
	viewOnly = false;
	currentStep;
	@api actualStep;
	currentForm;
	clave;
	showFooter = false;
	btnSaving = false;
	showAlert = false;
	reloadcmp = true;
	initFormRulesBool = false;

	@api setInitTrue(aaa){
		this.init = true;
	}

	// Setter y Getter de 'step'
	@api
	get step() {
		return this.currentStep;
	}
	set step(value) {
		this.currentStep = value;
		this.initFormByStep(value);
	}

	initFormByStep(value){
		
		this.showForm = false;
		if (this.init) {			
			this.configinfo = JSON.parse(JSON.stringify(this.configinfo));
			this.mapsobjsdb = JSON.parse(JSON.stringify(this.mapsobjsdb));	
			console.log('this.configinfo ', this.configinfo);	console.log('--value--', value);	
			if(this.bloqconditions)this.bloqconditions = JSON.parse(JSON.stringify(this.bloqconditions));
			if(this.viewonlyconditions)this.viewonlyconditions = JSON.parse(JSON.stringify(this.viewonlyconditions));
			console.log('viewonlyconditions ', this.viewonlyconditions);
			this.init = false;
			//this.viewOnly = this.disableBtnEval;
		}
		
		this.draftValues = {};
		this.currentForm = [];
		this.currentForm = this.configinfo[value] ? this.configinfo[value] : [];
		console.log("currentForm", this.mapsobjsdb);	
		//this.changeSectionTitle(this.mapsobjsdb, this.currentForm);
		this.customEval(this.mapsobjsdb);
		this.viewOnlyMode(this.mapsobjsdb);
		//this.disableBtnEval();

		if (this.hiddenRules && this.hiddenRules[value]) this.config_hiddenFields = this.hiddenRules[value] ? this.hiddenRules[value] : {};		
		this.labelBtnSave = 'Edit';
		if (this.currentForm.length != 0) {
			this.showForm = true;
			this.reloadcmp = true;
			console.log('desactivar btn');
			this.viewOnly = this.disableSaveBtn;
			
		}else{
			console.log('--muestra--');
				this.showForm = false;
		}
		this.initFormRulesBool = true;
		this.showSpinner = false;
	}

	viewOnlyMode(mapsobjsdb){
		console.log('>>> viewOnlyMode ', mapsobjsdb);
		if(this.viewonlyconditions){
			var mapkeys = Object.keys(mapsobjsdb);
			for (let i = 0; i < this.viewonlyconditions.length; i++) {
				let conditionAux = this.viewonlyconditions[i].condition;

				mapkeys.forEach(function (key) {

					if (conditionAux.includes(`$${key}`)) {
						conditionAux = conditionAux.replaceAll('$', 'mapsobjsdb.');
					}

				})
				
				if (this.calccondition(conditionAux, mapsobjsdb)) {
					this.mapErrors.bloq = true;
					this.viewOnly = this.disableSaveBtn;
					this.showFooter = true;
					return;
				}
			}
		}
	}


	customEval(mapsobjsdb) {		
		console.log('mapsobjsdb ', mapsobjsdb , ' this.bloqconditions ', this.bloqconditions);
		if(this.bloqconditions){
			var mapkeys = Object.keys(mapsobjsdb);

			for (let i = 0; i < this.bloqconditions.length; i++) {
				
				let indexCurrentStep = this.configStepsOrder[this.currentStep];
				let indexActualStep = this.bloqconditions[i].show ? this.configStepsOrder[this.bloqconditions[i].show] : 0;
				console.log(`index current ${indexCurrentStep} index actual ${indexActualStep} and show step ${this.bloqconditions[i].show}`);
				console.log(indexCurrentStep >= this.bloqconditions[i].show);
				//if(!this.bloqconditions[i].show || (this.bloqconditions[i].show && indexCurrentStep >= indexActualStep)){
					let conditionAux = this.bloqconditions[i].condition;

					mapkeys.forEach(function (key) {

						if (conditionAux.includes(`$${key}`)) {
							conditionAux = conditionAux.replaceAll('$', 'mapsobjsdb.');
						}

					})
					if (this.calccondition(conditionAux, mapsobjsdb) && (!this.bloqconditions[i].show || (this.bloqconditions[i].show && indexCurrentStep >= indexActualStep))) {
						if (this.mapErrors.lstmsg.indexOf(this.bloqconditions[i].msg) == -1) {
							if (!this.mapErrors.bloq) {
								this.mapErrors.bloq = this.bloqconditions[i].bloq.bloq;
								this.showAlert = true;
							}

							this.mapErrors.lstmsgErrors.push({'msg' : this.bloqconditions[i].msg, 'icon' : this.bloqconditions[i].icon});
							this.mapErrors.lstmsg.push(this.bloqconditions[i].msg);

							this.mapErrors.lststeps = this.mapErrors.lststeps.concat(this.bloqconditions[i].bloq.steps);												
							//this.mapErrors.lstIcons = this.bloqconditions[i].icon;
						}
					} else {
						if (this.mapErrors.lstmsg.length > 0 && this.mapErrors.lstmsg.indexOf(this.bloqconditions[i].msg) != -1) {

							let msgindex = this.mapErrors.lstmsg.indexOf(this.bloqconditions[i].msg);
							this.mapErrors.lstmsg.splice(msgindex, 1);
							this.mapErrors.lstmsgErrors.splice(msgindex, 1);

							if (this.mapErrors.lststeps.length > 0 && this.mapErrors.lststeps.indexOf(this.bloqconditions[i].bloq.steps) != - 1) {
								this.mapErrors.lststeps.splice(this.mapErrors.lststeps.indexOf(this.bloqconditions[i].bloq.steps), 1);
							}

						}
						if (this.mapErrors.lstmsg.length == 0) {

							this.showAlert = false;
							this.mapErrors.bloq = false;
						} else {
							this.showAlert = true;
						}

					}
				//}
			}

			let msgalertel = this.template.querySelector('c-msg-alert');			
			if(msgalertel){
				msgalertel.refreshError(this.mapErrors);
			}
		}
	}


	formatDate(date) {
		var d = new Date(date),
			month = '' + (d.getMonth() + 1),
			day = '' + d.getDate(),
			year = d.getFullYear();

		if (month.length < 2) 
			month = '0' + month;
		if (day.length < 2) 
			day = '0' + day;

		return [year, month, day].join('-');
	}

	calccondition(conditionAux, mapsobjsdb) {
		//console.log('conditionAux ', conditionAux, ' mapsobjsdb ', mapsobjsdb);
		let constants = this.fillConstants();
		return Function("mapsobjsdb, constants", `return ${conditionAux}`)(mapsobjsdb, constants);
	}
	
	
	fillConstants(){
		let constantsObj = {};
		constantsObj.today = this.formatDate(new Date());
		constantsObj.getAge = function calculateAge(birthday) { // birthday is a date
			var ageDifMs = Date.now() - new Date(birthday).getTime();
			var ageDate = new Date(ageDifMs); // miliseconds from epoch
			//console.log('prueba123123 dos ', Math.abs(ageDate.getUTCFullYear() - 1970));
			return Math.abs(ageDate.getUTCFullYear() - 1970);
		}
		return constantsObj;
	}

	cancelRefresh() {
		this.init = true;
		//this.currentForm = [];
		
		this.dispatchEvent(new CustomEvent("cancelx", {
			detail: { "cancel": true, "actualStep": this.actualStep,  "currentStep": this.currentStep }
		}));
		//this.step = this.actualStep;


	}

	renderedCallback() {
		//after everything is set, call initrules, that changes visibility rules and call services if needed
		//let obBtns = this.template.querySelector('c-ob-webservice-buttons');		
		if (this.initFormRulesBool) {
			//logic here after everythyng is loaded
			this.initFormRules(this.currentForm);
		}		
	}



	initFormRules(currentForm) {


		for (let i = 0; i < currentForm.length; i++) {
			let fconfig = currentForm[i];

			/*if (fconfig.apiName in this.config_hiddenFields && (this.config_hiddenFields[fconfig.apiName].value == fconfig.value || (this.config_hiddenFields[fconfig.apiName].value == '$.' && fconfig.value != null) )) {
				this.toggleFieldVisibility(this.config_hiddenFields[fconfig.apiName].show, 'show');
			} else if (fconfig.apiName in this.config_hiddenFields && (this.config_hiddenFields[fconfig.apiName].value != fconfig.value || (this.config_hiddenFields[fconfig.apiName].value == '$.' && fconfig.value == null))) {
				this.toggleFieldVisibility(this.config_hiddenFields[fconfig.apiName].show, 'hide');
			}*/

			this.getWSParams(fconfig.sobj, fconfig.apiName, fconfig.value);
			this.checkParamsHiddenRules(fconfig.apiName,fconfig.sobj, fconfig.value);

		}
		this.initFormRulesBool = false;

	}
	checkParamsHiddenRules(apiName, sobjx , fvalue) {
		
		let actionstr = '';
		let apiNameField = sobjx + '.' + apiName;
		
		if (apiNameField in this.config_hiddenFields) {			
			
			for (let i = 0; i < this.config_hiddenFields[apiNameField].length; i++) {
				let hiddenRule = this.config_hiddenFields[apiNameField][i];
				actionstr = '';				
				if (hiddenRule.value == fvalue || (hiddenRule.value == '$.' && fvalue != null)) {
					actionstr = 'show';
				} else if (hiddenRule.value != fvalue || (hiddenRule.value == '$.' && fvalue == null)) {
					actionstr = 'hide'
				}				
				console.log(`apiNameField ${apiNameField} actionstr ${actionstr}`);
				if (actionstr) {
					if (Array.isArray(hiddenRule.show)) {
						for (let j = 0; j < hiddenRule.show.length; j++) {							
							this.toggleFieldVisibility(hiddenRule.show[j], actionstr);
						}
					} else {						
						this.toggleFieldVisibility(hiddenRule.show, actionstr);

					}
				}
			}
		}
	}
	// Metodo para cuando cambie el step
	fieldChanged(evt) {
		console.log('Salta el onchange ');
		let evtinfo = evt.detail;
		console.log('evtinfo', evtinfo.api);
		//this.currentForm[evtinfo.index].value = evtinfo.value;
		this.checkParamsHiddenRules(evtinfo.api? evtinfo.api : evtinfo.key, evtinfo.sobj, evtinfo.value);
		/*if (evtinfo.api in this.config_hiddenFields && (this.config_hiddenFields[evtinfo.api].value == evtinfo.value || this.config_hiddenFields[evtinfo.api].value == '$.')) {
			this.toggleFieldVisibility(this.config_hiddenFields[evtinfo.api].show, 'show');
		} else if (evtinfo.api in this.config_hiddenFields && (this.config_hiddenFields[evtinfo.api].value != evtinfo.value || (this.config_hiddenFields[evtinfo.api].value == '$.' && evtinfo.value == null))) {
			this.toggleFieldVisibility(this.config_hiddenFields[evtinfo.api].show, 'hide');
		}*/

		switch (evtinfo.action) {
			case 'add':
				this.toggleBgEditColor(evtinfo.api, evtinfo.sobj, true);				
				this.fillDraftValues(evtinfo);
				this.lastValPicklist = JSON.parse(JSON.stringify(evtinfo));
				break;
			case 'remove':
				if(this.draftValues[evtinfo.sobj] && this.draftValues[evtinfo.sobj].hasOwnProperty(evtinfo.key)){					
					delete this.draftValues[evtinfo.sobj][evtinfo.key];
					//this.toggleBgEditColor(evtinfo.key, false)
					this.toggleBgEditColor(evtinfo.key, evtinfo.sobj, false);
					this.fillDraftValues(evtinfo);
				}
				break;
		}
		if (Object.keys(this.draftValues).length > 0) {
			this.customEval(this.joinObjects(this.mapsobjsdb, this.draftValues));
		} else {
			this.customEval(this.mapsobjsdb);
		}		

		this.getWSParams(evtinfo.sobj, evtinfo.api, evtinfo.value);
		console.log(' this.draftValues',  this.draftValues);
	}

	joinObjects(obj1, obj2) {
		let objAux = Object.assign({}, obj1);
		let objkeys = Object.keys(obj1);
		let objkeys2 = Object.keys(obj2);
		objkeys.forEach(function (key) {


			objkeys2.forEach(function (keyobj2) {

				if (key == keyobj2) {

					objAux[key] = ({
						...obj1[key],
						...obj2[keyobj2],
					})
				}

			})
		})

		return objAux;
	}

	extend(target) {
		for (var i = 1; i < arguments.length; ++i) {
			var from = arguments[i];
			if (typeof from !== 'object') continue;
			for (var j in from) {
				if (from.hasOwnProperty(j)) {
					target[j] = typeof from[j] === 'object'
						? extend({}, target[j], from[j])
						: from[j];
				}
			}
		}
		return target;
	}

	fillDraftValues(evtinfo) {
		console.log(`filldraft values ${evtinfo.api} ${evtinfo.value}`);
		switch (evtinfo.action) {
			case 'add':
				if (!this.draftValues[evtinfo.sobj]) this.draftValues[evtinfo.sobj] = {};
				this.draftValues[evtinfo.sobj][evtinfo.api] = evtinfo.value;
				/*
				if(!this.mapsobjsdb[evtinfo.sobj]) this.mapsobjsdb[evtinfo.sobj] = {};
				this.mapsobjsdb[evtinfo.sobj][evtinfo.api] = evtinfo.value;

				
				*/
				break;
			case 'remove':
				delete this.draftValues[evtinfo.sobj][evtinfo.key];
				if (Object.keys(this.draftValues[evtinfo.sobj]).length == 0) delete this.draftValues[evtinfo.sobj];
				/*
				delete this.mapsobjsdb[evtinfo.sobj][evtinfo.key];
				if (Object.keys(this.mapsobjsdb[evtinfo.sobj]).length == 0) delete this.mapsobjsdb[evtinfo.sobj];
				*/
				break;
		}

	}

	// Metodo para hacer campos invisibles, utiliza como parametros el nombre del objeto y si quiere cambiarlo a visible o invisible
	toggleFieldVisibility(apiName, action) {		
		let apiNameLst = apiName.split('.');		
		// Si action es visible
		if (action == 'show') {
			console.log(`show ${apiNameLst[0]} ${apiNameLst[1]}`);
			// Muestra el objeto
			this.template.querySelector(`c-pathformfield[data-name="${apiNameLst[1]}"][data-sobj="${apiNameLst[0]}"]`).show();
			// Si el action es hide
		} else if (action == 'hide') {
			console.log(`hide ${apiNameLst[0]} ${apiNameLst[1]}`);

			// Quita el objeto
			let pathFormEl = this.template.querySelector(`c-pathformfield[data-name="${apiNameLst[1]}"][data-sobj="${apiNameLst[0]}"]`);
			if(this.draftValues[apiNameLst[0]]){
				pathFormEl.defaultValues();
				this.toggleBgEditColor(apiNameLst[1], apiNameLst[0], false);
				delete this.draftValues[apiNameLst[0]][apiNameLst[1]];
			}
			pathFormEl.hide();
		}

	}

	toggleLayoutItem(evt) {

		let layoutItem = this.template.querySelector(`lightning-layout-item[data-name="${evt.detail.apiName}"][data-sobj="${evt.detail.sobj}"]`);

		if (evt.detail.hide) {
			layoutItem.classList.add('slds-hide');
		} else {
			layoutItem.classList.remove('slds-hide');
		}
	}

	handleChangeEdit(evt) {				
		if (evt.detail.action) {
			//this.checkOtherEditableFields(evt.detail.fieldSobj);
			let listPathform;
			if(this.editAllInputs == 'true'){
				listPathform = this.template.querySelectorAll(`c-pathformfield`);
			}else{
				listPathform = this.template.querySelectorAll(`c-pathformfield[data-sobj="${evt.detail.fieldSobj}"]`);
			}

			for (let i = 0; i < listPathform.length; i++) {
				listPathform[i].editMode();
			}
			this.labelBtnSave = 'Save';
		}
	}


	checkOtherEditableFields(sObjx){
		let listPathform = this.template.querySelectorAll(`c-pathformfield`);
		for (let i = 0; i < listPathform.length; i++) {			
			if(listPathform[i].finfo.sobj != sObjx){
				listPathform[i].readMode();
			}
			//if(listPathform)
			//listPathform[i].editMode();
		}
	}

	handleSave(evt) {

		let listPathform = this.template.querySelectorAll(`c-pathformfield`);

		if (evt.currentTarget.label == 'Edit') {
			for (let i = 0; i < listPathform.length; i++) {
				listPathform[i].editMode();
			}
			this.labelBtnSave = 'Save';
		} else {
			this.showSpinner = true;
			let validInputs = true;

			for (let i = 0; i < listPathform.length; i++) {

				let isValid = listPathform[i].checkValidInputs();

				if (!isValid){
					this.showToast('Error', 'Completa todos los campos', 'error');
					validInputs = false;
				} 
			}
			if (!this.draftValues[this.sobjectType]) this.draftValues[this.sobjectType] = {};
			if(this.configStepsOrder && this.actualStep == this.currentStep){
				if(this.mapErrors.lstmsg.length == 0){
					if(!this.checkErrosIcons())this.draftValues[this.sobjectType][this.stepFieldApiName] = Object.keys(this.configStepsOrder)[this.configStepsOrder[this.actualStep] + 1];
				}
			}
			console.log(this.draftValues);
			this.customEval(Object.assign({}, this.mapsobjsdb, this.draftValues));
			if (validInputs) {		
				for(let key of Object.keys(this.mapsobjsdb)){
					//Account-1
					//this.draftValues[key+this.mapsobjsdb[i]]['Id'] = this.mapsobjsdb[i]['Id']
					if(this.draftValues[key]){
						this.draftValues[key]['Id'] = this.mapsobjsdb[key]['Id'];
						//this.draftValues[key].attributes = {"type" : key};
					}
				}				
				this.btnSaving = true;
				this.viewOnly = this.disableSaveBtn;
				
				console.log('tosave ', this.draftValues);
				this.dispatchEvent(new CustomEvent("savex", {
					detail: { "draftValues": this.draftValues, "actualStep": this.actualStep,  "currentStep": this.currentStep }
				}));
			} else {
				this.showSpinner = false;
			}
		}

	}

	showToast(title, msg, variant){		
		this.dispatchEvent(new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
		}));
	}

	toggleBgEditColor(apiname, sobjname, add) {		
		let div = this.template.querySelector(`lightning-layout-item[data-name="${apiname}"][data-sobj="${sobjname}"]`);
		if(div){	
			if (add) {
				div.classList.add('editBgColor');
			} else {

				div.classList.remove('editBgColor');
			}
		}

	}



	get disableSaveBtn() {
		console.log(' this.actualStep ',  this.actualStep , ' this.currentStep ', this.currentStep , ' Object.keys(this.configStepsOrder) ', Object.keys(this.configStepsOrder), ' this.currentForm ', this.currentForm);
		let disableBtn = true;

		//let btnFooter = this.template.querySelector('div[slot="footer"]')?.querySelector('div[data-name="customBtns"]');
		console.log('prueba ', Object.keys(this.configStepsOrder).indexOf(this.currentStep), ' ', this.currentStep);
		if(this.currentForm.length != 0){
			if(Object.keys(this.configStepsOrder).indexOf(this.currentStep) >= 0){
				this.showFooter = false;
			if (this.configStepsOrder) {
				let indexCurrentStep = this.configStepsOrder[this.currentStep];
				let indexActualStep = this.configStepsOrder[this.actualStep];
				this.mapErrors.bloq == true;
				if (indexCurrentStep > indexActualStep ) {
					disableBtn = true;
				} else {
					disableBtn = false;
				}
				if(this.mapErrors.bloq == true){
					if(this.checkErrosIcons()){
						console.log('existe error');
						if(this.labelBtnSave != 'Save'){
							if(this.mapErrors.lststeps.length == 0) {						
								disableBtn = true;
							}else{
								if(this.mapErrors.lststeps.includes(this.currentStep)){
									disableBtn = true;
								}
							}		
						}	
					}		
				}
			}else{
				disableBtn = false;
			}
			}else{
				disableBtn = true;
				this.showFooter = true;
			}


			if(this.btnSaving){
				disableBtn = true;
			}


		}
		/*if(btnFooter){			
			if(disableBtn)btnFooter.classList.add('disableFooter');
			else btnFooter.classList.remove('disableFooter');
		}*/

		return disableBtn;
	}


	checkErrosIcons(){
		for(let i = 0; i < this.mapErrors.lstmsgErrors.length; i++){
			console.log('lista ',this.mapErrors.lstmsgErrors[i] , ' index ' ,  this.mapErrors.lstmsgErrors[i].icon.indexOf('error'));
			if(this.mapErrors.lstmsgErrors[i].icon.indexOf('error') >= 0 /* meter otra condición step */)return true;
		}
		return false;
	}

	getWSParams(sobj, api, value) {

		
		let auxAllFieldsWithParams = this.currentForm.filter(el => el.params);
		//console.log('getWSParams ', auxAllFieldsWithParams);
		for (let i = 0; i < auxAllFieldsWithParams.length; i++) {			

			let finfo = auxAllFieldsWithParams[i];			
			if (finfo.params[sobj+"."+api]) {

				let sobjapiname = finfo.sobj+'.'+finfo.apiName;				
				if (!this.paramsWSConfig[sobjapiname]) {

					this.paramsWSConfig[sobjapiname] = {};
				}


				this.paramsWSConfig[sobjapiname][finfo.params[sobj+"."+api]] = value;
				
				if (Object.keys(this.paramsWSConfig[sobjapiname]).length == Object.keys(finfo.params).length) {

					//console.log('this.paramsWSConfig ', this.paramsWSConfig[sobjapiname]);

					let pathformfieldel = this.template.querySelector(`c-pathformfield[data-name="${finfo.apiName}"][data-sobj="${finfo.sobj}"]`);					
					if (pathformfieldel){
						//pathformfieldel.clearInput();
						pathformfieldel.callWS(finfo.endpoint, this.paramsWSConfig[sobjapiname]);
					}

				}
			}
		}

	}

}