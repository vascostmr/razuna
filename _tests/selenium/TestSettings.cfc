// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Settings
	function testSettings() { 
		Super.doRazLogin();
		selenium.click("css=##apDiv1 > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > a:nth-child(1)");
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