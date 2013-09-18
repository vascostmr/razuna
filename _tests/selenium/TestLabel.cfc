// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Add Label 
	function testLabels() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("css=##apDiv1 > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > a:nth-child(1)");
		selenium.click("link=Administration");
		selenium.setspeed("2000");
		selenium.click("xpath=(//a[contains(text(),'Labels')])[2]");
		selenium.check("css=input[name='labels_public'][value='t']");
		selenium.click("id=label_text_admin");
		selenium.type("id=label_text_admin", "TestLabel");
		selenium.click("//input[@value='Add Label']");
		selenium.click("link=TestLabel");
		selenium.select("id=sublabelofedit", "label=Move to root");
		selenium.click("name=savecomment");
		selenium.click("//div[@id='admin_labels']/table/tbody/tr[4]/td[2]/a/img");
		selenium.click("name=remove");
		Super.doRazLogout();
	}
}