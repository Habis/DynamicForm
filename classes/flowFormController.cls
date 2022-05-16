public with sharing class flowFormController {


	@auraEnabled
	public static Map<String, Object> getInfo(Id recordId, String stepField){
		System.debug(stepField + ' ' + String.valueOf(recordId.getSObjectType()));
		PathFormMdtUtil pathMdtHelper = new PathFormMdtUtil(recordId, stepField, 'OnBoarding', String.valueOf(recordId.getSObjectType()));
		return pathMdtHelper.getConfigForm();
	}
}
	