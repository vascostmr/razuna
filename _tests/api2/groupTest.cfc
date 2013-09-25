<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	<!--- Get one group --->
	<cffunction name="testGetOne">
		<cfscript>
			GRP_ID = "1B2A68D9-3280-4EDE-9D4DBF81B9767510";
			qGroup = CUT.getone(API_KEY,GRP_ID);
			if (qGroup.recordCount NEQ 0){
				message ="success";
				assertEquals("success",message);	
			}
			else {
				fail("No record found for GROUP ID :: " & GRP_ID);
			}
		</cfscript>
	</cffunction>
	
	<!--- get all group --->
	<cffunction name="testGetAll">
		<cfscript>
			qAllGroup = CUT.getall(API_KEY);
			if (qAllGroup.recordCount NEQ 0){
				message ="success";
				assertEquals("success",message);	
			}
			else {
				fail("No records found");
			}
		</cfscript>
	</cffunction>
	
	<!--- get users of group --->
	<cffunction name="testGetUsersOfGroups">
		<cfscript>
			GRP_ID = "1B2A68D9-3280-4EDE-9D4DBF81B9767510";
			qAllUsers = CUT.getusersofgroups(API_KEY,GRP_ID);
			if (qAllUsers.recordCount NEQ 0){
				message ="success";
				assertEquals("success",message);	
			}
			else {
				fail("No records found for GROUP ID ::" & GRP_ID);
			}
		</cfscript>
	</cffunction>
	
	<!--- add new group --->
	<cffunction name="testAddGroup">
		<cfscript>
			GRP_NAME = "mygroup";
			qAdd = CUT.add(API_KEY,GRP_NAME);
			if (structKeyExists(qAdd,'MESSAGE')){
				assertEquals("Group has been added successfully",qAdd.message);	
			}
			else {
				fail("Group already exists");
			}
		</cfscript>
	</cffunction>
	
	<!--- update group --->
	<cffunction name="testUpdateGroup">
		<cfscript>
			GRP_ID = "1B2A68D9-3280-4EDE-9D4DBF81B9767510";
			GRP_NAME = "samplegroup";
			qUpdate = CUT.update(API_KEY,GRP_NAME,GRP_ID);
			if (structKeyExists(qUpdate,'MESSAGE')){
				assertEquals("Group has been updated successfully",qUpdate.message);	
			}
			else {
				fail("Group does not updated successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- delete group --->
	<cffunction name="testDeleteGroup">
		<cfscript>
			GRP_ID = "B9F33A7D-1FAF-4628-9457E7C6021E29AD";
			qDelete = CUT.delete(API_KEY,GRP_ID);
			if (structKeyExists(qDelete,'MESSAGE')){
				assertEquals("Group has been removed successfully",qDelete.message);	
			}
			else {
				fail("Group does not removed successfully");
			}
		</cfscript>
	</cffunction>
	
	
<cfscript>
	// ------------------------ IMPLICIT ------------------------ //

	/**
	* this will run before every single test in this test case
	*/
	function setUp(){
		// initialise component under test
		CUT = new global.api2.group();
		API_KEY = "dummy_api_key";
	}

	/**
	* this will run after every single test in this test case
	*/
	function tearDown(){
		// destroy test data
			
	}

	/**
	* this will run once after initialization and before setUp()
	*/
	function beforeTests(){}

	/**
	* this will run once after all tests have been run
	*/
	function afterTests(){}


	
</cfscript>
</cfcomponent>