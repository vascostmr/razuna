// component extends testRazunaBase
component extends="TestRazunaBase"{
	
	// Description & Keywords
	function testDescriptionKeywords() {
		Super.doRazLogin();
		selenium.setspeed("3000");
		selenium.click("link=Uploads");
		selenium.click("css=a[title='Click to select all assets in this folder'] > div");
		selenium.click("//div[@id='folderselectionallform']/a[3]/div[2]");
		selenium.type("name=all_desc_1", "Description");
		selenium.type("name=all_keywords_1", "Keywords");
		selenium.click("document.form0.elements['submit'][1]");
		selenium.type("name=all_desc_1", "Test description");
		selenium.type("name=all_keywords_1", "Test keywords");
		selenium.click("name=batch_replace");
		selenium.click("document.form0.elements['submit'][1]");
	}
	// XMP Description
	function testXMP() {
		selenium.click("xpath=(//a[contains(text(),'XMP Description')])");
		selenium.type("name=xmp_document_title", "Test Document Title");
		selenium.type("name=xmp_author", "Test Author");
		selenium.type("name=xmp_author_title", "Test Author Title");
		selenium.type("name=xmp_description_writer", "Test Description Writer");
		selenium.select("name=xmp_copyright_status", "label=Copyrighted");
		selenium.type("name=xmp_copyright_notice", "©2013");
		selenium.type("name=xmp_copyright_info_url", "www.Testurl.com");
		selenium.click("document.form0.elements['submit'][1]");
	}
	// IPTC Contact
	function testIPTCContact() {
		selenium.click("xpath=(//a[contains(text(),'IPTC Contact')])");
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
		selenium.click("document.form0.elements['submit'][1]");
		Super.doRazLogout();
	}
	// IPTC Image
	function testIPTCImage() {
		selenium.click("xpath=(//a[contains(text(),'IPTC Image')])");
		selenium.type("name=iptc_date_created", "8/23/2013");
		selenium.type("name=iptc_intellectual_genre", "Test Intellectual Genre");
		selenium.type("name=iptc_scene", "Test Scene");
		selenium.type("name=iptc_image_location", "Test Location");
		selenium.type("name=iptc_image_city", "Test City");
		selenium.type("name=iptc_image_state_province", "Test Province");
		selenium.type("name=iptc_image_country", "Test Country");
		selenium.type("name=iptc_iso_country_code", "235");
		selenium.click("document.form0.elements['submit'][1]");
	}
	// IPTC Content
	function testIPTCContent() {
		selenium.click("xpath=(//a[contains(text(),'IPTC Content')])");
		selenium.type("name=iptc_content_headline", "Test Headline");
		selenium.type("name=iptc_content_description_1", "Test Description");
		selenium.type("name=iptc_content_keywords_1", "Test Keywords");
		selenium.type("name=iptc_content_subject_code", "");
		selenium.type("name=iptc_content_description_writer", "Test Description Writer");
		selenium.click("document.form0.elements['submit'][1]");
	}
	// IPTC Status
	function testIPTCStatus() {
		selenium.click("xpath=(//a[contains(text(),'IPTC Status')])");
		selenium.type("name=iptc_status_title", "Title");
		selenium.type("name=iptc_status_job_identifier", "Test Job Identifier");
		selenium.type("name=iptc_status_instruction", "Test Instructions");
		selenium.type("name=iptc_status_provider", "Test Provider");
		selenium.type("name=iptc_status_source", "Test Source");
		selenium.type("name=iptc_status_copyright_notice", "Test Copyright Notice");
		selenium.type("name=iptc_status_rights_usage_terms", "Test Rights Usage Terms");
		selenium.type("name=xmp_category", "");
		selenium.type("name=xmp_supplemental_categories", "");
		selenium.click("document.form0.elements['submit'][1]");
	}
	// Origin
	function testOrigin() {
		selenium.click("xpath=(//a[contains(text(),'Origin')])");
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
		selenium.click("document.form0.elements['submit'][1]");
	}
}