<cfcomponent output="false">
	
	<cffunction name="insertDummyData" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		

			<cfquery datasource="#arguments.thestruct.dsn#">		
				INSERT INTO #arguments.thestruct.theschema#.hosts (HOST_ID, HOST_NAME, HOST_PATH, HOST_CREATE_DATE, HOST_DB_PREFIX, HOST_LANG, HOST_TYPE, HOST_SHARD_GROUP, HOST_NAME_CUSTOM) VALUES
				(1, 'Demo', 'raz1', '2013-08-02', 'raz1_', NULL, 'F', 'raz1_', '');
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.theschema#.users (USER_ID, USER_LOGIN_NAME, USER_EMAIL, USER_FIRST_NAME, USER_LAST_NAME, USER_PASS, USER_COMPANY, USER_STREET, USER_STREET_NR, USER_STREET_2, USER_STREET_NR_2, USER_ZIP, USER_CITY, USER_COUNTRY, USER_PHONE, USER_PHONE_2, USER_MOBILE, USER_FAX, USER_CREATE_DATE, USER_CHANGE_DATE, USER_ACTIVE, USER_IN_ADMIN, USER_IN_DAM, USER_SALUTATION, USER_IN_VP, SET2_NIRVANIX_NAME, SET2_NIRVANIX_PASS, USER_API_KEY) VALUES
				('6CE5BBF5-45F3-43C6-BE483C1AC21905B2', 'admin', 'admin@admin.com', 'admin', 'user', '21232F297A57A5A743894A0E4A801FC3', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2013-08-02', NULL, 'T', 'T', 'T', NULL, 'F', NULL, NULL, 'dummy_api_key');
			</cfquery>
		
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.theschema#.ct_users_hosts (CT_U_H_USER_ID, CT_U_H_HOST_ID, rec_uuid) VALUES
				('6CE5BBF5-45F3-43C6-BE483C1AC21905B2', 1, 'B33F2AF5-8139-4A27-BAD8F006F17CE521');
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.theschema#.ct_groups_users (CT_G_U_GRP_ID, CT_G_U_USER_ID, rec_uuid) VALUES
				('1', '6CE5BBF5-45F3-43C6-BE483C1AC21905B2', 'CE2B4548-CACC-44B5-9A1FAA741191667F');
			</cfquery>
			
			<!--- set defult folder --->
				
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders
				(folder_id, folder_name, folder_level, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, folder_of_user, folder_id_r, folder_main_id_r, host_id)
				values (
				<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="Uploads" cfsqltype="cf_sql_varchar">, 
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
				<cfqueryparam value="f" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				)
			</cfquery>
			
			<!--- Insert the DESCRIPTION --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders_desc
				(folder_id_r, lang_id_r, folder_desc, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="Public Uploads folder" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			<!--- Make it public for everyone --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders_groups
				(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
				VALUES(
					<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="W" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			
			<!--- set sub folders --->
				
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders
				(folder_id, folder_name, folder_level, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, folder_of_user, folder_id_r, folder_main_id_r, host_id)
				values (
				<cfqueryparam value="0D49524AE47D4BF686C8D1409C7559F9" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="demo" cfsqltype="cf_sql_varchar">, 
				<cfqueryparam value="2" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
				<cfqueryparam value="f" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				)
			</cfquery>
			
			<!--- Insert the sub folder DESCRIPTION --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders_desc
				(folder_id_r, lang_id_r, folder_desc, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="0D49524AE47D4BF686C8D1409C7559F9" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="Insert test sub folder" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			<!--- Make it public for everyone --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders_groups
				(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
				VALUES(
					<cfqueryparam value="0D49524AE47D4BF686C8D1409C7559F9" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="W" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			
			<!--- Insert Images --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#images(img_id,img_filename,folder_id_r,img_custom_id,img_online,img_owner,img_create_date,img_create_time,img_change_date,
					img_change_time,img_in_progress,img_extension,thumb_extension,thumb_width,thumb_height,img_filename_org,img_width,img_height,img_size,
					thumb_size,shared,link_path_url,img_meta,host_id,path_to_asset,hashtag,is_available,in_trash) VALUES(
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Tulips.jpg">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="A9D8939DFF774C94886882175BB28199">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Tulips">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2">,
					<cfqueryparam cfsqltype="CF_SQL_DATE" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,					
					<cfqueryparam cfsqltype="CF_SQL_DATE" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="T">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="jpg">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="jpg">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="400">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="300">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Tulips.jpg">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1024">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="768">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="620888">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="156164">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="E:\razuna\webapps\razuna\raz1\dam/incoming/api8AF522125A584C06B897C138316D253B">,
					'---- File ----
					File Name                       : Tulips.jpg
					File Size                       : 606 kB
					File Modification Date/Time     : 2013:08:19 16:33:07+05:30
					File Access Date/Time           : 2013:08:19 16:33:07+05:30
					File Creation Date/Time         : 2013:08:19 16:33:07+05:30
					File Permissions                : rw-rw-rw-
					File Type                       : JPEG
					MIME Type                       : image/jpeg
					Exif Byte Order                 : Big-endian (Motorola, MM)
					Current IPTC Digest             : 50bb6030364fbdfb1842e98de0e81efe
					Image Width                     : 1024
					Image Height                    : 768
					Encoding Process                : Baseline DCT, Huffman coding
					Bits Per Sample                 : 8
					Color Components                : 3
					Y Cb Cr Sub Sampling            : YCbCr4:4:4 (1 1)
					---- JFIF ----
					JFIF Version                    : 1.02
					Resolution Unit                 : inches
					X Resolution                    : 96
					Y Resolution                    : 96
					---- EXIF ----
					Modify Date                     : 2009:03:12 13:48:39
					Rating                          : 4
					Rating Percent                  : 63
					Copyright                       : Microsoft Corporation
					Date/Time Original              : 2008:02:07 11:33:11
					Create Date                     : 2008:02:07 11:33:11
					Sub Sec Time Original           : 02
					Sub Sec Time Digitized          : 02
					Compression                     : JPEG (old-style)
					X Resolution                    : 72
					Y Resolution                    : 72
					Thumbnail Offset                : 358
					Thumbnail Length                : 4406
					---- ExifTool ----
					Warning                         : Suspicious IFD0 offset for XPAuthor
					Warning                         : Suspicious IFD0 offset for Padding
					Warning                         : Suspicious ExifIFD offset for Padding
					---- Ducky ----
					Quality                         : 100%
					---- APP14 ----
					DCT Encode Version              : 100
					APP14 Flags 0                   : [14], Encoded with Blend=1 downsampling
					APP14 Flags 1                   : (none)
					Color Transform                 : YCbCr
					---- XMP ----
					XMP Toolkit                     : Adobe XMP Core 4.2-c020 1.124078, Tue Sep 11 2007 23:21:40
					Artist                          : David Nadalin
					Orientation                     : Horizontal (normal)
					Image Width                     : 1024
					Image Height                    : 768
					Photometric Interpretation      : RGB
					Samples Per Pixel               : 3
					X Resolution                    : 96
					Y Resolution                    : 96
					Resolution Unit                 : inches
					Rating                          : 4
					Create Date                     : 2008:02:07 19:33:11.020Z
					Modify Date                     : 2008:02:07 11:33:11.02-08:00
					Metadata Date                   : 2009:02:02 11:41:17-08:00
					Rating                          : 63
					Instance ID                     : uuid:faf5bdd5-ba3d-11da-ad31-d33d75182f1b
					Exif Version                    : 0221
					Date/Time Original              : 2008:02:07 11:33:11.02-08:00
					Date/Time Digitized             : 2008:02:07 11:33:11.02-08:00
					Exif Image Width                : 1024
					Exif Image Height               : 768
					Color Space                     : Uncalibrated
					Already Applied                 : True
					Color Mode                      : RGB
					ICC Profile Name                : 
					Legacy IPTC Digest              : 50BB6030364FBDFB1842E98DE0E81EFE
					Marked                          : True
					Bits Per Sample                 : 8, 8, 8
					Creator                         : David Nadalin
					Rights                          : Â© Microsoft Corporation
					---- IPTC ----
					Application Record Version      : 2
					By-line                         : David Nadalin
					Copyright Notice                : Â© Microsoft Corporation
					---- Photoshop ----
					Copyright Flag                  : True
					IPTC Digest                     : 50bb6030364fbdfb1842e98de0e81efe
					---- Composite ----
					Image Size                      : 1024x768
					Create Date                     : 2008:02:07 11:33:11.02
					Date/Time Original              : 2008:02:07 11:33:11.02
					Thumbnail Image                 : (Binary data 4406 bytes, use -b option to extract)',
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="A9D8939DFF774C94886882175BB28199/img/8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="FAFA5EFEAF3CBE3B23B2748D13E629A1">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#images_text(ID_INC,IMG_ID_R,LANG_ID_R,HOST_ID)
				VALUES(
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="DBD383F5-5BD7-4979-A60797E1A2D7A3E6">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">)
				
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#log_assets(log_id,log_user,log_action,log_date,log_time,log_desc,log_file_type,log_timestamp,host_id,asset_id_r)
				VALUES(
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="2E948D00-A96E-4F60-9F013C53FC27A6DE">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="C1075878-7913-40A3-BB5B0CBE542E0D44">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Add">,
					<cfqueryparam cfsqltype="CF_SQL_DATE" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Added: Tulips.jpg">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img">,	
					<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#share_options(asset_id_r,host_id,group_asset_id,folder_id_r,asset_type,asset_format,asset_dl,asset_order,asset_selected,rec_uuid)
				VALUES
					(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="A9D8939DFF774C94886882175BB28199">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="org">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="18A472A6-61E9-46FC-9DA5FCDB7B6998BD">),
					
					(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="A9D8939DFF774C94886882175BB28199">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="thumb">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="3485ED73-8D64-4C7A-BD5AF0244AB088A9">)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#xmp(ID_R,asset_type,creator,copyrightstatus,rights,xres,yres,resunit,host_id)
				VALUES(
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="David Nadalin">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="True">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Â© Microsoft Corporation">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="96">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="96">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="inches">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">)
			</cfquery>
			
			<!--- Insert audio --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#audios
				(aud_ID,FOLDER_ID_R,aud_CREATE_DATE,aud_CREATE_TIME,aud_CHANGE_DATE,aud_CHANGE_TIME,aud_OWNER,aud_TYPE,aud_NAME,aud_EXTENSION,aud_NAME_NOEXT,aud_ONLINE,aud_NAME_ORG,aud_size,SHARED,aud_meta,LINK_PATH_URL,HOST_ID,PATH_TO_ASSET,HASHTAG,IS_AVAILABLE)
				VALUES(
					<cfqueryparam value="01796D62A2A3409BB327142798C7A032" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="01796D62A2A3409BB327142798C7A032" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="aud" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="Kalimba.mp3" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="mp3" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="Kalimba" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="Kalimba.mp3" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="8414449" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
					'---- File ----
					File Name                       : Kalimba.mp3
					Directory                       : D:/razuna/webapps/razuna/raz1/dam/incoming/api01796D62A2A3409BB327142798C7A032
					File Size                       : 8.0 MB
					File Modification Date/Time     : 2013:08:19 16:39:33+05:30
					File Access Date/Time           : 2013:08:19 16:39:33+05:30
					File Creation Date/Time         : 2013:08:19 16:39:33+05:30
					File Permissions                : rw-rw-rw-
					File Type                       : MP3
					MIME Type                       : audio/mpeg
					ID3 Size                        : 60731
					---- MPEG ----
					MPEG Audio Version              : 1
					Audio Layer                     : 3
					Audio Bitrate                   : 192 kbps
					Sample Rate                     : 44100
					Channel Mode                    : Stereo
					MS Stereo                       : Off
					Intensity Stereo                : Off
					Copyright Flag                  : False
					Original Media                  : False
					Emphasis                        : None
					---- ID3 ----
					WM Media Class Secondary ID     : 00000000-0000-0000-0000-000000000000
					WM Media Class Primary ID       : D1607DBC-E323-4BE2-86A1-48A42A28441E
					WM Provider                     : AMG
					WM Content ID                   : 4F0FA0F3-3D95-471A-B0D2-9DCB30A9BBAE
					WM Collection ID                : 5FA05D35-A682-4AF6-96F7-0773E42D4D16
					WM Collection Group ID          : 5FA05D35-A682-4AF6-96F7-0773E42D4D16
					Publisher                       : Ninja Tune
					WM Unique File Identifier       : (Binary data 114 bytes, use -b option to extract)
					Picture Mime Type               : image/jpeg
					Picture Type                    : Front Cover
					Picture Description             : thumbnail
					Picture                         : (Binary data 59867 bytes, use -b option to extract)
					Track                           : 1
					Album                           : Ninja Tuna
					Year                            : 2008
					Band                            : Mr. Scruff
					Title                           : Kalimba
					Genre                           : Electronic
					Composer                        : A. Carthy and A. Kingslow
					Artist                          : Mr. Scruff
					Comment                         : Ninja Tune Records
					---- Composite ----
					Date/Time Original              : 2008
					Duration                        : 0:05:48 (approx)',
					<cfqueryparam value="D:\razuna\webapps\razuna\raz1\dam/incoming/api01796D62A2A3409BB327142798C7A032" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="A9D8939DFF774C94886882175BB28199/aud/01796D62A2A3409BB327142798C7A032" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">,
					<cfqueryparam value="1" CFSQLType="cf_sql_numeric">
					)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#audios_text(id_inc,aud_ID_R,LANG_ID_R,aud_DESCRIPTION,aud_KEYWORDS,HOST_ID)
				VALUES(
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">,
					<cfqueryparam value="01796D62A2A3409BB327142798C7A032" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="Test audio file inserted" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="audio file" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">
					)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#share_options(asset_id_r,host_id,group_asset_id,folder_id_r,asset_type,asset_format,asset_dl,asset_order,asset_selected,rec_uuid)
				VALUES
					(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="01796D62A2A3409BB327142798C7A032">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="01796D62A2A3409BB327142798C7A032">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0D49524AE47D4BF686C8D1409C7559F9">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="aud">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="org">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
			</cfquery>
			
			<!--- Insert videos --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#videos(VID_ID,VID_FILENAME,FOLDER_ID_R,VID_CUSTOM_ID,VID_ONLINE,VID_OWNER,VID_CREATE_DATE,VID_CREATE_TIME,VID_CHANGE_DATE,VID_CHANGE_TIME,VID_SINGLE_SALE,
				VID_IS_NEW,VID_SELECTION,VID_IN_PROGRESS,VID_WIDTH,VID_HEIGHT,VID_EXTENSION,VID_NAME_ORG,VID_NAME_IMAGE,vid_size,LINK_PATH_URL,VID_META,HOST_ID,PATH_TO_ASSET,HASHTAG,IS_AVAILABLE)
				VALUES(
					<cfqueryparam value="149E0F769428440AAF5FFBDA28E6F974" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="Wildlife.wmv" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="A9D8939DFF774C94886882175BB28199" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">,
					<cfqueryparam value="F" CFSQLType="CF_SQL_VARCHAR">,
					<cfqueryparam value="01796D62A2A3409BB327142798C7A032" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="f" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="t" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="f" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="t" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="1280" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="720" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="wmv" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="Wildlife.wmv" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="Wildlife.jpg" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="26246026" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="D:\razuna\webapps\razuna\raz1\dam/incoming/api149E0F769428440AAF5FFBDA28E6F974" cfsqltype="cf_sql_varchar">,
					'---- File ----
					File Name                       : Wildlife.wmv
					File Size                       : 25 MB
					File Modification Date/Time     : 2013:08:19 20:05:35+05:30
					File Access Date/Time           : 2013:08:19 20:05:39+05:30
					File Creation Date/Time         : 2013:08:19 20:05:39+05:30
					File Permissions                : rw-rw-rw-
					File Type                       : WMV
					MIME Type                       : video/x-ms-wmv
					---- ASF ----
					Is VBR                          : False
					Title                           : Wildlife in HD
					Copyright                       : Â© 2008 Microsoft Corporation
					Description                     : Footage: Small World Productions, Inc; Tourism New Zealand | Producer: Gary F. Spradling | Music: Steve Ball
					File ID                         : EA76F9DF-171A-4C17-BCAB-6BD400BCE4B0
					File Length                     : 26246026
					Creation Date                   : 2008:08:25 21:11:16Z
					Data Packets                    : 3280
					Play Duration                   : 0:00:38
					Send Duration                   : 0:00:36
					Preroll                         : 8000
					Flags                           : 2
					Min Packet Size                 : 8000
					Max Packet Size                 : 8000
					Max Bitrate                     : 6.18 Mbps
					Audio Codec Name                : Windows Media Audio 9.2
					Audio Codec Description         : 192 kbps, 44 kHz, stereo (A/V) 1-pass CBR
					Video Codec Name                : Windows Media Video 9 Advanced Profile
					Video Codec Description         : 
					Stream Type                     : Audio
					Error Correction Type           : Audio Spread
					Time Offset                     : 0 s
					Stream Number                   : 1
					Audio Codec ID                  : Windows Media Audio V2 V7 V8 V9 / DivX audio (WMA) / Alex AC3 Audio
					Audio Channels                  : 2
					Audio Sample Rate               : 44100
					Stream Type                     : Video
					Error Correction Type           : No Error Correction
					Time Offset                     : 0 s
					Stream Number                   : 2
					Image Width                     : 1280
					Image Height                    : 720
					---- Composite ----
					Image Size                      : 1280x720',
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="A9D8939DFF774C94886882175BB28199/vid/149E0F769428440AAF5FFBDA28E6F974" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">,
					<cfqueryparam value="1" CFSQLType="cf_sql_numeric">
					)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#videos_text(ID_INC,VID_ID_R,LANG_ID_R,VID_KEYWORDS,VID_DESCRIPTION,VID_TITLE,HOST_ID)
				VALUES(
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">,
					<cfqueryparam value="149E0F769428440AAF5FFBDA28E6F974" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="wild life" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="video file for test" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="wild life" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">
					)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#share_options(asset_id_r,host_id,group_asset_id,folder_id_r,asset_type,asset_format,asset_dl,asset_order,asset_selected,rec_uuid)
				VALUES
					(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="149E0F769428440AAF5FFBDA28E6F974">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="149E0F769428440AAF5FFBDA28E6F974">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="A9D8939DFF774C94886882175BB28199">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="vid">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="org">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
			</cfquery>
			
			<!--- Insert Collection Folder --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders
				(folder_id, folder_name, folder_level, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, folder_of_user, folder_is_collection, folder_id_r, folder_main_id_r, host_id)
				values (
				<cfqueryparam value="B3999E8296F544B8875AF48AF267AED8" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="Collections" cfsqltype="cf_sql_varchar">, 
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
				<cfqueryparam value="f" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="T" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="B3999E8296F544B8875AF48AF267AED8" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="B3999E8296F544B8875AF48AF267AED8" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders_desc
				(folder_id_r, lang_id_r, folder_desc, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="B3999E8296F544B8875AF48AF267AED8" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="This is the default collections folder for storing collections" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO  #arguments.thestruct.host_db_prefix#folders_groups
				(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
				VALUES(
					<cfqueryparam value="B3999E8296F544B8875AF48AF267AED8" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="W" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			
			<!--- Insert Collection --->	
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#collections
				(col_id,folder_id_r,col_owner,create_date,create_time,change_date,change_time, host_id, col_shared, share_dl_org, share_dl_thumb, share_comments, share_upload)
				VALUES(
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="42916093FE7A46DA9CAF6EB57AB21A9A">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="B3999E8296F544B8875AF48AF267AED8">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2">,
					<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#collections_text
				(col_id_r, lang_id_r, col_desc, col_keywords, col_name, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="42916093FE7A46DA9CAF6EB57AB21A9A" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="Collection for Test" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="Collection" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="Testcollection" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			
			<!--- Insert Collection Asset --->
			<!--- Insert Images --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#collections_ct_files
				(col_id_r, file_id_r, col_file_type, col_item_order, col_file_format, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="42916093FE7A46DA9CAF6EB57AB21A9A" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="8AF522125A584C06B897C138316D253B" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="thumb" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
			<!--- Insert Audio --->
			<cfquery datasource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.host_db_prefix#collections_ct_files
				(col_id_r, file_id_r, col_file_type, col_item_order, col_file_format, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="42916093FE7A46DA9CAF6EB57AB21A9A" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="01796D62A2A3409BB327142798C7A032" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="aud" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="2" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>	
			
			<!--- Insert image comment --->
			<cfquery datasource="#application.razuna.datasource#" name="qry">
				INSERT INTO #arguments.thestruct.host_db_prefix#comments
				(com_id, com_text, com_date, asset_id_r, user_id_r, asset_type, host_id)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="FBE3517179344A25B27C1A55A239405A">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="test comment for image">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="8AF522125A584C06B897C138316D253B">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="img">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				)
			</cfquery>
			<!--- Insert audio comment --->
			<cfquery datasource="#application.razuna.datasource#" name="qry">
				INSERT INTO #arguments.thestruct.host_db_prefix#comments
				(com_id, com_text, com_date, asset_id_r, user_id_r, asset_type, host_id)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="78AF98784C5A424BAF0B220D14100EDB">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="test comment for audio">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="01796D62A2A3409BB327142798C7A032">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="aud">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				)
			</cfquery>
			
			<cfquery datasource="#application.razuna.datasource#" name="qry">
				INSERT INTO #arguments.thestruct.host_db_prefix#comments
				(com_id, com_text, com_date, asset_id_r, user_id_r, asset_type, host_id)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="56EC301371AB441C84718DEBD0E67C1A">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="sample comment for audio">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="01796D62A2A3409BB327142798C7A032">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="6CE5BBF5-45F3-43C6-BE483C1AC21905B2">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="aud">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				)
			</cfquery>
		<cfreturn />

	</cffunction>
</cfcomponent>