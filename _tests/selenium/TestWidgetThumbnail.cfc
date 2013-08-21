// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Widget
	function testWidgetThumbnail() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.click("link=Folder Sharing & Settings");
		selenium.click("link=Widgets");
		selenium.click("//input[@value='Add Widget']");
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
		selenium.click("//div[11]/div/a/span");
		selenium.click("link=Thumbnail");
		selenium.type("id=thumb_folder_file", #expandpath('.')# & "\Desert.jpg");
		selenium.click("link=Reset to default");
		selenium.waitForPageToLoad("30000");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}