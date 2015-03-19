global with sharing class AutomatedTestJobQueuer implements schedulable {
	global static final String SCH_CRON_STR = AutoTUParams__c.getOrgDefaults().Cron_Queuer_Job__c;

	global void execute(SchedulableContext SC) {
		doExecute();
	}

	@future (callout=true)
	public static void doExecute(){
		enqueueUnitTests();
	}

	public static void scheduleIt(){
		AutomatedTestJobQueuer atj = new AutomatedTestJobQueuer();
		system.schedule('Enqueue Unit Tests 4 AM',SCH_CRON_STR,atj);
	}

	/* Allows us to externally enqueue our unit tests. For example,
		 whenever we check our code into source control, we could
		 run our unit tests.
	*/
	webservice static void enqueueUnitTests(){
		enqueueTests();
	}

	// Enqueue all classes beginning with "Test".
	public static void enqueueTests() {
		 /* The first thing you need to do is query the classes that contain
			 the unit tests you want executed.
		 */
		 ApexClass[] testClasses =
			[SELECT Id,
					Name
				FROM ApexClass];

		 Integer testClassCnt = testClasses != null ? testClasses.size() : 0;

		 system.debug('   enqueueTests::testClassCnt ' + testClassCnt);

		 if (testClassCnt > 0) {
			/*
				 Insertion of the ApexTestQueueItem causes the unit tests to be
				 executed. Since they're asynchronous, the apex async job id
				 needs to be stored somewhere so we can process the test results
				 when the job is complete.
			*/
			ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();

			for (ApexClass testClass : testClasses) {
					system.debug('   enqueueTests::testClass ' + testClass);

					queueItems.add(new ApexTestQueueItem(ApexClassId=testClass.Id));
			}
			if (!Test.isRunningTest())
				insert queueItems;

			// Get the job ID of the first queue item returned.
			String parentJobId;
			if (!Test.isRunningTest()){
				ApexTestQueueItem item =
					[SELECT ParentJobId
						 FROM ApexTestQueueItem
						WHERE Id=:queueItems[0].Id
						LIMIT 1];
				parentJobId = item.parentjobid;
			} else {
				parentjobid = 'TEST';
			}
			AutomatedTestingQueue__c atq = new AutomatedTestingQueue__c(
					AsyncId__c = parentjobid
			);

			insert atq;
		}
	}
}