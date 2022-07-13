/****************************************************************************************************
Desarrollado por:   VASS
Proyecto:           -
Descripción:        Implementaciones comunes a los callouts

Cambios (Versiones)
-----------------------------------------------------------------------------------------------------
No.     Fecha           Autor                   Descripción
-----   ----------      --------------------    -----------------------------------------------------
1.0     2019-11-04		Jorge Levenfeld			Creación de la Clase.
*/
public with sharing virtual class ServiceVirtual_CLS implements Service_CLS {

	protected String mdtName;
	protected Map<String, String> urlParams;
	protected HttpRequest httpRequest = new HttpRequest();
	protected String requestBodyJSON;
	protected ResponseBody_CLS responseBody;
	protected List<GetAllMovementsResponse> respListBody;
	protected Object undefinedResponseBody;
	protected Integer timeout = 120000;
  
	public String getMdtName() {
	  return mdtName;
	}
  
	public Map<String, String> getUrlParams() {
	  return urlParams;
	}
  
	public virtual void setUrlParams(Map<String, String> urlParams) {
	  this.urlParams = urlParams;
	}
	
	public virtual void setRequestBody(RequestBody_CLS requestBody) {
		System.debug('@@@@@@@requestBody ->'+requestBody);
		String serializedBody = requestBody.serializeRequestBody( requestBody );
		httpRequest.setBody( serializedBody );
		setRequestBodyJSON( serializedBody );
	}

	public virtual void setRequestBody(String requestBody) {
	  //String serializedBody = requestBody.serializeRequestBody( requestBody );
	  httpRequest.setBody( requestBody );
	  setRequestBodyJSON( requestBody );
	}
  
	public virtual void setAccessToken(String accessToken) {
	  httpRequest.setHeader( 'Authorization', 'Bearer ' + accessToken );
	}
  
	public virtual ResponseBody_CLS run() {
  
	  Http http = new Http();
  
	  httpRequest = Service_Helper_CLS.setCommonHeaders(httpRequest, mdtName, urlParams);
	  httpRequest.setTimeout( timeout );system.debug( httpRequest );system.debug(httpRequest.getBody()  );
	  HTTPResponse response = http.send(httpRequest);

	  System.debug('@statusCode: ' + response.getStatusCode() );
	  System.debug('@responseBodySerialize: ' + response.getBody());
  
	  if (response.getStatusCode() >= 200 && response.getStatusCode() < 300 ) {
		responseBody = String.isNotBlank(response.getBody()) ? responseBody.deserializeResponseBody(response.getBody()) : null;
		System.debug('@responseBody: ' + responseBody);
	  } else {
		manageErrorStatus(response);
	  }
  
	  return responseBody;
  
	}

	public virtual List<GetAllMovementsResponse> runBodyLst() {
  
		Http http = new Http();
	
		httpRequest = Service_Helper_CLS.setCommonHeaders(httpRequest, mdtName, urlParams);
		httpRequest.setTimeout( timeout );system.debug( httpRequest );system.debug(httpRequest.getBody()  );
		HTTPResponse response = http.send(httpRequest);
	
		if (response.getStatusCode() >= 200 && response.getStatusCode() < 300 ) {
		  System.debug('@statusCode: ' + response.getStatusCode() );
		  respListBody = (List<GetAllMovementsResponse>) System.JSON.deserialize(response.getBody(), List<GetAllMovementsResponse>.class);
		  System.debug('@responseBody: ' + respListBody);
		} else {
		  manageErrorStatus(response);
		}
	
		return respListBody;
	
	}
	
	public virtual Object runNoDefinedObj() {
  
		Http http = new Http();
	
		httpRequest = Service_Helper_CLS.setCommonHeaders(httpRequest, mdtName, urlParams);
		httpRequest.setTimeout( timeout );system.debug( httpRequest );system.debug(httpRequest.getBody()  );
		HTTPResponse response = http.send(httpRequest);
	
		if (response.getStatusCode() >= 200 && response.getStatusCode() < 300 ) {
		  System.debug('@statusCode: ' + response.getStatusCode() );
		  undefinedResponseBody = JSON.deserializeUntyped( response.getBody());
		  System.debug('@responseBody: ' + responseBody);
		} else {
		  manageErrorStatus(response);
		}
	
		return undefinedResponseBody;
	
	  }
  
	public virtual void manageErrorStatus ( HTTPResponse response ) {
  
	  System.debug('@Response: ' + JSON.serializePretty( response.getBody() ));
	  ServiceException serviceException = new ServiceException();
	  serviceException.status = response.getStatus();
	  serviceException.statusCode = response.getStatusCode();
	  serviceException.setMessage('Status code ' + response.getStatusCode() + ' not expected!');
	  serviceException.responseBody = response.getBody();
	  serviceException.requestBody = this.requestBodyJSON;
	  serviceException.webServiceName = this.mdtName;
	  throw serviceException;
  
	}

	public virtual List<GetAllMovementsResponse> setMockListResponse() {

		List<WebService_Info__mdt> lst_wsInfo = [
			SELECT EndPoint__c, Method__c, Content_Type__c, mockResponse__c
			FROM WebService_Info__mdt
			WHERE DeveloperName = :mdtName
		];

		List<GetAllMovementsResponse> respListBody = (List<GetAllMovementsResponse>) JSON.deserialize(lst_wsInfo.get(0).mockResponse__c, List<GetAllMovementsResponse>.class);

		System.debug('respListBody--> '+respListBody);
		return respListBody;

	}
  
	public virtual ResponseBody_CLS setMockResponse() {
  
	  List<WebService_Info__mdt> lst_wsInfo = [
		  SELECT EndPoint__c, Method__c, Content_Type__c, mockResponse__c
		  FROM WebService_Info__mdt
		  WHERE DeveloperName = :mdtName
	  ];
  
	  ResponseBody_CLS responseBody = lst_wsInfo.get(0).mockResponse__c != null ? responseBody.deserializeResponseBody( lst_wsInfo.get(0).mockResponse__c ) : null;
  
	  return responseBody;
  
	}
	
	public virtual Object setMockResponseNoDefinedObj() {
  
		List<WebService_Info__mdt> lst_wsInfo = [
			SELECT EndPoint__c, Method__c, Content_Type__c, mockResponse__c
			FROM WebService_Info__mdt
			WHERE DeveloperName = :mdtName
		];
		undefinedResponseBody = JSON.deserializeUntyped( lst_wsInfo.get(0).mockResponse__c );
		return undefinedResponseBody;
	
	  }
  
	public void setRequestBodyJSON( String requestBody ) {
	  this.requestBodyJSON = setLogBody( requestBody );
	}
  
	private String setLogBody( String body ) {
	  return body.length() > 32768 ? body.mid( 0, 32768 ) : body;
	}
  
  
  }