// component extends testRazunaBase
component extends="TestRazunaBase"{

    function testAssetsearch() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("link=Uploads");
		selenium.setspeed("10000");
		selenium.click("link=Search within folder");
		selenium.setspeed("3000");
		//Search All Assets
		selenium.type("name=searchfor", "test" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		//}
		/*//Select All Searched Assets
		selenium.click("link=Select all");
		selenium.setspeed("4000");
		//Put in Basket
		selenium.click("//div[@id='folderselectionsearchformall']/a/div[2]");
		//Add to Existing Collection
		selenium.click("//div[@id='folderselectionsearchformall']/a[4]/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		//Move File
		selenium.click("//div[@id='folderselectionsearchformall']/a[2]/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		//Batch
		selenium.click("//div[@id='folderselectionsearchformall']/a[3]/div[2]");
		//Add to Existing Collection
		selenium.click("//div[@id='folderselectionsearchformall']/a[4]/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		//
		//Add to Existing Collection
		selenium.click("//div[@id='folderselectionsearchformall']/a[4]/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		//Export Metadata CSV Format
		selenium.click("link=Export metadata");
		selenium.click("//input[@value='Export']");
		//Export Metadata XLS Format
		selenium.click("link=Export metadata");
		selenium.select("id=export_format", "label=XLS");
		selenium.click("//input[@value='Export']");
		//Export Metadata XLSX Format
		selenium.click("link=Export metadata");
		selenium.select("id=export_format", "label=XLSX");
		selenium.click("//input[@value='Export']");*/
		// Search Only Documents
		//function testSearchDocuments(){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Documents");
		selenium.setspeed("4000");
		selenium.type("name=extension", "doc" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		//}
		// Search Only Images
		//function testSearchImages(){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Images");
		selenium.setspeed("4000");
		selenium.type("name=extension", "jpg" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		//}
		// Search Only Videos
		//function testSearchVideos(){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Videos");
		selenium.setspeed("4000");
		selenium.type("name=extension", "mp4" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		//}
		// Search Only Audios
		//function testSearchAudios(){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Audios");
		selenium.setspeed("4000");
		selenium.type("name=extension", "mp3" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		//}
		
		//View Assets 
		selenium.click("//div[@id='tooltip']/a/img");
		selenium.click("//div[@id='tooltip']/a[2]/img");
		selenium.click("//div[@id='tooltip']/a[3]/img");
		/*//Select All Searched Assets
		selenium.click("xpath=(//div[@id='tooltip']/a/div)[5]");
		selenium.setspeed("2000");
		//Put in Basket
		selenium.click("//div[@id='folderselectionsearchformall']/a/div[2]");
		//Add to Existing Collection
		selenium.click("//div[@id='folderselectionsearchformall']/a[4]/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		//Batch
		selenium.click("//div[@id='folderselectionsearchformall']/a[3]/div[2]");
		selenium.type("name=aud_desc_1","Test Batch Description");
		selenium.type("name=aud_keywords_1","Test Batch Keywords");
		selenium.click("//div[@id='folderselectionaudform']/a[3]/div[2]");
		selenium.click("name=submit");
		//Export Metadata CSV Format
		selenium.click("link=Export metadata");
		selenium.click("//input[@value='Export']");
		//Export Metadata XLS Format
		selenium.click("link=Export metadata");
		selenium.select("id=export_format", "label=XLS");
		selenium.click("//input[@value='Export']");
		//Export Metadata XLSX Format
		selenium.click("link=Export metadata");
		selenium.select("id=export_format", "label=XLSX");
		selenium.click("//input[@value='Export']");
		//Move File
		selenium.click("//div[@id='folderselectionsearchformall']/a[2]/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		selenium.click("css=div:last-child .ui-button-icon-primary");*/
		Super.doRazLogout();
		}
}
