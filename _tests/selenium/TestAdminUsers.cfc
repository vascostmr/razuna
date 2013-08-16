// component extends testRazunaBase
component extends="TestRazunaBase"{

	//Validate and Add User 
	function testAddUsers() {
		Super.doLogin();
		selenium.setSpeed("1000");
		selenium.click("//a[contains(text(),'Users')]");
		selenium.click("link=Add User");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.click("link=Add User");
		selenium.type("id=user_email", "John_david@gmail.com");
		selenium.type("id=user_login_name", "John");
		selenium.type("id=user_pass", "12345");
		selenium.type("id=user_pass_confirm", "12345");
		selenium.type("id=user_first_name", "John");
		selenium.type("id=user_last_name", "David");
		selenium.type("name=user_salutation", "Welcome");
		selenium.type("document.userdetailadd.user_company", "Razuna");
		selenium.type("name=user_phone", "04422546854");
		selenium.type("name=user_fax", "04485698753");
		selenium.type("name=user_mobile", "9876543210");
		selenium.click("name=SubmitUser");
		selenium.click("link=Groups");
		selenium.click("id=admin_group_1");
		selenium.click("name=SubmitUser");
		selenium.click("link=Tenants/Hosts");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
	}

	// Search for User
	function testSearchUser() {
		selenium.click("//a[contains(text(),'Users')]");
		selenium.setSpeed("1000");
		selenium.type("id=user_login_name2", "John");
		selenium.click("name=Button");
		selenium.click("link=John");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doLogout();
	}

}