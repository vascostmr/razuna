// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Widget
	function testWidget() {
		selenium.click("link=Widgets");
		selenium.click("//input[contains(@value,'Add Widget')]");
		selenium.type("id=widget_name", "TestWidget");
		selenium.click("name=submitbutton");
		selenium.click("document.form_widget.widget_permission[1]");
		selenium.click("name=submitbutton");
		selenium.click("document.form_widget.widget_permission[2]");
		selenium.click("name=widget_password");
		selenium.type("name=widget_password", "12345");
		selenium.click("name=submitbutton");
		selenium.click("link=Widget Settings");
		selenium.click("document.form_widget.widget_style[1]");
		selenium.click("link=Reset setting of individual assets");
		selenium.click("id=widget_dl_org");
		selenium.click("name=widget_uploading");
		selenium.click("name=submitbutton");
		selenium.click("link=Widget Code");
		selenium.click("name=submitbutton");
		selenium.click("css=div:last-child .ui-button-icon-primary");
		Super.doRazLogout();
	}
	// Thumbnail
	function testThumbnail() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("link=Uploads");
		selenium.setspeed("3000");
		selenium.click("link=Folder Sharing & Settings");
		selenium.click("link=Thumbnail");
		selenium.type("id=thumb_folder_file", #expandpath('.')# & "\Desert.jpg");
		selenium.click("link=Reset to default");
	}
}