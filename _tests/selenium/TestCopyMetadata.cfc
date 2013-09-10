// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Select all
	function testSelectAll() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='img']/a[contains(text(),'Images')]");
		selenium.setspeed("4000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='img']");
		selenium.setspeed("2000");
		selenium.click("link=Meta Data");
		selenium.setspeed("2000");
		selenium.click("css=div##meta.collapsable div button.button");
		selenium.type("id=searchtext", "jpg, png, gif, bmp, tif");
		selenium.click("//button[@onclick='copy_meta();return false;']");
		selenium.click("id=selectallcm");
		selenium.click("id=apply");
	}
	// Select Folder
	function testSelectFolder() {
		selenium.click("//div[@id='container']/div/a/button");
		selenium.click("xpath=//div[@id='win_choosefolder']/ul[@class='ltr']/li[@class='last leaf']/a");
		selenium.click("id=selectallcm");
		selenium.click("css=input[name='insert_type'][type='radio'][value='append']");
		selenium.click("id=apply");
		selenium.click("//div[11]/div/button");
		Super.doRazLogout();
	}
}