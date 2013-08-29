// component extends testRazunaBase
component extends="TestRazunaBase"{
	//Move Collection Files
	function testMoveTrash(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Collections");
		selenium.setspeed("1000");
		selenium.click("link=Test_Folder");
		//selenium.click("css=.clicked");
		selenium.click("link=Collection Settings");
		selenium.click("name=trashfolder");
		selenium.click("name=trash");
		//Super.doRazLogout();
	}
	// Move All 
	
}
