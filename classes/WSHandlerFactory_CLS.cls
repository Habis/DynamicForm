public with sharing class WSHandlerFactory_CLS { 

	public WSHandlerFactory_CLS (){
	//EventLoggerBase.getInstance().setLogType(WSHandlerFactory_CLS.class.getName());
	}
	 
	 public static IWSHandler_CLS createWSHandler(String action) {
		 IWSHandler_CLS handler = getWSHandler(action);
		 if (handler == null){
			 System.debug('Error handler=null in createWSHandler('+action+')');
			 //throw new  OwnException(System.Label.MYLABEL + ' ' + action);            
		 }
			   
		 return handler;
	 }
 
	 /** 
	 * Dynamically get the appropiate handler based on the Type of the action.
	 *               Handler's name has to follow this format:
	 *               <ObjectName>WSHandler, the dispatcher has to be named
	 *               Custom<NAME>WSHandler. Take into account that limit for class name size is 40 char!
	 * @param strActionId        String Id for the action for which to create the WSHandler
	 * @return ISignatureHandler A handler if it exists or null if it doesn't.
	 */
	 private static IWSHandler_CLS getWSHandler(String strActionId) {
		 
		 try {
		 
			 String handlerTypeName = null;
		 
			 handlerTypeName = 'Custom' + strActionId + 'WSHandler';
			 Type obType = Type.forName(handlerTypeName);
			 System.debug('objType:'+obType);
			 
			 IWSHandler_CLS dispatcher = (obType == null) ? null : (IWSHandler_CLS)obType.newInstance();
			 
			 return dispatcher;
			 
		 } catch (Exception e) {
			 System.debug('getWSHandler: '+e.getMessage() + '\n' + e.getStackTraceString());
			 //EventLoggerBase.getInstance().commitLog(e);  // Logs the Exception in EventLogger__c custom object
			 return null;
		 }
	 }
	 
 }