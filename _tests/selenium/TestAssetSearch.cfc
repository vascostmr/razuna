// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Search Assets
	function testSearch() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("id=simplesearchtext");
		selenium.type("id=simplesearchtext", "Test");
		selenium.click("//form[@id='form_simplesearch']/div/div[4]/button");
		selenium.click("css=img.ddicon");
		selenium.click("link=Images only");
		selenium.click("//form[@id='form_simplesearch']/div/div[4]/button");
		selenium.click("css=img.ddicon");
		selenium.click("link=Documents only");
		selenium.click("//form[@id='form_simplesearch']/div/div[4]/button");
		selenium.click("id=searchselectionlink");
		selenium.click("link=Videos only");
		selenium.click("//form[@id='form_simplesearch']/div/div[4]/button");
		selenium.click("id=searchselectionlink");
		selenium.click("link=Audios only");
		selenium.click("//form[@id='form_simplesearch']/div/div[4]/button");
		selenium.click("link=Advanced Search");
		selenium.type("id=searchforadv_all", "Test");
		selenium.click("name=submitsearch");
		selenium.click("//form[@id='form_searchsearch']/table/tbody/tr[2]/td/div[3]/button");
		selenium.type("id=s_filename", "Desert");
		selenium.click("//form[@id='form_searchsearch']/table/tbody/tr[2]/td/div[3]/button");
		selenium.type("id=s_filename", "");
		selenium.type("id=s_keywords", "Test keywords");
		selenium.click("//form[@id='form_searchsearch']/table/tbody/tr[2]/td/div[3]/button");
		selenium.type("id=s_keywords", "");
		selenium.type("id=s_description", "Test description");
		selenium.click("//form[@id='form_searchsearch']/table/tbody/tr[2]/td/div[3]/button");
		selenium.type("id=s_description", "");
		Super.doRazLogout();
	}
	
}