// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add Collections Released
	function testCollectionsReleased() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Collections");
		selenium.click("css=a[rel=prefetch]");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[2]/a[contains(text(),'Collections Released')]");
		// Add Collection
		selenium.click("link=Create Collection");
		selenium.type("id=collectionname", "Test_Collection");
		selenium.type("name=col_desc_1", "Test_Collection  Description");
		selenium.type("name=col_keywords_1", "Test_Collection Keywords");
		selenium.click("name=save");
		// Add Folder
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[2]/a[contains(text(),'Collections Released')]");
		selenium.click("//a[contains(text(),'Add Folder')]");
		selenium.type("id=folder_name", "Test_Folder");
		selenium.type("name=folder_desc_1", "Test_Folder Description");
		selenium.click("id=foldersubmitbutton");
		Super.doRazLogout();
	}
}