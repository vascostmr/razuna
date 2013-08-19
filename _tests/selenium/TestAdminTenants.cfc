// component extends testRazunaBase
component extends="TestRazunaBase"{

	//List and Add new Tenant 
	function testListAddTenants() {
		super.doLogin();
		selenium.open(browserURL &"/admin/index.cfm?fa=c.main");
		selenium.setspeed("2000");
		selenium.click("//a[contains(text(),'List/add tenants')]");
		selenium.click("link=Upgrade Settings");
		selenium.click("name=remove");
		selenium.click("link=Reset Cache");
		selenium.click("//a[contains(text(),'Add a Tenant')]");
		selenium.type("id=host_name", "Demo_openBD");
		selenium.click("id=Button");
		selenium.click("xpath=//div[@id='hostslist']/table/tbody/tr[last()]/td[last()]/a[contains(text(),'Remove')]");
		selenium.click("xpath=//div[@id='thewindowcontent1']/table/tbody/tr[2]/td/input[@name='remove']");
		selenium.click("name=remove");
	}
	
	//Tenants settings 
	function testTenantsSettings() {
		selenium.setspeed("1000");
		selenium.click("//a[contains(text(),'Tenant Settings')]");
		selenium.click("name=savebutton");
		selenium.click("link=Meta Tags");
		selenium.type("name=set_title_intra_1", "test");
		selenium.click("name=savebutton");
		selenium.click("link=Storage Location");
		selenium.setspeed("1000");
		selenium.click("name=savebutton");
	}
	
	// Load Tenant
   	function testLoadTenant() {
		selenium.setspeed("2000");
		selenium.select("id=gotodam", "label=DEMO");
		super.doLogout();
	}
	
}