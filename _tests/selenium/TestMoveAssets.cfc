// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Move Assets Files 
	function testMoveAssets(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='img']/a[contains(text(),'Images')]");
		selenium.click("css=div[class='theimg ui-selectee'][type$='img']");
		selenium.setspeed("1000");
		selenium.click("css=div##detailinfo div.collapsable div.headers a:nth-child(6)");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child a");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		selenium.click("css=button.ui-button");
	}
    //Preview image
     function testPreviewImage() {
		selenium.click("link=Upload another Preview Image");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\img\Desert.jpg");
		selenium.waitForPageToLoad("20000");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		Super.doRazLogout();
    }
    //Recreate Preview image
    function testRecreatePwImage() {
		selenium.click("link=Recreate Preview Image");
		selenium.click("//button[@type='button']");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		selenium.click("link=Uploads");
    }
    
    //Move Trash
	function testMoveTrash() {
		selenium.click("//div[@id='detailinfo']/div[@class='collapsable']/div[@class='headers']/a[7]");
		selenium.setspeed("1000");
		selenium.click("name=trash");
    }
}

