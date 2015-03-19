@isTest
public class AutomatedTestingTestUtils {
	public static void insertAutoTUCS(){
		createCSParameters();
		createCSDests();
	}

	private static void createCSParameters(){
		AutoTUParams__c param = new AutoTUParams__c(
			Login_Url__c = 'https://test.salesforce.com',
			OAuth_Client_ID__c = 'CLIENT_ID_TOKEN',
			OAuth_Client_Secret__c = 'CLIENT_SECRET_TOKEN',
			username__c = 'test@test.com',
			password__c='testpass_token',
			Cron_Queuer_Job__c = '0 0 4 * * ?',
			Cron_Sender_Job__c = '0 0 6 * * ?'
			);
		insert param;
	}

	private static void createCSDests(){
		AutoTUDest__c dest1 = new AutoTUDest__c(Name='1', destinataire__c=Userinfo.getUserId());
		insert dest1;
	}

	public class LoggerCalloutMock implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest req){
			HttpResponse resp = new HttpResponse();
			resp.setHeader('Content-Type', 'application/json');
			resp.setBody('{"access_token":"testing"}');
			return resp;
		}
	}
}