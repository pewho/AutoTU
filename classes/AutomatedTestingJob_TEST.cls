@isTest
private class AutomatedTestingJob_TEST {
	private static testMethod void test_job(){
		AutomatedTestingTestUtils.insertAutoTUCS();

		Test.startTest();
		AutomatedTestingJob.getMailResults();	
		Test.stopTest();
		System.assert(True); //Coverage Only, cannot launch test in test context
	}

	private static testMethod void test_schedulator(){
		AutomatedTestingTestUtils.insertAutoTUCS();

		Test.startTest();

		Id jobId = System.schedule('enqueue TESTS', AutomatedTestingJob.SCH_CRON_STR, new AutomatedTestingJob());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id=:jobId];

		System.assertEquals(AutomatedTestingJob.SCH_CRON_STR, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertNotEquals(null, ct.NextFireTime);

		Test.stopTest();
	}

	private static testMethod void test_createSchedulator(){
		AutomatedTestingTestUtils.insertAutoTUCS();
		
		Integer ct_number = [SELECT count() FROM CronTrigger];
		AutomatedTestingJob.scheduleIt();
		Integer new_ct_number = [SELECT count() FROM CronTrigger];
		System.assertEquals(ct_number+1, new_ct_number);
	}

	private static testMethod void test_logger(){
		AutomatedTestingTestUtils.insertAutoTUCS();
		Test.setMock(HttpCalloutMock.class, new AutomatedTestingTestUtils.LoggerCalloutMock());
		
		Test.startTest();
		String result = AutomatedTestingLogger.handleJob();
		System.assertEquals('testing', result);
		Test.stopTest();	
	}	

	private static testMethod void test_CodeCoverageWrapperConstruction(){
		List<String> clsIds = new List<String>(AutomatedTestingCoverageAggregator.bagOfClassAndTriggerNames.keyset());
		
		ToolingAPI.ApexCodeCoverageAggregate ag1 = new ToolingAPI.ApexCodeCoverageAggregate();
		ag1.ApexClassOrTriggerId = clsIds.get(0);
		ag1.NumLinesCovered = 0;
		ag1.NumLinesUncovered = 0;
			
		ToolingAPI.ApexCodeCoverageAggregate ag2 = new ToolingAPI.ApexCodeCoverageAggregate();
		ag2.ApexClassOrTriggerId = clsIds.get(1);
		ag2.NumLinesUncovered = 1;
		ag2.NumLinesCovered = 32;

		try{
			new AutomatedTestingCoverageAggregator.CodeCoverageWrapper(ag1);
			new AutomatedTestingCoverageAggregator.CodeCoverageWrapper(ag2);
		} catch (Exception e){
			System.assert(false, e.getMessage());
		}
	}
}