@isTest
private class AutomatedTestingJobQueuer_TEST {
	private static testMethod void test_job(){
		AutomatedTestingTestUtils.insertAutoTUCS();
		AutomatedTestJobQueuer.enqueueUnitTests();

		List<AutomatedTestingQueue__c> jobs =  [select id,
				   name,
				   AsyncId__c
			  from AutomatedTestingQueue__c
			 limit 5];
		System.assertEquals(1, jobs.size());
		System.assertNotEquals(null, jobs[0].AsyncId__c);
	}

	private static testMethod void test_schedulator(){
		AutomatedTestingTestUtils.insertAutoTUCS();
		List<AutomatedTestingQueue__c> jobs =  [select id,
				   name,
				   AsyncId__c
			from AutomatedTestingQueue__c
			limit 5];
		System.assertEquals(0, jobs.size());

		Test.startTest();

		Id jobId = System.schedule('enqueue TESTS', AutomatedTestJobQueuer.SCH_CRON_STR, new AutomatedTestJobQueuer());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id=:jobId];

		System.assertEquals(AutomatedTestJobQueuer.SCH_CRON_STR, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertNotEquals(null, ct.NextFireTime);

		Test.stopTest();
	}

	private static testMethod void test_createSchedulator(){
		AutomatedTestingTestUtils.insertAutoTUCS();
		Integer ct_number = [SELECT count() FROM CronTrigger];
		AutomatedTestJobQueuer.scheduleIt();
		Integer new_ct_number = [SELECT count() FROM CronTrigger];
		System.assertEquals(ct_number+1, new_ct_number);
	}
}