<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	
	<!--- Get one label --->
	<cffunction name="testGetLabel">
		<cfscript>
			LABEL_ID = "08FC43D60B4646BA9D8539F276B4FB90";
			qLabel = CUT.getlabel(API_KEY,LABEL_ID);
			if (structKeyExists(qLabel, "label_text")){
				assertEquals( "Test label", qLabel.label_text);	
			}
			else {
				fail("No record found for LABEL ID :: " & LABEL_ID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Add label --->
	<cffunction name="testAddlabel" >
		<cfscript>
			LABEL_ID = 0;
			LABEL_TEXT = "set label value";
			qSetlabel = CUT.setlabel(API_KEY,LABEL_ID,label_text);
			if (structKeyExists(qSetlabel, "message")){
				assertEquals( "Label successfully added or updated", qSetlabel.message);	
			}
			else {
				fail("The label does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Update label --->
	<cffunction name="testUpdatelabel" >
		<cfscript>
			LABEL_ID = "08FC43D60B4646BA9D8539F276B4FB90";
			LABEL_TEXT = "Update label value";
			qUpdatelabel = CUT.setlabel(API_KEY,LABEL_ID,label_text);
			if (structKeyExists(qUpdatelabel, "message")){
				assertEquals( "Label successfully added or updated", qUpdatelabel.message);	
			}
			else {
				fail("The label does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Get all label --->
	<cffunction name="testGetAllLabel">
		<cfscript>
			qAllLabel = CUT.getall(API_KEY);
			if (qAllLabel.recordCount NEQ 0){
				message = "success";
				assertEquals( "success", message);	
			}
			else {
				fail("No records found");
			} 
		</cfscript>
	</cffunction>
	
	<!--- Set asset label --->
	<cffunction name="testSetassetlabel" >
		<cfscript>
			LABEL_ID = "08FC43D60B4646BA9D8539F276B4FB90";
			ASSET_ID = "01796D62A2A3409BB327142798C7A032";
			ASSET_TYPE = "aud";
			APPEND = "false";
			qSetassetlabel = CUT.setassetlabel(API_KEY,LABEL_ID,ASSET_ID,ASSET_TYPE,APPEND);
			if (structKeyExists(qSetassetlabel, "message")){
				assertEquals( "Label(s) added to asset successfully", qSetassetlabel.message);	
			}
			else {
				fail("The label does not added to asset successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Get label of asset --->
	<cffunction name="testGetlabelofasset" >
		<cfscript>
			ASSET_ID = "8AF522125A584C06B897C138316D253B";
			ASSET_TYPE = "img";
			qGetlabelofasset = CUT.getlabelofasset(API_KEY,ASSET_ID,ASSET_TYPE);
			if (qGetlabelofasset.recordCount NEQ 0){
				message ="success";
				assertEquals("success",message);	
			}
			else {
				fail("No record found for ASSET ID :: " & ASSET_ID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get label from asset --->
	<cffunction name="testGetassetoflabel" >
		<cfscript>
			session.rowmaxpage = 25;
			session.sortby = "name";
			LABEL_ID = "08FC43D60B4646BA9D8539F276B4FB90";
			qGetassetoflabel = CUT.getassetoflabel(API_KEY,LABEL_ID);
			if (qGetassetoflabel.recordCount NEQ 0){
				message ="success";
				assertEquals("success",message);	
			}
			else {
				fail("No record found for LABEL ID :: " & LABEL_ID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Remove asset label --->
	<cffunction name="testRemoveassetlabel" >
		<cfscript>
			LABEL_ID = "08FC43D60B4646BA9D8539F276B4FB90";
			ASSET_ID = "149E0F769428440AAF5FFBDA28E6F974";
			qRemoveassetlabel = CUT.removeassetlabel(API_KEY,LABEL_ID,ASSET_ID);
			if (structKeyExists(qRemoveassetlabel, "message")){
				assertEquals( "Label(s) removed from asset successfully", qRemoveassetlabel.message);	
			}
			else {
				fail("The label does not removed from asset successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Remove label --->
	<cffunction name="testRemovelabel" >
		<cfscript>
			LABEL_ID = "08FC43D60B4646BA9D8539F276B4FB90";
			qRemove = CUT.remove(API_KEY,LABEL_ID);
			if (structKeyExists(qRemove, "message")){
				assertEquals( "Label(s) successfully removed", qRemove.message);	
			}
			else {
				fail("The label does not removed successfully");
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
		CUT = new global.api2.label();
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