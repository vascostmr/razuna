<cfcomponent extends="mxunit.framework.TestCase">
	

	<!---
		CFscript based functions is not recognized by MXUnit in openBD 
			UNIT TESTS  - Recommended function name xxx_should_yyy_when_zzz
	--->
	<cffunction name="testGetUser">
		
		<cfscript>
			qUser = CUT.getuser(API_KEY);
			//debug(qUser);
			
			if (structKeyExists(qUser, "USER_LOGIN_NAME")){
				assertEquals( "admin", qUser.USER_LOGIN_NAME);	
			}
			else {
				fail("No record found for API KEY :: " & API_KEY);
			}
		</cfscript>
	</cffunction>
	<!--- Add an user --->
	<cffunction name="testAdd_when_passingAllArgs">
		<cfscript>
			USER_FIRST_NAME = "test_firstname";
			USER_LAST_NAME = "test_lastname";
			USER_EMAIL = "cfmitrah.test@gmail.com";
			USER_NAME = "testuser";
			USER_PASS = "password";
			USER_ACTIVE = "T";
			USER_GROUP = "0";
			//debug(CUT);
			qAdd = CUT.add(API_KEY,USER_FIRST_NAME,USER_LAST_NAME,USER_EMAIL,USER_NAME,USER_PASS,USER_ACTIVE,USER_GROUP);
			if(structKeyExists(qAdd, "MESSAGE")){
				assertEquals( "User has been added successfully", qAdd.MESSAGE);
			}else {
				fail("User does not added successfully");
			}
		</cfscript>
	</cffunction>
	
	<!--- update an user --->
	<cffunction name="testUpdateUser">
		<cfscript>
			USERID = "6CE5BBF5-45F3-43C6-BE483C1AC21905B2";
			USERLOGINNAME = "admin";
			USEREMAIL = "admin@admin.com";
			USERDATA = '[["user_first_name","firstname"],["user_last_name","lastname"]]';
			qUpdate = CUT.update(API_KEY,USERID,USERLOGINNAME,USEREMAIL,USERDATA);
			if (structKeyExists(qUpdate, "MESSAGE")){
				assertEquals( "User has been updated successfully", qUpdate.MESSAGE);
			}else{
				fail("User with the ID could not be updated successfully");
			}
		</cfscript>
		
	</cffunction>
	
	<!--- Delete an user --->
	<cffunction name="testDeleteUser">
		<cfscript>
			USERID = "6CE5BBF5-45F3-43C6-BE483C1AC21905B2";
			USERLOGINNAME = "admin";
			USEREMAIL = "admin@admin.com";
			//debug(CUT);
			qDel = CUT.delete(API_KEY,USERID,USERLOGINNAME,USEREMAIL);
			if(structKeyExists(qDel, "MESSAGE")){
				assertEquals( "User has been removed successfully", qDel.MESSAGE);
			}else {
				fail("User with the ID could not be found");
			}
			//fail("testAdd not yet implemented");
		</cfscript>
	</cffunction>
<cfscript>
	// ------------------------ IMPLICIT ------------------------ //

	/**
	* this will run before every single test in this test case
	*/
	function setUp(){
		// initialise component under test
		CUT = new global.api2.user();
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