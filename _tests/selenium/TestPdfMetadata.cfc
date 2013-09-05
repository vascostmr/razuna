// component extends testRazunaBase
component extends="TestRazunaBase"{

	//Pdf Metadata
	function testPdfMetadata(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("1000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='pdf']/a[contains(text(),'PDF')]");
		selenium.setspeed("3000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='doc']");
		selenium.click("link=Metadata");
		selenium.type("name=desc_1", "Test Description");
		selenium.type("name=keywords_1", "Test Keywords");
		selenium.type("name=authorsposition", "Test Title");
		selenium.type("name=captionwriter", "Test Writer");
		selenium.select("name=rightsmarked", "label=Copyrighted");
		selenium.type("name=rights", "Test Copyright Notice");
		selenium.type("name=webstatement", "www.testing.com");
		selenium.click("//div[@id='meta']/a[2]/div");
		selenium.click("//div[@id='meta']/a[2]/div");
		selenium.click("xpath=(//input[@name='submit'])[2]");
		selenium.isTextPresent("The record has been updated successfully");
		Super.doRazLogout();
	}
}