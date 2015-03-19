global with sharing class AutomatedTestingJob implements Schedulable {
	global static final String SCH_CRON_STR = AutoTUParams__c.getOrgDefaults().Cron_Sender_Job__c;
	global static String[] TO_ADRESSES;
	private static String coverageDatas;
	
	private static String[] retrieveUserIds(){
		Map<String, AutoTUDest__c> dests = AutoTUDest__c.getAll();
		List<String> userIds = new List<String>();
		for (AutoTUDest__c dest : dests.values()){
			userIds.add(dest.destinataire__c);
		}
		return userIds;
	} 

	global void execute(SchedulableContext SC) {
		

		doExecute();
	}

	// Have to use a future method so the email will be sent out.
	@future(callout=true)
	public static void doExecute(){
		TO_ADRESSES = retrieveUserIds();
		coverageDatas = AutomatedTestingCoverageAggregator.handleJob();
		processAsyncResults();
	}

	webservice static void getMailResults(){
		doExecute();
	}

	/*
		Schedule String Format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	*/
	public static void scheduleIt(){
		AutomatedTestingJob atj = new AutomatedTestingJob();

		system.schedule('Process Queued Unit Tests Every 6AM',SCH_CRON_STR,atj);
	}

	public static void processAsyncResults(){
		List<AutomatedTestingQueue__c> queuedTests =
		   [select id,
				   name,
				   AsyncId__c
			  from AutomatedTestingQueue__c
			 limit 5];

		if (Test.isRunningTest() || (queuedTests != null && queuedTests.size() > 0)){
			Set<Id> AsyncIds = new Set<Id>();

			for (AutomatedTestingQueue__c queuedJob : queuedTests){
				 AsyncIds.add(queuedJob.AsyncId__c);
			}

			List<ApexTestQueueItem> queuedItems = checkClassStatus(AsyncIds);

			Map<Id, List<ApexTestQueueItem>> groupedTestsByJob = new Map<Id, List<ApexTestQueueItem>>();

			for (ApexTestQueueItem atqi : queuedItems){
				 if (groupedTestsByJob.containsKey(atqi.ParentJobId) == true){
					 List<ApexTestQueueItem> groupedTests = groupedTestsByJob.get(atqi.ParentJobId);
					 groupedTests.add(atqi);
				 }
				 else{
					List<ApexTestQueueItem> groupedTests = new List<ApexTestQueueItem>();
					groupedTests.add(atqi);
					groupedTestsByJob.put(atqi.ParentJobId, groupedTests);
				}
			}

			Set<Id> completedAsyncIds = getCompletedAsyncJobsIds(groupedTestsByJob);

			if (Test.isRunningTest() || completedAsyncIds != null && completedAsyncIds.size() > 0){

				List<ApexTestResult> testResults = checkMethodStatus(completedAsyncIds);

				Map<Id, List<ApexTestResult>> groupedTestResultsByJob = new Map<Id, List<ApexTestResult>>();


				for (ApexTestResult testResult : testResults){
					if (groupedTestResultsByJob.containsKey(testResult.AsyncApexJobId)){
						List<ApexTestResult> groupedTestsResults = groupedTestResultsByJob.get(testResult.AsyncApexJobId);
						groupedTestsResults.add(testResult);
					}
					else{
						List<ApexTestResult> groupedTestsResults = new List<ApexTestResult>();
						groupedTestsResults.add(testResult);

						groupedTestResultsByJob.put(testResult.AsyncApexJobId, groupedTestsResults );
					}
				}

				List<AutomatedTestingQueue__c> queuedTestsToDelete = new List<AutomatedTestingQueue__c>();

				for (List<ApexTestResult> jobTestResults : groupedTestResultsByJob.values()){
					sendTestResultEmail(jobTestResults);
				}

				for (AutomatedTestingQueue__c queuedTest : queuedTests){
					for (Id completedAsyncId : completedAsyncIds){
						if (queuedTest.AsyncId__c == completedAsyncId){
							queuedTestsToDelete.add(queuedTest);
							break;
						}
					}
					if (groupedTestsByJob.containsKey(queuedTest.asyncId__c) == false){
						queuedTestsToDelete.add(queuedTest);
					}
				}

				if (queuedTestsToDelete.size() > 0){
					delete queuedTestsToDelete;
				}
			}
		}
	}

	public static Set<Id> getCompletedAsyncJobsIds(Map<Id, List<ApexTestQueueItem>> groupedTestsByJob){
		Set<Id> completedAsyncJobIds = new Set<Id>();

		for (List<ApexTestQueueItem> jobTests : groupedTestsByJob.values()){
			if (jobTests == null || jobTests.size() == 0){
				continue;
			}

			Boolean allCompleted = true;

			for (ApexTestQueueItem queuedTest : jobTests){
				if (queuedTest.Status != 'Completed' && queuedTest.Status != 'Failed' && queuedTest.Status != 'Aborted'){
					allCompleted = false;
					break;
				}
			}

			if (allCompleted == true){
				completedAsyncJobIds.add(jobTests[0].ParentJobId);
			}
		}

		return completedAsyncJobIds;
	}

	@TestVisible
	private static void sendTestResultEmail(List<ApexTestResult> jobTestResults){
		system.debug(' In sendTestResultEmail');
		List<Messaging.Email> emails = new List<Messaging.Email>();

		for (Id userId : TO_ADRESSES){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			mail.setTargetObjectId(userId);

			String emailSubject = 'Dev Unit Test Results ' + String.valueOf(Date.today());

			mail.setSubject(emailSubject);
			mail.setSaveAsActivity(false);

			String testResultEmailbody = getTestResultHtmlEmailBody(jobTestResults);

			mail.setHtmlBody(testResultEmailbody);
			emails.add(mail);
			System.debug('Add one Email');
		}
		Messaging.sendEmail(emails);

		system.debug(' sent test results email');
	}

	@TestVisible
	private static String getTestResultHtmlEmailBody(List<ApexTestResult> jobTestResults){
		system.debug(' In getTestResultHtmlEmailBody');
		
		List<ApexTestResult> successTests = new List<ApexTestResult>();
		List<ApexTestResult> failedTests = new List<ApexTestResult>();

		for (ApexTestResult jobTestResult : jobTestResults){
			if (jobTestResult.Outcome == 'Pass'){
				successTests.add(jobTestResult);
			}
			else{
				failedTests.add(jobTestResult);
			}
		}

		Integer numTestsRun = successTests.size() + failedTests.size();
		Integer numFailures = failedTests.size();
		Integer successNum = numTestsRun - numFailures;

		if (successNum < 0){
			successNum = 0;
		}

		String testResultBody = '';

		testResultBody += '<table><tbody><tr class="firstTr"><td>Tests Run:&nbsp;</td><td style="text-align: right;">' + numTestsRun + '</td></tr>';
		testResultBody += '<tr><td>Failure Count:&nbsp;</td><td style="text-align: right;">' + numFailures + '</td></tr>';
		testResultBody += '<tr><td>Success Count:&nbsp;</td><td style="text-align: right;">' + successNum + '</td></tr></tbody></table>';

		if (numFailures > 0){

			testResultBody += '<div style="margin: 5px 0px; font-weight: bold;">Test Failures</div>';

			testResultBody += '<table>';

			testResultBody += '<tr>';
			testResultBody += '<th style="text-align: left; padding-left: 5px;">Test Class</th>';
			testResultBody += '<th style="text-align: left; padding-left: 5px;">Unit Test</th>';
			testResultBody += '<th style="text-align: left; padding-left: 5px;">Message</th>';
			testResultBody += '<th style="text-align: left; padding-left: 5px;">Stack Trace</th>';
			testResultBody += '<th style="text-align: left; padding-left: 5px;">Time (Ms)</th>';
			testResultBody += '</tr>';

			for (ApexTestResult testFailure : failedTests){
				testResultBody += '<tr>';

				testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexClass.Name +'</td>';
				testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.MethodName +'</td>';
				testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.message +'</td>';
				testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.stackTrace +'</td>';
				testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexLog.DurationMilliseconds +'</td>';
				//testResultBody += '<td style="vertical-align: top;">' + testFailure.type_x +'';

				testResultBody += '</tr>';
			}

			testResultBody += '</table>';
		}
		testResultBody += coverageDatas;

		return testResultBody;
	}


	// Get the status and pass rate for each class

	// whose tests were run by the job.

	// that correspond to the specified job ID.

	public static List<ApexTestQueueItem> checkClassStatus(Set<ID> jobIds) {
		ApexTestQueueItem[] items;
		if (!Test.isRunningTest()) {
			items = [SELECT ApexClass.Name,
					   Status,
					   ExtendedStatus,
					   ParentJobId
				FROM ApexTestQueueItem
				WHERE ParentJobId in :jobIds];
		} else {
			items = new List<ApexTestQueueItem>();
		}

		for (ApexTestQueueItem item : items) {
			String extStatus = item.extendedstatus == null ? '' : item.extendedStatus;
			System.debug(item.ApexClass.Name + ': ' + item.Status + extStatus);
		}

		return items;
	}

	// Get the result for each test method that was executed.

	public static List<ApexTestResult> checkMethodStatus(Set<ID> jobIds) {
		ApexTestResult[] results;

		if (!Test.isRunningTest()){
			results = [SELECT Outcome,
					   MethodName,
					   Message,
					   StackTrace,
					   AsyncApexJobId,
					   ApexClass.Name,
					   ApexClass.Body,
					   ApexClass.LengthWithoutComments,
					   ApexClass.NamespacePrefix,
					   ApexClass.Status,
					   ApexLogId,
					   ApexLog.DurationMilliseconds,
					   ApexLog.Operation,
					   ApexLog.Request,
					   ApexLog.Status,
					   ApexLog.Location,
					   ApexLog.Application
				FROM ApexTestResult
				WHERE AsyncApexJobId in :jobIds];
		} else {
			results = new List<ApexTestResult>{ 
				new ApexTestResult(MethodName='Test', Message=null,Outcome='Pass'),
				new ApexTestResult(MethodName='TestFail', Message='Error', Outcome='Failed')
			};
		}


		for (ApexTestResult atr : results) {
			System.debug(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
			if (atr.message != null) {
				System.debug(atr.Message + '\n at ' + atr.StackTrace);
			}
		}

		return results;
	}
}