// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add to Existing Collection
	function testBatchCollection() {
		Super.doRazLogin();
		selenium.setspeed("3000");
		selenium.click("link=Uploads");
		selenium.click("link=Select all");
		//Put in Basket
		selenium.click("//div[@id='folderselectionallform']/a/div[2]");
		// Collection
		selenium.click("//div[@id='folderselectionallform']/a[4]/div[2]");
		selenium.click("xpath=//div[@id='win_choosefolder']/ul[@class='ltr']/li[@class='last leaf']/a");
		if(selenium.isElementPresent("link=exact:Maybe create one now?") EQ true){
		// Create new Collection
		selenium.click("link=exact:Maybe create one now?");
		selenium.type("id=collectionname", "TestCollection");
		selenium.click("name=save");
		selenium.click("css=td > a > strong");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		}
		else{
		// Add assets to existing collection
		selenium.click("css=td > a > strong");
		}
	}
	
	// Export
	function testExport() {
		selenium.click("//div[@id='folderselectionallform']/a[5]/div[2]");
		selenium.click("css=input[type='button']");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.select("id=export_format", "label=XLS");
		selenium.click("css=input[type='button']");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.select("id=export_format", "label=XLSX");
		selenium.click("css=input[type='button']");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.click("css=div:last-child .ui-button-icon-primary");
	}
	
	// Move Assets
	function testMove() {
		selenium.click("//div[@id='folderselectionallform']/a[2]/div[2]");
		selenium.click("xpath=//div[@id='win_choosefolder']/ul[@class='ltr']/li[@class='leaf']/a");
		selenium.click("css=div:last-child .ui-button-icon-primary");
	}
	
	// Move to trash
	/*function testTrash() {
		selenium.click("//div[@id='folderselectionallform']/a[6]/div[2]");
		selenium.click("name=trash");
	}*/
}