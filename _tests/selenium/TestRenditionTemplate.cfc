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
		selenium.type("id=upl_name", "TestRendition");
		selenium.click("name=SubmitUser");
	}
	// Images Rendition
	function testImages() {
		selenium.click("link=Images");
		selenium.click("name=convert_to");
		selenium.type("id=convert_width_jpg", "600");
		selenium.click("link=Additional JPG conversions");
		selenium.click("css=##jpg_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.type("id=convert_width_jpg_2", "550");
		selenium.click("link=Additional JPG conversions");
		selenium.click("document.formupltemp.convert_to[6]");
		selenium.type("id=convert_width_gif", "500");
		selenium.click("link=Additional GIF conversions");
		selenium.click("css=##gif_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.type("id=convert_width_gif_2", "450");
		selenium.click("link=Additional GIF conversions");
		selenium.click("document.formupltemp.convert_to[12]");
		selenium.type("id=convert_width_png", "400");
		selenium.click("link=Additional PNG conversions");
		selenium.click("css=##png_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.type("id=convert_width_png_2", "350");
		selenium.click("link=Additional PNG conversions");
		selenium.click("document.formupltemp.convert_to[18]");
		selenium.type("name=convert_dpi_tif", "300");
		selenium.click("link=Additional TIF conversions");
		selenium.click("css=##tif_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.type("name=convert_dpi_tif_2", "250");
		selenium.click("link=Additional TIF conversions");
		selenium.click("document.formupltemp.convert_to[24]");
		selenium.type("name=convert_dpi_bmp", "200");
		selenium.click("link=Additional BMP conversions");
		selenium.click("css=##bmp_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.type("name=convert_dpi_bmp_2", "150");
		selenium.click("link=Additional BMP conversions");
		selenium.click("name=SubmitUser");
	}
	// Audios Rendition
	function testTemplAudios() {
		selenium.click("link=Audios");
		selenium.click("document.formupltemp.convert_to[84]");
		selenium.select("id=convert_bitrate_mp3", "label=160");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[10]");
		selenium.click("css=##mp3_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=convert_bitrate_mp3_2", "label=256");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[10]");
		selenium.click("document.formupltemp.convert_to[90]");
		selenium.click("document.formupltemp.convert_to[91]");
		selenium.select("id=convert_bitrate_ogg", "label=192");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[11]");
		selenium.click("css=##ogg_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=convert_bitrate_ogg_2", "label=224");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[11]");
		selenium.click("document.formupltemp.convert_to[97]");
		selenium.click("name=SubmitUser");
	}
	// Videos Rendition
	function testVideos() {
		selenium.click("link=Videos");
		selenium.click("document.formupltemp.convert_to[30]");
		selenium.select("id=preset_ogv", "label=128x96");
		selenium.click("link=additional conversions");
		selenium.click("css=##ogv_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_ogv_2", "label=160x120");
		selenium.click("link=additional conversions");
		selenium.click("document.formupltemp.convert_to[36]");
		selenium.select("id=preset_webm", "label=160x120");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[2]");
		selenium.click("css=##webm_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_webm_2", "label=176x144");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[2]");
		selenium.click("document.formupltemp.convert_to[42]");
		selenium.select("id=preset_flv", "label=176x144");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[3]");
		selenium.click("css=##flv_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_flv_2", "label=320x200");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[3]");
		selenium.click("document.formupltemp.convert_to[48]");
		selenium.select("id=preset_mp4", "label=320x200");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[4]");
		selenium.click("css=##mp4_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_mp4_2", "label=320x240");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[4]");
		selenium.click("document.formupltemp.convert_to[54]");
		selenium.select("id=preset_wmv", "label=320x240");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[5]");
		selenium.click("css=##wmv_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_wmv_2", "label=352x288");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[5]");
		selenium.click("document.formupltemp.convert_to[60]");
		selenium.select("id=preset_avi", "label=352x288");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[6]");
		selenium.click("css=##avi_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_avi_2", "label=640x350");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[6]");
		selenium.click("document.formupltemp.convert_to[66]");
		selenium.select("id=preset_mov", "label=640x350");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[7]");
		selenium.click("css=##mov_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_mov_2", "label=640x480");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[7]");
		selenium.click("document.formupltemp.convert_to[72]");
		selenium.select("id=preset_mpg", "label=640x480");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[8]");
		selenium.click("css=##mpg_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("id=preset_mpg_2", "label=640x480");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[8]");
		selenium.click("document.formupltemp.convert_to[78]");
		selenium.select("name=convert_wh_3gp", "label=176x144 (200K)");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[9]");
		selenium.click("css=##3gp_more > table.grid > tbody > tr > td > input[name='convert_to']");
		selenium.select("name=convert_wh_3gp_2", "label=352x288 (No size limit)");
		selenium.click("xpath=(//a[contains(text(),'additional conversions')])[9]");
		selenium.click("name=SubmitUser");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		Super.doRazLogout();
	}
}