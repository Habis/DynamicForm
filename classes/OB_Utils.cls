/**
 * @description       : Common methods for implementation in onboarding classes
 * @author            : juan.duarte@vass.es
 * @group             : VASS
 * @last modified on  : 08-07-2022
 * @last modified by  : marcos.gimeno@vass.es
**/
public with sharing class OB_Utils {

	public static Map<String, Opportunity> createOBOpportunity(Map<String, Account> mapHolderAcc, String stage, Boolean blnMultTitulares) {

		Map<String, Opportunity> mapInsert = new Map<String, Opportunity>();
		Id rTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Onboarding').getRecordTypeId();

		Product2 product = getProduct();
		for(String holderNumber : mapHolderAcc.keySet()){
			Account currentAcc = mapHolderAcc.get(holderNumber);
			mapInsert.put(holderNumber, new Opportunity(
				Name = 'Onboarding '+String.valueOf(System.now()),
				CloseDate = System.today().addYears(1),
				AccountId = currentAcc.Id,
				Product__c = product?.Id,
				StageName = stage,
				Subestado__c = 'PAC',
				RecordTypeId = rTypeId
			));
			break;
		}
        try {
            Insert mapInsert.values();
			return mapInsert;
        } catch (exception e) {
            return null;
        }
    }

	/*public static Map<String, Contact> createContactIndividual(Map<String, OB_New2HoldersWSWrapper.Holder> mapHolders){

		Map<String, Contact> mapInsert = new Map<String, Contact>();

		for(String holderNumber : mapHolders.keySet()){
			OB_New2HoldersWSWrapper.Holder currentHolder = mapHolders.get(holderNumber);
			mapInsert.put(holderNumber, new Contact(
				lastName = String.isNotBlank( currentHolder.strName ) && currentHolder.strName != 'null' ? currentHolder.strName : currentHolder.strEmail,
				phone = currentHolder.strPhone,
				email = currentHolder.strEmail,
				//OB_Onboarding__c = true,
				//FinServ__Gender__c = String.isNotBlank( currentHolder.strGender ) && currentHolder.strGender != 'null' ? ( currentHolder.strGender == 'W' ? 'Female' : 'Male' ) : '',
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
    }*/


	/**
	* @description Creates a new person account with the holder data received in the request
	* @author marcos.gimeno@vass.es | 17-06-2022 
	* @param Map<String OB_New2HoldersWSWrapper.Holder> mapHolders 
	* @param String strTimeStamp 
	* @return Map<String, Account> 
	**/
	public static Map<String, Account> createAccountByHolder(Map<String, OB_New2HoldersWSWrapper.Holder> mapHolders, String strTimeStamp) {
		Map<String, Account> mapInsert = new Map<String, Account>();
		List<RecordType> lstRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' WITH SECURITY_ENFORCED];
		for(String holderN : mapHolders.keySet()){

			//Getting the holder
			OB_New2HoldersWSWrapper.Holder currentHolder = mapHolders.get(holderN);

			// Convert timestamps from millisecond to datetime
			DateTime timeStamp = getDateTimeFromMillisecond(strTimeStamp);

			mapInsert.put(holderN, new Account(
				// Static data
				RecordtypeId =  lstRt[0].Id,
				FinServ__BranchCode__c = '3141',
				FinServ__Status__c = 'Onboarding',
				Onboarding__c = true,
				IntegrationId__c = currentHolder.integrationId,
				// Request data
				PersonMobilePhone = currentHolder.strPhone,
				PersonEmail = currentHolder.strEmail,
				LastName = currentHolder.strName,
				CheckFinancialCreditInformation__c = currentHolder.blnCheckFinancialCreditInformation,
				CheckTreatmentPersonalInformation__c =  currentHolder.blnTreatmentPersonalInformation,
				CheckSharePersonalDataEconomicGroup__c =  currentHolder.blnSharePersonalDataEconomicGroup,
				TStampSharePersonalDataEconomicGroup__c = timeStamp,
				TStampFinancialCreditInformation__c = timeStamp,
				TStampTreatmentPersonalInformation__c = timeStamp
			));
		}

		try{
			Upsert mapInsert.values();
			return mapInsert;
		} catch (exception e) {
			System.debug('Exception ' + e);
			return null;
		}
	}

	public static Map<Boolean, FinServ__FinancialAccount__c> createOBFinancialAccount( Map<String, Account> mapHolderAcc ) {
        system.debug('\n\n--> mapHolderAcc -'+mapHolderAcc+'-');

		Map<Boolean, FinServ__FinancialAccount__c> result = new Map<Boolean, FinServ__FinancialAccount__c>();
		List<SObject> finantialRecords = new List<SObject>();
		
		FinServ__FinancialAccount__c financialAcc;
		FinServ__FinancialAccount__c financialReference;
		FinServ__FinancialAccountRole__c financialAccRole;
		String externalId;
		String recordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('BankingAccount').getRecordTypeId();
		Map<String, Opportunity> mapInsert = new Map<String, Opportunity>();
		
		Product2 product = getProduct();

		System.debug('mapHolderAcc.keySet --> '+mapHolderAcc.keySet());
		//Obtener un external Id para financialAccount.
		externalId = getUUID();
		//Obtener el primer elemento de la lista
		string firstHolder = (new list<string>(mapHolderAcc.keySet()) [0] );

		financialAcc = new FinServ__FinancialAccount__c(
				FinServ__PrimaryOwner__c = mapHolderAcc.get(firstHolder).Id,
				Name = product?.Name,
				FinServ__SourceSystemId__c = externalId,
				FinServ__FinancialAccountType__c = 'Checking',
				FinServ__Status__c = 'Pending approval',
				RecordTypeId = recordTypeId,
				FinServ__ProductName__c = product?.Id
			);
			
		finantialRecords.add(financialAcc);

		for(String holderNumber : mapHolderAcc.keySet()){
			Account currentAcc = mapHolderAcc.get(holderNumber);
			System.debug('currentAcc.Id --> '+currentAcc.Id); 

			financialAccRole = new FinServ__FinancialAccountRole__c(
				FinServ__RelatedAccount__c = currentAcc.Id,
				FinServ__Role__c = holderNumber==firstHolder ? 'Primary Owner' : 'Additional Owner'
			);

			financialReference = new FinServ__FinancialAccount__c(
				FinServ__SourceSystemId__c = externalId
			);
			financialAccRole.FinServ__FinancialAccount__r = financialReference;

			if(holderNumber!=firstHolder){
				finantialRecords.add(financialAccRole);
			}
		}

        try {
			System.debug('finantialRecords--> '+finantialRecords.size());
            insert finantialRecords;
			result.put(true, financialAcc);
        } catch (exception e) {
            system.debug('\n create finantial records error @@@ \n' + e);
            result.put(false, null);
        }
		return result;
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
			product = [SELECT Id,Name,ProductCode FROM Product2 WHERE ProductCode = 'CTA001' WITH SECURITY_ENFORCED];
		}
		return product;
	}

	public static Id getAccIdByOppId(String strOppId, String rol) {
        Id accountId;
        try {
            Id financialAccId = [SELECT Id FROM FinServ__FinancialAccount__c WHERE FinServ__PrimaryOwner__c IN (SELECT AccountId FROM Opportunity WHERE Id =:strOppId)]?.Id;

            accountId = [SELECT FinServ__RelatedAccount__c FROM FinServ__FinancialAccountRole__c
                                WHERE FinServ__FinancialAccount__c = :financialAccId
                                AND FinServ__Role__c = :rol
                                WITH SECURITY_ENFORCED]?.FinServ__RelatedAccount__c;
        } catch(exception e) {
            system.debug('\n consultando financial account role relacionado @@@ \n' + e);
            return null;
        }
        return accountId;
    }

	/**
	* @description Transforms milliseconds to datetime format
	* @author marcos.gimeno@vass.es | 24-05-2022 
	* @param String strMillisecond
	* @return Datetime
	**/
	public static Datetime getDateTimeFromMillisecond(String strMillisecond) {
		Long lgMillisecond = Long.valueOf(strMillisecond);
		DateTime dt = DateTime.newInstance(lgMillisecond);
		return dt;
	}

	/**
	* @description Método para obtener el total de clientes relacionados a una oportunidad
	* @author juan.duarte@vass.es | 06-27-2022 
	* @param strOppId 
	* @return Integer 
	**/
	public static Integer totalHoldersByOppId(String strOppId) {
        Integer total = 0;
        try {
            Id financialAccId = [SELECT Id FROM FinServ__FinancialAccount__c WHERE FinServ__PrimaryOwner__c IN (SELECT AccountId FROM Opportunity WHERE Id =:strOppId)]?.Id;

            AggregateResult result = [SELECT COUNT(FinServ__RelatedAccount__c) FROM FinServ__FinancialAccountRole__c
                                WHERE FinServ__FinancialAccount__c = :financialAccId
                                WITH SECURITY_ENFORCED];

			total = Integer.valueof(result.get('expr0'));
        } catch(exception e) {
            system.debug('\n consultando financial account role relacionado @@@ \n' + e);
            return null;
        }
        return total;
    }

	/**
	* @description Método para obtener el estado del proceso de firma
	* @author juan.duarte@vass.es | 06-27-2022 
	* @param strOppId 
	* @return String 
	**/
	public static String getStatusSignProcess(String strOppId){
		return [SELECT Status__c 
				FROM SignProcess__c WHERE 
				Opportunity__c =: strOppId
				ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1]?.Status__c;
	}


	/**
	* @description Método para obtener el estado de aceptación de la oportunidad
	* @author juan.duarte@vass.es | 06-27-2022 
	* @param strOppId 
	* @return String 
	**/
	public static String getOppAcceptanceStatus(String strOppId){
		return [SELECT Estado_de_aceptacion__c 
				FROM Opportunity 
				WHERE Id =:strOppId]?.Estado_de_aceptacion__c;
	}

	/**
	* @description Método para obtener información de la FA a partir del Id de Opp
	* @author juan.duarte@vass.es | 06-27-2022 
	* @param strOppId 
	* @return FinServ__FinancialAccount__c 
	**/
	public static FinServ__FinancialAccount__c getAccountNumber(String strOppId){
		return [SELECT FinServ__FinancialAccountNumber__c,FinServ__FinancialAccountType__c 
					FROM FinServ__FinancialAccount__c 
					WHERE FinServ__PrimaryOwner__c IN (SELECT AccountId FROM Opportunity WHERE Id =:strOppId)
				];
	}

	/**
	* @description Método para obtener el Id de referencia del contrato
	* @author juan.duarte@vass.es | 07-07-2022
	* @param strOppId
	* @return String
	**/
	public static String getContractId(String strOppId){
		return [SELECT ReferenceId__c
						FROM DocumentChecklistItem
						WHERE ParentRecordId IN (SELECT Id
													FROM SignProcess__c
													WHERE Status__c != 'Expirado'
													AND Opportunity__c =:strOppId)]?.ReferenceId__c;
	}
}