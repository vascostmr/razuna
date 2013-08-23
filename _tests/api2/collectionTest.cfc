<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	
	<!--- Get colletions --->
	<cffunction name="testGetCollections">
		<cfscript>
			FOLDERID = "B3999E8296F544B8875AF48AF267AED8";
			qCollections = CUT.getcollections(API_KEY,FOLDERID);
			if(qCollections.recordCount NEQ 0){
				assertEquals( "Testcollection", qCollections.col_name);
			}else{
				fail("No record found for FOLDER ID :: " & FOLDERID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get assets --->
	<cffunction name="testGetAssets" >
		<cfscript>
			COLLECTIONID = "42916093FE7A46DA9CAF6EB57AB21A9A";
			qGetAssets = CUT.getassets(API_KEY,COLLECTIONID);
			if(qGetAssets.recordCount NEQ 0){
				assertEquals( "0", qGetAssets.responsecode);
			}else{
				fail("No record found for COLLECION ID :: " & COLLECTIONID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Search collection --->
	<cffunction name="testSearch">
		<cfscript>
			ID = "42916093FE7A46DA9CAF6EB57AB21A9A";
			NAME = "Testcollection";
			KEYWORD = "Collection";
			DESCRIPTION = "Collection for Test";
			RELEASED = "false";
			qSearch = CUT.search(API_KEY,ID,NAME,KEYWORD,DESCRIPTION,RELEASED);
			if(qSearch.recordCount NEQ 0){
				assertEquals( "Testcollection", qSearch.col_name);
			}else{
				fail("No record found");
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
		CUT = new global.api2.collection();
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