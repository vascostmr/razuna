// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Folder Content Options
	function testFolderOptions() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("1000");
		// Sort By
		selenium.click("id=selectsortbyallb");
		selenium.select("id=selectsortbyallb", "label=Type of Asset");
		selenium.click("id=selectsortbyallb");
		selenium.select("id=selectsortbyallb", "label=Size (Descending)");
		selenium.click("id=selectsortbyallb");
		selenium.select("id=selectsortbyallb", "label=Size (Ascending)");
		selenium.click("id=selectsortbyallb");
		selenium.select("id=selectsortbyallb", "label=Date Added");
		selenium.click("id=selectsortbyallb");
		selenium.select("id=selectsortbyallb", "label=Last Changed");
		selenium.click("id=selectsortbyallb");
		selenium.select("id=selectsortbyallb", "label=Same file");
		selenium.click("id=selectsortbyallb");
		selenium.select("id=selectsortbyallb", "label=Name");
		// Views
		selenium.click("link=Views");
		selenium.click("css=a[title='List View'] > div");
		selenium.click("link=Views");
		selenium.click("css=a[title='Combined/Quick Edit View'] > div");
		selenium.click("link=Views");
		selenium.click("css=a[title='Thumbnail View'] > div");
		Super.doRazLogout();
	}
}