// component extends testRazunaBase
component extends="TestRazunaBase"{

	//Import Template 
	function testImportTemplate() {
		Super.doRazLogin();
		selenium.click("css=##apDiv1 > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > a:nth-child(1)");
		selenium.click("link=Administration");
		selenium.setspeed("3000");
		selenium.click("link=Import Templates");
		selenium.click("link=Add a Import Template");
		selenium.click("name=imp_active");
		selenium.type("id=imp_name", "TestImport");
		selenium.type("name=imp_description", "TestImport");
		selenium.type("name=imp_description", "TestImport Description");
		selenium.click("name=SubmitUser");
		selenium.click("link=Mapping");
		selenium.type("id=field_1", "ImportDescription");
		selenium.select("id=select_1", "label=description");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.click("link=Import Templates");
		selenium.click("link=TestImport");
		selenium.click("link=Mapping");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}