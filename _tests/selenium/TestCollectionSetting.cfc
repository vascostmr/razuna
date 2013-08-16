// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Collection Settings
	function testCollectionSetting() {
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Collections");
		selenium.click("css=a[rel=prefetch]");
		selenium.click("link=Collection Settings");
		selenium.click("name=grp_0");
		selenium.click("name=perm_inherit");
		selenium.click("id=foldersubmitbutton");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.setspeed("1000");
		selenium.click("link=Test_Collection");
		selenium.click("link=Description & Keywords");
		selenium.click("css=input[name=submit]");
		selenium.click("link=Comments");
		selenium.type("id=assetComment", "Test collection comment");
		selenium.click("css=td > input.button");
		selenium.click("link=Settings & Share");
		selenium.click("name=grp_0");
		//setting and share
		selenium.click("name=col_shared");
		selenium.click("id=share_dl_org");
		selenium.click("name=share_comments");
		selenium.click("name=share_upload");
		selenium.click("name=share_order");
		selenium.setspeed("1000");
		selenium.click("css=input[name=submit]");
		selenium.click("link=Widgets");
		selenium.click("css=input[value='Add Widget']");
		selenium.type("id=widget_name", "Test_widget");
		selenium.click("name=submitbutton");
		selenium.click("link=Widget Settings");
		selenium.click("name=submitbutton");
		selenium.click("link=Widget Code");
		selenium.click("name=submitbutton");
		selenium.click("//div[10]/div/a/span");
		selenium.click("//a[contains(text(),'Assets in this Collection')]");
		selenium.click("//input[@value='Save']");
		// After adding assets
		/*selenium.click("name=buttoncopy");
		selenium.click("//input[@value='Release Collection']");*/
		Super.doRazLogout();
	}
}