public with sharing class formBasedOnPath {
    @AuraEnabled
    public static string saveData(String jsonData, String pathField, Id recId){
        //try {
            Map<String, Object> mapDraftValues = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
            Map<String, sObject> mapSobject = new Map<String, sObject>();
			String sobjAux;
			sObject sobj;
			String mainObjType = String.valueOf(recId.getSobjectType());
            for(String key : mapDraftValues.keySet()){
                system.debug(key);
				
				Map<String, Object> map_sobj = (Map<String, Object>)mapDraftValues.get(key);
				System.debug('map_sobj');
				if(map_sobj.containsKey('Id')){
					Id sobjId = (Id)map_sobj.get('Id');
					System.debug('sobjId ' + sobjId);
					map_sobj.put('attributes', new Map<String, String>{'type' => String.valueOf(sobjId.getSobjectType())});
				}
				System.debug('map_sobj' + map_sobj);

				sobjAux = JSON.serialize(map_sobj);
				System.debug(sobjAux);

                sobj = (SObject)JSON.deserialize(sobjAux, SObject.class);
				System.debug(sobj);
                mapSobject.put(key, sobj);

            }
            system.debug('>>>>> mapSobject ' + mapSobject);
            system.debug('>>>>> mapDraftValues ' + mapDraftValues);

            upsert mapSobject.values();
			String returnPathStep = (String)mapSobject.get(mainObjType).get(pathField);
            return returnPathStep != null ? returnPathStep : 'currentStep';
        /*} catch (Exception e) {
            return e.getMessage();
        }*/
    }
	public static Map<String, SObject> getMapParamsForm(String process, Id recordId){
		
		Map<String, SObject> map_params;

		switch on process {
			when  'Test'{
				map_params = new Map<String, SObject>{
					'Opportunity' => [SELECT Id, AccountId, StageName FROM Opportunity WHERE Id =: recordId],
					'firstHolder' => [SELECT Id, FirstName, PersonEmail,Phone FROM Account LIMIT 1],
					'secondHolder' => [SELECT Id, FirstName, PersonEmail,Phone FROM Account LIMIT 1]
				};
			}
			when 'OnBoarding'{
				map_params = new Map<String, SObject>();
				
				Opportunity opp = [SELECT Id, AccountId, StageName,FinServ__FinancialAccount__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
				
				map_params.put('Opportunity', opp);

                Set<Id> setAccId = new Set<Id>();
                Map<Id, String> map_accId_role = new Map<Id,String>();
                for(FinServ__FinancialAccount__c fAcc : [SELECT name ,(SELECT id, FinServ__Role__c, FinServ__RelatedAccount__c FROM FinServ__FinancialAccountRoles__r) FROM FinServ__FinancialAccount__c WHERE Id =: opp.FinServ__FinancialAccount__c]){

                    for(FinServ__FinancialAccountRole__c fRoles : fAcc.FinServ__FinancialAccountRoles__r){
                        //setAccId.add(fRoles.FinServ__RelatedAccount__c);
                        map_accId_role.put(fRoles.FinServ__RelatedAccount__c, fRoles.FinServ__Role__c);
                    }
                }
				if(!map_accId_role.keySet().isEmpty()){
                	Map<String, Account> mapAcc = new Map<String,Account>();
					for(Account acc : [SELECT Id, BillingStreet,/*StateCode__c,DepartmentCode__c,*/FirstName,FirstLastName__c,SecondLastName__c,
										BirthDate__c,Country_ISO__c,Nationality_ISO__c,ExpiryDate__c,DocumentNumber__c,DocumentType__c,/*CargoActual__c,
										SituacionLaboral__c,TipoDeActividad__c,SectorProfesional__c,*/PersonEmail,Phone FROM Account WHERE Id IN: map_accId_role.keySet()]){
						mapAcc.put(map_accId_role.get(acc.Id), acc);
					}
					if(mapAcc.containsKey('Primary Owner'))map_params.put('firstHolder', mapAcc.get('Primary Owner'));
					if(mapAcc.containsKey('Additional Owner'))map_params.put('secondHolder', mapAcc.get('Additional Owner'));
				}
			}
		}
		return map_params;
	}
}