// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add Watermark Template 
	function testWatermarkTemplate() {
		Super.doRazLogin();
		selenium.click("css=##apDiv1 > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > a:nth-child(1)");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Watermark Templates");
		selenium.click("link=Add a Watermark Template");
		selenium.click("css=input[name='wm_active'][value='true']");
		selenium.type("id=wm_name", "Test_watermark");
		selenium.click("css=input[name='wm_use_image'][value='true']");
		selenium.type("id=filedata", #expandpath('.')# & "\assets\img\Desert.jpg"); 
		selenium.waitForPageToLoad( timeout );
		selenium.select("name=wm_image_position", "label=Upper right corner");
		selenium.click("css=input[name='wm_use_text'][value='true']");
		selenium.type("name=wm_text_content", "Hello World");
		selenium.select("name=wm_text_font", "label=Helvetica Bold");
		selenium.select("name=wm_text_position", "label=Upper left corner");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}