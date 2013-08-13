// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add User Group 
	function testAddUserGroup() {
		Super.doRazLogin();
		selenium.click("link=admin admin");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Groups");
		selenium.click("id=grpnew");
		selenium.type("id=grpnew", "Testing");
		selenium.click("document.grpdamadd.Button");
		selenium.setspeed("2000");
		selenium.click("link=Testing");
		selenium.type("id=grpname", "Testing group");
		selenium.click("document.grpedit.Button");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.click("//div[@id='grpdamlist']/table/tbody/tr[3]/td[2]/a/img");
		selenium.click("name=remove");
		Super.doRazLogout();
	}
}