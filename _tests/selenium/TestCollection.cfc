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
		selenium.type("id=collectionname", "Test_Collection");
		selenium.type("name=col_desc_1", "Test_Collection  Description");
		selenium.type("name=col_keywords_1", "Test_Collection Keywords");
		selenium.click("name=save");
	}
	// Add Folder	
	function testFolderAdd(){
		selenium.click("//a[contains(text(),'Add Folder')]");
		selenium.type("id=folder_name", "Test_Folder");
		selenium.type("name=folder_desc_1", "Test_Folder Description");
		selenium.click("name=grp_0");
		selenium.check("css=input[name='per_0'][value='X']");
		selenium.click("id=foldersubmitbutton");
		Super.doRazLogout();
	}
}