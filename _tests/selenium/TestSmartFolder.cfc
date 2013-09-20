// component extends testRazunaBase
component extends="TestRazunaBase"{

	// Dropbox folder
	function testDropbox() {
		Super.doRazLogin();
		selenium.setspeed("2000");
		selenium.click("id=mainsectionchooser");
		selenium.click("link=Smart Folders");
		selenium.click("css=div##smartfolders a button.awesome");
		selenium.type("id=sf_name", "TestDropbox");
		selenium.type("id=sf_description", "TestDropbox Description");
		selenium.click("link=Permissions");
		selenium.check("css=input[name='grp_0'][type='checkbox']");
		selenium.click("css=input[name='per_0'][value='X']");
		selenium.click("css=input[name='sfsubmit'][value='Save']");
	}

	// Amazon S3 folder
	function testAmazonS3() {
		selenium.click("link=Manage");
		selenium.click("link=New Smart Folder");
		selenium.type("id=sf_name", "TestAmazon");
		selenium.type("id=sf_description", "TestAmazon S3 Description");
		selenium.click("css=input[name='sf_type'][value='amazon']");
		selenium.click("link=Permissions");
		selenium.check("css=input[name='grp_0'][type='checkbox']");
		selenium.click("css=input[name='per_0'][value='X']");
		selenium.click("css=input[name='sfsubmit'][value='Save']");
		Super.doRazLogout();
	}
}
