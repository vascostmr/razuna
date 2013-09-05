// component extends testRazunaBasesss
component extends="TestRazunaBase"{

	//Home Page Load
	function testHomePageLoads() {
		selenium.open( browserUrl & "/admin/" );
		selenium.setSpeed("2000");
		selenium.waitForPageToLoad( timeout );
		assertEquals( "Razuna - the open source alternative to Digital Asset Management", selenium.getTitle() );
	}
	// Change Language
	function testChangeLanguage() {
		Super.doLogin();
		selenium.waitForPageToLoad( timeout );
		selenium.setSpeed("2000");
		selenium.select("name=app_lang", "label=German");
		selenium.setSpeed("3000");
		selenium.select("name=app_lang", "label=English");
	}
	//Support and Blog
	function testSupportBlog(){
		selenium.setSpeed("2000");
		selenium.click("link=System Information");
		selenium.click("link=Installation Checklist");
		selenium.click("link=Support");
		selenium.click("link=Blog");
		selenium.setSpeed("2000");
		Super.doLogout();
	}
}