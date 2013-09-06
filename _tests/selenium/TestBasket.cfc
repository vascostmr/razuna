// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Put in Basket
	function TestBasket(){
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
		selenium.click("link=Select all");
		selenium.click("//div[@id='folderselectionallform']/a/div[2]");
		selenium.click("link=Show Basket");
		selenium.setspeed("1000");
		//Checkout link in basket	
		selenium.click("link=Checkout basket");
		selenium.setspeed("2000");
		//Download
		selenium.click("//input[@value='Download']");
		selenium.setspeed("5000");
		//Save & Publish Basket Save as ZIP
		selenium.click("//input[@value='Save & publish Basket']");
		selenium.setspeed("2000");
		selenium.click("name=saveaszip");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='win_choosefolder']/ul[@class='ltr']/li[@class='last leaf']/a");
		selenium.click("name=save");
		selenium.setspeed("3000");
		//Save & Publish Basket Save as Collection
		selenium.click("//input[@value='Save & publish Basket']");
		selenium.setspeed("2000");
		selenium.click("name=saveascol");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='win_choosefolder']/ul[@class='ltr']/li[@class='last leaf']/a");
		selenium.type("id=collectionname", "testing");
		selenium.setspeed("1000");
		selenium.click("name=save");
		selenium.setspeed("2000");
		//Save & Publish Basket Save as Choose Collection
		selenium.click("//input[@value='Save & publish Basket']");
		selenium.setspeed("2000");
		selenium.click("xpath=(//input[@name='saveascol'])[2]");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='win_choosefolder']/ul[@class='ltr']/li[@class='last leaf']/a");
		selenium.setspeed("2000");
		selenium.click("link=testing");
		selenium.setspeed("2000");
		// Email Basket
		selenium.click("//input[@value='email Basket']");
		selenium.setspeed("5000");
		selenium.type("name=to", "testing@test.com");
		selenium.type("name=cc", "tester@test.com");
		selenium.type("name=bcc", "admin@test.com");
		selenium.type("name=subject", "Testing subject");
		selenium.type("name=message", "Testing Messages.");
		selenium.click("name=submitbutton");
		selenium.setspeed("2000");
		//Export Metadata CSV Format
		selenium.click("link=Export metadata");
		selenium.setspeed("2000");
		selenium.click("//input[@value='Export']");
		selenium.setspeed("1000");
		//Export Metadata XLS Format
		selenium.click("link=Export metadata");
		selenium.setspeed("2000");
		selenium.select("id=export_format", "label=XLS");
		selenium.click("//input[@value='Export']");
		selenium.setspeed("1000");
		//Export Metadata XLSX Format
		selenium.click("link=Export metadata");
		selenium.setspeed("2000");
		selenium.select("id=export_format", "label=XLSX");
		selenium.click("//input[@value='Export']");
		selenium.setspeed("1000");
		//Remove Basket
		selenium.click("//input[@value='Remove Basket']");
		selenium.setspeed("2000");	
		selenium.click("name=remove");
		selenium.setspeed("4000");
		
		//Other links in Basket
		selenium.click("link=test");
		selenium.setspeed("3000");
		selenium.click("link=Select all");
		selenium.click("//div[@id='folderselectionallform']/a/div[2]");
		selenium.click("link=Show Basket");
		selenium.setspeed("1000");
		//Remove An Asset
		selenium.click("link=Remove");
		selenium.setspeed("1000");
		//Reload basket	
		selenium.click("link=Reload basket");
		selenium.setspeed("1000");
		//Export Metadata CSV Format
		selenium.click("link=Export metadata");
		selenium.setspeed("2000");
		selenium.click("//input[@value='Export']");
		selenium.setspeed("1000");
		//Export Metadata XLS Format
		selenium.click("link=Export metadata");
		selenium.setspeed("2000");
		selenium.select("id=export_format", "label=XLS");
		selenium.click("//input[@value='Export']");
		selenium.setspeed("1000");
		//Export Metadata XLSX Format
		selenium.click("link=Export metadata");
		selenium.setspeed("2000");
		selenium.select("id=export_format", "label=XLSX");
		selenium.click("//input[@value='Export']");
		selenium.setspeed("1000");
		//Clear basket	
		selenium.click("link=Clear basket");
		selenium.setspeed("1000");
		Super.doRazLogout();
	}
}
