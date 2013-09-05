// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Put in Basket
	function testPutBasket() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.click("css=img.ui-selectee");
		selenium.setspeed("1000");
		selenium.click("//div[@id='detailinfo']/div/div/a/div[2]");
		selenium.setspeed("1000");
	}
	// Send Via Email
	function testSendViaEmail() {
		selenium.click("//div[@id='detailinfo']/div/div/a[2]/div[2]");
		selenium.setspeed("1000");
		selenium.type("id=to", "test@a.com");
		selenium.type("name=cc", "test@test.com");
		selenium.type("name=bcc", "cfmitrah.test@gmail.com");
		selenium.type("id=subject", "image");
		selenium.click("css=input[name='artofimage'][value='thumb']");
		selenium.click("css=input[name='artofimage'][value='original']");
		selenium.click("name=submitbutton");
		selenium.setspeed("1000");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		// Add to existing collection
		selenium.click("css=div##detailinfo div.collapsable div.headers a:nth-child(4)");
		selenium.click("//div[@id='detailinfo']/div/div/a[4]/div[2]");
		selenium.setspeed("1000");
		selenium.click("xpath=//div[@id='win_choosefolder']/ul[@class='ltr']/li[@class='last leaf']/a");
		selenium.click("css=td > a > strong");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		// Print details
		selenium.click("css=div##detailinfo div.collapsable div.headers a:nth-child(5)"); 
		selenium.select("name=pagetype", "label=A4");
		selenium.click("//input[@value='Create PDF now']");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		Super.doRazLogout();
	}
} 