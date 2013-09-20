// component extends testRazunaBase
component extends="TestRazunaBase"{
	// Videos Rendition
	function testVideosRendition(){
		Super.doRazLogin();
		selenium.setspeed("1000");
		selenium.click("link=Uploads");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='vid']/a[contains(text(),'Videos')]");
		selenium.setspeed("4000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='vid']");
		selenium.click("link=Renditions");
		selenium.click("link=View");
		selenium.click("link=Download");
		selenium.click("link=Direct Link");
		selenium.click("link=Direct Link");
		selenium.click("link=Embed");
		selenium.click("link=Embed"); 
		selenium.check("css=input[name = 'convert_to'][value='ogv']");
		selenium.select("id=preset_ogv", "label=352x288");
		selenium.check("css=input[name = 'convert_to'][value='webm']");
		selenium.select("id=preset_webm","label=320x200");
		selenium.check("css=input[name = 'convert_to'][value='flv']");
		selenium.select("id=preset_flv","label=320x240");
		selenium.check("css=input[name = 'convert_to'][value='mp4']");
		selenium.select("id=preset_mp4","label=352x288");
		selenium.check("css=input[name = 'convert_to'][value='wmv']");
		selenium.select("id=preset_wmv","label=800x600");
		selenium.check("css=input[name = 'convert_to'][value='avi']");
		selenium.select("id=preset_avi","label=1408x1152");
		selenium.check("css=input[name = 'convert_to'][value='mov']");
		selenium.select("id=preset_mov","label=2560x2048");
		selenium.check("css=input[name = 'convert_to'][value='mxf']");
		selenium.select("id=preset_mxf","label=3200x2048");
		selenium.check("css=input[name = 'convert_to'][value='mpg']");
		selenium.select("id=preset_mpg","label=6400x4096");
		selenium.check("css=input[name = 'convert_to'][value='3gp']");
		selenium.select("name=convert_wh_3gp","label=352x288 (No size limit)");
		selenium.check("css=input[name = 'convert_to'][value='rm']");
		selenium.select("id=preset_rm","label=640x480");
		selenium.click("name=convertbutton");
		selenium.click("//div[11]/div/button");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='vid']/a[contains(text(),'Videos')]");
		selenium.setspeed("2000");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='vid']/a[contains(text(),'Videos')]");
		selenium.setspeed("4000");
		selenium.click("css=div[class='theimg ui-selectee'][type$='vid']");
		selenium.setspeed("2000");
		selenium.click("link=Renditions");
		selenium.setspeed("3000");
		selenium.click("link=Refresh");
		if(selenium.isElementPresent("css=a:contains('Create new Renditions')") EQ true){
		selenium.click("xpath=(//a[contains(text(),'Metadata')])[2]");
		selenium.type("xpath=(//textarea[@name='vid_desc_1'])[2]", "Testing Description");
		selenium.type("xpath=(//textarea[@name='vid_keywords_1'])[2]", "Testing keyword");
		selenium.click("xpath=(//input[@name='submit'])[3]");
		selenium.isTextPresent("The record has been updated successfully");
		selenium.click("link=Create new Renditions");
		selenium.check("css=input[name = 'convert_to'][id='ogvid']");
		selenium.select("xpath=(//select[@id='preset_ogv'])[2]", "label=352x288");
		selenium.check("css=input[name = 'convert_to'][id='webmid']");
		selenium.select("xpath=(//select[@id='preset_webm'])[2]","label=320x200");
		selenium.check("css=input[name = 'convert_to'][id='flvid']");
		selenium.select("xpath=(//select[@id='preset_flv'])[2]","label=320x240");
		selenium.check("css=input[name = 'convert_to'][id='mp4id']");
		selenium.select("xpath=(//select[@id='preset_mp4'])[2]","label=352x288");
		selenium.check("css=input[name = 'convert_to'][id='wmvid']");
		selenium.select("xpath=(//select[@id='preset_wmv'])[2]","label=800x600");
		selenium.check("css=input[name = 'convert_to'][id='aviid']");
		selenium.select("xpath=(//select[@id='preset_avi'])[2]","label=1408x1152");
		selenium.check("css=input[name = 'convert_to'][id='movid']");
		selenium.select("xpath=(//select[@id='preset_mov'])[2]","label=2560x2048");
		selenium.check("css=input[name = 'convert_to'][id='mxfid']");
		selenium.select("xpath=(//select[@id='preset_mxf'])[2]","label=3200x2048");
		selenium.check("css=input[name = 'convert_to'][id='mpgid']");
		selenium.select("xpath=(//select[@id='preset_mpg'])[2]","label=6400x4096");
		selenium.check("css=input[name = 'convert_to'][id='3gpid']");
		selenium.select("xpath=(//select[@name='convert_wh_3gpid'])","label=352x288 (No size limit)");
		selenium.check("css=input[name = 'convert_to'][id='rmid']");
		selenium.select("xpath=(//select[@id='preset_rm'])[2]","label=640x480");
		selenium.click("name=convertbutton");
		selenium.click("link=Delete");
		selenium.click("//button[@type='button']");
		}
		Super.doRazLogout();
	}
}