public with sharing class FieldCallouts {

	
	  public class FieldRes extends ServiceVirtual_CLS {
	
		public FieldRes(String mdtName) {
		  this.mdtName = mdtName;
		  //undefinedResponseBody = new Object();
		}
	
		public override void manageErrorStatus ( HTTPResponse response ) {
	
		  System.debug('@Error Response: ' + response.getBody() );
		  ServiceException serviceException = new ServiceException();
		  serviceException.status = response.getStatus();
		  serviceException.statusCode = response.getStatusCode();
		  serviceException.requestBody = this.requestBodyJSON;
		  serviceException.responseBody = response.getBody();
		  serviceException.webServiceName = this.mdtName;
	
		  String message = 'Ha habido un problema en la llamada al servicio HOST: ' + response.getStatusCode() + ' not expected!';
  
		  serviceException.setMessage( message );
		  system.debug('@ServiceExceptionMessage' + message);
		  system.debug('@ServiceException' + serviceException);
		  throw serviceException;
	
		}
	  }
}