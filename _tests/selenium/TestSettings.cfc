// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Settings
	function testSettings() { 
		Super.doRazLogin();
		selenium.click("link=admin admin");
		selenium.click("link=Administration");
		selenium.setspeed("2000");
		selenium.click("link=Settings");
		selenium.click("name=submit");
		selenium.click("link=Maintenance");
		selenium.click("name=flushdb");
		selenium.click("name=rebuiltcache");
		selenium.click("name=cleaner");
		selenium.waitForPageToLoad( timeout );
		Super.doRazLogout();
	}
}