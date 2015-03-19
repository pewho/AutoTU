public class AutomatedTestingLogger {
	private static final AutoTUParams__c params = AutoTUParams__c.getOrgDefaults();
	private static final String CLIENT_ID = params.OAuth_Client_ID__c;
	private static final String CLIENT_SECRET = params.OAuth_Client_Secret__c;
	private static final String CLIENT_LOGIN = params.username__c;
	private static final String CLIENT_PASSWORD = params.password__c;
	private static final String BASE_TOKEN_URL = params.Login_Url__c;
 
	public static String handleJob(){
		return requestSessionId();
	}   

	private static String requestSessionId(){
		HttpRequest req = new HttpRequest();
		req.setEndpoint(BASE_TOKEN_URL + '/services/oauth2/token');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setBody('grant_type=password&client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&username='+CLIENT_LOGIN+'&password='+CLIENT_PASSWORD);
		
		Http http = new Http();
		HttpResponse resp = http.send(req);

		Map<String, Object> mapBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

		return (String)mapBody.get('access_token');	
	}
}