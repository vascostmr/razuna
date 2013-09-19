// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Log 
	function testLog() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("css=##apDiv1 > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > a:nth-child(1)");
		selenium.click("link=Administration");
		selenium.setspeed("2000");
		selenium.click("link=Logs");
		selenium.select("id=actionsassets", "label=Add");
		selenium.select("id=actionsassets", "label=Update");
		selenium.select("id=actionsassets", "label=Delete");
		selenium.select("id=actionsassets", "label=Move");
		selenium.select("id=actionsassets", "label=Renditions");
		selenium.click("xpath=(//a[contains(text(),'Search')])[6]");
		selenium.type("id=searchtext", "Desert");
		selenium.click("name=search");
		selenium.click("link=Searches (Summarized)");
		selenium.click("xpath=(//a[contains(text(),'Images only')])[2]");
		selenium.click("xpath=(//a[contains(text(),'Documents only')])[2]");
		selenium.click("xpath=(//a[contains(text(),'Videos only')])[2]");
		selenium.click("link=Searches");
		selenium.click("xpath=(//a[contains(text(),'Folders')])[4]");
		selenium.click("link=User Actions");
		selenium.click("link=Errors");
		selenium.click("link=Assets");
		Super.doRazLogout();
	}
}