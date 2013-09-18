// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Restore One
	function testRestoreOne(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Trash");
		selenium.setspeed("3000");
		selenium.click("css=div##tabsfolder_tab ul.ui-tabs-nav li:nth-child(2) a.ui-tabs-anchor");
		selenium.click("//div[@id='folderselectionallform_folders']/a/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
	}
	//Restore All
	function testRestoreAll(){
		selenium.click("link=Trash");
		selenium.setspeed("3000");
		selenium.click("css=div##tabsfolder_tab ul.ui-tabs-nav li:nth-child(2) a.ui-tabs-anchor");
		selenium.click("css=##folders > div:nth-child(1) > a:nth-child(3) > div:nth-child(1)");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		Super.doRazLogout();
	}
}