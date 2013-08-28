// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Move Assets Files 
	/*function testMoveAssets(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
	}*/
    
	function testAudioFiles(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='aud']/a[contains(text(),'Audios')]");
		selenium.setspeed("3000");
		selenium.click("css=img.ui-selectee");
		selenium.click("link=Renditions");
		selenium.click("link=View");
		selenium.click("link=Download");
		selenium.click("link=Direct Link");
		selenium.click("link=Direct Link");
		selenium.click("link=Embed");
		selenium.click("link=Embed");
		selenium.check("css=input[name = 'convert_to'][value='mp3']");
		selenium.setspeed("1000");
		selenium.check("css=input[name = 'convert_to'][value='ogg']");
		selenium.setspeed("1000");
		selenium.click("name=convertbutton");
		selenium.click("//div[@id='convertt']/div[3]/a/div");
		selenium.type("id=av_link_title", "Additional Renditions URL");		
		selenium.type("id=av_link_url", "http://openbd.org/a/img/openbd_vector.png");
		selenium.click("//input[@value='Add']");
		selenium.click("//div[@id='convertt']/div[3]/a/div");
		selenium.setspeed("2000");
		selenium.click("link=Additional Renditions URL");
		selenium.click("//div[@id='convertt']/div[3]/a/div");
		selenium.click("link=Edit");
		selenium.type("id=ave_link_title", "Additional Renditions from web");		
		selenium.type("id=ave_link_url", "http://www.mitrahsoft.com/default/assets/Image/Railo/Railo_block_logo.png");
		selenium.click("name=savecomment");
		selenium.click("//div[@id='moreversions']/table[2]/tbody/tr[5]/td[4]/a/img");
		selenium.click("name=remove");
		selenium.type("id=folder_path","C:\Users\Public\Pictures\Sample Pictures");
		selenium.click("//input[@value='Import from path']");
		selenium.click("//div[@id='convertt']/div[3]/a/div");
		selenium.setspeed("4000");
		selenium.click("link=Refresh"); 
		selenium.click("link=Meta Data");
		selenium.type("name=desc_1","Test Audio Descriptions");
		selenium.type("name=keywords_1","Test Audio Keywords");
		selenium.click("//div[@id='meta']/a[2]/div");
		selenium.click("xpath=(//input[@name='submit'])[2]");
		selenium.isTextPresent("The record has been updated successfully");
		selenium.click("//div[@id='meta']/a[2]/div");
	}

}

