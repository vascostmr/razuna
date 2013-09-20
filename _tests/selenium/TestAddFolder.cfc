// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	//Create New Folder 
	function testCreateFolder() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Manage");
		selenium.click("link=Add Folder (on root level)");
		selenium.type("id=folder_name", "Sample");
		selenium.click("name=grp_0");
		selenium.click("id=foldersubmitbutton");
		Super.doRazLogout();
	}
}