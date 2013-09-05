// component extends mxunit.framework.TestCase
component extends="TestRazunaBase"{
	function testAddServer(){
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("link=Uploads");
		selenium.click("//div[@id='tooltip']/a/div/button");
		//Add files from Server
		selenium.setspeed("1000");
		selenium.click("link=Add from server");
		selenium.type("id=folder_path", #expandPath('.')# & "\assets\img"); 
		selenium.click("css=input.button");
		selenium.click("//input[@value='Import from path']");
		selenium.setspeed("1000");
	}
	//Add files from Email
	function testEmailAdd(){	
		selenium.click("link=Add from email");
		selenium.type("//input[@id='email_server']", "pop");
		selenium.type("//input[@id='email_address']", "test@popmail.com");
		selenium.type("//input[@id='email_pass']", "1234");
		selenium.type("//input[@id='email_subject']", "testing");
		selenium.click("name=submit");
		Super.doRazLogout();
		
	}
}
