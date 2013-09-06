// component extends mxunit.framework.TestCase
component extends="TestRazunaBase"{

	// Plugins 
	function testPlugins() {
		super.doLogin();
		selenium.setspeed('2000');
		selenium.open( browserURL & "/admin/index.cfm?fa=c.main");
		selenium.click("//a[contains(text(),'Plugins')]");
		selenium.click("link=Add new");
		// adding some dummy zip files
		selenium.type("id=thefile", #expandpath('.')# & "\assets\doc\Test.zip"); 
		selenium.click("name=save");
		selenium.isTextPresent( "Plugin has been uploaded successfully." );
		selenium.click("link=Activate");
	}
	//Plugins tenants activation
	function testPluginHost() {
		selenium.click("link=Plugin tenant activation");
		selenium.click("link=Select all");
		selenium.click("//input[@name='savebutton']");
	}
	//Plugin Deactivate
	function testPluginDeactivate() {
		selenium.click("link=Plugins");
		selenium.click("link=Deactivate");
		super.doLogout();
	}
}