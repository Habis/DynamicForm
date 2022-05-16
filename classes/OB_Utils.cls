/**
 * @description       : 
 * @author            : juan.duarte@vass.es
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : juan.duarte@vass.es
**/
public with sharing class OB_Utils {
    


	public static Map<String, Opportunity> createOBOpportunityAndRelation(Map<String, Account> map_holder_acc, Map<String, Contact> map_holder_contact , String stage, String strAccountType, Boolean blnMultTitulares ) {
        
		Map<String, Opportunity> mapInsert = new Map<String, Opportunity>();
		List<OpportunityAccount__c> lstInsertRelation = new List<OpportunityAccount__c>();
        system.debug('\n\n--> strCaseStage -'+stage+'-');
		for(String holderNumber : map_holder_contact.keySet()){

			Contact currentContact = map_holder_contact.get(holderNumber);
			mapInsert.put(holderNumber, new Opportunity(
				Name = 'Onboarding',
				CloseDate = System.today().addYears(1),
				ContactId = currentContact.Id,
				StageName = stage,
				AccountType__c = strAccountType,
				//Origin = 'Onboarding',
				//Subject = System.Label.CaseSubjectOnboardingLBL,
				//Description = System.Label.CaseDescriptionOnboardingLBL,
				RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Onboarding').getRecordTypeId()
				//OB_MultipleTitular__c = blnMultTitulares
			));
		}



        //try {
        
            Insert mapInsert.values();

			//Create relation between opp and account for multiples acc related to opp
			for(String holderNumber : mapInsert.keySet()){

				lstInsertRelation.add(new OpportunityAccount__c(
					client__c = map_holder_acc.get(holderNumber).Id,
					Opportunity__c = mapInsert.get(holderNumber).Id,
					Role__c = holderNumber
				));
				
			}
			Insert lstInsertRelation;

			return mapInsert;


        /*} catch (exception e) {
            system.debug('\n create Case error @@@ \n' + e);

            return null;
        }*/
    }

	public static Map<String, Opportunity> createOBOpportunityAndRelation(Map<String, Account> map_holder_acc, String stage, String strAccountType, Boolean blnMultTitulares ) {
        
		Map<String, Opportunity> mapInsert = new Map<String, Opportunity>();
		List<OpportunityAccount__c> lstInsertRelation = new List<OpportunityAccount__c>();
        system.debug('\n\n--> strCaseStage -'+stage+'-');
		system.debug('\n\n--> map_holder_acc -'+map_holder_acc+'-');

		Product2 product = getProduct();
		for(String holderNumber : map_holder_acc.keySet()){

			Account currentAcc = map_holder_acc.get(holderNumber);
			mapInsert.put(holderNumber, new Opportunity(
				Name = 'Onboarding '+String.valueOf(System.now()),
				CloseDate = System.today().addYears(1),
				AccountType__c = strAccountType,
				AccountId = currentAcc.Id,
				Product__c = product?.Id,
				//ContactId = currentAcc.FinServ__PrimaryContact__c,
				StageName = stage,
				//Origin = 'Onboarding',
				//Subject = System.Label.CaseSubjectOnboardingLBL,
				//Description = System.Label.CaseDescriptionOnboardingLBL,
				RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Onboarding').getRecordTypeId()
				//OB_MultipleTitular__c = blnMultTitulares
			));
		}



        //try {
        
            Insert mapInsert.values();

			//Create relation between opp and account for multiples acc related to opp
			for(String holderNumber : mapInsert.keySet()){

				lstInsertRelation.add(new OpportunityAccount__c(
					client__c = map_holder_acc.get(holderNumber).Id,
					Opportunity__c = mapInsert.get(holderNumber).Id,
					Role__c = holderNumber.right(1)
				));
				
			}
			Insert lstInsertRelation;

			return mapInsert;


        /*} catch (exception e) {
            system.debug('\n create Case error @@@ \n' + e);

            return null;
        }*/
    }

	public static void createRelationOpp(Map<String, Account> map_holder_acc,String oppId){
		List<OpportunityAccount__c> lstInsertRelation = new List<OpportunityAccount__c>();
		for(String holderNumber : map_holder_acc.keySet()){

			lstInsertRelation.add(new OpportunityAccount__c(
				client__c = map_holder_acc.get(holderNumber).Id,
				Opportunity__c = oppId,
				Role__c = holderNumber.right(1)
			));
			
		}
		Insert lstInsertRelation;
	}

	public static Map<String, Contact> createContactIndividual(Map<String, NewUser2HoldersRequestv2.holder> mapHolders){

		Map<String, Contact> mapInsert = new Map<String, Contact>();

		for(String holderNumber : mapHolders.keySet()){
			NewUser2HoldersRequestv2.holder currentHolder = mapHolders.get(holderNumber);
			mapInsert.put(holderNumber, new Contact(
				lastName = String.isNotBlank( currentHolder.strName ) && currentHolder.strName != 'null' ? currentHolder.strName : currentHolder.strEmail,
				phone = currentHolder.strPhone,
				email = currentHolder.strEmail,
				//OB_Onboarding__c = true,
				FinServ__Gender__c = String.isNotBlank( currentHolder.strGender ) && currentHolder.strGender != 'null' ? ( currentHolder.strGender == 'W' ? 'Female' : 'Male' ) : '',
				recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId()
			));
		}

        try{
			system.debug('\n new individual @@@@@  \n' + mapInsert );

			Insert mapInsert.values();
            return mapInsert;

        }catch(exception e){
            system.debug('\n create individual error @@@ \n' + e); 
            return null;
        }        
    }


	public static Map<String, Account> createAccountByHolder(Map<String, NewUser2HoldersRequestv2.holder> mapHolders) {

		Map<String, Account> map_insert = new Map<String, Account>();

		Map<String, String> map_cId_holderN = new Map<String, String>();
		
		/*for(String holdern : map_holder_contact.keySet()){
			map_cId_holderN.put(map_holder_contact.get(holdern).Id, holdern);
		}
		//Retrieve all the contact info, including the account
		for(Contact c : [SELECT Id, AccountId,lastName, phone, email, FinServ__Gender__c, recordtypeId FROM Contact WHERE Id IN :map_cId_holderN.keySet()]){
			c.Phone = mapHolders.get(map_cId_holderN.get(c.Id)).strPhone;
			c.email = mapHolders.get(map_cId_holderN.get(c.Id)).strEmail;
			map_holder_contact.put(map_cId_holderN.get(c.Id), c);
		}*/

		List<RecordType> lstRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount'];
		for(String holderN : mapHolders.keySet()){
			//getting the right holder and the contact
			//Contact currentContact = map_holder_contact.get(holderN);
			NewUser2HoldersRequestv2.holder currentHolder = mapHolders.get(holderN);
			
			System.debug('lstRt ' + lstRt);
			map_insert.put(holderN, new Account(//FinServ__PrimaryContact__c = currentContact.Id,
											FinServ__BranchCode__c = '3141',                    
											FinServ__Status__c   =   'Onboarding',           
											//Name = String.isNotBlank( currentHolder.strName ) && currentHolder.strName != 'null' ? currentHolder.strName : currentHolder.strEmail ,  
											Gender__c = String.isNotBlank( currentHolder.strGender ) && currentHolder.strGender != 'null' ? currentHolder.strGender : '',
											Phone = currentHolder.strPhone,
											PersonEmail = currentHolder.strEmail,
											FirstName = currentHolder.strFirstName,
											LastName = currentHolder.strName, 
											Estado_de_aceptacion__c = 'Aceptado',
											//email__c = currentHolder.strEmail,
											//Acepta_politica_privacidad__c = blnPoliticaPrivacidad;
											// PrecontractualInformation__c = blnPrecontractualInformation;
											// indAceptaCederDatosEmpresasGrupo__c =  blnAllowedPersonalData;               
											Consent2__c = currentHolder.blnAllowedPersonalData,
											Consent1__c =  currentHolder.blnAllowedPublicity,
											Consent3__c =  currentHolder.blnAssetSolvencyFiles,
											RecordtypeId =  lstRt[0].Id));//Schema.SObjectType.Account.getRecordTypeInfosByName().get('PersonAccount').getRecordTypeId()));
		}



		try{

			Upsert map_insert.values();
			//Upsert map_holder_contact.values();
			

			return map_insert;

		} catch (exception e) {
			System.debug('Exception ' + e);
			return null;
		}
		
	}

	/**
	* @description Método para generar un identificador externo
	* @author juan.duarte@vass.es | 03-15-2022
	* @return String
	**/
	public static String getUUID()
	{
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }

	public static Product2 getProduct(){
		Product2 product;
		if(product==null){
			System.debug('--soql product--');
			product = [SELECT Id,Name,ProductCode FROM Product2 WHERE ProductCode = 'CTA001'];
		}
		return product;
	}

	public static Map<Boolean, String> createOBFinancialAccount( Map<String, Account> map_holder_acc ) {
        system.debug('\n\n--> map_holder_acc -'+map_holder_acc+'-');

		Map<Boolean, String> result = new Map<Boolean, String>();
		List<SObject> finantialRecords = new List<SObject>();
		
		FinServ__FinancialAccount__c financialAcc;
		FinServ__FinancialAccount__c financialReference;
		FinServ__FinancialAccountRole__c financialAccRole;
		String externalId;
		String recordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('BankingAccount').getRecordTypeId();
		Map<String, Opportunity> mapInsert = new Map<String, Opportunity>();
		List<OpportunityAccount__c> lstInsertRelation = new List<OpportunityAccount__c>();
		
		Product2 product = getProduct();

		System.debug('map_holder_acc.keySet --> '+map_holder_acc.keySet());
		for(String holderNumber : map_holder_acc.keySet()){
			externalId = getUUID();
			Account currentAcc = map_holder_acc.get(holderNumber);
			System.debug('currentAcc.Id --> '+currentAcc.Id);

			financialAccRole = new FinServ__FinancialAccountRole__c(
				FinServ__RelatedAccount__c = currentAcc.Id,
				FinServ__Role__c = 'Primary Owner'
			);

			financialReference = new FinServ__FinancialAccount__c(
				FinServ__SourceSystemId__c = externalId
			);
			financialAccRole.FinServ__FinancialAccount__r = financialReference;

			financialAcc = new FinServ__FinancialAccount__c(
				FinServ__PrimaryOwner__c = currentAcc.Id,
				Name = product?.Name,
				FinServ__SourceSystemId__c = externalId,
				FinServ__FinancialAccountType__c = 'Savings',
				FinServ__Status__c = 'Borrador',
				RecordTypeId = recordTypeId,
				FinServ__ProductName__c = product?.Id
			);
			
			finantialRecords.add(financialAcc);
			finantialRecords.add(financialAccRole);
		}



        try {
            insert finantialRecords;
			result.put(true,'');
        } catch (exception e) {
            system.debug('\n create finantial records error @@@ \n' + e);
            result.put(false,' create finantial records error');
        }
		return result;
    }
}