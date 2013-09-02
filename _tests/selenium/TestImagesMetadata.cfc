// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Metadata 
	function testMetadata() {
		Super.doRazLogin();
		selenium.setspeed("3000");
		selenium.click("link=Uploads");
		selenium.click("xpath=//div[@id='tabsfolder_tab']/ul/li[@aria-controls='img']/a[contains(text(),'Images')]");
		selenium.click("css=form##imgform table.grid tbody tr td##selectme.ui-selectable div.assetbox a.ui-selectee div");
		// XMP Description
		selenium.setspeed("3000");
		selenium.click("css=a:contains('Meta Data')");
		selenium.click("//div[@id='meta']/a[2]/div");
		selenium.setspeed("2000");
		selenium.type("name=xmp_document_title", "Test Document Title");
		selenium.type("name=xmp_author", "Test Author");
		selenium.type("name=xmp_author_title", "Test Author Title");
		selenium.type("name=xmp_description_writer", "Test Description Writer");
		selenium.select("name=xmp_copyright_status", "label=Copyrighted");
		selenium.type("name=xmp_copyright_notice", " ©2013");
		selenium.type("name=xmp_copyright_info_url", "www.Testurl.com");
		selenium.setspeed("1000");
		selenium.click("//div[@id='meta']/a[2]/div");
	}

	// IPTC Contact
	function testIPTCMetaContact() {
		selenium.click("//div[@id='meta']/a[3]/div");
		selenium.setspeed("2000");
		selenium.type("name=iptc_contact_creator", "Test Creator");
		selenium.type("name=iptc_contact_creator_job_title", "Test Creator's Job Title");
		selenium.type("name=iptc_contact_address", "Test Address");
		selenium.type("name=iptc_contact_city", "Test City");
		selenium.type("name=iptc_contact_state_province", "Test State");
		selenium.type("name=iptc_contact_postal_code", "");
		selenium.type("name=iptc_contact_country", "Test Country");
		selenium.type("name=iptc_contact_phones", "9558654321");
		selenium.type("name=iptc_contact_emails", "Test@gmail.com");
		selenium.type("name=iptc_contact_websites", "www.Testwebsite.com");
		selenium.click("//div[@id='meta']/a[3]/div");
	}

	// IPTC Image
	function testIPTCImage() {
		selenium.click("//div[@id='meta']/a[4]/div");
		selenium.setspeed("1000");
		selenium.type("name=iptc_date_created", "8/23/2013");
		selenium.type("name=iptc_intellectual_genre", "Test Intellectual Genre");
		selenium.type("name=iptc_image_location", "Test Location");
		selenium.type("name=iptc_image_city", "Test City");
		selenium.type("name=iptc_image_state_province", "Test Province");
		selenium.type("name=iptc_image_country", "Test Country");
		selenium.type("name=iptc_iso_country_code", "12345");
		selenium.click("//div[@id='meta']/a[4]/div");
		selenium.setspeed("2000");
	}

	// IPTC Content
	function testContentIPTC() {
		selenium.click("css=##meta  a:nth-child(17) div:nth-child(1)");
		selenium.setspeed("2000");
		selenium.type("name=iptc_content_headline", "Test Headline");
		selenium.type("name=iptc_content_description_1", "Test Description");
		selenium.type("name=iptc_content_keywords_1", "Test Keywords");
		selenium.type("name=iptc_content_subject_code", "");
		selenium.type("name=iptc_content_description_writer", "Test Description Writer");
		selenium.click("//div[@id='meta']/a[5]/div");
		selenium.setspeed("1000");
	}

	// IPTC Status
	function testIPTCStatus() {
		selenium.setspeed("1000");
		selenium.click("//div[@id='meta']/a[6]/div");
		selenium.type("name=iptc_status_title", "Test Title");
		selenium.type("name=iptc_status_job_identifier", "Test Job Identifier");
		selenium.type("name=iptc_status_instruction", "Test Instructions");
		selenium.type("name=iptc_status_provider", "Test Provider");
		selenium.type("name=iptc_status_source", "Test Source");
		selenium.type("name=iptc_status_copyright_notice", "Test Copyright Notice");
		selenium.type("name=iptc_status_rights_usage_terms", "Test Rights Usage Terms");
		selenium.type("name=xmp_category", "");
		selenium.type("name=xmp_supplemental_categories", "");
		selenium.click("//div[@id='meta']/a[6]/div");
	}

	// IPTC Origin
	function testIPTCOrigin() {
		selenium.click("//div[@id='meta']/a[7]/div");
		selenium.setspeed("1000");
		selenium.type("name=xmp_origin_date_created", "8/23/2013");
		selenium.type("name=xmp_origin_city", "Test City");
		selenium.type("name=xmp_origin_state_province", "Test State/Province");
		selenium.type("name=xmp_origin_country", "Test Country");
		selenium.type("name=xmp_origin_credit", "Test Credit");
		selenium.type("name=xmp_origin_source", "Test Source");
		selenium.type("name=xmp_origin_headline", "Test Headline");
		selenium.type("name=xmp_origin_instructions", "Test Instructions");
		selenium.type("name=xmp_origin_transmission_reference", "Test Transmission Reference");
		selenium.select("name=xmp_origin_urgency", "label=3");
		selenium.click("css=td > div > input[name='submit']");
		selenium.click("//div[@id='meta']/a[7]/div");
		selenium.check("css=input[name='submit'][value='Save']");
	}

	// Copy Metadata
	/*function testMetadata() {
		selenium.click("css=button.button");
		selenium.type("id=searchtext", "Desert");
		selenium.click("//button[@onclick='copy_meta();return false;']");
		selenium.click("id=selectallcm");
		selenium.click("id=apply");
		selenium.check("css=input[value='append'][name='insert_type']");
		selenium.click("id=apply");
		selenium.click("css=div:last-child .ui-button-icon-primary");
	}*/
}