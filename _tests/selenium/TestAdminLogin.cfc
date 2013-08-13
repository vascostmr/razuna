// component extends testRazunaBasesss
component extends="TestRazunaBase"{

	//Valid Login 
	function testValidLogin() {
		Super.doLogin();
		assertTrue( selenium.isTextPresent( "Welcome to Razuna" ) );
		Super.doLogout();
	}
	
	//Invalid Login 
	function testInvalidLogin() {
		selenium.open( browserURL & "/admin/index.cfm?fa=c.logoff" );
		selenium.waitForPageToLoad( timeout );
		selenium.type( "id=name", "foo" );
		selenium.type( "id=pass", "bar" );
		selenium.click("name=submitbutton");
		selenium.waitForPageToLoad( timeout );
		assertTrue( selenium.isTextPresent( "We are sorry but we could not log you in. Try again please" ) );
	}
	
}