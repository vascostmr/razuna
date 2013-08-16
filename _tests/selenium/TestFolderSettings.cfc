// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	//Folder Settings
	function testFolderSettings() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("1000");
		selenium.click("link=Folder Sharing & Settings");
		selenium.click("//div[@id='properties']/form");
		selenium.check("css=input[name='per_0'][value='X']");
		selenium.click("css=input[name='perm_inherit'][type='checkbox']");
		selenium.click("id=foldersubmitbutton");
		selenium.click("link=Sharing options");
		selenium.setspeed("1000");
		selenium.check("css=input[name='folder_shared'][value='T']");
		selenium.click("id=share_dl_thumb");
		selenium.click("link=Reset setting of individual assets");
		selenium.click("id=share_dl_org");
		selenium.click("name=share_comments");
		selenium.click("name=share_upload");
		selenium.click("name=share_order");
		selenium.click("//div[@id='sharing']/form");
		Super.doRazLogout();
	}
	
}