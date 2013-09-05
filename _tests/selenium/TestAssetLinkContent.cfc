// component extends testRazunaBase
component extends="TestRazunaBase"{
	 //Add files link to content
	function testLinkToContent(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.click("//div[@id='tooltip']/a/div/button");
		selenium.click("css=div##tab_addassets > ul:nth-child(1) > li:nth-child(5) > a.ui-tabs-anchor");
		selenium.setspeed("1000");
		selenium.type("//textarea[@name='link_path_url']", "http://openbd.org/a/img/openbd_vector.png");
		selenium.setspeed("1000");
		selenium.type("//input[@name='link_file_name']", "OpenBd_logo");
		selenium.setspeed("1000");
		selenium.click("name=submit");
		Super.doRazLogout();
	}
	
}