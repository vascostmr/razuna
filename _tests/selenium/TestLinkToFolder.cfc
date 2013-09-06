// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Link To Folder 
	function testLinkToFolder(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Manage");
		selenium.click("link=Add Folder (on root level)");
		selenium.click("//a[contains(text(),'Link to Folder')]");
		selenium.type("id=link_path", #expandpath('.')# & "\assets\img");
		selenium.click("link=Check Folder");  
		selenium.click("name=linkbutton");
		selenium.click("link=Uploads");
		Super.doRazLogout();
	}
	
}