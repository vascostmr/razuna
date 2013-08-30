// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Views and Sort By
	function testSortBy() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("3000");
		// Views
		selenium.click("link=Views");
		selenium.click("css=a[title='List View'] > div");
		selenium.click("link=Views");
		selenium.click("css=a[title='Combined/Quick Edit View'] > div");
		selenium.click("link=Views");
		selenium.click("css=a[title='Thumbnail View'] > div");
		// Sort By
		selenium.select("id=selectsortbyallb", "label=Type of Asset");
		selenium.select("id=selectsortbyallb", "label=Size (Descending)");
		selenium.select("id=selectsortbyallb", "label=Size (Ascending)");
		selenium.select("id=selectsortbyallb", "label=Date Added");
		selenium.select("id=selectsortbyallb", "label=Last Changed");
		selenium.select("id=selectsortbyallb", "label=Same file");
		selenium.select("id=selectsortbyallb", "label=Name");
		// Pagination
		if (selenium.isElementPresent("link=Next >") EQ true) {
		selenium.click("link=Next >");
		selenium.click("link=< Back");
		selenium.select("id=thepagelistall", "label=2");
		selenium.select("id=thepagelistall", "label=1");
		selenium.select("id=selectrowperpageallb", "label=50");
		selenium.select("id=selectrowperpageallb", "label=75");
		selenium.select("id=selectrowperpageallb", "label=100");
		selenium.select("id=selectrowperpageallb", "label=25");
		}
		Super.doRazLogout();
	}
}