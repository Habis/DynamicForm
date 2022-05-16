/****************************************************************************************************
Desarrollado por:   VASS
Proyecto:           -
Descripción:        Clase auxiliar con métodos de ayuda a todos los callouts

Cambios (Versiones)
-----------------------------------------------------------------------------------------------------
No.     Fecha           Autor                   Descripción
-----   ----------      --------------------    -----------------------------------------------------
1.0     2019-10-03		Santiago Cividanes		Creación de la Clase.                                       
*/
public class Service_Helper_CLS {

	public static HttpRequest setCommonHeaders(HttpRequest httpRequest, String mdtName, Map<String, String> urlParams) {
	  List<WebService_Info__mdt> lst_wsInfo = [
		  SELECT EndPoint__c, Method__c, Content_Type__c,webServiceTokens__c,webServiceTokens__r.client_id__c, webServiceTokens__r.client_secret__c
		  , webServiceTokens__r.sf_certificate_name__c
		  FROM WebService_Info__mdt
		  WHERE DeveloperName = :mdtName
	  ];
  
	  httpRequest.setEndpoint(formatUrl(lst_wsInfo.get(0).EndPoint__c, urlParams));
	  
	  httpRequest.setMethod(lst_wsInfo.get(0).Method__c);
	  // httpRequest.setClientCertificateName('db_hd_salesforce');
	  httpRequest.setTimeout(120000);
	  if(lst_wsInfo.get(0).webServiceTokens__c != null){
		if(lst_wsInfo.get(0).webServiceTokens__r.sf_certificate_name__c!= null)httpRequest.setClientCertificateName(lst_wsInfo.get(0).webServiceTokens__r.sf_certificate_name__c);
		httpRequest.setHeader('client_secret', lst_wsInfo.get(0).webServiceTokens__r.client_secret__c);
		httpRequest.setHeader('client_id', lst_wsInfo.get(0).webServiceTokens__r.client_id__c);
	  }
  
  
	  if(lst_wsInfo.get(0).Content_Type__c != null)httpRequest.setHeader('content-type', lst_wsInfo.get(0).Content_Type__c);
  
	  return httpRequest;
	}
  
	public static String urlEncode(Map<String, String> vals) {
	  String result = '';
	  for (String thisKey : vals.keySet()) {
		result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(vals.get(thisKey), 'UTF-8') + '&';
	  }
	  return result.removeEnd('&');
	}
  
	private static String formatUrl(String url, Map<String, String> urlParams){
	  
	  if(urlParams == null) return url;
	  String retUrl = url;
	  for(String key : urlParams.keySet()){
		  System.debug('key ' + key);
		  String formattedKey = '{' + key.trim() + '}';
		  System.debug('formattedKey ' + formattedKey + ' retUrl ' + retUrl);
		  System.debug('contains ' + retUrl.contains(formattedKey));
		  if(retUrl.contains(formattedKey)){
			  System.debug('formattedKey ' + urlParams.get(key));
			  retUrl = retUrl.replace(formattedKey, urlParams.get(key));
		  }
	  }
	  system.debug('url ' + retUrl);
	  return retUrl;
	}
  
  }