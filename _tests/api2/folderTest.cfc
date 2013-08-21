<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	<!--- Get a folder --->
	<cffunction name="testGetFolder">
		<cfscript>
			FOLDERID = "A9D8939DFF774C94886882175BB28199";
			qGetFolder = CUT.getfolder(API_KEY,FOLDERID);
			if(qGetFolder.recordCount NEQ 0){
				assertEquals( "Uploads", qGetFolder.folder_name);
			}else{
				fail("No record found for FOLDER ID :: " & FOLDERID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get assets --->
	<cffunction name="testGetAssets">
		<cfscript>
			FOLDERID = "A9D8939DFF774C94886882175BB28199";
			SHOWSUBFOLDERS = "false";
			SHOW = "all";
			qGetAssets = CUT.getassets(API_KEY,FOLDERID,SHOWSUBFOLDERS,SHOW);
			if(qGetAssets.recordCount NEQ 0){
				assertEquals( "A9D8939DFF774C94886882175BB28199", qGetAssets.calledwith);
			}else{
				fail("No record found for FOLDER ID :: " & FOLDERID);
			}
		</cfscript>
	</cffunction>	
	
	<!--- Get folders --->
	<cffunction name="testGetFolders">
		<cfscript>
			FOLDERID = "A9D8939DFF774C94886882175BB28199";
			COLLECTIONFOLDER = "false";
			qGetFolders = CUT.getfolders(API_KEY,FOLDERID,COLLECTIONFOLDER);
			if(qGetFolders.recordCount NEQ 0){
				assertEquals( "Uploads", qGetFolder.folder_name);
			}else{
				fail("No record found for FOLDER ID :: " & FOLDERID);	
			}
			
		</cfscript>
	</cffunction>
	
	<!--- Set folder --->
	<cffunction name="testSetFolder">
		<cfscript>
			FOLDER_NAME = "sample";
			FOLDER_OWNER = "6CE5BBF5-45F3-43C6-BE483C1AC21905B2";
			FOLDER_RELATED = "";
			FOLDER_COLLECTION = "false";
			FOLDER_DESCRIPTION = "This folder is created for test";
			qSetFolder = CUT.setfolder(API_KEY,FOLDER_NAME,FOLDER_OWNER,FOLDER_RELATED,FOLDER_COLLECTION,FOLDER_DESCRIPTION);
			if(structKeyExists(qSetFolder, "RESPONSECODE")){
				assertEquals( "0", qSetFolder.RESPONSECODE);
			}else{
				fail("The folder does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Set folder permissions --->
	<cffunction name="testSetFolderPermission">
		<cfscript>
			PERMISSIONS ='[["A9D8939DFF774C94886882175BB28199", "0", "X"]]';
			qSetPermission = CUT.setFolderPermissions(API_KEY,PERMISSIONS);
			if(structKeyExists(qSetPermission, "MESSAGE")){
				assertEquals( "Folder permissions successfully updated", qSetPermission.MESSAGE);
			}else{
				fail("The permission does not updated successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Remove folder --->
	<cffunction name="testRemoveFolder">
		<cfscript>
			FOLDERID = "0D49524AE47D4BF686C8D1409C7559F9";
			qRemoveFolder = CUT.removefolder(API_KEY,FOLDERID);
			if(structKeyExists(qRemoveFolder, "MESSAGE")){
				assertEquals( "Folder and all content within has been successfully removed.", qRemoveFolder.MESSAGE);
			}else{
				fail("The folderdoes not successfully removed");
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
		CUT = new global.api2.folder();
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