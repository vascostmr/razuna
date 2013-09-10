// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Add SmartFolder
	function testAddSmartFolder() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Smart Folders");
		if(selenium.isElementPresent("css=a:contains('Add a new smart folder')") EQ true){
		selenium.click("css=div##smartfolders > a");
		selenium.type("id=sf_name", "TestSmartFolder");
		selenium.type("id=sf_description", "TestSmartFolder Description");
		selenium.click("document.sf_form.sf_type[1]");
		selenium.click("name=sfsubmit");
		selenium.click("link=Permissions");
		selenium.click("name=grp_0");
		selenium.click("document.sf_form.per_0[2]");
		selenium.click("//input[@name='sfsubmit']");
		}
		else{
		selenium.click("css=##smartfolders > a:nth-child(2) > div:nth-child(2)");
		selenium.click("css=div##apDiv4 div##rightside  div:nth-child(1) a:nth-child(1)");
		selenium.type("id=sf_name", "TestSmartFolder");
		selenium.type("id=sf_description", "TestSmartFolder Description");
		selenium.click("document.sf_form.sf_type[1]");
		selenium.click("name=sfsubmit");
		selenium.click("link=Permissions");
		selenium.click("name=grp_0");
		selenium.click("document.sf_form.per_0[2]");
		selenium.click("//input[@name='sfsubmit']");	
		selenium.click("link=Remove Folder");
		selenium.click("//button[@type='button']");
		}
		Super.doRazLogout();
	}
	
}