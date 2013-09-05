// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Empty files from Trash
	function testEmptyTrash(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Trash");
		selenium.click("css=##assets > div:nth-child(1) > a:nth-child(2) > div:nth-child(1)");
		Super.doRazLogout();
	}
}