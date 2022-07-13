/**
 * @description       : 
 * @author            : Antonio Pardo Corral
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Rafael Vargas Pinilla
**/
public without sharing class PathFormMdtUtil {
    
	private String recordId;
	private String stepField;
	private String rtName;
	private String formName;
	private String sobjType;
	private Map<String, Set<String>> map_sobj_availabeflds;

	public PathFormMdtUtil(String recordId, String stepField, String rtName, String sobjType){
		this.recordId = recordId;
		this.stepField = stepField;
		this.rtName = rtName;
		this.sobjType = sobjType;
		this.map_sobj_availabeflds = new Map<String, Set<String>>();
	}

	public PathFormMdtUtil(String recordId, String formName, String sobjType){
		this.recordId = recordId;
		this.formName = formName;
		this.sobjType = sobjType;
		this.map_sobj_availabeflds = new Map<String, Set<String>>();
	}
	
	public Map<String, Object> getConfigForm(){
		system.debug('>>>>>>>>>>>>>>>> getConfigForm1');
		Map<String, Object> map_ret = new Map<String, Object>();
		Map<String, List<Object>> map_form = new Map<String, List<Object>>();
		Map<String, Set<String>> map_obj_flds = new Map<String, Set<String>>();
		Map<String, String> map_rel_sobj = new Map<String, String>();
		Map<String, Object> map_hiddenrules = new Map<String, Object>();
		Set<String> setFormConfigId = new Set<String>();
		Map<String, SObject> map_sobjects;
		List<Object> lstConditionsBloq;
		List<Object> lstConditionsViewOnly;

		if(String.isNotBlank(this.formName)){

			map_sobjects = formBasedOnPath.getMapParamsSingleForm(this.formName, this.recordId);
			Set<String> setKeyObjects = map_sobjects.keySet();
			List<FormConfig__mdt> lstSingleForm = [SELECT Id, JSONFieldConfig__c,Label FROM FormConfig__mdt WHERE DeveloperName =: this.formName];

				system.debug('>>>>>>> for getConfigSingleForm '+ lstSingleForm[0]);
				List<Object> lstSobjAux = (List<Object>)JSON.deserializeUntyped(lstSingleForm[0].JSONFieldConfig__c);
				filterForm(setKeyObjects, lstSobjAux);
				getQueryMapConfig(lstSobjAux,map_obj_flds);
				map_form.put(lstSingleForm[0].Label, lstSobjAux);
				setFormConfigId.add(lstSingleForm[0].Id);

				map_ret.put('step',lstSingleForm[0].Label);
		}else{
			map_sobjects = formBasedOnPath.getMapParamsForm(this.rtName, this.recordId);
			if(map_sobjects != null){
				Set<String> setKeyObjects = map_sobjects.keySet();
				System.debug('setKeyObjects ' + setKeyObjects);
				for(DynamicPathConfig__mdt configs : [SELECT DeveloperName, JSONBlockingConditions__c,JSON_ViewOnlyConfig__c,  (SELECT Id, JSONFieldConfig__c,Label FROM FormConfigs__r) FROM DynamicPathConfig__mdt WHERE RecordType__c = :this.rtName AND SObjectType__c = :this.sobjType LIMIT 1]){
					if(configs.JSONBlockingConditions__c != null){
						lstConditionsBloq = (List<Object>)JSON.deserializeUntyped(configs.JSONBlockingConditions__c);
						filterConditions(setKeyObjects, lstConditionsBloq);

					}
					if(configs.JSON_ViewOnlyConfig__c != null){
						lstConditionsViewOnly = (List<Object>)JSON.deserializeUntyped(configs.JSON_ViewOnlyConfig__c);
						filterConditions(setKeyObjects, lstConditionsViewOnly);
					}

					for(FormConfig__mdt formconfig : configs.FormConfigs__r){
						system.debug('>>>>>>> for getConfigForm '+ formconfig);
						List<Object> lstSobjAux = (List<Object>)JSON.deserializeUntyped(formconfig.JSONFieldConfig__c);
						filterForm(setKeyObjects, lstSobjAux);
						getQueryMapConfig(lstSobjAux,map_obj_flds);
						map_form.put(formconfig.Label, lstSobjAux);
						setFormConfigId.add(formconfig.Id);
					}
				}

				map_ret.put('step', (String)map_sobjects.get(sobjType).get(this.stepField));
				map_ret.put('stepOrder', getPathSteps(this.stepField, this.sobjType));
			}
		}

		for(HiddeRules__mdt hiddentRules : [SELECT Id, FormConfig__r.Label, JSONHiddeRule__c from HiddeRules__mdt WHERE FormConfig__c IN :setFormConfigId]){
			map_hiddenrules.put(hiddentRules.FormConfig__r.Label, JSON.deserializeUntyped(hiddentRules.JSONHiddeRule__c));
		}
		
		//map_sobjects = rtNameQueryMap(this.recordId, this.sobjType, map_obj_flds, map_rel_sobj);
		
		System.debug('map_sobjects ' + map_sobjects);
		if(map_sobjects!=null && !map_sobjects.isEmpty())fuseSobjInfoIntoConfig(map_sobjects, map_form, map_rel_sobj);
		map_ret.put('form', map_form);
		map_ret.put('map_sobjects', map_sobjects);
		if(lstConditionsBloq != null)map_ret.put('lstConditionsBloq', lstConditionsBloq);
		if(lstConditionsViewOnly != null)map_ret.put('lstConditionsViewOnly', lstConditionsViewOnly);
		map_ret.put('mainSobjType', sobjType);
		map_ret.put('hiddenRules', map_hiddenrules);
		return map_ret;

	}

	private void filterForm(Set<String> setKeyObjects, List<Object> lstSobjAux){
		Map<String, Object> map_finfo = new Map<String,Object>();

		for (Integer i = (lstSobjAux.size()-1) ; i>= 0 ; i--){
			
			map_finfo = (Map<String, Object>)lstSobjAux[i];
			System.debug(' sobjjjjjjjj' +  map_finfo.get('sobj'));
			if(!setKeyObjects.contains((String)map_finfo.get('sobj'))){
				System.debug('delete field ' + map_finfo.get('apiName'));
				lstSobjAux.remove(i);
			}

		} 

	}

	private void filterConditions(Set<String> setKeyObjects, List<Object> lstSobjAux){
		Map<String, Object> map_finfo = new Map<String,Object>();
		String cond =  '';
		Boolean delElement = true;
		for (Integer i = (lstSobjAux.size()-1) ; i>= 0 ; i--){
			delElement = true;
			map_finfo = (Map<String, Object>)lstSobjAux[i];
			System.debug(' sobjjjjjjjj' +  map_finfo.get('condition'));
			for(String sobjName : setKeyObjects){
				cond = (String)map_finfo.get('condition');
				if(cond.contains(sobjName)){
					System.debug('cond contains ' + sobjName + ' cond ' + cond);
					delElement = false;
					break;
				}
			}
			
			if(delElement){
				System.debug('delete condition ' + map_finfo.get('condition'));
				lstSobjAux.remove(i);
				delElement = false;
			}

		}


	}

	public static Object getConfigForm(String rtName){
		system.debug('>>>>>>>>>>>>>>>> getConfigForm');
		Map<String, List<Object>> map_form = new Map<String, List<Object>>();
		for(FormConfig__mdt configs : [SELECT JSONFieldConfig__c,DeveloperName FROM FormConfig__mdt WHERE DeveloperName= :rtName LIMIT 1]){
			map_form.put(configs.DeveloperName, (List<Object>)JSON.deserializeUntyped(configs.JSONFieldConfig__c));
		}	

		return map_form;

	}

	private void getQueryMapConfig(List<Object> fieldConfig, Map<String, Set<String>> map_obj_flds){
		system.debug('>>>>>>>>>>>>>>>> getQueryMapConfig');
		for(Object objfield :fieldConfig ){

			Map<String, Object> map_fieldInfo = (Map<String, Object>)objfield;
			System.debug(map_fieldInfo);
			Boolean isStandard = map_fieldInfo.containsKey('standard') ? (Boolean)map_fieldInfo.get('standard') : false;
			System.debug(isStandard);
			if(isStandard && map_fieldInfo.containsKey('sobj')){
				System.debug('Añado map query ' + map_fieldInfo.get('sobj') + map_fieldInfo.get('apiName'));
				if(map_obj_flds.containsKey((String)map_fieldInfo.get('sobj'))){
					if(String.isNotBlank((String)map_fieldInfo.get('apiName')))map_obj_flds.get((String)map_fieldInfo.get('sobj')).add((String)map_fieldInfo.get('apiName'));
				}else{
					map_obj_flds.put((String)map_fieldInfo.get('sobj'), String.isNotBlank((String)map_fieldInfo.get('apiName')) ? new Set<String>{(String)map_fieldInfo.get('apiName')} :  new Set<String>());
				}
			}
		}
		
	}
	/*public Map<String, List<SObject>> rtNameQueryMap(String recordId, String mainObj, Map<String, Set<String>> map_obj_flds, Map<String, String> map_rel_sobj){
		system.debug('>>>>>>>>>>>>>>>> rtNameQueryMap '+ mainObj);
		//getting schema mainObj field
		Map<String, List<SObject>> map_sobj_query = new Map<String, List<Sobject>>();
		//if(map_obj_flds.containsKey(mainObj)){
			system.debug('>>>>>>>>>>>>>>>> rtNameQueryMap '+ mainObj);

			map_rel_sobj.put(mainObj, mainObj);
			Map<String,Schema.SObjectField> map_schemafields = Schema.getGlobalDescribe().get(mainObj).getDescribe().fields.getMap();
			
			Set<String> setRelationShips = map_obj_flds.keySet().clone();
			setRelationShips = delUnexpectedTokens(setRelationShips);
			System.debug(setRelationShips); 
			setRelationShips.remove(mainObj);setRelationShips.remove(null);
			System.debug(setRelationShips);
			Set<String> setAuxFields = new Set<String>(setRelationShips);if(map_obj_flds.containsKey(mainObj))setAuxFields.addAll(map_obj_flds.get(mainObj));
			if(!setAuxFields.contains(this.stepField))setAuxFields.add(stepField);
			System.debug('setAuxFields ' + setAuxFields);

			String soqlMainObj = 'SELECT ' + joinIdSetByComma(setAuxFields) + ' FROM ' + mainObj + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
			System.debug(soqlMainObj);
			SObject mainObjQuery = Database.query(soqlMainObj);
			map_sobj_query.put(mainObj, new List<SObject>{mainObjQuery});
			map_sobj_availabeflds.put(mainObj, getSetAvailableFlds(mainObjQuery));
			System.debug(map_sobj_availabeflds);
			for(String relObjName : map_obj_flds.keySet()){
				String objToQuery;
				System.debug(relObjName);
				List<String> lstApiNameRelForm = relObjName.split('\\[');
				System.debug(lstApiNameRelForm);
				Integer indexPositionForm = Integer.valueOf(lstApiNameRelForm[1].removeEnd(']'));
				System.debug(lstApiNameRelForm);

				String objApiName = map_rel_sobj.get(lstApiNameRelForm[0]);

				if(mainObj == objApiName)continue;
				system.debug('>>>>>>>>>>>>>>>>>> rtNameQueryMap dentro del for map_rel_sobj ' + map_rel_sobj + '  relObjName ' + relObjName);
				if(relObjName != null){
					System.debug(objApiName);
					objToQuery = map_schemafields.get(lstApiNameRelForm[0]).getDescribe().getRelationshipName();
				
					system.debug('>>>>>>>>>>>>>>>>>> rtNameQueryMap relObjName '+  objToQuery+ ' ' +lstApiNameRelForm[0] + ' map_obj_flds.get(relObjName) ' + map_obj_flds.get(relObjName));
					String soql = 'SELECT ' + joinIdSetByComma(map_obj_flds.get(relObjName)) + ' FROM ' + objToQuery + ' WHERE Id = \'' + (String)map_sobj_query.get(mainObj).get(0).get(lstApiNameRelForm[0]) + '\' LIMIT 1';
					System.debug(soql);
					SObject relObj = Database.query(soql);
					if(map_sobj_query.containsKey(objToQuery)){
						map_sobj_query.get(objToQuery).add(relObj);

					}else{
						map_sobj_query.put(objToQuery, new List<SObject>{relObj});

					}
					map_rel_sobj.put(lstApiNameRelForm[0], objToQuery);
					System.debug('QUE COJONES TE PASAS ' + objToQuery);
					map_sobj_availabeflds.put(objToQuery, getSetAvailableFlds(relObj));


				}else{
					system.debug('>>>>>>>>>>>>>>> rtNameQueryMap es null ');
				}
				
			}
		//}
		system.debug('>>>>>>>>>> map_sobj_query '+ map_sobj_query);
		return map_sobj_query;
	}*/


	public void fuseSobjInfoIntoConfig(Map<String, SObject> map_sobjects ,Map<String, List<Object>> map_form, Map<String, String> map_rel_sobj){
		system.debug('>>>>>>>>>>>>>>>> fuseSobjInfoIntoConfig');
		system.debug('>>>>>>>>>>>>>>>> fuseSobjInfoIntoConfig Map<String, SObject> map_sobjects ' + map_sobjects);
		system.debug('>>>>>>>>>>>>>>>> fuseSobjInfoIntoConfig Map<String, List<Object>> map_form ' + map_form);
		system.debug('>>>>>>>>>>>>>>>> fuseSobjInfoIntoConfig  Map<String, String> map_rel_sobj ' + map_rel_sobj);

		Map<String, Map<String,Schema.SObjectField>> map_sobtype_fieldmap = new Map<String, Map<String,Schema.SObjectField>>();
		for(String key : map_sobjects.keySet()){
			String auxType = String.valueOf(map_sobjects.get(key).getSObjectType());
			map_rel_sobj.put(key, auxType);
			map_sobtype_fieldmap.put(auxType, Schema.getGlobalDescribe().get(auxType).getDescribe().fields.getMap());
		}
		system.debug('>>>>>>>>>>>>> fuseSobjInfoIntoConfig segundo for ');
		System.debug('map_sobj_availabeflds'+ map_sobj_availabeflds );

		for(String relObjName : map_form.keySet()){
			for(Object objField : map_form.get(relObjName)){
				
				Map<String, Object> map_fieldconfig = (Map<String, Object>)objField;
				String objApiName = (String)map_fieldconfig.get('sobj');
			
				System.debug('objApiName ' + objApiName);
				SObject currentSobj = map_sobjects.get(objApiName);
				//Map<String,Schema.SObjectField> currentSchema = map_sobtype_fieldmap.get(objApiName);
				system.debug('>>>>>>>>>>>>> fuseSobjInfoIntoConfig detras currentSobj ' + currentSobj + ' map_sobtype_fieldmap ' + map_sobtype_fieldmap);
				system.debug('>>>>>>>>>> relObjName ' + relObjName);
				if(!map_fieldconfig.containsKey('size'))map_fieldconfig.put('size', 6);
				if(currentSobj == null){
					system.debug('>>>>>>>>>>> fuseSobjInfoIntoConfig es null');
				}else{
					//System.debug('map_sobj_availabeflds.get(objApiName).contains((String)map_fieldconfig.get(apiNam))'+ map_sobj_availabeflds.containsKey(objApiName) );
					if((map_fieldconfig.containsKey('standard') && Boolean.valueOf(map_fieldconfig.get('standard')) || map_sobtype_fieldmap.get(map_rel_sobj.get(objApiName)).containsKey((String)map_fieldconfig.get('apiName')))/*map_sobj_availabeflds.containsKey(objApiName) && map_sobj_availabeflds.get(objApiName).contains((String)map_fieldconfig.get('apiName'))*/){
						//System.debug('map_sobj_availabeflds.get(objApiName).contains((String)map_fieldconfig.get(apiNam))'+ map_sobj_availabeflds.get(objApiName).contains((String)map_fieldconfig.get('apiName')) );
						
						Schema.SObjectField map_schemaAUX = map_sobtype_fieldmap.get(map_rel_sobj.get(objApiName)).get((String)map_fieldconfig.get('apiName'));
						if(String.valueOf(map_schemaAUX.getDescribe().getType()) == 'PICKLIST' && !map_fieldconfig.containsKey('endpoint')){
							if(!map_fieldconfig.containsKey('attributes')){
								map_fieldconfig.put('attributes', new Map<String, Object> {'options'=> new List<Map <String, Object>>(), 'placeholder' => ''});
							}
							for(Schema.PicklistEntry valorPicklist : map_schemaAUX.getDescribe().getPicklistValues()){
								if(valorPicklist.isActive()){
									Map <String, Object> mapfieldAUX = (Map <String, Object>)map_fieldconfig.get('attributes');
									List<Map <String, Object>> mapoptAUX = (List<Map <String, Object>>)mapfieldAUX.get('options');
										mapoptAUX.add(new Map<String, Object> {
										'label' => valorPicklist.getLabel(),
										'value' => valorPicklist.getValue()
									});
								}
							}
							
							map_fieldconfig.put('fieldType', 'picklist');
						}
					
						map_fieldconfig.put('value', currentSobj.get((String)map_fieldconfig.get('apiName')));
						if(!map_fieldconfig.containsKey('label'))map_fieldconfig.put('label', map_schemaAUX.getDescribe().getLabel());

					}else if(map_fieldconfig.containsKey('section') && (Boolean)map_fieldconfig.get('section')){
						map_fieldconfig.put('title', replaceKeysForValues((String)map_fieldconfig.get('title'), map_sobjects));
					}

					map_fieldconfig.put('sobjInfo', new Map<String, String>{'sobjtype' => map_rel_sobj.get(objApiName), 'sobjId' => (String)currentSobj.get('Id')});
				}


			}
		}
	}

	private String replaceKeysForValues(String text, Map<String, Sobject> mapSobj){
		System.debug('replaceKeysForValues');
		String calculatedStr = text;
		for(String key : mapSobj.keySet()){
			String finalKey= '$'+key;
			if(calculatedStr.contains(finalKey)){
				List<String> lstText = calculatedStr.split(' ');
				for(String word : lstText){
					if(word.contains('$')){
						System.debug('replaceKeysForValues ' + word);
						List<String> lstFields = word.split('\\.');
						System.debug('replaceKeysForValues ' + lstFields);
						System.debug('replaceKeysForValues ' + word);
						System.debug('replaceKeysForValues ' + key + ' ' + lstFields[1]);
						calculatedStr = calculatedStr.replace(word, ( mapSobj.get(key).get(lstFields[1]) != null ? (String) mapSobj.get(key).get(lstFields[1]) : '') );
						System.debug('replaceKeysForValues ' + calculatedStr);

					}
				}
			}
		}
		return calculatedStr;
	}

	/*private String joinIdSetByComma(Set<String> setStrings){
		system.debug('>>>>>>>>>>>>>>>> joinIdSetByComma');
		List<String> auxset = new List<String>();
		if(!setStrings.contains('Id'))setStrings.add('Id');
		auxset.addAll(setStrings);

		return String.join(auxset, ',');
	}*/
	/**
	 * Elements in the picklist must be ordered
	 */
	private Map<String, Integer> getPathSteps(String field, String sobjtype){
		Map<String, Integer> map_ret = new Map<String, Integer>();
		List<Schema.PicklistEntry> lstPE = Schema.getGlobalDescribe().get(sobjtype).getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues();
		Integer i = 0;
		for(Schema.PicklistEntry pe : lstPE){
			if(pe.isActive()){
				map_ret.put(pe.getValue(), i);
				i++;
			}
			
		}
		return map_ret;
	}

	/*private Set<String> getSetAvailableFlds(SObject sobj){
		// Serialize our Sobject into JSON
		Set<String> fieldsPresent = new Set<String>();
		if(sobj!=null){
			System.debug('sobj getSetAvailableFlds' + sobj); 
			String jsonSobj = JSON.serialize(sobj);
			Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(jsonSobj);
			
			fieldsPresent = obj.keyset().clone();
			fieldsPresent.remove('attributes');
			System.debug('availableFlds '+  fieldsPresent);
		}
		return fieldsPresent;
	}*/
	private Set<String> delUnexpectedTokens(Set<String> setFields){
		Set<String> set_formatted = new Set<String>();
		for(String field : setFields){
			set_formatted.add(field.substring(0,field.length()-3));

		}
		return set_formatted;
	}

	
}