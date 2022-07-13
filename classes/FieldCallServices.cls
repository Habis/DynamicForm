public class FieldCallServices {

	@AuraEnabled
	public static Object fillField(String mdtEndpoint, String params){
		System.debug(mdtEndpoint + ' ' + params);
		Map<String, String> map_params;
		Boolean hasParams = String.isNotBlank(params) && params != '""';
		if(hasParams)map_params = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);

		return Callout_CLS.callService(new FieldCallouts.FieldRes(mdtEndpoint),map_params, hasParams);
	}
}