// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	//Folder Setting
	function testFolderSetting(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("//a[contains(text(),'Uploads')]");
		selenium.setspeed("3000");
		selenium.click("css=.grid > tbody:nth-child(1) > tr:nth-child(1) > td:nth-child(1) > div:nth-child(2) > a:nth-child(1)");
		selenium.setspeed("1000");
		selenium.click("//div[@id='properties']/form");
		selenium.check("css=input[name='per_0'][value='X']");
		selenium.click("css=input[name='perm_inherit'][type='checkbox']");
		selenium.click("id=foldersubmitbutton");
		selenium.click("link=Sharing options");
		selenium.setspeed("2000");
		selenium.check("css=input[name='folder_shared'][value='T']");
		selenium.click("id=share_dl_thumb");
		selenium.click("link=Reset setting of individual assets");
		selenium.click("id=share_dl_org");
		selenium.click("name=share_comments");
		selenium.click("name=share_upload");
		selenium.click("name=share_order");
		selenium.click("css=input[class='button'][value='Update']");
		Super.doRazLogout();
	}
}