import { api, LightningElement } from 'lwc';

export default class MsgAlert extends LightningElement {
    
	@api body;
    @api icon;
	mapErrors_ = {};
	lstmsgErrors;
	lstAllErrors = [];
	lstmsgErrors
	icon;

	classTxt = "alert slds-p-vertical_medium";

	@api
	get mapErrors(){
		return this.mapErrors;
	}
	set mapErrors(value){

		let valueAux = JSON.parse(JSON.stringify(value));
		console.log(valueAux);
		if(valueAux){
			this.initMsgs(valueAux);
		}
	}
	@api
	refreshError(mapError){
		this.initMsgs(JSON.parse(JSON.stringify(mapError)));
	}
	initMsgs(mapError){
		this.mapErrors_ = mapError;
		this.lstmsgErrors = mapError.lstmsgErrors;
		this.lstmsgErrors.sort(function (a, b) {
			if (a.icon > b.icon) {
			  return 1;
			}
			if (a.icon < b.icon) {
			  return -1;
			}
			// a must be equal to b
			return 0;
		  });
		  console.log('lstmsgErrors', this.lstmsgErrors);
		  let errorAux = {};
		this.lstmsgErrors.forEach(el => {
				if(el.icon.includes('success')){
					el.classTxt = this.classTxt + ' alert--success';
				}else if(el.icon.includes('warning')){
					el.classTxt = this.classTxt + ' alert--warning';
				}else if(el.icon.includes('error')){
					el.classTxt = this.classTxt + ' alert--danger';
				}else{
					el.classTxt = this.classTxt + ' alert--info';
				}
				if(!errorAux[el.icon])errorAux[el.icon] = {};
				errorAux[el.icon].icon = el.icon;
				console.log('errorAux ', errorAux);
				errorAux[el.icon].classTxt = el.classTxt;
				if(!errorAux[el.icon].lstMsg)errorAux[el.icon].lstMsg = [];
				console.log('prueba ', el.icon, ' ' , errorAux[el.icon] , ' ', errorAux[el.icon].lstMsg.length);
				if(errorAux[el.icon].lstMsg.length >= 1){
					errorAux[el.icon].twoOrMore = true;
				}else{
					errorAux[el.icon].twoOrMore = false;
				}
				errorAux[el.icon].lstMsg.push(el.msg);
		});

		Object.entries(errorAux).forEach(([key, value]) => {
			value.class = 'alertmsg slds-m-vertical_small slds-p-bottom_x-small';
			this.lstAllErrors.push(value);
			
		});
		console.log('this.lstAllErrors.l ', this.lstAllErrors.length - 1);
		this.lstAllErrors[this.lstAllErrors.length - 1].class = 'alertmsg slds-m-vertical_small';
		console.log('this.lstAllErrors ', this.lstAllErrors);
		console.log('this.lstmsgErrors', this.lstmsgErrors);


	}
}