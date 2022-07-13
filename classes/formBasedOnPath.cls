/**
 * @description       : 
 * @author            : Rafael Vargas Pinilla
 * @group             : 
 * @last modified on  : 06-30-2022
 * @last modified by  : juan.duarte@vass.es
**/
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
			String returnPathStep = mainObjType!=null ? (String)mapSobject.get(mainObjType)?.get(pathField) : null;
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
			when  'General'{
				map_params = new Map<String, SObject>{
					'Opportunity' => [SELECT Id, AccountId, StageName FROM Opportunity WHERE Id =: recordId],
					'firstHolder' => [SELECT Id, LastName, Name, FirstName, PersonEmail,Phone FROM Account LIMIT 1],
					'secondHolder' => [SELECT Id, LastName, Name, FirstName, PersonEmail,Phone FROM Account LIMIT 1]
				};
			}
			when 'Onboarding'{
				map_params = new Map<String, SObject>();
				
				Opportunity opp = [SELECT Id, Subestado__c, AccountId, StageName,FinServ__FinancialAccount__c,Resultado_Firma_OTP__c, Fecha_resultado_firma_OTP__c, Estado_aceptacion_cliente__c, TemporaryPassword__c, IsClosed,
				(SELECT Id, Status__c, SignatureDateFirstHolder__c, SignatureDateSecondHolder__c, StartDate__c FROM SignatureProcesses__r WHERE Status__c != 'Expirado' ORDER BY CreatedDate DESC LIMIT 1)
								FROM Opportunity WHERE Id =: recordId LIMIT 1];
				
				map_params.put('Opportunity', opp);

				if(!opp.SignatureProcesses__r.isEmpty()){
				List<DocumentChecklistItem> lstCheckList = [SELECT Id,ReferenceId__c FROM DocumentChecklistItem WHERE Type__c = 'Contrato ONB' AND ParentRecordId = :opp.SignatureProcesses__r[0].Id ORDER BY CreatedDAte DESC LIMIT 1];
					if(!lstCheckList.isEmpty())map_params.put('Contract', lstCheckList[0]);
					map_params.put('SignProcess__c',opp.SignatureProcesses__r[0]);
				}
				if(!map_params.containsKey('Contract'))map_params.put('Contract', new DocumentChecklistItem());
				if(!map_params.containsKey('SignProcess__c'))map_params.put('SignProcess__c', new SignProcess__c());

                Set<Id> setAccId = new Set<Id>();
                Map<Id, String> map_accId_role = new Map<Id,String>();
                for(FinServ__FinancialAccount__c fAcc : [SELECT name , TSApproval__c,FinServ__FinancialAccountNumber__c, FinServ__Status__c, FinServ__SourceSystemId__c, (SELECT id, FinServ__Role__c, FinServ__RelatedAccount__c FROM FinServ__FinancialAccountRoles__r) FROM FinServ__FinancialAccount__c WHERE Id =: opp.FinServ__FinancialAccount__c]){
                    for(FinServ__FinancialAccountRole__c fRoles : fAcc.FinServ__FinancialAccountRoles__r){
                        //setAccId.add(fRoles.FinServ__RelatedAccount__c);
                        map_accId_role.put(fRoles.FinServ__RelatedAccount__c, fRoles.FinServ__Role__c);
                    }
					map_params.put('financialAccount', fAcc);
                }
				if(!map_accId_role.keySet().isEmpty()){
                	Map<String, Account> mapAcc = new Map<String,Account>();
					for(Account acc : [SELECT Id,PersonMobilePhone, FinServ__Occupation__pc, Occupation__c, Country__c, BillingCountry, Assets__c,Liabilities__c,MonthlyExpenses__c,MonthlyIncome__c,OtherIncome__c,OtherIncomeDetails__c,SourceIncome__c,
					TStampCaptureBiometricInformation__c,TStampFinancialCreditInformation__c,TStampSharePersonalDataEconomicGroup__c,TStampTreatmentPersonalInformation__c,CheckCaptureBiometricInformation__c, CheckFinancialCreditInformation__c, CheckIntTransfer__c, CheckSharePersonalDataEconomicGroup__c, CheckTreatmentPersonalInformation__c, HasDutiesOutEU__c,HasApprovedFundsStatement__c,
					AccountPurpose__c, Role__c, RoleText__c,BillingStreet,ShippingStateCode__c, ShippingState, ShippingCityCode__c, ShippingCity, ShippingAddress, ShippingStreet,ShippingAddressComplement__c,/*StateCode__c,DepartmentCode__c,*/FirstName,FirstLastName__c,SecondLastName__c,
					PersonBirthdate,FinServ__Age__pc,Country_ISO__c,Nationality_ISO__c,ExpiryDate__c,DocumentNumber__c,DocumentTypeCode__c,DocumentTypeLabel__c,ActivityType__c,ActivityTypeText__c,ProfessionalSector__c,ProfessionalSectorText__c,/*CargoActual__c,
										SituacionLaboral__c,TipoDeActividad__c,SectorProfesional__c,*/PersonEmail,Phone, Name, LastName, Estado_de_aceptacion__c, Estado_de_aceptacion_cliente__c, CustomerId__c, TS_generated_password__c, CheckRegulationsPibankProduct__c, CheckNotificationsToMobileBankingInbox__c,
										TStampRegulationsPibankProduct__c,TStampNotificationsToMobileBankingInbo__c, CheckPEPs__c, TStampPEPs__c
										FROM Account WHERE Id IN: map_accId_role.keySet()]){
						mapAcc.put(map_accId_role.get(acc.Id), acc);
					}
					if(!map_params.containsKey('firstHolder') && mapAcc.containsKey('Primary Owner'))map_params.put('firstHolder', mapAcc.get('Primary Owner'));
					if(!map_params.containsKey('secondHolder') && mapAcc.containsKey('Additional Owner'))map_params.put('secondHolder', mapAcc.get('Additional Owner'));

					for(Olimpia__c olimpia : [SELECT Id, Client__c, PrimerNombre__c, SegundoNombre__c,SegundoApellido__c,EstadoDescripcion__c, EncontradoEnFuente__c, 
											FechaRegistro__c,FechaFinalizacion__c,MotivoCancelacion__c,TipoDoc__c,NumDoc__c,ScoreProceso__c, Aprobado__c, Cancelado__c, Finalizado__c FROM Olimpia__c WHERE Client__c IN :map_accId_role.keySet() ORDER BY CreatedDate DESC LIMIT 2]){
						if(!map_params.containsKey('Olimpia1Holder') && map_params.containsKey('firstHolder') && map_params.get('firstHolder').Id == olimpia.Client__c)map_params.put('Olimpia1Holder', olimpia);
						if(!map_params.containsKey('Olimpia2Holder') && map_params.containsKey('secondHolder') && map_params.get('secondHolder').Id == olimpia.Client__c)map_params.put('Olimpia2Holder', olimpia);
					} 
						if(!map_params.containsKey('Olimpia1Holder'))map_params.put('Olimpia1Holder', new Olimpia__c());
						if(!map_params.containsKey('Olimpia2Holder') && map_params.containsKey('secondHolder'))map_params.put('Olimpia2Holder', new Olimpia__c());

					for(RestrictiveList__c inspektor : [SELECT Client__c, SearchNumber__c, NumberOfMatches__c, ErrorCode__c, Message__c, ClientName__c, DocumentNumber__c, ExternalId__c FROM RestrictiveList__c WHERE Client__c IN :map_accId_role.keySet() ORDER BY CreatedDate DESC LIMIT 2]){
						if(!map_params.containsKey('Inspektor1Holder') && map_params.containsKey('firstHolder') && map_params.get('firstHolder').Id == inspektor.Client__c)map_params.put('Inspektor1Holder', inspektor);
						if(!map_params.containsKey('Inspektor2Holder') && map_params.containsKey('secondHolder') && map_params.get('secondHolder').Id == inspektor.Client__c)map_params.put('Inspektor2Holder', inspektor);
					}
					
					if(!map_params.containsKey('Inspektor1Holder'))map_params.put('Inspektor1Holder', new RestrictiveList__c());
					if(!map_params.containsKey('Inspektor2Holder') && map_params.containsKey('secondHolder'))map_params.put('Inspektor2Holder', new RestrictiveList__c());
					
				}
			}
		}
		return map_params;
	}

	public static Map<String, SObject> getMapParamsSingleForm(String formName, Id recordId){
		
		Map<String, SObject> map_params;

		switch on formName {
			when 'clientForm'{

				map_params = new Map<String, SObject>();

				if(String.valueOf(recordId.getSobjectType()) == 'Account'){
					map_params.put('Account',[SELECT Id FROM Account LIMIT 1]);
					map_params.put('client',[SELECT name, id,role__c,roleText__c, FinServ__Occupation__pc, Occupation__c, ActivityType__c, ActivityTypeText__c, ProfessionalSector__c, ProfessionalSectorText__c, AccountPurpose__c  FROM Account WHERE Id =: recordId LIMIT 1]);
					//Query del cliente que sea
				}else if(String.valueOf(recordId.getSobjectType()) == 'Case'){
					map_params.put('Case',[SELECT Id  FROM Case LIMIT 1]);
					map_params.put('client',[SELECT name, id FROM Account LIMIT 1]);
					//Accedo a la cuenta desde el caso y tiro query
				}
			}
		}
		return map_params;
	}
}