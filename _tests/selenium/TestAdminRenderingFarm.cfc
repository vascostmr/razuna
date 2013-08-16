// component extends testRazunaBase
component extends="testRazunaBase"{

	//FileType 
	function testFileType() {
		super.doLogin();
		selenium.setSpeed("1000");
		selenium.click("//a[contains(text(),'General Configuration')]");
		selenium.click("link=File Types");
		selenium.type("id=new_type_id", "testjpeg");
		selenium.select("id=new_type_type", "label=Image");
		selenium.type("id=new_type_mimecontent", "image");
		selenium.click("name=save");
	}
	// Add File Type
	function testRenderingFarm() {
		selenium.setSpeed("1000");
		selenium.click("link=Rendering Farm");
		selenium.click("//input[@value='Add Server']");
		selenium.click("name=Submit");
		selenium.click("xpath=(//input[@value='Validate'])[3]");
		selenium.click("xpath=(//a[contains(text(),'Tools')])[2]");
		selenium.click("name=Submit");
		selenium.type("id=rfs_imagemagick", "C:\\\\ImageMagick\\\\ImageMagick-6.8.3-Q16");
		selenium.type("id=rfs_ffmpeg", "C:\\FFMpeg\\bin");
		selenium.type("id=rfs_exiftool", "C:\\Exiftool");
		selenium.type("id=rfs_dcraw", "C:\\dcraw");
		selenium.type("id=rfs_mp4box", "C:\\MP4Box");
		selenium.click("name=Submit");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
		selenium.click("css=span.ui-icon.ui-icon-closethick");
	}
	
}