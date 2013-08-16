// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add User 
	function testAddUser() {
		Super.doRazLogin();
		selenium.click("link=admin admin");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Users");
		selenium.setspeed("1000");
		selenium.click("link=Add User");
		selenium.click("name=SubmitUser");
		selenium.setspeed("1000");
		selenium.click("link=Users");
		selenium.click("link=Add User");
		selenium.click("name=user_active");
		selenium.type("id=user_email", "john@gmail.com");
		selenium.type("id=user_login_name", "John");
		selenium.type("id=user_pass", "12345");
		selenium.type("id=user_pass_confirm", "12345");
		selenium.type("id=user_first_name", "John");
		selenium.type("id=user_last_name", "David");
		selenium.type("name=user_salutation", "Welcome");
		selenium.type("document.userdetailadd.user_company", "razuna");
		selenium.type("name=user_phone", "02254629874");
		selenium.type("name=user_fax", "04485698753");
		selenium.type("name=user_mobile", "9876543210");
		selenium.click("xpath=(//a[contains(text(),'Groups')])[2]");
		selenium.click("name=admin_group_2");
		selenium.click("name=SubmitUser");
		selenium.click("link=Search");
		selenium.type("id=user_login_name2", "john");
		selenium.click("name=Button");
		selenium.setspeed("1000");
		selenium.click("link=John");
		selenium.type("id=user_email", "Michael@gmail.com");
		selenium.type("id=user_login_name", "Michael");
		selenium.type("id=user_first_name", "Michael");
		selenium.click("name=SubmitUser");
		selenium.click("xpath=(//a[contains(text(),'Groups')])[2]");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");

		// Export to CSV
		selenium.click("link=Export");
		selenium.click("link=Export to CSV");
		selenium.waitForPopUp("", "1000");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		
		// Export to Excel as XLSx
		selenium.click("link=Export");
		selenium.click("link=Export to Excel as XLSx");
		selenium.waitForPopUp("", "1000");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		
		// Export to Excel as XLS
		selenium.click("link=Export");
		selenium.click("link=Export to Excel as XLS");
		selenium.waitForPopUp("", "1000");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}