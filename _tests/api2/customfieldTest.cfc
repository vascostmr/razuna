<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	
	<!--- Set custom field  --->
	<cffunction name="testSetCustomfield">
		<cfscript>
			FIELD_TEXT = "Test custom field";
			FIELD_TYPE = "text";
			qSetCustomfield = CUT.setfield(API_KEY,FIELD_TEXT,FIELD_TYPE);
			if(structKeyExists(qSetCustomfield,"MESSAGE")){
				assertEquals( "Custom field successfully added", qSetCustomfield.MESSAGE);
			}
			else {
				fail("The Custom field does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Set Custom field value --->
	<cffunction name="testSetCustomfieldValue">
		<cfscript>
			ASSETID = "8AF522125A584C06B897C138316D253B";
			FIELD_VALUES = '[["DF8D3A0C-8CB2-44B2-AB38A64FD7FD61FE","Test value"]]';
			qSetCustomfieldValue = CUT.setfieldvalue(API_KEY,ASSETID,FIELD_VALUES);
			if(structKeyExists(qSetCustomfieldValue,"MESSAGE")){
				assertEquals( "Custom field values successfully added", qSetCustomfieldValue.MESSAGE);
			}
			else {
				fail("The Custom field value does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Set Custom field bulk values --->
	<cffunction name="testSetCustomfieldBulkValues">
		<cfscript>
			FIELD_VALUES = '[["01796D62A2A3409BB327142798C7A032",[["ADFA6E8E-4A8C-416E-AC8B45F5BC905A1A","Test value1"],["DF8D3A0C-8CB2-44B2-AB38A64FD7FD61FE","Test value2"]]],["149E0F769428440AAF5FFBDA28E6F974",[["ADFA6E8E-4A8C-416E-AC8B45F5BC905A1A","Test value3"],["DF8D3A0C-8CB2-44B2-AB38A64FD7FD61FE","Test value4"]]]]';
			qSetCustomfieldValue = CUT.setfieldvaluebulk(API_KEY,FIELD_VALUES);
			if(structKeyExists(qSetCustomfieldValue,"MESSAGE")){
				assertEquals( "Custom field values successfully added", qSetCustomfieldValue.MESSAGE);
			}
			else {
				fail("The Custom field value does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- get custom fields from asset --->
	<cffunction name="testGetfieldsofasset">
		<cfscript>
			ASSET_ID = "8AF522125A584C06B897C138316D253B";
			qGetfieldsofasset = CUT.getfieldsofasset(API_KEY,ASSET_ID);
			if(structKeyExists(qGetfieldsofasset,"FILE_ID")){
				assertEquals( "8AF522125A584C06B897C138316D253B", qGetfieldsofasset.file_id);
			}
			else {
				fail("No record found for ASSET ID :: " & ASSET_ID);
			}
		</cfscript>
	</cffunction>
		
	<!--- Get all custom fields --->
	<cffunction name="testGetCustomfields">
		<cfscript>
			qGetCustomfields = CUT.getall(API_KEY);
			if (qGetCustomfields.recordCount NEQ 0){
			 	message = "success";
			 	assertEquals( "success", message);
			}
			else {
				fail("No record found for API KEY :: " & API_KEY);
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
		CUT = new global.api2.customfield();
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