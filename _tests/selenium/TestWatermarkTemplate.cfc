// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add Watermark Template 
	function testWatermarkTemplate() {
		Super.doRazLogin();
		selenium.click("link=admin admin");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Watermark Templates");
		selenium.click("link=Add a Watermark Template");
		selenium.setspeed("1000");
		selenium.click("name=wm_active");
		selenium.type("id=wm_name", "Test_watermark");
		selenium.click("name=wm_use_image");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\img\Desert.jpg"); 
		selenium.waitForPageToLoad( timeout );
		selenium.select("name=wm_image_position", "label=Upper right corner");
		selenium.click("name=wm_use_text");
		selenium.type("name=wm_text_content", "Hello World");
		selenium.select("name=wm_text_font", "label=Helvetica Bold");
		selenium.select("name=wm_text_position", "label=Upper left corner");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}