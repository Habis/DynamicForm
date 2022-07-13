/**
 * @description       : 
 * @author            : Antonio Pardo Corral
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Rafael Vargas Pinilla
**/
public with sharing class flowFormController {


	@auraEnabled
	public static Map<String, Object> getInfo(Id recordId,String flow, String stepField){
		System.debug(stepField + ' ' + String.valueOf(recordId.getSObjectType()));
		SObject relObj = Database.query('SELECT RecordType.DeveloperName FROM ' + recordId.getSObjectType() + ' WHERE Id = \'' + recordId + '\' LIMIT 1');
        String devName = String.valueOf(relObj.getSObject('RecordType').get('DeveloperName'));
		system.debug('pruebaOB ' + devName);
		PathFormMdtUtil pathMdtHelper = new PathFormMdtUtil(recordId, stepField, devName, String.valueOf(recordId.getSObjectType()));
		return pathMdtHelper.getConfigForm();
	}

	@auraEnabled
	public static Map<String, Object> getSingleInfo(Id recordId, String formName){
		PathFormMdtUtil pathMdtHelper = new PathFormMdtUtil(recordId, formName, String.valueOf(recordId.getSObjectType()));
		return pathMdtHelper.getConfigForm();
	}
}