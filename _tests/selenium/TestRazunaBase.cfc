/* 
	- We will run the selenium tests from Adobe ColdFusion.
	- run these tests in your browser at http://localhost:8080/razuna/_tests/selenium/Tests.cfc?method=runTestRemote
	- occasionally it maybe necessary to start the Java server manually by double clicking cfselenium/Selenium-PC/selenium-server-standalone-2.24.1.jar 
*/

// component extends mxunit.framework.TestCase 
component extends="mxunit.framework.TestCase"{

	// run once before all tests
	function beforeTests() {
		// set url of Razuna installation
		browserURL = "http://localhost:8080/razuna";
		// set browser to be used for testing
		browserCommand = "*firefox"; // Other possible strings are : *googlechrome, *firefox, *iexplore, *safari, *opera
		// create a new instance of CFSelenium
	   	selenium = createobject( "component", "CFSelenium.selenium" ).init();
		// start Selenium server
		selenium.start( browserUrl, browserCommand );
		// set timeout period to be used when waiting for page to load
		timeout = 6000000;

		// We may have to reset data in database. not yet implmented
		/*httpService = new http();
		httpService.setUrl( browserURL & "/_tests/resetData.cfm" ); 
		httpService.send();*/

		// Useful to see the action  
		//selenium.setSpeed("1000");
		
		// Valid Amazon S3 Storage
		awsAccessKey = "";
		awsSecretKey = "";
		// Invalid Amazon S3 Storage
		InvalidAwsAccessKey = "";
		InvalidAwsSecretKey = "";


		createObject( "java", "coldfusion.tagext.lang.SettingTag" ).setRequestTimeout(javaCast( "double", 0 ));
	}
	
	// run once after each test
	function tearDown() {
		// tests fail in Railo 4 if next line uncommented. In chrome, it is giving Null results.
		//selenium.stop();
	}	

	// run once after all tests
	function afterTests() {
		//selenium.stopServer();
	}
	
	// login Razuna Admin
	private function doLogin(){
		selenium.open( browserURL & "/admin/index.cfm?fa=c.logoff" );
		selenium.waitForPageToLoad( timeout );
		selenium.type( "id=name", "admin" );
		selenium.type( "id=pass", "admin" );
		selenium.click("name=submitbutton");
		selenium.waitForPageToLoad( timeout );
	}
	
	// logout Razuna Admin
	private function doLogout(){
		selenium.open( browserURL & "/admin/index.cfm?fa=c.logoff" );
		selenium.waitForPageToLoad( timeout );
	}
	
	// login Tenants Users
	private function doRazLogin(){
		selenium.open( browserURL & "/raz1/dam/index.cfm?fa=c.logout" );
		selenium.waitForPageToLoad( timeout );
		selenium.type( "id=name", "admin" );
		selenium.type( "id=pass", "admin" );
		selenium.click("name=submitbutton");
		selenium.waitForPageToLoad( timeout );
	}
	
	// logout Tenants Users
	private function doRazLogout(){
		selenium.open( browserURL & "/raz1/dam/index.cfm?fa=c.logout" );
		selenium.waitForPageToLoad( timeout );
	}
}
