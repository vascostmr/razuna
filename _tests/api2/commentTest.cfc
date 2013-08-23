<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	<!--- Get comment --->
	<cffunction name="testGetComment">
		<cfscript>
			ID = "FBE3517179344A25B27C1A55A239405A";
			qGetComment = CUT.get(API_KEY,ID);
			if (qGetComment.recordCount NEQ 0){
				 assertEquals( "FBE3517179344A25B27C1A55A239405A", qGetComment.com_id);	
			}else{
				fail("No record found for COMMENT ID :: " & ID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get all comment --->
	<cffunction name="testGetAllComment">
		<cfscript>
			ID = "01796D62A2A3409BB327142798C7A032";
			TYPE = "aud";
			qGetAllComment = CUT.getall(API_KEY,ID,TYPE);
			if (qGetAllComment.recordCount NEQ 0){
				 MESSAGE = "success";
				 assertEquals( "success",MESSAGE);	
			}else{
				fail("No record found for ID :: " & ID);
			}
		</cfscript>
	</cffunction>
	
	<!--- Add comment --->
	<cffunction name="testAddComment">
		<cfscript>
			ID = 0;
			ID_RELATED = "8AF522125A584C06B897C138316D253B";
			COMMENT = "test add comment";
			TYPE = "img";
			qAddComment = CUT.set(API_KEY,ID,ID_RELATED,COMMENT,TYPE);
			if(structKeyExists(qAddComment, "MESSAGE")){
				assertEquals( "Comment successfully added", qAddComment.MESSAGE);
			}else {
				fail("Comment does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Update comment --->
	<cffunction name="testUpdateComment">
		<cfscript>
			ID = "56EC301371AB441C84718DEBD0E67C1A";
			ID_RELATED = "01796D62A2A3409BB327142798C7A032";
			COMMENT = "test update comment";
			TYPE = "aud";
			qUpdateComment = CUT.set(API_KEY,ID,ID_RELATED,COMMENT,TYPE);
			if(structKeyExists(qUpdateComment, "MESSAGE")){
				assertEquals("Comment successfully updated", qUpdateComment.MESSAGE);
			}else {
				fail("Comment does not updated successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- Remove comment --->
	<cffunction name="testRemoveComment">
		<cfscript>
			ID = "56EC301371AB441C84718DEBD0E67C1A";
			qRemoveComment = CUT.remove(API_KEY,ID);
			if(structKeyExists(qRemoveComment, "MESSAGE")){
				assertEquals("Comment(s) successfully removed", qRemoveComment.MESSAGE);
			}else {
				fail("Comment does not removed successfully");
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
		CUT = new global.api2.comment();
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