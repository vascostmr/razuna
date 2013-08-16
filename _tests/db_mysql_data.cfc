 
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

		<cfreturn />

	</cffunction>
<!---  
#arguments.thestruct.host_db_prefix#
delete from users where USER_ID != 1

delete from modules where mod_id not in (1,2)

groups grp_id  not in (1,2)

ct_groups_users CT_G_U_USER_ID  != 1

permissions PER_ID > 11

ct_groups_permissions CT_G_P_GRP_ID != 1


--->
		
</cfcomponent>