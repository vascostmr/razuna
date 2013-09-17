// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Root Folder
	function testInformation() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.click("//a[contains(text(),'Images ')]");
		selenium.setspeed("3000");
		selenium.click("css=img.ui-selectee");
		selenium.setspeed("1000");
		selenium.click("name=submit");
		selenium.setspeed("1000");
	}
	//Rendition 
	function testRendition(){
		selenium.setspeed("1000");	
		selenium.click("//a[contains(text(),'Renditions')]");
		selenium.click("name=convert_to");
		selenium.type("id=convert_width_gif", "100");
		selenium.type("id=convert_dpi_gif", "300");
		selenium.click("name=convertbutton");
		selenium.type("id=convert_width_bmp", "1000");
		selenium.type("id=convert_dpi_bmp", "100");
		selenium.click("name=convertbutton");
		selenium.setspeed("1000");	
	}
	//Meta Data 
	function testMetaData(){
		selenium.click("link=Meta Data");
		selenium.setspeed("1000");	
		selenium.type("name=desc_1", "test");
		selenium.check("css=input[name='submit'][value='Save']");
	}
	//Comments
	function testComments(){
		selenium.click("//a[contains(text(),'Comments')]");
		selenium.setspeed("1000");	
		selenium.type("id=assetComment", "test comment");
		selenium.click("css=##divcomments > table.grid > tbody > tr > td > input.button");
	}
	//Edit Comments
	function testEditComment(){
		selenium.click("//a[contains(text(),'Comments')]");
		selenium.click("xpath=(//a[contains(text(),'Edit')])");
		selenium.type("id=commentup", "comment");
		selenium.click("name=savecomment");
		selenium.click("//a[contains(text(),'Remove Record')]");
		selenium.click("name=remove");
		
	}
	//Version  
	function testVersion(){
		selenium.click("//a[contains(text(),'Versions')]");
		selenium.setspeed("2000");	
		selenium.type("id=filedata", #expandpath('.')# & "\assets\img\Desert.jpg");
		selenium.waitForPageToLoad("30000");
		selenium.click("xpath=(//a[contains(text(),'Reload')])[2]");
	}
	//Sharing Option 
	function testSharingOption(){
		selenium.click("//a[contains(text(),'Sharing options')]");
		selenium.setspeed("2000");	
		selenium.click("id=thumb_dl");
		selenium.click("id=org_or");
		selenium.click("id=org_dl");
		selenium.setspeed("2000");
	}
	//History 
	function testHistory(){
		selenium.click("//a[contains(text(),'History')]");
		selenium.setspeed("2000");	
		selenium.select("id=actionsassets", "label=Add");
		selenium.click("link=Search");
		selenium.type("id=searchtext", "test");
		selenium.click("name=search");
		selenium.setspeed("2000");	
		selenium.select("id=actionsassets", "label=Update");
		selenium.select("id=actionsassets", "label=Renditions");
		selenium.select("id=actionsassets", "label=Delete");
		selenium.select("id=actionsassets", "label=Move");
		selenium.select("id=actionsassets", "label=Update");
	}
}