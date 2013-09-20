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
	}
		
	//Link To Folder 
	function testLinkToFolder(){
		selenium.setspeed("2000");
		selenium.click("link=Manage");
		selenium.click("link=Add Folder (on root level)");
		selenium.click("//a[contains(text(),'Link to Folder')]");
		selenium.type("id=link_path", #expandpath('.')# & "\assets\img");
		selenium.click("link=Check Folder");  
		selenium.click("name=linkbutton");
		selenium.setspeed("2000");
		selenium.click("link=Uploads");
		Super.doRazLogout();
	}
	
}