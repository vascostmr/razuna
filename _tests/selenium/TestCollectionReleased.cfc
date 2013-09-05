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
	}
	// Add Collection	
	function testAddCollection(){
		selenium.click("link=Create Collection");
		selenium.type("id=collectionname", "TestCollection");
		selenium.type("name=col_desc_1", "TestCollection  Description");
		selenium.type("name=col_keywords_1", "TestCollection Keywords");
		selenium.click("name=save");
		selenium.setspeed("3000");
	}
	// Add Folder	
	function testFolderAdd(){
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[2]/a[contains(text(),'Collections Released')]");
		selenium.click("//a[contains(text(),'Add Folder')]");
		selenium.type("id=folder_name", "TestFolder");
		selenium.type("name=folder_desc_1", "TestFolder Description");
		selenium.click("id=foldersubmitbutton");
		selenium.setspeed("3000");
		Super.doRazLogout();
	}
}