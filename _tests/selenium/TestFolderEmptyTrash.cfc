// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Empty folders from Trash 
	function testFolderEmptyTrash(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Trash");
		selenium.click("css=div##tabsfolder_tab ul.ui-tabs-nav li:nth-child(2) a.ui-tabs-anchor");
		selenium.click("css=##folders > div:nth-child(1) > a:nth-child(2) > div:nth-child(1)");
		Super.doRazLogout();
	}
}