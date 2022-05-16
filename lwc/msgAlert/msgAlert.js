import { api, LightningElement } from 'lwc';

export default class MsgAlert extends LightningElement {
    
	@api body;
    @api icon;
	mapErrors_ = {};
	lstmsgErrors;
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
		});

		console.log('this.lstmsgErrors', this.lstmsgErrors);


	}
}