@isTest
private  class FieldCallServicesTest {

	private static final String EXCEPTION_MESSAGE = 'Ha habido un problema en la llamada al servicio HOST: 400 not expected!';

	@isTest
	static void testIntegratedField(){
		Object objNationality;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpCalls(200, 'Status', '[{"name" : "Colombia", "isoCode3" : "COL"}]', new Map<String, String>{'Content-Type'=>'application/json;charset=UTF-8'}));
            objNationality = FieldCallServices.fillField('OB_GetCountryList', null);
        Test.stopTest();
	}
	@isTest
	static void testIntegratedFieldError(){
		Object objNationality;
        Exception serviceException;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpCalls(400, 'Status', '[{"name" : "Colombia", "isoCode3" : "COL"}]', new Map<String, String>{'Content-Type'=>'application/json;charset=UTF-8'}));
            try {
                objNationality = FieldCallServices.fillField('OB_GetCountryList', null);
            } catch(Exception e) {
                serviceException = e;
            } 
        Test.stopTest();

        System.assertEquals(EXCEPTION_MESSAGE, serviceException.getMessage(), 'Service exception should be thrown');
	}
}