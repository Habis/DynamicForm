## Introduction

Step by step implementation guide of Dynamic form component, I will show you how to setup the components and how the metadatas and their configurable JSON work.

## Setup form by steps

In the folder demo, you will have an example wich you can easily modify for your needs.

Forms based on a picklist/path, easy setup with JSON:
- Setup sections and fields with standard or custom labels
- You can print in the form fields from every object
- Create/Update objects
- Change the size of fields/sections from 1 to 12
- Integrated fields, where the values come from a web service in real time
- Visibility rules, you can hide or show fields based on your criteria
- Custom alert messages that are displayed (error, warning or info) based on certain criteria, and that can block the step/form
- View only form, based on certain critera

Look and feel example:
![[Pasted image 20220701124211.png]]

you need to implement flowformlwc in your custom lwc:
```
<template>

    <c-flowformlwc step={step} steps-field={stepsField} record-id={recordId} onsave={handleSave} oncancel={handleCancel}>

        <div slot="body">

            _<!--additionals componentes for the body-->_

        </div>

        <div slot="footer">

            _<!--additional componentes for the footer-->_

            <c-ob-webservice-buttons oncancel={handleCancelButtons} step={step} steps-field={stepsField} record-id={recordId}></c-ob-webservice-buttons>

        </div>

    </c-flowformlwc>

</template>
```

flowformlwc attributes needed

- `step` => actual value of the path or the picklist, so the component knows wich form to show
- `stepsField` => Api name of the picklist
- `recordId` => Id of the current record

	### Form metadatas
	
	to setup the forms you need to fill `DynamicPathConfig` and `FormConfig` mdts.
	Fields and their uses:
	
	#### DynamicPathConfig
	
	| ApiName | FieldType | Description |
	| ------ | ------ | ------ |
	| DeveloperName | Text | Name of the flow |
	| JSONBlockingConditions__c | Long Text Area | JSON configuration to tell components alerts and/or conditions to block form and buttons |
	| JSON_ViewOnlyConfig__c | Long Text Area | JSON configuration set conditions to put forms in view only mode |
	| SObjectType__c | Text | SObject of the recordPage |
	| RecordType__c | Text | SObject recordType |
	
	#### FormConfig
		
	| ApiName | FieldType | Description |
	| ------ | ------ | ------ |
	| DeveloperName | Text | Name of the step where the form will be located |
	| JSONFieldConfig__c | Text | JSON configuration that includes all the field information to render the form |
	| DynamicPathConfig__c | Lookup | Lookup to DynamicPathConfig |


### Aura components

Since it is not possible to send events between two separate LWC in the same page, we need aura. (if a path is needed, or another component that notifys the changes)

- `recordPath` => uses `lightning:path` to render the default path for that record.
	- register pathEvent and it is fired anytime the path changes, or is clicked by the user
	- handle pathEventReset, that is fired by childs components to refresh the path and the view
```
<aura:component implements="flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId" access="global">

    <aura:registerEvent name="pathevt" type="c:pathEvent"/>

    <aura:handler event="c:pathEventReset" action="{!c.handleResetPath}" />

    <lightning:path
        aura:id="path"
        recordId="{!v.recordId}"
        hideUpdateButton="true"
        onselect="{!c.handleSelectStep}"
        />

</aura:component>
```

- `containerPathListener` => aura component to listen to the events fired by `recordPath`
	- register pathEventRest, to notify `recordPath` that needs to refresh the view
	- handle pathEvent, to listen changes on the path
```
<aura:component implements="flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId" access="global">

    <aura:handler event="c:pathEvent" action="{!c.handlePathChange}" />

    <aura:registerEvent name="pathevtrst" type="c:pathEventReset"/>

  

    <aura:attribute name="step" type="String"/>

    <aura:attribute name="stepsField" type="String"/>

  

    <c:formBasedOnPath step="{!v.step}" stepsField="{!v.stepsField}" recordId="{!v.recordId}" oncancel="{!c.cancelPath}"/>

</aura:component>
```

## Apex classes

For the form to work, we need to write some apex code `formBasedOnPath` class, methods:
- `public static Map<String, SObject> getMapParamsForm(String process, Id recordId)`
	- process => it is the RecordType.DeveloperName of the SObject
	- recordId => Id of the main object
	implement a swich case in this method, so based on the process we query the objects needed.
	
	```
	switch on process {
	
	            when  'Test'{
	
	                map_params = new Map<String, SObject>{
	
	                    'Opportunity' => [SELECT Id, AccountId, StageName FROM Opportunity WHERE Id =: recordId],
	
	                    'firstHolder' => [SELECT Id, FirstName, PersonEmail,Phone FROM Account LIMIT 1],
	
	                    'secondHolder' => [SELECT Id, FirstName, PersonEmail,Phone FROM Account LIMIT 1]
	
	                };
	
	            }
	```

	as we can see in the example, we need to instantiate a Map<String, SObject> and fill it with a key,which will be the one that we will reference in the JSONs.
- `public static string saveData(String jsonData, String pathField, Id recId)`
	- jsonData => is the data in json mode provided by the component
	- pathField => Api name of the field that the forms are based on
	- recId => id of the parent record
	this method saves all the form information and advance the step if there's no alerts

Class `flowFormController`, have two methods:
- `public static Map<String, Object> getInfo`, this method retrieve the configuration for the form based on the SObject type and RecordType
- `public static Map<String, Object> getSingleInfo`, this method retrieves a single form, given the form name, (DeveloperName of FormConfig)

Class `PathFormMdtUtil` is the core of the component, have methods to create the structure wich allow the component to display the form and all the alerts/hidden rules/etc
- `getConfigForm` returns the map whit the info needed, it reads from **DynamicFormConfig filtered by RecordType__c and SObjectType__c**

Class `FieldCallServices`, this class allows the component to make use of the REST framework implemented. Given a DeveloperName of a `WebServiceInfo` metadata name

## Metadata configuration
Once we have all the steps above, it is time to setup the metadatas that have all the information and criteria to render the forms.

### DynamicPathConfig
this metadata is the one that controlls the forms wich are displayed, based on the fields SObjectType and RecordType. Fill those fields with the Object api name, and the RecordType developerName to get started.

from the page layout, you can see **FormConfig** related records, that contains the form information, their fields and hidden rules.
![[Pasted image 20220708123508.png]]

- JSONBlockingConditions__c

	Añade reglas de validación en el formulario de OnBoarding, si se cumple la regla se muestra una alerta.
	``` 
	{  
	"msg" : "", "show" : "",  
	"condition" : "",  
	"icon" : "",  
	"bloq" : { "bloq" : , "steps" : []}  
	}
	```

	- Msg: Cadena de texto que contiene el mensaje que se muestra en la alerta.
	
	- Show: Contiene una lista de etapas del formulario, la alerta solo se mostrara cuando el formulario se encuentre en esa etapa o más adelante, si la lista esta vacía se mostrara la alerta en todas las etapas.
	
	- Condition: Cadena de texto que específica la condición de la regla de validación, se pueden utilizar los siguientes operadores(`&&, ||, ==, !=, (, ), >=, >, <=, <`), también están disponibles algunos métodos como: constants.getAge() este método recoge una fecha de nacimiento y devuelve la edad. Para poder referirse a campos del formulario hace falta utilizar este formato: objeto.campo.
	
	- Icon: Icono que se muestra en la alerta, los iconos pueden ser de distintos colores y tipos, los iconos disponibles son los siguientes: utility:warning, utility:error, utility:success y utility:info.
	
	- bloq
		- bloq: Boolean que determina si la regla de validación va a bloquear alguna etapa.
		- steps: Contiene una lista de etapas, las etapas seleccionadas se bloquearán si se cumple la condición de la regla de validación, si la lista esta vacía se bloquean todas las etapas.

- JSON_ViewOnlyConfig__c
	Cuando se cumple la condición.
	
	Cuando el icono es 'utility:error' se bloquea el formulario haciendo que el usuario no pueda ni editar ni guardar.
	
	Cuando el icono no es 'utility:error' se permite guardar al usuario pero el formulario no pasa de etapa.
	
##### Ejemplos
Bloqueo en todas las etapas si el primer usuario es menor de edad.
```
{  
"msg" : "Primer titular: menor de edad", "show" : "",  
"condition" : "constants.getAge($firstHolder.PersonBirthdate) < 18",  
"icon" : "utility:error",  
"bloq" : { "bloq" : true, "steps" : []}  
}
```

Bloqueo en la etapa 'Inspektor' si el primer titular no tiene objeto de inspektor asociado.
```
{  
"msg" : "El primer titular no tiene Inspektor asociado", "show" : "Inspektor",  
"condition" : "$Inspektor1Holder.Id== null",  
"icon" : "utility:error",  
"bloq" : { "bloq" : true, "steps" : "Inspektor"}  
}
```

### FormConfig
Contains the configuration in JSON format for every Stage/Step for a given SObject and RecordType, that's why this records are related to DynamicPathConfig.
I'll show you their JSONs and how to fill them properly.
![[Pasted image 20220708123732.png]]

In the page layout you can also see, their related records formsHiddeRules, those metadatas let you set how fields are displayed, and if there are some dependecies between fields.

for every field you can hidde or show other fields, that criteria must be informed in HiddeRule mdt, that we will see in the next section


- JSONFieldConfig__c 
	- example of basic json empty with their types
	``` 
	[{  
	"title": String,  
	"sobj": String,  
	"size": Integer,  
	"section": Boolean 
	},  
	{  
	"label": String,  
	"sobj": String,  
	"apiName": String,  
	"required": Boolean,  
	"readOnly": Boolean,  
	"hidden": Boolean,  
	"standard": Boolean
	"size" : Integer
	}
	]
	```
	JSON attributes description to setup the fields
	- ``label``: Custom label for the field, if not informed takes it from schema
	- ``sobj``: Custom name given in formBasedOnPath class for that SObject
	- ``apiName``: Field api name
	- ``required``: Default false, indicates if the field is required, the code will search for empty required fields and display error if they're empty
	- ``readOnly``: Default false, specifies readOnly fields
	- ``hidden``:  Default false, when set to true hidde the field
	- ``standard``: Default false, if set to true the field takes the label and format from Apex schema
	- ``fieldType``:  Indicates fieldType, default is String, we'll see in next section the field types supported
	-  ``size``:  size of the field from 1 to 12 where 12 is 100% width of the form
	
	- section example:
	```
	{  
	"title": "Primer titular: $[firstHolder.Name]",  
	"sobj": "firstHolder",  
	"size": 12,  
	"section": true  
	}
	```

	JSON attributes description for sections:
	- ``title``: Section title
	- ``sobj``:  Custom name given in formBasedOnPath class for that SObject
	- ``size``: Integer that indicates size of the section from 1 to 12
	- ``section``: Boolean que específica si es una sección o no

#### Supported field types

###### Text
Text are the default fieldType, label it is not required if standard is set to true, Apex can bring the label from schema
```
{  
"label": "Nombre",  
"sobj": "firstHolder",  
"apiName": "LastName",  
"required": true,  
"readOnly": false,  
"hidden": false,  
"standard": true  
}
```

###### Integrated picklist

this picklist get values from the endpoint given in `endpoint`, makes uses of `FieldCallServices` class.

```
{  
"label":"Cargo Actual",  
"apiName":"Role__c",  
"labelField":"RoleText__c",  
"sobj" : "firstHolder",  
"required":true,  
"readOnly":false,  
"hidden":false,  
"fieldType": "picklist",  
"standard":false,  
"endpoint" : "OB_GetRoleList",  
"keys" : ["name", "id"]  
},  
{  
"label":"Situacion Laboral",  
"labelField":"FinServ__Occupation__pc",  
"apiName":"Occupation__c",  
"sobj" : "firstHolder",  
"required":true,  
"readOnly":false,  
"hidden":false,  
"endpoint":"OB_GetOccupationsList",  
"keys" : ["name", "id"],  
"fieldType": "picklist",  
"standard":false  
}
```

- Picklist from WebService , `labelField` => stores the text and `apiName` => stores the code
- fieldType: picklist
- endpoint: Metadata DeveloperName where the endpoint information is stored
- keys: This fields has the keys from wich the values are going to be extracted, in first position from where you want the JavaScript to extract the picklist label, and in second position from where you want to extract the code/api, then the information is transformed into a combobox structure.
- params: map with the params if the web service need some information of another picklist, example : 'key' : 'field1'

###### Checks
```
{  
"sobj": "firstHolder",  
"apiName": "CheckFinancialCreditInformation__c",  
"fieldType":"boolean",  
"required": false,  
"readOnly": false,  
"hidden": false,  
"standard": true  
}
```

- fieldType: boolean


###### Currency
```
{  
"apiName":"Assets__c",  
"sobj" : "firstHolder",  
"required":false,  
"fieldType":"currency",  
"readOnly":true,  
"hidden":false,  
"standard":true  
}
```
- fieldType: currency

###### Link to SObject
```
{  
"sobj": "firstHolder",  
"apiName": "Name",  
"readMode":true,  
"required": true,  
"readOnly": false,  
"linksobj" : true,  
"size":4,  
"hidden": false,  
"standard": true  
}
```
- linksobj: Default false, set to true if you want the field to navigate to the SObject, specified in sobj

###### Ejemplos

### FormHiddeRules
Contains the information in JSON format, to make visible or invisible some fields, based on the criteria you want.

- Example JSON
	```
	{  
	"": [{  
	"show": String,  
	"value": String 
	}, {  
	[controlling field] : [""],  
	"value": ""  
	}]
	}
	```
	
	La estructura del JSON es la siguiente:
	```
	"Campo de control":[{
		"show": ""
		"value": ""
	}]
	```
	
	- Controlling field: condition is based in this field, based on the values of this field, you could show one or multiple fields
	- show: List of fields to be displayed, based on value criteria
	- value: Criteria to display or hidde fields