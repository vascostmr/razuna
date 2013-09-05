// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Search within folder
	function testSearchWithinFolder() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("link=Uploads");
		selenium.setspeed("3000");
		selenium.click("link=Search within folder");
		selenium.setspeed("3000");
		//Search All Assets
		selenium.type("name=searchfor", "Test" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		// Search Only Documents
		if(selenium.isElementPresent("css=a:contains('Search again')") EQ true){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Documents");
		selenium.setspeed("4000");
		selenium.type("name=extension", "txt, doc, docx, pdf, ppt, pptx, xls, xlsx" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		}
		else{
		selenium.click("xpath=(//a[contains(text(),'Folder Content')])");
		selenium.setspeed("3000");
		selenium.click("link=Search within folder");
		selenium.setspeed("3000");
		selenium.click("link=Documents");
		selenium.setspeed("4000");
		selenium.type("name=extension", "txt, doc, docx, pdf, ppt, pptx, xls, xlsx" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		}
		// Search Only Images
		if(selenium.isElementPresent("css=a:contains('Search again')") EQ true){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Images");
		selenium.setspeed("4000");
		selenium.type("name=extension", "jpg, jpeg" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		}
		else{
		selenium.click("xpath=(//a[contains(text(),'Folder Content')])");
		selenium.setspeed("10000");
		selenium.click("link=Search within folder");
		selenium.setspeed("3000");
		selenium.click("link=Images");
		selenium.setspeed("4000");
		selenium.type("name=extension", "jpg, jpeg" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		}
		// Search Only Videos
		if(selenium.isElementPresent("css=a:contains('Search again')") EQ true){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Videos");
		selenium.setspeed("4000");
		selenium.type("name=extension", "3gp, avi, mp4, wmv" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		}
		else{
		selenium.click("xpath=(//a[contains(text(),'Folder Content')])");
		selenium.setspeed("10000");
		selenium.click("link=Search within folder");
		selenium.setspeed("3000");
		selenium.click("link=Videos");
		selenium.setspeed("4000");
		selenium.type("name=extension", "3gp, avi, mp4, wmv" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		}
		// Search Only Audios
		if(selenium.isElementPresent("css=a:contains('Search again')") EQ true){
		selenium.click("link=Search again");
		selenium.setspeed("4000");
		selenium.click("link=Audios");
		selenium.setspeed("4000");
		selenium.type("name=extension", "mp3, ogg, wav" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");
		}
		else{
		selenium.click("xpath=(//a[contains(text(),'Folder Content')])");
		selenium.setspeed("10000");
		selenium.click("link=Search within folder");
		selenium.setspeed("3000");
		selenium.click("link=Audios");
		selenium.setspeed("4000");
		selenium.type("name=extension", "mp3, ogg, wav" );
		selenium.setspeed("2000");
		selenium.click("name=submitsearch");
		selenium.setspeed("6000");	
		}
		//View Assets 
		if(selenium.isElementPresent("css=a:contains('Search again')") EQ true){
		selenium.click("//div[@id='tooltip']/a/img");
		selenium.click("//div[@id='tooltip']/a[2]/img");
		selenium.click("//div[@id='tooltip']/a[3]/img");
		}
		Super.doRazLogout();
	}
}
