import { LightningElement,api } from 'lwc';
import getFieldInfoService from '@salesforce/apex/FieldCallServices.fillField';
import { NavigationMixin } from 'lightning/navigation';


export default class Pathformfield extends NavigationMixin(LightningElement) {

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
	isRichText = false;
	isCurrency = false;
    isNumber = false;
    readOnly = true;
	isHidden = false;
	isStandard = false;
	isRequired = false;
	isEditable = false;
	isReadMode = false;
	isLinkSobj = false;

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
		
		this.readOnly = this.field.readOnly;
		if(this.field.linksobj)this.isLinkSobj = this.field.linksobj;

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
			case 'richtext':
				this.isRichText = true;
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
			case 'currency':
				this.isCurrency = true;
			break;
			default:
				this.isText = true;
			break;
		}
		if(this.field.readMode){
			this.isReadMode = this.field.readMode;
		}else if(this.isRichText && this.readOnly ){
			this.isReadMode = true;
		}
		
		this.notifyHideLayoutItem(this.field.apiName,this.field.sobj, this.isHidden);

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
		//console.log('value ', value , ' isChecked ', isChecked)
		let lstEvts = [];
		let lstValues = [];

		let calcValue = this.field.fieldType != 'boolean' ? value : (isChecked ? isChecked : value);
		//console.log(calcValue);

		if(this.field.labelField){
			lstValues.push({'api' : this.field.labelField, 'value' :  this.getPicklistObj(calcValue)});
		}
		lstValues.push({'api' : this.field.apiName, 'value' : calcValue});
		//console.log('lstValues ',lstValues);

/*
        if((this.field.fieldType != 'boolean' && value != this.oldValue) || 
            (this.field.fieldType == 'boolean' && isChecked != this.oldValue) ){
*/
		if(calcValue != this.oldValue){
			lstValues.push({'api' : this.field.apiName, 'value' : calcValue});

			if(Array.isArray(lstValues)){
				for(let i = 0 ; i < lstValues.length ; i++){

					lstEvts.push({
						'action' : 'add',
						'api' : lstValues[i]['api'],
						'value' : lstValues[i]['value'],
						'index' : this.index,
						'sobj' : this.field.sobj,
						'sobjinfo' : this.field.sobjInfo
					})
				}
			}

        }else{
			//console.log('reset ws');
			if(this.field.endpoint)this.callWS(this.field.endpoint, '');

			for(let i = 0 ; i < lstValues.length ; i++){

				lstEvts.push({
					'action' : 'remove',
					'key' : lstValues[i]['api'],
					'index' : this.index,
					'sobj' : this.field.sobj,
					'value' : this.oldValue,
					'sobjinfo' : this.field.sobjInfo
				})
			}
        }
        
       // let div = this.template.querySelector(`lightning-input[name="${this.field.apiName}"]`);
        //div.classList.add('slds-hide');
        
		//this.fieldinfo = auxClone;//Object.assign({}, auxClone);

		if(lstEvts.length>0){
			//console.log('lstEvts to send', lstEvts);
			for(let j = 0 ; j<lstEvts.length; j++){
				//console.log('Evt to send', lstEvts[j]);
				this.dispatchEvent(new CustomEvent("valuechanged", {
					detail: lstEvts[j]
				}));
			}
		}
    }

	get fieldsInReadMode(){
		if(this.isRichText && this.readOnly || this.isReadMode || !this.isEditable){
			return true;
		}else{
			return false;
		}
	}
	getPicklistObj(picklistval){
		let filteredOpt = this.field.attributes.options.find(opt => opt.value === picklistval);
		if(filteredOpt)
			return filteredOpt.label
		else return null;
	}
    @api
    checkValidInputs(){
        
        let input = this.template.querySelector('[data-fieldtype="editablefields"]');
        let validity = true;

        if(input){
            //console.log(`VALIIIIIDO AAA ${input.reportValidity()} ${input.value} ${input.required}`);
			input.disabled = false;
			validity = input.reportValidity();
			input.disabled = this.readOnly;
        }

		return validity;
    }
    @api
    editMode(){
		let inpufield = this.template.querySelector('lightning-input-field');		
		if(inpufield)inpufield.reset();
		if(!this.isEditable) this.isEditable = true;
    }

	@api
    readMode(){		
		//let inpufield = this.template.querySelectorAll(`c-pathformfield[sobj="${this.field.sobj}"]`);		
		//if(inpufield)inpufield.reset();		
		if(this.isEditable) this.isEditable = false;
    }

	@api
	show(){
		//this.initFieldSetup();
		if(this.isHidden){
			this.isHidden = false;
			this.notifyHideLayoutItem(this.field.apiName, this.field.sobj, false);
		}
	}
	@api
	hide(){
		//this.initFieldSetup();
		if(!this.isHidden){
			this.isHidden = true;
			this.notifyHideLayoutItem(this.field.apiName, this.field.sobj,true);
		}
		
	}

	@api
	defaultValues(){
		this.field.value = this.oldValue;
	}

	notifyHideLayoutItem(apiname,sobjx, action){

		this.dispatchEvent(new CustomEvent("togglelayoutitem", {
            detail: {hide : action, apiName : apiname, sobj : sobjx}
        }));
	}
	changeToEdit(evt){
		//this.isEditable = false;		
		if(!this.viewOnly && !this.isReadMode){
			this.dispatchEvent(new CustomEvent("changeedit", {
				//detail: true,
				detail: {action : true, fieldSobj : this.field.sobj}
			}));
		}else{
			if(this.isLinkSobj)this.navigateToRecord(this.field.sobjInfo.sobjId);
		}
	}

	@api callWS(endpoint, paramsattr){
        
		getFieldInfoService({mdtEndpoint: endpoint, params: JSON.stringify(paramsattr)})
		.then(result =>{
			if(result){
				let input = this.template.querySelector('[data-fieldtype="editablefields"]');

				this.field.attributes.options = this.transformEndpointContent(result, this.field.keys);
				this.valorPicklist = this.buscarFieldValue(this.field.attributes.options);

				//console.log('this.field.attributes.options ', this.field.attributes.options);
				if(input){
					//console.log("changing options input");
					input.options = this.field.attributes.options;
					
					if(!this.valorPicklist){
						this.field.value='';
						input.value='';
						this.valueChangedAction('', null);
					}

				}

				//let auxOptions = JSON.parse(JSON.stringify(this.field.attributes.options));
				//this.valorPicklist = auxOptions.filter(this.buscarCampoPicklist);

		
                //this.opciones = this.field.attributes.options;
			}
		})
		.catch(error =>{
			console.log('error', error);		
		})

	}

	transformEndpointContent(jsonbody, keysattr){
		
		let keys = jsonbody.map(item => item[keysattr[0]])
		let values = jsonbody.map(item => item[keysattr[1]])

		let result =  values.reduce(function(result, field, index) {
		  result.push({"label":keys[index], "value" : field+''});
		  return result;
		}, []);

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
        //if(evt.currentTarget.reportValidity()){
            this.valueChangedAction(evt.currentTarget.value, evt.currentTarget.checked);
        //}
    }

	navigateToRecord(objId) {
        // Navigate to the Account home page
		console.log('navigate to view ' + objId);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objId,
                actionName: 'view',
            },
        }).then((url) => {
			console.log('url ' + url);
			window.open(url)
        });
		
    }
}