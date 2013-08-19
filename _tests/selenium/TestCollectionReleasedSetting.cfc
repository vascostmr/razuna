// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Collections Released Settings
	function testCollectionSetting() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Collections");
		selenium.click("css=a[rel=prefetch]");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[2]/a[contains(text(),'Collections Released')]");
		selenium.click("link=Collection Settings");
		selenium.click("name=grp_0");
		selenium.check("css=input[name='per_0'][value='X']");
		selenium.click("css=input[name='perm_inherit'][value='T']");
		selenium.click("id=foldersubmitbutton");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.setspeed("1000");
		selenium.click("link=Test_Collection copy");
		// Description & Keywords
		selenium.click("link=Description & Keywords");
		selenium.click("css=input[name=submit]");
		// Comment
		selenium.click("link=Comments");
		selenium.type("id=assetComment", "Test collection comment");
		selenium.click("css=td > input.button");
		selenium.click("//a[contains(text(),'Edit')]");
		selenium.type("id=commentup","Test collection commented");
		selenium.check("css=input[name='savecomment'][value='Update']");
		selenium.click("//a[contains(text(),'Remove')]");
		selenium.click("css=input[name='remove'][value='Remove Record']");
		// Setting and share
		selenium.click("link=Settings & Share");
		selenium.click("name=grp_0");
		selenium.check("css=input[name='per_0'][value='X']");
		selenium.click("//a[contains(text(),'Reset setting of individual assets')]");
		selenium.click("name=col_shared");
		selenium.click("id=share_dl_org");
		selenium.click("name=share_comments");
		selenium.click("name=share_upload");
		selenium.click("name=share_order");
		selenium.setspeed("1000");
		selenium.click("css=input[name=submit]");
		// Widgets
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
		selenium.click("//a[contains(text(),'Reset setting of individual assets')]");
		selenium.click("id=widget_dl_org");
		selenium.click("name=widget_uploading");
		selenium.click("name=submitbutton");
		selenium.click("link=Widget Code");
		selenium.click("name=submitbutton");
		selenium.click("//div[10]/div/a/span");
		selenium.setspeed("1000");
		selenium.click("//a[contains(text(),'Assets in this Collection')]");
		selenium.click("//input[@value='Save']");
		// After adding assets
		//selenium.click("//em/a[contains(text(),'Un-Release it, if you need to make changes')]");
		Super.doRazLogout();
	}
}