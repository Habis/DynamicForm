/**
 * @description       : Auxiliary class with methods to support all callouts
 * @author            : Santiago Cividanes
 * @group             : VASS
 * @last modified on  : 06-24-2022
 * @last modified by  : Rafael Vargas Pinilla
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   03-10-2019   Santiago Cividanes      Initial Version
 * 2.0	 16-06-2022   marcos.gimeno@vass.es   callGetJWTToken + post-v.51.0 improved SF methods
**/
public with sharing class Service_Helper_CLS {

	private static final String MDW_JWT_TOKEN_DEVNAME = 'MDWJWTToken';

	public static HttpRequest setCommonHeaders(HttpRequest httpRequest, String mdtName, Map<String, String> urlParams) {

		WebService_Info__mdt mcWSInfo = WebService_Info__mdt.getInstance(mdtName);

		httpRequest.setEndpoint(formatUrl(mcWSInfo.EndPoint__c, urlParams));
		System.debug('Body---> ' + httpRequest.getBody());
		httpRequest.setMethod(mcWSInfo.Method__c);
		httpRequest.setTimeout(120000);
		
		/*if(mcWSInfo.webServiceTokens__c != null) {
			if(mcWSInfo.webServiceTokens__r.sf_certificate_name__c != null) {
				httpRequest.setClientCertificateName(mcWSInfo.webServiceTokens__r.sf_certificate_name__c);
			}
			httpRequest.setHeader('client_secret', mcWSInfo.webServiceTokens__r.client_secret__c);
			httpRequest.setHeader('client_id', mcWSInfo.webServiceTokens__r.client_id__c);
		}*/

		if(mcWSInfo.webServiceTokens__c != null && mcWSInfo.webServiceTokens__r.DeveloperName == MDW_JWT_TOKEN_DEVNAME) {

			webService_tokens__mdt mcWSInfoToken = [SELECT url__c, method__c, content_type__c, username__c, password__c, 
			                                               grant_type__c, client_id__c, client_secret__c
			                                        FROM webService_tokens__mdt
			                                        WHERE DeveloperName = :MDW_JWT_TOKEN_DEVNAME
													WITH SECURITY_ENFORCED];

			String jwtToken = callGetJWTToken(mcWSInfoToken);
			httpRequest.setHeader('Authorization', 'Bearer ' + 'eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiJkZXZlbG9wIiwiaWF0IjoxNjQ4NzM0OTcwLCJpc3MiOiJkZXZlbG9wIiwiYXVkIjoicGljaGluY2hhIiwia2lkIjoiZGV2ZWxvcCIsImlkRXh0ZXJubyI6IjMzNjYyMjU1RiIsImlkSW50ZXJub1BlIjoiOGE0NGNjOTQ3ZmJmMjMxYjAxN2ZjMWUyMmI4MTVjNWMiLCJleHAiOjE2ODU3Mzg1NzB9.ECAYd374Te-Rql5WuezRh_4-zjC8W6nyMHf1aGY2jaJQUHXEwgqPx4Kh8FR-rE0_s6cEz4XgzIxKGKvpQOKE5pHmeMODH7GHBLXILbpRkXLFwZCwDFTu4B7MGARvaNojxiX6QPgGxENF53KYXx-QgYPcAoxTKkKFGJRL2CPSXTzyAEKnkY_DKODkH34DRXMqwKWgZYevbuEt-b1Kdkuy9lH-5tnAWSCecdxFXQTE5QgDcjEmHNSBnrAKkzQgaeof0F_8z0za1oK6prm0k6MbRFnHfrElZrfN_HYd99dTXvFeMVXbYMEEM8Vg_So5pr5Ya_MfIpb4kqZL80tMh25A8w');//httpRequest.setHeader('Authorization', 'Bearer ' + jwtToken);
			System.debug('--HEADER--'+httpRequest.getHeader('Authorization'));
		}

		if(mcWSInfo.Content_Type__c != null) {
			httpRequest.setHeader('content-type', mcWSInfo.Content_Type__c);
		}

		//Intervención para el cifrado en tránsito
		if(mcWSInfo.CustomSecurity__c) {
			String encryptedBody = SecurityUtils_CLS.encryptData(httpRequest.getBody());
			httpRequest.setBody(encryptedBody);
		}
		//Fin intervención cifrado en tránsito

		System.debug('httpRequest--> ' + httpRequest);
		return httpRequest;
	}

	public static String urlEncode(Map<String, String> vals) {
		String result = '';
		for(String thisKey : vals.keySet()) {
			result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(vals.get(thisKey), 'UTF-8') + '&';
		}
		return result.removeEnd('&');
	}

	private static String formatUrl(String url, Map<String, String> urlParams) {
		if(urlParams == null) {
			return url;
		}
		String retUrl = url;
		for(String key : urlParams.keySet()) {
			System.debug('key ' + key);
			String formattedKey = '{' + key.trim() + '}';
			System.debug('formattedKey ' + formattedKey + ' retUrl ' + retUrl);
			System.debug('contains ' + retUrl.contains(formattedKey));
			if(retUrl.contains(formattedKey)) {
				System.debug('formattedKey ' + urlParams.get(key));
				retUrl = retUrl.replace(formattedKey, urlParams.get(key));
			}
		}
		system.debug('url ' + retUrl);
		return retUrl;
	}

	/**
	* @description Retrieves a jwt token for MDW web services authorization
	* @author marcos.gimeno@vass.es | 16-06-2022 
	* @return String 
	**/
	public static String callGetJWTToken(webService_tokens__mdt mcWSInfoToken) {

		Service_Helper_CLS.TokenMDWResponse objToken = new Service_Helper_CLS.TokenMDWResponse();

		//JWTToken__c mcJWTToken = JWTToken__c.getOrgDefaults();

		HttpRequest httpReq = new HttpRequest();
		httpReq.setEndpoint(mcWSInfoToken.url__c);
		httpReq.setMethod(mcWSInfoToken.method__c);
		httpReq.setHeader('Content-Type', mcWSInfoToken.content_type__c);

		String payload = urlEncode(new Map<String, String>{
			'username' => mcWSInfoToken.username__c,
			'password' => mcWSInfoToken.password__c,
			'grant_type' => mcWSInfoToken.grant_type__c,
			'client_id' => mcWSInfoToken.client_id__c,
			'client_secret' => mcWSInfoToken.client_secret__c
		});
		httpReq.setBody(payload);

		System.debug('httpReq -->'+httpReq);

		Http http = new Http();
		HTTPResponse httpRes = http.send(httpReq);

		if(httpRes != null && httpRes.getStatusCode() == 200) {
			try {
				objToken = (Service_Helper_CLS.TokenMDWResponse)System.JSON.deserialize(httpRes.getBody(), Service_Helper_CLS.TokenMDWResponse.class);
				return objToken.access_token;
			} catch(Exception e) {
				System.debug(e);
				return null;
			}
		} else if(httpRes == null || (httpRes.getStatusCode() == 400 || httpRes.getStatusCode() == 403 || httpRes.getStatusCode() == 404 || httpRes.getStatusCode() == 405 || httpRes.getStatusCode() == 503)) {
			return null;
		}
		return null;
	}

	public class TokenMDWResponse {
		private String access_token;
		private String expires_in;
		private String refresh_expires_in;
		private String token_type;
		//private String not-before-policy;
		private String scope;
	}
}