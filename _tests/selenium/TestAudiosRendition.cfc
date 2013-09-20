// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Audios Rendition
	function testAudiosRendition(){
		Super.doRazLogin();
		selenium.setspeed("3000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='aud']/a[contains(text(),'Audios')]");
		selenium.setspeed("3000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='aud']");
		selenium.setspeed("3000");
		selenium.click("link=Renditions");
		selenium.click("link=View");
		selenium.click("link=Download");
		selenium.click("link=Direct Link");
		selenium.click("link=Direct Link");
		selenium.click("link=Embed");
		selenium.click("link=Embed");
		selenium.check("css=input[name = 'convert_to'][value='mp3']");
		selenium.select("id=convert_bitrate_mp3","label=160");
		selenium.check("css=input[name = 'convert_to'][value='ogg']");
		selenium.select("id=convert_bitrate_ogg","label=224");
		selenium.check("css=input[name = 'convert_to'][value='wav']");
		selenium.check("css=input[name = 'convert_to'][value='flac']");
		selenium.click("name=convertbutton");
		selenium.click("//div[11]/div/button");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='aud']/a[contains(text(),'Audios')]");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='aud']/a[contains(text(),'Audios')]");
		selenium.setspeed("2000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='aud']");
		selenium.setspeed("4000");
		selenium.click("link=Renditions");
		selenium.setspeed("4000");  
		selenium.click("link=Refresh");
		if(selenium.isElementPresent("css=a:contains('Metadata')") EQ true){
		selenium.click("xpath=(//a[contains(text(),'Metadata')])");
		selenium.type("xpath=(//textarea[@name='aud_desc_1'])[2]", "Testing Description");
		selenium.type("xpath=(//textarea[@name='aud_keywords_1'])[2]", "Testing keyword");
		selenium.click("xpath=(//input[@name='submit'])[3]");
		selenium.isTextPresent("The record has been updated successfully");
		selenium.click("link=Create new Renditions");
		selenium.check("css=input[name = 'convert_to'][id='mp3id']");
		selenium.setspeed("3000");
		selenium.select("xpath=(//select[@id='convert_bitrate_mp3'])[2]","label=192");
		selenium.check("css=input[name = 'convert_to'][id='oggid']");
		selenium.select("xpath=(//select[@id='convert_bitrate_ogg'])[2]","label=290");
		selenium.check("css=input[name = 'convert_to'][id='wavid']");
		selenium.check("css=input[name = 'convert_to'][id='flacid']");
		selenium.click("xpath=(//input[@name='convertbutton'])[2]");
		selenium.click("//div[12]/div/button");
		selenium.click("xpath=(//a[contains(text(),'Delete')])[2]");
		selenium.click("//button[@type='button']");
		}
		Super.doRazLogout();
	}
}
