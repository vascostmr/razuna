// component extends testRazunaBase
component extends="testRazunaBase"{

	// Validate Amazon S3 storage
	function testAmazonValidate() { 
		super.doLogin();
		selenium.setSpeed("1000");
		selenium.click("//a[contains(text(),'General Configuration')]");
		selenium.click("link=Storage");
		selenium.setspeed("1000");
		selenium.click("document.form_settings_global.conf_storage[2]");
		selenium.click("document.form_settings_global.validate[1]");
		selenium.click("name=save");
	}
	// Local storage
	/*function testLocalStorage() {
		selenium.click("link=Storage");
		selenium.click("name=conf_storage");
		selenium.setspeed("1000");
		selenium.click("name=save");
	}*/
	// Valid Amazon S3 storage
	function testValidAmazonStorage() {
		selenium.click("document.form_settings_global.conf_storage[2]");
		selenium.setspeed("1000");
		selenium.type("id=conf_aws_access_key", "#awsAccessKey#");
		selenium.type("id=conf_aws_secret_access_key", "#awsSecretKey#");
		selenium.select("id=conf_aws_location", "label=EU (Ireland)");
		selenium.click("document.form_settings_global.validate[1]");
		selenium.setspeed("1000");
		selenium.click("name=save");
	}
	// Invalid Amazon S3
	function testAmazonInvalid() {
		selenium.click("document.form_settings_global.conf_storage[2]");
		selenium.type("id=conf_aws_access_key", "#InvalidAwsAccessKey#");
		selenium.type("id=conf_aws_secret_access_key", "#InvalidAwsSecretKey#");
		selenium.click("document.form_settings_global.validate[1]");
	}
	function testLocal(){
		selenium.click("link=Storage");
		selenium.click("name=conf_storage");
		selenium.setspeed("1000");
		selenium.click("name=save");
	}
	// Backup & Restore
	function testBackup() {
		selenium.click("link=Backup & Restore");
		selenium.setspeed("1000");
		selenium.click("name=save");
		super.doLogout();
	}
}