// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Pdf Details 
	function testPdfDetails(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("1000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='pdf']/a[contains(text(),'PDF')]");
		selenium.setspeed("3000");
		selenium.click("//div[3]/form/table/tbody/tr[3]/td/div/a/div/img");
		selenium.click("link=Metadata");
		selenium.type("name=desc_1", "Test Description");
		selenium.type("name=keywords_1", "Test Keywords");
		selenium.type("name=authorsposition", "Testing Title");
		selenium.type("name=captionwriter", "Testing Writer");
		selenium.select("name=rightsmarked", "label=Copyrighted");
		selenium.type("name=rights", "Testing Copyright Notice");
		selenium.type("name=webstatement", "www.testing.com");
		selenium.click("//div[@id='meta']/a[2]/div");
		selenium.click("//div[@id='meta']/a[2]/div");
		selenium.click("xpath=(//input[@name='submit'])[2]");
		selenium.isTextPresent("The record has been updated successfully");
		Super.doRazLogout();
	}
	
}