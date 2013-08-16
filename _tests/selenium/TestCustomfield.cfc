// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add Custom Field 
	function testCustomfield() {
		Super.doRazLogin();
		selenium.click("link=admin admin");
		selenium.click("link=Administration");
		selenium.setspeed("2000");
		selenium.click("link=Custom Fields");
		selenium.type("name=cf_text_1", "Company");
		selenium.select("name=cf_show", "label=Only for Images");
		selenium.click("name=submit");
		selenium.click("link=Company");
		selenium.select("document.form_cf_detail.cf_type", "label=Radio Button (Yes/No)");
		selenium.select("document.form_cf_detail.cf_show", "label=Only for Documents");
		selenium.setspeed("2000");
		selenium.click("css=div > input[name='submit']");
		Super.doRazLogout();
	}
}