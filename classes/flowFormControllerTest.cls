@isTest
private class flowFormControllerTest {


	@TestSetup
	static void initData(){
		OB_TestDataFactory.createOBInitialData1Holder();
	}

	@IsTest
	static void testOnBoardingForm(){
		flowFormController.getInfo([SELECT Id FROM Opportunity LIMIT 1].Id, 'OnBoarding', 'StageName');
	}

	@IsTest
	static void testSingleForm(){
		flowFormController.getSingleInfo([SELECT Id FROM Account LIMIT 1].Id, 'clientForm');
	}

	@IsTest
	static void testSaveDataForm(){
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		String jsonData = '{"firstHolder" : {"Id" : \"'+ acc.Id+'\", "Estado_de_aceptacion__c" : "Aceptado"}, "Opportunity" : {"Id" : \"'+ opp.Id+'\", "StageName" : "Verification"}}';
		formBasedOnPath.saveData(jsonData, 'StageName', opp.Id);
	}
}