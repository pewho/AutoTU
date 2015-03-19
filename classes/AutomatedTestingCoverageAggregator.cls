public class AutomatedTestingCoverageAggregator {
	private static ToolingAPI toolingAPI {
		get{
			if (Test.isRunningTest())
				return null;
			else
  				return new ToolingAPI(AutomatedTestingLogger.handleJob());
		}
	}
	@TestVisible
	private static Map<String, String> bagOfClassAndTriggerNames = AutomatedTestingCoverageAggregator.retrieveClassAndTriggerNames();
	private static Set<String> hasCoverageIDs = new Set<String>();

	public static String handleJob(){
		List<ToolingAPI.ApexCodeCoverageAggregate> covertures = retrieveCoverture();
		List<CodeCoverageWrapper> wrappers = new List<CodeCoverageWrapper>();
		
		for (ToolingAPI.ApexCodeCoverageAggregate ag : covertures){
			wrappers.add(new CodeCoverageWrapper(ag));
		}
		
		return AutomatedTestingCoverageAggregator.getAggregatedDataTable(wrappers);
	}


	/////////////////////////
	// COVERTURE RETRIEVE  //
	/////////////////////////
	private static List<ToolingAPI.ApexCodeCoverageAggregate> retrieveCoverture(){
		if(Test.isRunningTest()){
			return new List<ToolingAPI.ApexCodeCoverageAggregate>();
		} else {
			List<ToolingAPI.ApexCodeCoverageAggregate> accas = 
				((List<ToolingAPI.ApexCodeCoverageAggregate>)toolingAPI.query('SELECT ApexClassOrTriggerId, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate ORDER BY NumLinesUncovered DESC').records);
			if (accas == null)
				return new List<ToolingAPI.ApexCodeCoverageAggregate>();
			return accas;
		}
	}


	/////////////////////////////////////
	// RETRIEVE CLASS & TRIGGER NAMES  //
	/////////////////////////////////////
	private static Map<String, String> getClassNames(){
		List<ApexClass> cls = [SELECT Id, Name FROM ApexClass];
		Map<String, String> bagOfClsNames = new Map<String, String>();

		for (ApexClass clsMbr : cls){
			bagOfClsNames.put(((String)clsMbr.Id).toLowerCase().trim(), clsMbr.Name);
		}
		
		return bagOfClsNames;
	}

	private static Map<String, String> getTriggerNames(){
		List<ApexTrigger> triggers = [SELECT Id, Name FROM ApexTrigger];
		Map<String, String> bagOfTrgNames = new Map<String, String>();

		for (ApexTrigger trgMbr : triggers){
			bagOfTrgNames.put(((String)trgMbr.Id).toLowerCase().trim(), trgMbr.Name);
		}
		
		return bagOfTrgNames;
	}

	private static Map<String, String> retrieveClassAndTriggerNames(){
		Map<String, String> bagOfEntityNames = AutomatedTestingCoverageAggregator.getClassNames();
		bagOfEntityNames.putAll(AutomatedTestingCoverageAggregator.getTriggerNames());
		
		return bagOfEntityNames;
	}

	public static String getAggregatedDataTable(List<CodeCoverageWrapper> wrappers){
		String dataTable = getNoCoverageFoudTable();
		dataTable += '<br /><h2>Coverage Data</h2>';
		dataTable += '<table><thead>' +
			'<tr>' +
			'<td>Name</td>' +
			'<td>Is Trigger</td>' +
			'<td>Coverage</td>' +
			'<td>Coverage (%)</td>' +
			'<td>Status</td>' +
			'</tr>' +
			'</thead><tbody>';

		for (CodeCoverageWrapper wr : wrappers){
			dataTable += wr.getAggregatedData();
		}

		dataTable += '</tbody></table>';

		return dataTable;
	}

	private static String getNoCoverageFoudTable(){
		Map<String, String> classOrTriggerWithoutCoverage = new Map<String, String>();

		for (String triggerOrClassId : bagOfClassAndTriggerNames.keySet()){
			String type;
			if (triggerOrClassId.startswith('01q'))
				type = 'TRIGGER';
			else if (triggerOrClassId.startswith('01p'))
				type = 'CLASS';
			else
				type = 'UNKNOWN';
 
			if (!hasCoverageIDs.contains(triggerOrClassId)){
				classOrTriggerWithoutCoverage.put(
					bagOfClassAndTriggerNames.get(triggerOrClassId),
					type);
			}
		}	

		if (classOrTriggerWithoutCoverage.size() == 0){
			return '<h2>No Class or Trigger uncovered ! ;)</h2>';
		} else {
			String dataTable = '<h2>Class Or Trigger not covered by any test</h2>';
			dataTable += '<table><thead>' + 
			'<tr><td>Name</td><td>Type</td></tr>' +
			'</thead><tbody>'; 
			for (String classOrTriggerName : classOrTriggerWithoutCoverage.keySet()){
				dataTable += '<tr><td>' + classOrTriggerName + '</td><td>' + classOrTriggerWithoutCoverage.get(classOrTriggerName) + '</td></tr>';
			}
			dataTable += '</tbody></table><br />';

			return dataTable;
		}
	}

	/////////////////
	// Inner Class //
	/////////////////
	@TestVisible
	private class CodeCoverageWrapper{

		private String classOrTriggerId;
		private String classOrTriggerName;
		private Integer numLinesUncovered;
		private Integer numLinesCovered;
		private Integer numLinesTotal;
		private Decimal percentageCoverture;
		private String typeOfCoveredEntity;
		private String status;

		public CodeCoverageWrapper(ToolingAPI.ApexCodeCoverageAggregate ag){
			this.classOrTriggerId = ag.apexClassOrTriggerId.toLowerCase().trim();
			hasCoverageIDs.add(this.classOrTriggerId);
			this.numLinesCovered = ag.numLinesCovered != null ? ag.numLinesCovered : 0;
			this.numLinesUncovered = ag.numLinesUncovered != null ? ag.numLinesUncovered : 0;

			this.numLinesTotal = (this.numLinesCovered + this.numLinesUncovered) != 0 ? (this.numLinesCovered + this.numLinesUncovered) : 0;
			this.percentageCoverture = this.numLinesTotal == 0.0 ? 100.0 : ((Decimal)this.numLinesCovered / (Decimal)this.numLinesTotal) * 100.0;
			this.percentageCoverture = this.percentageCoverture.setScale(2);

			this.classOrTriggerName = AutomatedTestingCoverageAggregator.bagOfClassAndTriggerNames.get(this.classOrTriggerId);
			if (this.classOrTriggerName == null){
				this.classOrTriggerName = '<UnknownItem> ' +this.classOrTriggerId;
				System.debug('UKWN ::'+this.classOrTriggerId);
			}

			//type of element (01q > trigger, 01p > cls )
			if (this.classOrTriggerId.startswith('01q'))
				this.typeOfCoveredEntity = 'TRIGGER';
			else if (this.classOrTriggerId.startswith('01p'))
				this.typeOfCoveredEntity = 'CLASS';
			else
				this.typeOfCoveredEntity = 'UNKNOWN';

			//Status
			this.status = 'OK';
			if (this.percentageCoverture < 90.0)
				this.status = 'WARN';
			if (this.percentageCoverture < 75.0)
				this.status = 'CRITIQUE';
		}

		public String getAggregatedData(){
			return '<tr>' +
				'<td>'+this.classOrTriggerName+'</td>' +
				'<td>'+this.typeOfCoveredEntity+'</td>' +
				'<td>'+String.valueOf(this.numLinesCovered)+'/'+String.valueOf(this.numLinesTotal)+'</td>' +
				'<td>'+String.valueOf(this.percentageCoverture)+' %</td>' +
				'<td>'+this.status+'</td>' +
				'</tr>';
		}
	}
}