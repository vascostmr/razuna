<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	
	<!--- Asset search --->
	<cffunction name="testSearch">
		<cfscript>
			SEARCHFOR = "Tulips";
			SHOW = "img";
			qSearch = CUT.searchassets(API_KEY,SEARCHFOR,SHOW);
			if(structKeyExists(qSearch,"responsecode")){
				assertEquals( "0", qSearch.responsecode);
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
		CUT = new global.api2.search();
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