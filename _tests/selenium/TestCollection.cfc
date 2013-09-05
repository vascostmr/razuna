// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Add Collections
	function testCollections() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Collections");
		selenium.click("css=a[rel=prefetch]");
	}
	// Add Collection
	function testAddCollection(){
		selenium.click("link=Create Collection");
		selenium.type("id=collectionname", "TestCollection");
		selenium.type("name=col_desc_1", "TestCollection  Description");
		selenium.type("name=col_keywords_1", "TestCollection Keywords");
		selenium.click("name=save");
	}
	// Add Folder	
	function testFolderAdd(){
		selenium.click("//a[contains(text(),'Add Folder')]");
		selenium.type("id=folder_name", "TestFolder");
		selenium.type("name=folder_desc_1", "TestFolder Description");
		selenium.check("css=input[name='per_0'][value='X']");
		selenium.click("id=foldersubmitbutton");
		Super.doRazLogout();
	}
}