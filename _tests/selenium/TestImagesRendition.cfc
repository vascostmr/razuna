// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Images Rendition
	function testImagesRendition(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='img']/a[contains(text(),'Images')]");
		selenium.setspeed("4000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='img']");
		selenium.setspeed("2000");
		selenium.click("link=Renditions");
		selenium.click("link=View");
		selenium.click("link=Download");
		selenium.click("link=Direct Link");
		selenium.click("link=Direct Link");
		selenium.click("css=input[name='convert_to'][value='jpg']");
		selenium.type("id=convert_width_jpg","750");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][value='gif']");
		selenium.type("id=convert_width_gif","850");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][value='png']");
		selenium.type("id=convert_width_png","1010");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][value='tif']");
		selenium.type("id=convert_dpi_tif", "200");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][value='bmp']");
		selenium.type("id=convert_dpi_bmp", "150");
		selenium.setspeed("1000");
		selenium.click("name=convertbutton");
		selenium.click("//div[11]/div/button");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='img']/a[contains(text(),'Images')]");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='img']/a[contains(text(),'Images')]");
		selenium.setspeed("4000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='img']");
		selenium.setspeed("4000");
		selenium.click("link=Renditions");
		selenium.setspeed("4000");
		selenium.click("link=Refresh");
		if(selenium.isElementPresent("css=a:contains('Create new Renditions')") EQ true){
		selenium.click("link=Create new Renditions");
		selenium.click("css=input[name='convert_to'][id='jpgid']");
		selenium.type("id=convert_width_jpg","750");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][id='gifid']");
		selenium.type("id=convert_width_gif","850");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][id='pngid']");
		selenium.type("id=convert_width_png","1010");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][id='tifid']");
		selenium.type("id=convert_width_tif","1253");
		selenium.setspeed("1000");
		selenium.click("css=input[name='convert_to'][id='bmpid']");
		selenium.type("id=convert_width_bmp","586");
		selenium.setspeed("1000");
		selenium.click("xpath=(//input[@name='convertbutton'])[2]");
		selenium.click("link=Delete");
		selenium.click("//button[@type='button']");
		}
		Super.doRazLogout();
	}
}