/**
 * @description       : 
 * @author            : Rafael Vargas Pinilla
 * @group             : 
 * @last modified on  : 06-30-2022
 * @last modified by  : Rafael Vargas Pinilla
**/
public with sharing class Utils_CLS {



	public static Set<String> getSetDifference(Set<String> setA, Set<String> setB){
		Set<String> setAAux = setA.clone();
		Set<String> setBAux = setB;

		setAAux.removeAll(setBAux);
		return setAAux;
	}

	public static Map<String, Object> getSubMap(Set<String> toKeep, Map<String, Object> mapx){
		Map<String, Object> mapreturn = new Map<String, Object>();

		for(String key : toKeep){
			mapreturn.put(key, mapx.get(key));
		}

		return mapreturn;
	}

	//Comprueba si un objeto tiene cierto campo
	public static boolean hasSObjectField(String fieldName, SObject so){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.toLowerCase());
    }

	/**
	 * @description       : Method to fill the given wrapper with the field information in mapFieldMapping
	 * @author            : Rafael Vargas Pinilla
	 * @param  : Map<String,SObject> mapApiSobj - SObject with the field information
	 * @param  : Object ResponseWSWrapper - Wrapper to fill
	 * @param  : Map<String,String> mapFieldMapping - mapping information example wrapperField => SObject.field
	**/
	public Static Map<String,Object> getFieldsMapping(Map<String,SObject> mapApiSobj, Object ResponseWSWrapper, Map<String,String> mapFieldMapping){

        String JSONWrapper = JSON.serialize(ResponseWSWrapper);

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONWrapper); // Te convierte a mapa de string object el objeto, mapa apiname valor
		System.debug('mapwrapper ' + m);
            for(String apiName : mapFieldMapping.keySet()){

                if(mapFieldMapping.containsKey(apiName)){

					List<String> sobjectField = mapFieldMapping.get(apiName).split('\\.');
					SObject sobjt = mapApiSobj.get(sobjectField[0]);

					if(Utils_CLS.hasSObjectField(sobjectField[1],sobjt)) m.put(apiName,sobjt.get(sobjectField[1]));
                }
            }

        return m;
    }

	public static String getCustomerId(String recordId){

		String customerId =  [SELECT CustomerId__c FROM Account WHERE Id=:recordId].CustomerId__c;

		return customerId;
	}

	public static Map<String,String> getRtMapIdDevname(String sObj){

		Map<String, String> mapRtDevname = new Map<String,String>();
		Map<String, Schema.RecordTypeInfo> mapRtInfo = Schema.getGlobalDescribe().get(sObj).getDescribe().getRecordTypeInfosByDeveloperName();

		for(Schema.RecordTypeInfo rtInfo : mapRtInfo.values()){

			if(rtInfo.isActive()){

				mapRtDevname.put(rtInfo.getRecordTypeId(),rtInfo.getDeveloperName());

			}

		}

		return mapRtDevname;
	}

	public static Map<String,String> getMapPickListApi_Values(string sObj,string PicklistField)
	{
		Map<String, String> mapPickListValues = new Map<String, String>();
		Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(sObj);
		Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
		Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
		List<Schema.PicklistEntry> lstPickListValues = mapFields.get(PicklistField).getDescribe().getPickListValues();

		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			mapPickListValues.put(objPickList.getValue(),objPickList.getLabel());
		}

		return mapPickListValues;
    }
}