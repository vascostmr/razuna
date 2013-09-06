// component extends testRazunaBase
component extends="TestRazunaBase"{

	// More Actions
	function testMoreActions() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("3000");
		// Add Folder
		selenium.click("//a[contains(text(),'More actions')]");
		selenium.click("css=a[title='In the following dialog window you are able to create a new folder on the current level.'] > div");
		selenium.type("id=folder_name", "TestFolder");
		selenium.type("name=folder_desc_1", "TestFolder Description");
		selenium.click("css=input[id='foldersubmitbutton'][value='Add']");
		// Add folder to favorites and Show assets from Sub-Folders
		selenium.click("link=Uploads");
		selenium.setspeed("3000");
		selenium.click("//a[contains(text(),'More actions')]");
		selenium.click("//div[@id='dropcontent']/a[2]/div");
		selenium.setspeed("3000");
		selenium.click("link=More actions");
		selenium.click("//div[@id='dropcontent']/a[3]/div");
		// Print
		selenium.click("link=More actions");
		selenium.click("//div[@id='dropcontent']/a[4]/div");
		selenium.type("name=header", "Test header");
		selenium.type("name=footer", "Test footer");
		selenium.click("css=input.button");
		selenium.click("document.pdfsetting.pages[1]");
		selenium.select("name=pagetype", "label=A4");
		selenium.click("document.pdfsetting.view[1]");
		selenium.type("name=header", "Test header");
		selenium.type("name=footer", "Test footer");
		selenium.click("css=input.button");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		// Rss and Create Document
		selenium.setspeed("3000");
		selenium.click("link=More actions");
		selenium.click("//div[@id='dropcontent']/a[5]/div");
		selenium.click("link=More actions");
		selenium.click("//div[@id='dropcontent']/a[6]/div");
		// Export Metadata
		selenium.setspeed("3000");
		selenium.click("link=More actions");
		selenium.click("//div[@id='dropcontent']/a[7]/div");
		selenium.setspeed("1000");
		// CSV
		selenium.setspeed("3000");
		selenium.click("css=input[type='button'][value='Export']");
		selenium.waitForPopUp("", "30000");
		// XLS
		selenium.setspeed("3000");
		selenium.select("id=export_format", "label=XLS");
		selenium.click("css=input[type='button']");
		selenium.waitForPopUp("", "30000");
		// XLSX
		selenium.setspeed("3000");
		selenium.select("id=expwhat", "label=Export ALL assets in Razuna");
		selenium.select("id=export_format", "label=XLSX");
		selenium.click("css=input[type='button']");
		selenium.waitForPopUp("", "30000");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		// Import Metadata
		// CSV
		selenium.click("link=More actions");
		selenium.click("css=a[title='Import metadata from an external file to all assets in this folder (if you want to apply this to only selected assets then use the select drop-down menu).'] > div");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\doc\razuna-metadata-export.csv");
		selenium.click("name=submitbutton");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		// XLS
		selenium.click("//div[11]/div/button");
		selenium.click("link=More actions");
		selenium.click("css=a[title='Import metadata from an external file to all assets in this folder (if you want to apply this to only selected assets then use the select drop-down menu).'] > div");
		selenium.select("name=expwhat", "label=all assets in Razuna");
		selenium.select("name=file_format", "label=XLS");
		selenium.click("document.form_meta_imp.imp_write[1]");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\doc\razuna-metadata-export.xls");
		selenium.click("name=submitbutton");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		// XLSX
		selenium.click("//div[11]/div/button");
		selenium.click("link=More actions");
		selenium.click("css=a[title='Import metadata from an external file to all assets in this folder (if you want to apply this to only selected assets then use the select drop-down menu).'] > div");
		selenium.select("id=file_format", "label=XLSX");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\doc\razuna-metadata-export.xlsx");
		selenium.click("name=submitbutton");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		// Download Assets
		selenium.setspeed("3000");
		selenium.click("//div[11]/div/button");
		selenium.click("link=More actions");
		selenium.click("//div[@id='dropcontent']/a[9]/div");
		selenium.click("name=download_renditions");
		selenium.click("name=submitbutton");
		selenium.click("css=a > strong");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}