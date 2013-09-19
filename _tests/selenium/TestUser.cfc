// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Add User	
	function testAdduser() {
		Super.doRazLogin();
		selenium.click("css=##apDiv1 > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > a:nth-child(1)");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Users");
		selenium.setspeed("1000");
		selenium.click("link=Add User");
		selenium.click("name=SubmitUser");
		selenium.click("//div[11]/div/button");
		selenium.click("link=Add User");
		selenium.click("name=user_active");
		selenium.type("id=user_email", "John@gmail.com");
		selenium.type("id=user_login_name", "John");
		selenium.click("link=Generate password");
		selenium.type("id=user_first_name", "John");
		selenium.type("id=user_last_name", "David");
		selenium.type("name=user_salutation", "Hi");
		selenium.type("document.userdetailadd.user_company", "Razuna");
		selenium.type("name=user_phone", "02254629874");
		selenium.type("name=user_fax", "04485698753");
		selenium.type("name=user_mobile", "9876543210");
		selenium.click("name=SubmitUser");
		// Search and Modify User
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
		if(selenium.isElementPresent("link=API Key") EQ true){
		selenium.click("link=API Key");
		selenium.click("link=you can reset the API key");
		selenium.click("name=SubmitUser");
		}
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		// Export User
		selenium.click("link=Export");
		selenium.click("link=Export to CSV");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.click("link=Export to Excel as XLSx");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.click("link=Export to Excel as XLS");
		selenium.selectWindow("name=undefined");
		selenium.click("css=a > strong");
		selenium.selectWindow("null");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		// Import User
		selenium.click("link=Import");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\doc\razuna-users-export.csv");
		selenium.click("name=submitbutton");
		selenium.click("//div[11]/div/button");
		selenium.click("link=Import");
		selenium.click("document.form_meta_imp.file_format[1]");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\doc\razuna-users-export.xlsx");
		selenium.click("name=submitbutton");
		selenium.click("//div[11]/div/button");
		selenium.click("link=Import");
		selenium.click("document.form_meta_imp.file_format[2]");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\doc\razuna-users-export.xls");
		selenium.click("name=submitbutton");
		selenium.click("//div[11]/div/button");
		Super.doRazLogout();
	}
}