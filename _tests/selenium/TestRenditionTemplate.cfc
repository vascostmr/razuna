// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Add Rendition Template 
	function testRenditionTemplate() {
		Super.doRazLogin();
		selenium.click("link=admin admin");
		selenium.click("link=Administration");
		selenium.setspeed("1000");
		selenium.click("link=Rendition Templates");
		selenium.click("link=Add a template");
		selenium.click("name=upl_active");
		selenium.type("id=upl_name", "Test_rendition");
		selenium.click("name=SubmitUser");
		selenium.click("link=Images");
		selenium.click("name=convert_to");
		selenium.type("id=convert_width_jpg", "300");
		selenium.click("name=SubmitUser");
		selenium.click("link=Videos");
		selenium.click("document.formupltemp.convert_to[78]");
		selenium.select("name=convert_wh_3gp", "label=176x144 (300K)");
		selenium.click("name=SubmitUser");
		selenium.click("link=Audios");
		selenium.click("document.formupltemp.convert_to[84]");
		selenium.select("id=convert_bitrate_mp3", "label=96");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.click("link=Test_rendition");
		selenium.click("link=Images");
		selenium.click("link=Videos");
		selenium.click("link=Audios");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}