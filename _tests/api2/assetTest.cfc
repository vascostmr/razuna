<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	
	<!--- Get an asset --->
	<cffunction name="testGetAsset">
		<cfscript>
			ASSETID = "8AF522125A584C06B897C138316D253B";
			ASSETTYPE = "img";
			qGetasset = CUT.getasset(API_KEY,ASSETID,ASSETTYPE);
			if (structKeyExists(qGetasset, "responsecode")){
				assertEquals( "0", qGetasset.responsecode);	
			}
			else {
				fail("No record found for ASSET ID :: " & ASSETID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Update metadata --->
	<cffunction name="testSetmetadata">
		<cfscript>
			ASSETID = "8AF522125A584C06B897C138316D253B";
			ASSETTYPE = "img";
			ASSETMETADATA = '[["img_description","Updated description"],["img_keywords","image keyword"],["creator","Test creator"],["title","Test title"],["category","Test category"],["location","Test location"],["city","Test city"],["country","Test country"]]';
			qUpdate = CUT.setmetadata(API_KEY,ASSETID,ASSETTYPE,ASSETMETADATA);
			if (structKeyExists(qUpdate, "MESSAGE")){
				assertEquals( "Metadata successfully stored", qUpdate.message);	
			}
			else {
				fail("Metadata does not stored successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Get metadata --->
	<cffunction name="testGetmetadata">
		<cfscript>
			ASSETID = "8AF522125A584C06B897C138316D253B";
			ASSETTYPE = "img";
			ASSETMETADATA = "creator,title,category,location,city,country";
			qGetmetadata = CUT.getmetadata(API_KEY,ASSETID,ASSETTYPE,ASSETMETADATA);
			if (qGetmetadata.recordCount NEQ 0){
				message = "success";
				assertEquals( "success",message);	
			}
			else {
				fail("No record found for ASSET ID ::" & ASSETID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get renditions --->
	<cffunction name="testGetrenditions">
		<cfscript>
			ASSETID = "EDDA6A631EEA4B0DA1449679AE07CAC9";
			ASSETTYPE = "img";
			qGetrenditions = CUT.getrenditions(API_KEY,ASSETID,ASSETTYPE);
			if (structKeyExists(qGetrenditions,"id")){
				assertEquals( "EDDA6A631EEA4B0DA1449679AE07CAC9",qGetrenditions.id);	
			}
			else {
				fail("No record found for ASSET ID ::" & ASSETID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Move asset --->
	<cffunction name="testMove">
		<cfscript>
			ASSETID = "CF65C61D386047A393F5478F61527ECC";
			DESTINATION_FOLDER = "08F1A421827F4A3DAEDD0EA63F048A94";
			SOURCE_FOLDER = "A9D8939DFF774C94886882175BB28199";
			qMove = CUT.move(API_KEY,ASSETID,DESTINATION_FOLDER,SOURCE_FOLDER);
			if (structKeyExists(qMove,"message")){
				assertEquals("Asset(s) have been moved successfully",qMove.message);	
			}
			else {
				fail("Asset(s) does not moved successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Remove asset --->
	<cffunction name="testRemove">
		<cfscript>
			ASSETID = "CF65C61D386047A393F5478F61527ECC";
			qRemove = CUT.remove(API_KEY,ASSETID);
			if (structKeyExists(qRemove,"message")){
				assertEquals("Asset(s) have been removed successfully",qRemove.message);	
			}
			else {
				fail("Asset(s) does not removed successfully");
			}
		</cfscript>
	</cffunction>	
	
	
		
	<!---<cffunction name="testSetmetadata">
		<cfscript>
			ASSETID = "01796D62A2A3409BB327142798C7A032";
			ASSETTYPE = "aud";
			ASSETMETADATA = '[["aud_description","Updated description"],["aud_keywords","audio keyword"]]';
			qUpdate = CUT.setmetadata(API_KEY,ASSETID,ASSETTYPE,ASSETMETADATA);
			if (structKeyExists(qUpdate, "MESSAGE")){
				assertEquals( "Metadata successfully stored", qUpdate.message);	
			}
			else {
				fail("Metadata does not stored successfully");
			}
		</cfscript>
	</cffunction>--->
	
	
<cfscript>
	// ------------------------ IMPLICIT ------------------------ //

	/**
	* this will run before every single test in this test case
	*/
	function setUp(){
		// initialise component under test
		CUT = new global.api2.asset();
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