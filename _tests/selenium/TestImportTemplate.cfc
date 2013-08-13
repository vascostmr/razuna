// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Import Template 
	function testImportTemplate() {
		Super.doRazLogin();
		selenium.click("link=admin admin");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Import Templates");
		selenium.click("link=Add a Import Template");
		selenium.click("name=imp_active");
		selenium.type("id=imp_name", "Test_import");
		selenium.type("name=imp_description", "Test_import");
		selenium.type("name=imp_description", "Test_import Description");
		selenium.click("name=SubmitUser");
		selenium.click("link=Mapping");
		selenium.type("id=field_1", "Import_Description");
		selenium.select("id=select_1", "label=description");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.click("link=Import Templates");
		selenium.click("link=Test_import");
		selenium.click("link=Mapping");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.click("//div[@id='admin_imp_templates']/table[2]/tbody/tr[2]/td[4]/a/img");
		selenium.click("name=remove");
		Super.doRazLogout();
	}
}