import { LightningElement,api } from 'lwc';
import getFieldInfoService from '@salesforce/apex/FieldCallServices.fillField';

export default class Pathformfield extends LightningElement {

    //@api fieldinfo;
	field;
    valorPicklist;
	auxval;
    @api index;
    @api checkcol;
    @api rid;
    @api apiField;
	@api viewOnly;
    opciones = [];
    isUrl = false;
    isPhone = false;
    isEmail = false;
    isPicklist = false;
    isBoolean = false;
    isText = false;
    isNumber = false;
    readOnly = true;
	isHidden = false;
	isStandard = false;
	isRequired = false;

    oldValue;
	@api reload;
    
	@api
    set finfo(newFieldInfo){
        
        this.field = Object.assign({}, newFieldInfo);
        this.initFieldSetup();
    }
    get finfo(){
        return this.field;
    }
	
    initFieldSetup(){
		
		this.readOnly = !this.field.editable;
		
		this.isHidden = this.field.hidden;
		
		this.oldValue = this.field.value;
		this.isStandard = this.field.sobjInfo ? this.field.standard : false;
		this.isRequired = this.field.required;
		
		if(this.field.endpoint){
			
			if(!this.field.attributes)this.field.attributes = {};
			this.callWS(this.field.endpoint, '');
			//this.field.attributes.placeholder = '1234';
			
		}else if(this.field.fieldType == 'picklist'){
			this.valorPicklist = this.buscarFieldValue(this.field.attributes.options);
		}
		
		
		if(this.reload){

		}else{
			
			this.reload = false;
		}
		
		switch (this.field.fieldType) {
			case 'text':
				this.isText = true;
			break;
			case 'boolean':
				this.isBoolean = true;
			break;
			case 'url':
				this.isUrl = true;
			break;
			case 'phone':
				this.isPhone = true;
			break;
			case 'email':
				this.isEmail = true;
			break;
			case 'picklist':
				this.isPicklist = true;
			break;
			case 'number':
				this.isNumber = true;
			break;
			default:
				this.isText = true;
			break;
		}
		
		this.notifyHideLayoutItem(this.field.apiName, this.isHidden);

    }

    initSection(){
        this.isSection = true;
    }

    valueChanged(evt){

        //if(evt.currentTarget.checkValidity() || evt.currentTarget.value == ''){
            this.valueChangedAction(evt.currentTarget.value, evt.currentTarget.checked);
        //}
    }

    valueChangedAction(value, isChecked){
        console.log('valueChangedAction');
		var evtObj = {};
        
		let auxClone = this.field;
        auxClone.value = this.field.type != 'boolean' ? value : isChecked;
        console.log('this.field.type ', this.field , ' auxClone ', auxClone);
        console.log('value ', value, ' this.oldValue ', this.oldValue);
        if((this.field.fieldType != 'boolean' && value != this.oldValue) || 
            (this.field.fieldType == 'boolean' && isChecked != this.oldValue) ){
            let calcValue = this.field.fieldType != 'boolean' ? value : isChecked;
			
            evtObj = {
                'action' : 'add',
                'api' : this.field.apiName,
                'value' : calcValue,
                'index' : this.index,
				'sobj' : this.field.sobj,
                'sobjinfo' : this.field.sobjInfo
   
            }
        }else{
            console.log('key ', this.field.apiName, ' index ', this.index , 'sobj ', this.field.sobj, ' sobjinfo ', JSON.parse(JSON.stringify(this.field.sobjInfo)));
            evtObj = {
                'action' : 'remove',
                'key' : this.field.apiName,
                'index' : this.index,
				'sobj' : this.field.sobj,
                'sobjinfo' : this.field.sobjInfo

            }
        }
        
       // let div = this.template.querySelector(`lightning-input[name="${this.field.apiName}"]`);
        //div.classList.add('slds-hide');
        
		//this.fieldinfo = auxClone;//Object.assign({}, auxClone);

        this.dispatchEvent(new CustomEvent("valuechanged", {
            detail: evtObj
        }));
    }

    @api
    checkValidInputs(){
        
        let input = this.template.querySelector('[data-fieldtype="editablefields"]');
        
        if(input){
            
            return input.reportValidity();
        }else{
            return true;
        }
    }
    @api
    editMode(){
		let inpufield = this.template.querySelector('lightning-input-field');
		console.log(inpufield);
		if(inpufield)inpufield.reset();
		if(this.readOnly) this.readOnly = false;
    }

	@api
	show(){
		//this.initFieldSetup();
		if(this.isHidden){
			this.isHidden = false;
			this.notifyHideLayoutItem(this.field.apiName, false);
		}
	}
	@api
	hide(){
		//this.initFieldSetup();
		if(!this.isHidden){
			this.isHidden = true;
			this.notifyHideLayoutItem(this.field.apiName,true);
		}
		
	}

	notifyHideLayoutItem(apiname, action){

		this.dispatchEvent(new CustomEvent("togglelayoutitem", {
            detail: {hide : action, apiName : apiname}
        }));
	}
	changeToEdit(evt){
		//this.readOnly = false;
		if(!this.viewOnly){
			this.dispatchEvent(new CustomEvent("changeedit", {
				detail: true
			}));
		}
	}

	@api callWS(endpoint, paramsattr){
        
		getFieldInfoService({mdtEndpoint: endpoint, params: paramsattr})
		.then(result =>{
			if(result){
				
				this.field.attributes.options = this.transformEndpointContent(result, this.field.keys);
				
				//let auxOptions = JSON.parse(JSON.stringify(this.field.attributes.options));
				//this.valorPicklist = auxOptions.filter(this.buscarCampoPicklist);
                this.valorPicklist = this.buscarFieldValue(this.field.attributes.options);
		
                //this.opciones = this.field.attributes.options;
			}
		})
		.catch(error =>{
			console.log("error", error)
		})

	}

	transformEndpointContent(jsonbody, keysattr){
		
		let keys = jsonbody.map(item => item[keysattr[0]])
		let values = jsonbody.map(item => item[keysattr[1]])

		let result =  values.reduce(function(result, field, index) {
		  result.push({"label":keys[index], "value" : field});
		  return result;
		}, [])
		
		return result;
	}

    buscarFieldValue(arrayOpciones){

        for(let i = 0; i < arrayOpciones.length; i++){
            
            if(arrayOpciones[i].value == this.field.value){
                
                return arrayOpciones[i].label;
            }
        }
    }

    onChangeField(evt){
        console.log('xfavor funciona');
        //if(evt.currentTarget.reportValidity()){
            this.valueChangedAction(evt.currentTarget.value, evt.currentTarget.checked);
        //}
    }
}