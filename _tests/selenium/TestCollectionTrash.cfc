// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Remove Collection Files
	function testMoveTrash(){	
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("id=mainsectionchooser");
		selenium.setspeed("2000");
		selenium.click("css=##mainselection > a:nth-child(11)");
		selenium.click("css=div##colBox >ul:nth-child(1) > li:nth-child(1) > a:nth-child(1)");
		selenium.click("css=.list > td:nth-child(4) > a:nth-child(1) > img:nth-child(1)");
		selenium.click("css=div##div_win_trash_record >table >tbody >tr:nth-child(2)>td >input.button");
		selenium.click("css=tr.list:nth-child(3) > td:nth-child(4) > a:nth-child(1) > img:nth-child(1)");
		selenium.click("css=div##div_win_trash_record >table >tbody >tr:nth-child(2)>td >input.button");
	}
	//Restore one 
	function testRestoreOne(){
		selenium.click("link=Trash");
		selenium.click("css=div##tabsfolder_tab >ul:nth-child(1)>li:nth-child(3) >a.ui-tabs-anchor");
		selenium.click("name=file_id");
		selenium.click("//div[@id='folderselectionallform_collection']/a/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		selenium.click("css=div##colBox >ul:nth-child(1) > li:nth-child(1) > a:nth-child(1)");
	}
	//Restore All 
	function testRestoreAll(){
		selenium.click("link=Trash");
		selenium.click("css=div##tabsfolder_tab >ul:nth-child(1)>li:nth-child(3) >a.ui-tabs-anchor");
		selenium.click("css=##collections > div:nth-child(1) > a:nth-child(3) > div:nth-child(1)");
		selenium.click("//div[@id='folderselectionallform_collection']/a/div[2]");
		selenium.click("css=div##win_choosefolder ul.ltr li:first-child  a");
		selenium.click("css=div##colBox >ul:nth-child(1) > li:nth-child(1) > a:nth-child(1)");
		Super.doRazLogout();
	}
}
