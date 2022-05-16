/**
 * @description       : 
 * @author            : Rafael Vargas Pinilla
 * @group             : 
 * @last modified on  : 04-01-2022
 * @last modified by  : juan.duarte@vass.es
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
		System.debug('fieldName--> '+fieldName);
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
}