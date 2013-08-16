// component extends testRazunaBase
component extends="TestRazunaBase"{
	//TestRaz Admin settings
	 function testRazAdminsettings() { 
	 	Super.doRazLogin();
	 	selenium.setSpeed("1000");
		selenium.click("link=admin admin");
		selenium.setSpeed("1000");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Settings");
		selenium.setspeed("1000");
		selenium.click("name=submit");
		selenium.click("link=Maintenance");
		selenium.setspeed("1000");
		selenium.setspeed("1000");
		selenium.click("name=flushdb");
		selenium.setspeed("1000");
		Super.doRazLogout();
	}
	

}