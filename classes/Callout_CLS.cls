/****************************************************************************************************
Desarrollado por:   VASS
Proyecto:          -
Descripción:       Clase que centraliza las llamadas a los servicios externos

Cambios (Versiones)
-----------------------------------------------------------------------------------------------------
No.     Fecha           Autor                   Descripción
-----   ----------      --------------------    -----------------------------------------------------
1.0     2019-09-01      Jorge Levenfeld			Creación de la Clase.                                       
*/
public with sharing class Callout_CLS {

	Service_CLS service;
	RequestBody_CLS request;
	static String accessToken;
	static Map<String, WebService_Info__mdt> serviceInfosByDeveloperName {
	  get {
		if ( serviceInfosByDeveloperName == null ) {
		  List<WebService_Info__mdt> serviceInfos = [SELECT Id, isMock__c, DeveloperName FROM WebService_Info__mdt];
		  serviceInfosByDeveloperName = new Map<String, WebService_Info__mdt>();
		  for ( WebService_Info__mdt serviceInfo : serviceInfos ) {
			serviceInfosByDeveloperName.put( serviceInfo.DeveloperName, serviceInfo );
		  }
		}
		return serviceInfosByDeveloperName;
	  }
	  set;
	}
	//Service_CLS getAPIManagerToken = new DB_HD_APIManager_callout.DB_HD_getToken();
  
	static Callout_CLS singletonInstance;
	private Callout_CLS () {}
	public static Callout_CLS getInstance(  ) {
	  if ( singletonInstance == null ) {
		singletonInstance = new Callout_CLS();
	  }
	  return singletonInstance;
	}
  
	public static Object callService(Service_CLS service){

		Callout_CLS callout = Callout_CLS.getInstance();
		Object responseBody;
		
		Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
	
		try {
	
		  responseBody = isMock ? service.setMockResponseNoDefinedObj() : service.runNoDefinedObj();
		  System.debug('RESPONSE BODY '+ responseBody);
	
		} catch (Exception e) {
		  /*EventLogger.LogData logData = new EventLogger.LogData();
		  logData.error_Class_Name = 'Callout_CLS';
		  logData.exceptionToLog = e;
		  EventLogger.addLog( logData, true );*/
		  throw e;
		}
	
		return responseBody;
	}
	  
	public static Object callService(Service_CLS service, Map<String, String> urlParams, Boolean setUrlParams){

		Callout_CLS callout = Callout_CLS.getInstance();
		Object responseBody;
		System.debug('setUrlParams ' + setUrlParams);
		System.debug('setUrlParams ' + urlParams);
		if(setUrlParams)service.setUrlParams(urlParams);
		System.debug(service.getMdtName());
		Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
	
		try {
	
		  responseBody = isMock ? service.setMockResponseNoDefinedObj() : service.runNoDefinedObj();
		  System.debug('RESPONSE BODY '+ responseBody);
	
		} catch (Exception e) {
		  /*EventLogger.LogData logData = new EventLogger.LogData();
		  logData.error_Class_Name = 'Callout_CLS';
		  logData.exceptionToLog = e;
		  EventLogger.addLog( logData, true );*/
		  throw e;
		}
	
		return responseBody;
	}

	public static ResponseBody_CLS callService( Service_CLS service, RequestBody_CLS requestBody, Map<String, String> urlParams) {
  
	  Callout_CLS callout = Callout_CLS.getInstance();
	  ResponseBody_CLS responseBody;
  
	  service.setRequestBody( requestBody );
	  service.setUrlParams(urlParams);
	  //service.setAccessToken( callout.getAccessToken() );
  
	  System.debug(JSON.serializePretty(requestBody));
  
	  Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
  
	  try {
  
		responseBody = isMock ? service.setMockResponse() : service.run();
  
	  } catch (Exception e) {
		/*EventLogger.LogData logData = new EventLogger.LogData();
		logData.error_Class_Name = 'Callout_CLS';
		logData.exceptionToLog = e;
		EventLogger.addLog( logData, true );*/
		throw e;
	  }
  
	  return responseBody;
	}

	public static List<GetAllMovementsResponse> callServiceLst( Service_CLS service, RequestBody_CLS requestBody, Map<String, String> urlParams) {
  
		Callout_CLS callout = Callout_CLS.getInstance();
		List<GetAllMovementsResponse> responseBody;
	
		service.setRequestBody( requestBody );
		service.setUrlParams(urlParams);
		//service.setAccessToken( callout.getAccessToken() );
	
		System.debug(JSON.serializePretty(requestBody));
	
		Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
	
		try {
	
		  responseBody = isMock ? service.setMockListResponse() : service.runBodyLst();
	
		} catch (Exception e) {
		  /*EventLogger.LogData logData = new EventLogger.LogData();
		  logData.error_Class_Name = 'Callout_CLS';
		  logData.exceptionToLog = e;
		  EventLogger.addLog( logData, true );*/
		  throw e;
		}
	
		return responseBody;
	}
  
	public static ResponseBody_CLS callService( Service_CLS service, Map<String, String> urlParams) {
  
	  Callout_CLS callout = Callout_CLS.getInstance();
	  ResponseBody_CLS responseBody;
  
	  service.setUrlParams(urlParams);
	  //service.setAccessToken( callout.getAccessToken() );
  
	  Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
  
	  try {
  
		responseBody = isMock ? service.setMockResponse() : service.run();
  
	  } catch (Exception e) {
		/*EventLogger.LogData logData = new EventLogger.LogData();
		logData.error_Class_Name = 'Callout_CLS';
		logData.exceptionToLog = e;
		EventLogger.addLog( logData, true );*/
		throw e;
	  }
  
	  return responseBody;
	}

	public static ResponseBody_CLS callService( String params , Service_CLS service) {
  
		Callout_CLS callout = Callout_CLS.getInstance();
		ResponseBody_CLS responseBody;
	
		//service.setUrlParams(urlParams);
		//service.setAccessToken( callout.getAccessToken() );
	
		Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
	
		try {
	
		  responseBody = isMock ? service.setMockResponse() : service.run();
	
		} catch (Exception e) {
		  /*EventLogger.LogData logData = new EventLogger.LogData();
		  logData.error_Class_Name = 'Callout_CLS';
		  logData.exceptionToLog = e;
		  EventLogger.addLog( logData, true );*/
		  throw e;
		}
	
		return responseBody;
	  }
  
	public static ResponseBody_CLS callService( Service_CLS service, RequestBody_CLS requestBody ) {
  
	  Callout_CLS callout = Callout_CLS.getInstance();
	  ResponseBody_CLS responseBody;
  
	  service.setRequestBody( requestBody );
	  //service.setAccessToken( callout.getAccessToken() );
  
	  System.debug(JSON.serializePretty(requestBody));
  
	  Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
  
	  try {
  
		responseBody = isMock ? service.setMockResponse() : service.run();
  
	  } catch (Exception e) {
		/*EventLogger.LogData logData = new EventLogger.LogData();
		logData.error_Class_Name = 'Callout_CLS';
		logData.exceptionToLog = e;
		EventLogger.addLog( logData, true );*/
		throw e;
	  }
  
	  return responseBody;
	}
  
	public static ResponseBody_CLS callService( Service_CLS service, String requestBody ) {
  
	  Callout_CLS callout = Callout_CLS.getInstance();
	  ResponseBody_CLS responseBody;
  
	  service.setRequestBody( requestBody );
	  //service.setAccessToken( callout.getAccessToken() );
  
	  System.debug(requestBody);
  
	  Boolean isMock = serviceInfosByDeveloperName.get( service.getMdtName() ).isMock__c;
  
	  try {
  
		responseBody = isMock ? service.setMockResponse() : service.run();
  
	  } catch (Exception e) {
		/*EventLogger.LogData logData = new EventLogger.LogData();
		logData.error_Class_Name = 'Callout_CLS';
		logData.exceptionToLog = e;
		EventLogger.addLog( logData, true );*/
		throw e;
	  }
  
	  return responseBody;
	}
  
	/*private String getAccessToken() {
  
	  return accessToken != null ? accessToken : callAOuthService();
  
	}
  
	public String callAOuthService() {
  
	  String accessToken;
	  DB_HD_APIManager_getToken_BodyResponse response;
	  try {
		Boolean isMock = Test.isRunningTest() ? true : serviceInfosByDeveloperName.get( getAPIManagerToken.getMdtName() ).isMock__c;
		response = ( DB_HD_APIManager_getToken_BodyResponse ) ( isMock ? getAPIManagerToken.setMockResponse() : getAPIManagerToken.run() );
		System.debug(JSON.serializePretty( response ));
		accessToken = response.access_token;
	  } catch (Exception e) {
		//TODO: Registrar en algún log...
		throw e;
	  }
  
	  return accessToken;
  
	}*/
  
  }