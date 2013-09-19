// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Restore One
	 function testRestoreOne() {
		Super.doRazLogin();
		selenium.setspeed("3000");
		selenium.click("link=Trash");
		selenium.click("css=div.assetbox:nth-child(1) > div:nth-child(2) > div:nth-child(1) > input:nth-child(1)");
		selenium.click("//div[@id='folderselectionallform_assets']/a/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		//Delete 
		selenium.click("css=div.assetbox:nth-child(1) > div:nth-child(2) > div:nth-child(1) > input:nth-child(1)");
		selenium.click("//div[@id='folderselectionallform_assets']/a[2]/div[2]");
		selenium.click("name=remove");
    }
    //Restore All
    function testRestoreFilesAll(){
    	selenium.click("link=Trash");
    	selenium.setspeed("3000");
		selenium.click("css=##assets > div:nth-child(1) > a:nth-child(1) > div:nth-child(1)");
		selenium.click("//div[@id='assets']/div/a[3]/div");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		Super.doRazLogout();
	}
}