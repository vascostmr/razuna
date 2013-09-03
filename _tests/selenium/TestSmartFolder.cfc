// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add SmartFolder
	function testSmartFolder() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Smart Folders");
		selenium.click("//div[@id='smartfolders']/a/button");
		selenium.type("id=sf_name", "TestSmartFolder");
		selenium.type("id=sf_description", "TestSmartFolder Description");
		selenium.click("document.sf_form.sf_type[1]");
		selenium.click("name=sfsubmit");
		selenium.click("link=Permissions");
		selenium.click("name=grp_0");
		selenium.click("document.sf_form.per_0[2]");
		selenium.click("//input[@name='sfsubmit']");
		Super.doRazLogout();
	}
}