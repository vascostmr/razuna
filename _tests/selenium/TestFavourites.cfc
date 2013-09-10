// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Favourites
	function TestFavourites(){
		Super.doRazLogin();
		selenium.setspeed("3000");
		selenium.click("link=Uploads");
		selenium.setspeed("3000");
		selenium.click("//td[@id='selectme']/div/div[2]/a[4]/img");
		// Folder to favourites
		selenium.click("//a[contains(text(),'More actions')]");
		selenium.click("//div[@id='dropcontent']/a[2]/div");
		//Show favorites
		selenium.click("link=Show Favorites");
		selenium.click("link=Refresh");
		selenium.click("//div[@id='thedropfav']/div[2]/table/tbody/tr/td/a/img");
		selenium.setspeed("2000");
		//Remove Assets from favorites
		selenium.click("link=Remove");
		selenium.click("//div[@id='thedropfav']/div[2]/table/tbody/tr/td/a/img");
		selenium.click("//div[12]/div/button");
		selenium.click("link=Remove");
		selenium.click("link=About Razuna");
		Super.doRazLogout();
	}
}