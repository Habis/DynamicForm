public class FieldCallServices {

	@AuraEnabled
	public static Object fillField(String mdtEndpoint, String params){
		return Callout_CLS.callService(new FieldCallouts.FieldRes(mdtEndpoint));
	}
}
