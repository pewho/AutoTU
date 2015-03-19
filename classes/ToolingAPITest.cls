/**
 * Copyright (c) 2013, Apex Tooling API
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Apex Tooling API, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Some initial tests to get things started!
 **/
@IsTest
private class ToolingAPITest
{
	static testmethod void testCoverTypes(){
   		new ToolingAPI.AggregateExpressionResultColumnMetadata();
		new ToolingAPI.AllowedWorkitemAction();
		new ToolingAPI.ApexClassMetadata();
		new ToolingAPI.ApexCodeCoverage();
		new ToolingAPI.ApexCodeCoverageAggregate();
		new ToolingAPI.ApexComponent();
		new ToolingAPI.ApexExecutionOverlayAction();
		new ToolingAPI.ApexLog();
		new ToolingAPI.ApexOrgWideCoverage();
		new ToolingAPI.ApexResult();
		new ToolingAPI.ApexTestResult();
		new ToolingAPI.ApexTestQueueItem();
		new ToolingAPI.ApexPage();
		new ToolingAPI.ApexComponentMember();
		new ToolingAPI.ApexExecutionOverlayResult();
		new ToolingAPI.ApexPageMember();
		new ToolingAPI.ApiFault();
		new ToolingAPI.ApiQueryFault();
		new ToolingAPI.Attribute();
		new ToolingAPI.AttributeDefinition();
		new ToolingAPI.AsyncApexJob();
		new ToolingAPI.BooleanValue();
		new ToolingAPI.ChildRelationship();
		new ToolingAPI.ComplexQueryResultColumnMetadata();
		new ToolingAPI.ContainerAsyncRequest();
		new ToolingAPI.Coverage();
		new ToolingAPI.CustomFieldMetadata();
		new ToolingAPI.DescribeColorResult();
		new ToolingAPI.DescribeColumn();
		new ToolingAPI.DescribeGlobalResult();
		new ToolingAPI.DescribeGlobalSObjectResult();
		new ToolingAPI.DescribeIconResult();
		new ToolingAPI.DescribeLayoutButton();
		new ToolingAPI.DescribeLayoutItem();
		new ToolingAPI.DescribeLayoutComponent();
		new ToolingAPI.DescribeLayoutRow();
		new ToolingAPI.DescribeLayoutSection();
		new ToolingAPI.DescribeSObjectResult();
		new ToolingAPI.DescribeWorkitemActionResult();
		new ToolingAPI.Error();
		new ToolingAPI.ErrorResponse();
		new ToolingAPI.ExecuteAnonymousResult();
		new ToolingAPI.ExternalConstructor();
		new ToolingAPI.ExternalMethod();
		new ToolingAPI.ExternalReference();
		new ToolingAPI.ExternalSymbol();
		new ToolingAPI.Field();
		new ToolingAPI.FilterItem();
		new ToolingAPI.HeapAddress();
		new ToolingAPI.HeapDump();
		new ToolingAPI.InvalidateSessionsResult();
		new ToolingAPI.LogInfo();
		new ToolingAPI.ListValue();
		new ToolingAPI.MapEntry();
		new ToolingAPI.MapValue();
		new ToolingAPI.Metadata();
		new ToolingAPI.MetadataContainer();
		new ToolingAPI.MetadataContainerMember();
		new ToolingAPI.Method();
		new ToolingAPI.NumberValue();
		new ToolingAPI.PackageVersion();
		new ToolingAPI.Parameter();
		new ToolingAPI.Picklist();
		new ToolingAPI.PicklistEntry();
		new ToolingAPI.Position();
		new ToolingAPI.PrimitiveQueryResultColumnMetadata();
		new ToolingAPI.ProcessResult();
		new ToolingAPI.QueryResult();
		new ToolingAPI.QueryResultColumnMetadata();
		new ToolingAPI.QueryResultMetadata();
		new ToolingAPI.RecordTypeInfo();
		new ToolingAPI.RecordTypePicklist();
		new ToolingAPI.SaveResult();
		new ToolingAPI.SetValue();
		new ToolingAPI.SOQLResult();
		new ToolingAPI.StateValue();
		new ToolingAPI.StringValue();
		new ToolingAPI.SymbolTable();
		new ToolingAPI.ToolingAPIException();
		new ToolingAPI.TypeExtent();
		new ToolingAPI.UpsertResult();
		new ToolingAPI.UserPreference();
		new ToolingAPI.User_x();
	}
}