<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false" extends="extQueryCaching">
 
<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("general")>

<!--- UPLOAD TEMP --->
<cffunction name="upload" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.file_id" default="0">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<cfset var qry = "">
	<!--- RAZ-2907 Create tempid --->
	<cfif structKeyExists(arguments.thestruct,'extjs') AND arguments.thestruct.extjs EQ "T">
		<cfset arguments.thestruct.tempid = createuuid()>
	</cfif>	
	<!--- Change tempid a bit --->
	<cfset arguments.thestruct.tempid = replace(arguments.thestruct.tempid,"-","","ALL")>
	<!--- Create a unique name for the temp directory to hold the file --->
	<cfset arguments.thestruct.thetempfolder   = "asset#arguments.thestruct.tempid#">
	<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
	<!--- Create a temp directory to hold the file --->
	<cfif !DirectoryExists(arguments.thestruct.theincomingtemppath)>
		<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
	</cfif>
	<!--- Upload file --->
	<cffile action="upload" destination="#arguments.thestruct.theincomingtemppath#" nameconflict="overwrite" filefield="#arguments.thestruct.thefieldname#" result="thefile">
	<cfset arguments.thestruct.thefile.serverFileExt = "#lcase(thefile.serverFileExt)#">
	<cfset arguments.thestruct.thefile = thefile>
	<cfset arguments.thestruct.dsn = application.razuna.datasource>
	<cfset arguments.thestruct.hostid = session.hostid>
	<!--- If the extension is longer then 9 chars --->
	<cfif len(arguments.thestruct.thefile.serverFileExt) GT 9>
		<cfset arguments.thestruct.thefile.serverFileExt = "txt">
	</cfif>
	<cfset var tt = createUUID()>
	<!--- Put the rest into a thread --->
	<cfthread name="#tt#" intstruct="#arguments.thestruct#">
		<cfset md5hash = "">
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global" method="convertname" returnvariable="thefilename" thename="#attributes.intstruct.thefile.serverFile#">
		<cfinvoke component="global" method="convertname" returnvariable="thefilenamenoext" thename="#attributes.intstruct.thefile.serverFileName#">
		<cffile action="rename" source="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.thefile.serverFile#" destination="#attributes.intstruct.theincomingtemppath#/#thefilename#">
		<!--- MD5 Hash --->
		<cfif FileExists("#attributes.intstruct.theincomingtemppath#/#thefilename#")>
			<cfset md5hash = hashbinary("#attributes.intstruct.theincomingtemppath#/#thefilename#")>
		</cfif>
		<!--- Check if we have to check for md5 records --->
		<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
		<!--- Check for the same MD5 hash in the existing records --->
		<cfif checkformd5>
			<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
		<cfelse>
			<cfset md5here = 0>
		</cfif>
		<!--- If file does not exsist continue else send user an eMail --->
		<cfif md5here EQ 0>
			<!--- Add to temp db --->
			<cfquery datasource="#attributes.intstruct.dsn#" name="qry">
			INSERT INTO #session.hostdbprefix#assets_temp
			(tempid,filename,extension,date_add,folder_id,who,filenamenoext,path<!--- ,mimetype --->,thesize,file_id,host_id,md5hash)
			VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.tempid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilename#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(attributes.intstruct.thefile.serverFileExt)#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#attributes.intstruct.folder_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#attributes.intstruct.user_id#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilenamenoext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.theincomingtemppath#">,
			<!--- <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.thefile.contentType#/#attributes.intstruct.thefile.contentSubType#">, --->
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.thefile.filesize#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#attributes.intstruct.file_id#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.intstruct.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#md5hash#">
			)
			</cfquery>
		<cfelse>
			<!--- RAZ-2810 Customise email message --->
			<cfset transvalues = arraynew()>
			<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
			<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
			<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
			<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#" isdup = "yes"  filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
		</cfif>
	</cfthread>
	<!--- Wait --->
	<cfthread name="#tt#" action="join" />
	<cfset result = "T">
	<!--- Return --->
	<cfreturn result>
</cffunction>

<!--- INSERT FROM SERVER as thread --->
<cffunction name="addassetserver" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Thread --->
	<cftry>
		<!--- For scheduled tasks --->
		<cfif structkeyexists(arguments.thestruct,"sched")>
			<cfthread intstruct="#arguments.thestruct#" action="run">
				<cfinvoke method="addassetscheduledserverthread" thestruct="#attributes.intstruct#" />
			</cfthread>
		<!--- Normal processing --->
		<cfelse>
			<cfinvoke method="addassetserverthread" thestruct="#arguments.thestruct#" />
		</cfif>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function assets.addassetserver">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	
	<!--- <cfset var tt = createUUID()>
	<cfthread name="#tt#" intstruct="#arguments.thestruct#">
		<cfinvoke method="addassetserverthread" thestruct="#attributes.intstruct#" />
	</cfthread>
	<!--- Wait --->
	<cfthread name="#tt#" action="join" /> --->
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM SERVER --->
<cffunction name="addassetserverthread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="session.currentupload" default="0">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<cfparam name="arguments.thestruct.actionforfile" default="copy">
	<!--- Add each file to the temp db, create temp dir and so on --->
	<cfloop list="#arguments.thestruct.thefile#" index="i" delimiters=",">
		<cfset var md5hash = "">
		<!--- If we are coming from a scheduled task then... --->
		<cfif structkeyexists(arguments.thestruct,"sched")>
			<cfset var x = i>
			<!--- Get the filename --->
			<cfset var i = listlast(i, "/")>
			<!--- Get the folderpath --->
			<cfset arguments.thestruct.folderpath = replacenocase(x, "/#i#", "", "ALL")>
		</cfif>
		<!--- Create a unique name for the temp directory to hold the file --->
		<cfset arguments.thestruct.tempid = createuuid("")>
		<!--- Put current id into session --->
		<cfset session.currentupload = session.currentupload & "," & arguments.thestruct.tempid>
		<cfset arguments.thestruct.thetempfolder = "asset#arguments.thestruct.tempid#">
		<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
		<!--- Create a temp directory to hold the file --->
		<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
		<!--- Copy the file into the temp dir --->
		<cffile action="#arguments.thestruct.actionforfile#" source="#arguments.thestruct.folderpath#/#i#" destination="#arguments.thestruct.theincomingtemppath#/#i#" mode="775">
		<!--- Get file extension --->
		<cfset var theextension = listlast("#i#",".")>
		<!--- If the extension is longer then 9 chars --->
		<cfif len(theextension) GT 9>
			<cfset var theextension = "txt">
		</cfif>
		<cfset var namenoext = replacenocase("#i#",".#theextension#","","All")>
		<!--- Store the original filename --->
		<cfset arguments.thestruct.thefilenameoriginal = i>
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#i#">
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#namenoext#">
		<!--- Do the rename action on the file --->
		<cffile action="rename" source="#arguments.thestruct.theincomingtemppath#/#i#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
		<!--- Get the filesize --->
		<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" returnvariable="orgsize">
		<!--- MD5 Hash --->
		<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
			<cfset var md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
		</cfif>
		<!--- Check if we have to check for md5 records --->
		<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
		<!--- Check for the same MD5 hash in the existing records --->
		<cfif checkformd5>
			<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
		<cfelse>
			<cfset var md5here = 0>
		</cfif>
		<!--- If file does not exsist continue else send user an eMail --->
		<cfif md5here EQ 0>
			<!--- Add to temp db --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#assets_temp
			(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path<cfif structkeyexists(arguments.thestruct,"sched")>, sched_id, sched_action</cfif>, file_id, host_id, thesize, md5hash)
			VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#namenoext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">
			<cfif structkeyexists(arguments.thestruct,"sched")>
				,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.sched_id#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.sched_action#">
			</cfif>
			,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#orgsize#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
			)
			</cfquery>
			<!--- We don't need to send an email --->
			<cfset arguments.thestruct.sendemail = false>
			<!--- Call the on_pre_process workflow --->
			<cfinvoke method="run_workflow" thestruct="#arguments.thestruct#" workflow_event="on_pre_process" />
			<!--- Create inserts --->
			<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
			<!--- Grab file --->
			<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
			<!--- Call the addasset function --->
			<!--- <cfthread intstruct="#arguments.thestruct#"> --->
				<cfinvoke method="addasset" thestruct="#arguments.thestruct#">
			<!--- </cfthread> --->
		<cfelse>
			<!--- RAZ-2810 Customise email message --->
			<cfset transvalues = arraynew()>
			<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
			<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
			<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
			<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#" isdup = "yes"  filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
		</cfif>
	</cfloop>
</cffunction>

<!--- INSERT SCHEDULED ASSETS FROM SERVER  --->
<cffunction name="addassetscheduledserverthread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- Name of lock file --->
	<cfset var lockfile = ".lock">
	<cfif arguments.thestruct.iswindows>
		<cfset var lockfile = "lock">
	</cfif>
	<!--- Check for the lock file --->
	<cfif fileExists("#arguments.thestruct.directory#/#lockfile#")>
		<cfabort>
	<cfelse>
		<cffile action="write" file="#arguments.thestruct.directory#/#lockfile#" output="x" mode="775" />
		<!--- On Windows make it hidden --->
		<cfif arguments.thestruct.iswindows>
			<cfset FileSetattribute("#arguments.thestruct.directory#/#lockfile#","hidden")>
		</cfif>
	</cfif>
	<cfset var theServerDir = "">
	<cfset var tempDirfiles = "">
	<cfset var tempServerDir = "">
	<cfset var theServerDir = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Params --->
	<cfparam name="session.currentupload" default="0">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<cfset arguments.thestruct.folderpath = arguments.thestruct.directory>
	<!--- Query --->
	<cfquery name="qGetRootFolderID" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#qGetRootFolderID */ folder_main_id_r, folder_level 
	FROM #session.hostdbprefix#folders
	WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfset var folderIdr = qGetRootFolderID.folder_main_id_r>
	<cfset var folder_level = qGetRootFolderID.folder_level>
	<!--- List for directories --->
	<cfdirectory action="list" directory="#arguments.thestruct.directory#" name="tempServerDir" recurse="#arguments.thestruct.recurse#" type="dir">
	<!--- Sort the above list in a query because cfdirectory sorting sucks --->
	<cfquery dbtype="query" name="theServerDir">
	SELECT *
	FROM tempServerDir
	WHERE name NOT LIKE '__MACOSX%'
	ORDER BY name
	</cfquery>
	<!--- Create Directories --->
	<cfif theServerDir.RecordCount GT 0>
		<cfloop query="theServerDir">
			<cfset var temp = "">
			<!--- Check how long the folder list is --->
			<cfset var namelistlen = listlen(name,FileSeparator())>
			<!--- If longer then 1 we need to get the folder_id_r of the previous folder --->
			<cfif namelistlen GT 1>
				<!--- Get the list entry at one higher then the current len --->
				<cfset var lenminusone = namelistlen - 1>
				<cfset var fnameforqry = ListGetAt(name, lenminusone, FileSeparator())>
				<cfset var theServerDirlen = listLen(theServerDir.name, FileSeparator())-1>
				<cfset var temp = folderIdr>
				<cfloop index="i" from=1 to="#theServerDirlen#">
					<cfset folder_name = listGetAt(theServerDir.name, i, FileSeparator())>
					<cfquery name="qryGetFolderDetails" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
					SELECT /* #variables.cachetoken#qryGetFolderDetails */ folder_id, folder_name 
					FROM #session.hostdbprefix#folders 
					WHERE lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(folder_name)#">
					AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#temp#">
					AND folder_main_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="cf_sql_varchar">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<cfset temp="#qryGetFolderDetails.folder_id#">
				</cfloop>
				<cfset var fidr = temp>
				<cfset var fname = listlast(name, FileSeparator())>
			<cfelse>
				<cfset var fname = name>
				<cfset var fidr = folderIdr>
			</cfif>
			<!--- Query to get the folder_id_r --->
			<cfquery datasource="#application.razuna.datasource#" name="qryfidr" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#qryfidr */ folder_id
			FROM #session.hostdbprefix#folders
			WHERE lower(folder_name) = <cfqueryparam value="#lcase(fname)#" cfsqltype="cf_sql_varchar">
			AND folder_id_r = <cfqueryparam value="#fidr#" cfsqltype="cf_sql_varchar">
			AND folder_main_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Add the Folder to DB --->
			<cfif qryfidr.recordcount EQ 0>
				<cfset folder_level=folder_level + 1>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#folders
				(folder_id, folder_name,folder_level, folder_id_r, folder_main_id_r, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, host_id)
				values (
				<cfqueryparam value="#createuuid("")#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#fname#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#folder_level#" cfsqltype="cf_sql_integer" >,
				<cfqueryparam value="#fidr#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("folders")>
	</cfif>
	<!--- List for files --->
	<cfdirectory action="list" directory="#arguments.thestruct.directory#" name="tempDirfiles" recurse="#arguments.thestruct.recurse#" type="file">
	<!--- Sort the above list in a query because cfdirectory sorting sucks --->
	<cfquery dbtype="query" name="theServerDirfiles">
	SELECT *
	FROM tempDirfiles
	WHERE size != 0
	AND attributes != 'H'
	AND name != 'thumbs.db'
	AND name != '#lockfile#'
	AND name NOT LIKE '.DS_STORE%'
	AND name NOT LIKE '__MACOSX%'
	AND name NOT LIKE '%scheduleduploads_%'
	ORDER BY name
	</cfquery>
	<!--- FILES --->
	<cfif theServerDirfiles.recordcount NEQ 0>
		<cfloop query="theServerDirfiles">
			<cfif fileexists("#directory#/#name#")>
				<cftry>
					<!--- Create tempid --->
					<cfset arguments.thestruct.tempid = createuuid("")>
					<cfset var temp="">
					<cfset var md5hash = "">
					<cfset var fileinprocess = "">
					<cfset var newFileName = "">
					<cfset arguments.thestruct.thefilenameoriginal = name>
					<!--- Set Original FileName --->
					<cfset arguments.thestruct.theoriginalfilename = listlast(name,FileSeparator())>
					<cfset arguments.thestruct.thepathtoname = replacenocase(name,arguments.thestruct.theoriginalfilename,"","one")>
					<!--- Rename the file so that we can remove any spaces --->
					<cfinvoke component="global" method="convertname" returnvariable="newFileName" thename="#arguments.thestruct.theoriginalfilename#">
					<cffile action="rename" source="#directory#/#name#" destination="#directory#/#arguments.thestruct.thepathtoname#/#newFileName#" mode="775" />
					<!--- The temppath --->
					<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.incomingpath#/#arguments.thestruct.tempid#">
					<!--- Create dir in incoming path --->
					<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775" />
					<!--- Copy file to incoming path --->
					<cffile action="move" source="#directory#/#arguments.thestruct.thepathtoname#/#newFileName#" destination="#arguments.thestruct.theincomingtemppath#/#newFileName#" mode="775" />
					<!--- Detect file extension --->
					<cfinvoke method="getFileExtension" theFileName="#newFileName#" returnvariable="fileNameExt">
					<cfset var file = structnew()>
					<cfset file.fileSize = size>
					<cfset file.oldFileSize = size>
					<cfset file.dateLastAccessed = dateLastModified>
					<!--- Get and set file type and MIME content --->
					<cfquery datasource="#application.razuna.datasource#" name="fileType">
					SELECT type_type, type_mimecontent, type_mimesubcontent
					FROM file_types
					WHERE lower(type_id) = <cfqueryparam value="#lcase(fileNameExt.theext)#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<!--- set attributes of file structure --->
					<cfif #fileType.recordCount# GT 0>
						<cfset arguments.thestruct.thefiletype = fileType.type_type>
					<cfelse>
						<cfset arguments.thestruct.thefiletype = "other">
					</cfif>
					
					<cfset arguments.thestruct.thefilename = newFileName>
					<cfset arguments.thestruct.thefilenamenoext = replacenocase("#newFileName#", ".#fileNameExt.theext#", "", "ALL")>
					<!--- MD5 Hash --->
					<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#newfilename#")>
						<cfset var md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#newfilename#")>
					</cfif>
					<!--- Check if we have to check for md5 records --->
					<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
					<!--- Check for the same MD5 hash in the existing records --->
					<cfif checkformd5>
						<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
					<cfelse>
						<cfset var md5here = 0>
					</cfif>
					<!--- If file does not exsist continue else send user an eMail --->
					<cfif md5here EQ 0>
						<!--- Check for the name which now contains the directory --->
						<cfset var theServerDirlen = listLen(name, FileSeparator()) - 1>
						<!--- If the above return 0 --->
						<cfif theServerDirlen EQ 0>
							<cfset var theServerDirlen = 1>
						</cfif>
						<!--- Get the directory name at the exact position in the list --->
						<cfset var theServerDirname = listGetAt(name, theServerDirlen, FileSeparator())>
						<!--- Get folder id with the name of the folder --->
						<cfquery datasource="#application.razuna.datasource#" name="qryfolderidmain">
						SELECT f.folder_id, f.folder_name,
						CASE
							WHEN EXISTS(
								SELECT s.folder_id
								FROM #session.hostdbprefix#folders s
								WHERE s.folder_id = f.folder_id_r
								AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
							) THEN 1
							ELSE 0
						END AS ISHERE
						FROM #session.hostdbprefix#folders f
						WHERE lower(f.folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(theServerDirname)#">
						AND f.folder_main_id_r = <cfqueryparam value="#qGetRootFolderID.folder_main_id_r#" cfsqltype="cf_sql_varchar">
						<!---
						AND f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#rootfolderId#">
						--->
						AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
						<!--- Subselect --->
						<cfquery dbtype="query" name="qryfolderid">
						SELECT *
						FROM qryfolderidmain
						WHERE ishere = 1
						</cfquery>
						
						<cfset temp=folderIdr>
						<cfloop index="i" from=1 to="#theServerDirlen#">
							<cfset folder_name = listGetAt(theServerDirfiles.name, i, FileSeparator())>
							<cfquery name="qryGetFolderDetails" datasource="#application.razuna.datasource#">
							SELECT folder_id, folder_name 
							FROM #session.hostdbprefix#folders 
							WHERE lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(folder_name)#">
							AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#temp#">
							AND folder_main_id_r = <cfqueryparam value="#qGetRootFolderID.folder_main_id_r#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
							</cfquery>
							<cfset temp="#qryGetFolderDetails.folder_id#">
						</cfloop>
						
						<!--- Put folder id into the general struct --->
						<cfif isDefined('temp') AND temp NEQ ''>
							<cfset arguments.thestruct.theid = temp>
						<cfelse>
							<cfset arguments.thestruct.theid = folderIdr>
						</cfif>
						
						<!--- Add to temp db --->
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#assets_temp
						(tempid,filename,extension,date_add,folder_id,who,filenamenoext,path<cfif structkeyexists(arguments.thestruct,"sched")>, sched_id, sched_action</cfif>,thesize,file_id,host_id,md5hash)
						VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#fileNameExt.theext#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.theid#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
						<cfif structkeyexists(arguments.thestruct,"sched")>
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.sched_id#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.sched_action#">,
						</cfif>
						<cfif isnumeric(file.fileSize)>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#file.fileSize#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="0">,
						</cfif>
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
						)
						</cfquery>
						<!--- Return IDs in a variable --->
						<!--- <cfset thetempids = arguments.thestruct.tempid & "," & thetempids> --->
						<!--- For each file we need query for the file --->
						
						<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qryfile">
						SELECT 
						tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, mimetype,
						thesize, groupid, sched_id, sched_action, file_id, link_kind, md5hash
						FROM #session.hostdbprefix#assets_temp
						WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
						<!--- We don't need to send an email --->
						<cfset arguments.thestruct.sendemail = false>
						<cfset arguments.thestruct.importpath = true>
						<!--- Call the on_pre_process workflow --->
						<cfinvoke method="run_workflow" thestruct="#arguments.thestruct#" workflow_event="on_pre_process" />
						<!--- Create inserts --->
						<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
						<!--- Grab file --->
						<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
						<!--- Call the addasset function --->
						<!--- <cfthread intstruct="#arguments.thestruct#"> --->
							<cfinvoke method="addasset" thestruct="#arguments.thestruct#">
						<!--- </cfthread> --->
					<cfelse>
						<!--- RAZ-2810 Customise email message --->
						<cfset transvalues = arraynew()>
						<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
						<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
						<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
						<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#"  isdup = "yes" filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
					</cfif>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Error in function assets.addassetscheduledserverthread">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Remove lock file --->
	<cftry>
		<cffile action="delete" file="#arguments.thestruct.directory#/#lockfile#" />
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error deleting lock file in function assets.addassetscheduledserverthread">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
</cffunction>

<!--- INSERT FROM EMAIL --->
<cffunction name="addassetemail" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="session.currentupload" default="0">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<!--- Add each file to the temp db, create temp dir and so on --->
	<cfloop list="#arguments.thestruct.emailid#" index="i">
		<!--- Retrieve the message --->
		<cfpop action="getall" server="#session.email_server#" username="#session.email_address#" password="#session.email_pass#" name="qrymessage" messagenumber="#i#" attachmentpath="#arguments.thestruct.thepath#/incoming/emails" generateuniquefilenames="no" timeout="3600">
		<cfoutput query="qrymessage">
			<!--- Check that there is an attachment. If so loop over it --->
			<cfset var numattachments = listlen(attachments)>
			<!--- If the number of attachments is greater then 0 continue --->
			<cfif numattachments GT 0>
				<!--- Loop over the attachments and get one by one --->
				<cfloop list="#attachmentfiles#" delimiters="," index="at">
					<!--- Sometimes attachments contain unwanted file --->
					<cfif NOT at CONTAINS "smime">
						<cfset var md5hash = "">
						<!--- Set names --->
						<cfset arguments.thestruct.thefilename = listlast(#at#, "/\")>
						<cfset var theextension = listlast("#arguments.thestruct.thefilename#",".")>
						<cfset arguments.thestruct.thefilenamenoext = replacenocase("#arguments.thestruct.thefilename#",".#theextension#","","All")>
						<!--- If the extension is longer then 9 chars --->
						<cfif len(theextension) GT 9>
							<cfset var theextension = "txt">
						</cfif>
						<!--- Create a unique name for the temp directory to hold the file --->
						<cfset arguments.thestruct.tempid = createuuid("")>
						<!--- Put current id into session --->
						<cfset session.currentupload = session.currentupload & "," & arguments.thestruct.tempid>
						<cfset arguments.thestruct.thetempfolder = "asset#arguments.thestruct.tempid#">
						<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
						<!--- Create a temp directory to hold the file --->
						<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
						<!--- Copy the file into the temp dir --->
						<cffile action="copy" source="#arguments.thestruct.thepath#/incoming/emails/#arguments.thestruct.thefilename#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" mode="775">
						<!--- Get the filesize --->
						<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" returnvariable="orgsize">
						<!--- MD5 Hash --->
						<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
							<cfset var md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
						</cfif>
						<!--- Check if we have to check for md5 records --->
						<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
						<!--- Check for the same MD5 hash in the existing records --->
						<cfif checkformd5>
							<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
						<cfelse>
							<cfset var md5here = 0>
						</cfif>
						<!--- If file does not exsist continue else send user an eMail --->
						<cfif md5here EQ 0>
							<!--- Add to temp db --->
							<cfquery datasource="#application.razuna.datasource#">
							INSERT INTO #session.hostdbprefix#assets_temp
							(TEMPID,FILENAME,EXTENSION,DATE_ADD,FOLDER_ID,WHO,FILENAMENOEXT,PATH,file_id,host_id,thesize,md5hash)
							VALUES(
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
							<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#orgsize#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
							)
							</cfquery>
							<!--- We don't need to send an email --->
							<cfset arguments.thestruct.sendemail = false>
							<!--- Call the on_pre_process workflow --->
							<cfinvoke method="run_workflow" thestruct="#arguments.thestruct#" workflow_event="on_pre_process" />
							<!--- Create inserts --->
							<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
							<!--- Grab file --->
							<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
							<!--- Call the addasset function --->
							<!--- <cfthread intstruct="#arguments.thestruct#"> --->
								<cfinvoke method="addasset" thestruct="#arguments.thestruct#">
							<!--- </cfthread> --->
						<cfelse>
							<!--- RAZ-2810 Customise email message --->
							<cfset transvalues = arraynew()>
							<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
							<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
							<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
							<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#"  isdup = "yes" filename="#arguments.thestruct.thefilename#"  md5hash="#md5hash#">
						</cfif>
					</cfif>
					<!--- Remove the attachment from the email folder. This is on purpose outside of the if so that we remove unwanted attachments as well --->
					<cftry>
						<cffile action="delete" file="#arguments.thestruct.thepath#/incoming/emails/#arguments.thestruct.thefilename#">
						<cfcatch type="any">
							<cfset cfcatch.custom_message = "Error removing attachment from email folder in function assets.addassetemail">
							<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>
		</cfoutput>
	</cfloop>
</cffunction>

<!--- INSERT FROM FTP IN THREAD --->
<cffunction name="addassetftpthread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Add to arguments --->
	<cfset arguments.thestruct.dsn = application.razuna.datasource>
	<cfset arguments.thestruct.ftp_server = session.ftp_server>
	<cfset arguments.thestruct.ftp_passive = session.ftp_passive>
	<cfset arguments.thestruct.ftp_user = session.ftp_user>
	<cfset arguments.thestruct.ftp_pass = session.ftp_pass>
	<!--- Start the thread for adding --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="addassetftp" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>


<!--- INSERT FROM FTP --->
<cffunction name="addassetftp" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="session.currentupload" default="0">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<cfparam name="arguments.thestruct.folderpath" default="">
	<cfset var ts = dateformat(now(),"mm.dd.yyyy")>
	<cfset var error = false>
	<cfset arguments.thestruct.donedir = "#arguments.thestruct.folderpath#/DONE_#ts#">
	<cfset arguments.thestruct.errordir = "#arguments.thestruct.folderpath#/ERRORS_#ts#">
	<!--- Create required DONE AND ERROR folders for process. All files imported successfully will be moved into DONE and ones that did not will be in the ERROR folder --->
	<cfset var o = ftpopen(server=arguments.thestruct.ftp_server,username=arguments.thestruct.ftp_user,password=arguments.thestruct.ftp_pass,passive=arguments.thestruct.ftp_passive, stoponerror=true)>
	<cfif isdefined("arguments.thestruct.sched_id") AND listlen(arguments.thestruct.thefile) GT 0>
		<cftry>
			<cfset ftpcreatedir(ftpdata=o, directory="#arguments.thestruct.donedir#")>
			<cfcatch/>
		</cftry>
		<cftry>
			<cfset ftpcreatedir(ftpdata=o, directory='#arguments.thestruct.errordir#')>
			<cfcatch/>
		</cftry>
	</cfif>
	<!--- Add each file to the temp db, create temp dir and so on --->
	<cfloop list="#arguments.thestruct.thefile#" index="i">
		<cftry>
			<cfset var md5hash = "">
			<!--- Create a unique name for the temp directory to hold the file --->
			<cfset arguments.thestruct.tempid = createuuid("")>
			<!--- Put current id into session --->
			<cfset session.currentupload = session.currentupload & "," & arguments.thestruct.tempid>
			<cfset arguments.thestruct.thetempfolder = "ftp#arguments.thestruct.tempid#">
			<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
			<!--- Create a temp directory to hold the file --->
			<cfif !directoryExists(arguments.thestruct.theincomingtemppath)>
				<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
			</cfif>
			<!--- Get file extension --->
			<cfset var theextension = listlast("#i#",".")>
			<cfset var namenoext = replacenocase("#i#",".#theextension#","","All")>
			<!--- If the extension is longer then 9 chars --->
			<cfif len(theextension) GT 9>
				<cfset var theextension = "txt">
			</cfif>
			<!--- Rename the file so that we can remove any spaces --->
			<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#i#">
			<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#namenoext#">
			<!--- Get the file from FTP --->
			<cfset arguments.thestruct.theoriginalfilename = arguments.thestruct.thefilename >
			<!--- If we are coming from a scheduled task then... --->
			<cfif structkeyexists(arguments.thestruct,"sched")>
				<cfset var remote_file = arguments.thestruct.folderpath & "/" & i>
			<cfelse>
				<cfset var remote_file = arguments.thestruct.folderpath & "/" & i>
			</cfif>
			<!--- Get file from FTP --->
			<cfset arguments.thestruct.remote_file = remote_file>
			<!--- Create uuid --->
			<!--- <cfset var tt = createUUID("")>
			<cfthread name="#tt#" intstruct="#arguments.thestruct#" action="run"> --->
				<!--- Get the file and lock it by name for 10 hours so no other process can access it again --->
				<cflock type="exclusive" timeout="36000" name="#arguments.thestruct.thefilename#">
					<cfset var getfile = Ftpgetfile(ftpdata=o,remotefile="#arguments.thestruct.remote_file#",localfile="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#",failifexists=false,passive=arguments.thestruct.ftp_passive,stoponerror=true)>
				</cflock>
				<cfif isdefined("arguments.thestruct.sched_id")>
					<cfif fileexists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
						<cfset var done = ftprename(ftpdata=o, oldfile="#arguments.thestruct.remote_file#", newfile="#arguments.thestruct.donedir#/#arguments.thestruct.thefilename#", stoponerror=true)>
						<!--- Delete from issue log if successfully transferred --->
						<cfquery datasource="#application.razuna.datasource#">
						DELETE FROM #session.hostdbprefix#schedules_log WHERE sched_id_r = '#arguments.thestruct.sched_id#' AND sched_log_desc LIKE '%#arguments.thestruct.thefilename#%'
						AND notified = 'false'
						</cfquery>
					<cfelse>
						<cfquery datasource="#application.razuna.datasource#">
							INSERT INTO #session.hostdbprefix#schedules_log
							(sched_log_id, sched_id_r, sched_log_user, sched_log_action, sched_log_date, 
							sched_log_time, sched_log_desc, host_id, notified)
							VALUES 
							(
							<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">, 
							<cfqueryparam value="#arguments.thestruct.sched_id#" cfsqltype="CF_SQL_VARCHAR">, 
							<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
							<cfqueryparam value="Error" cfsqltype="cf_sql_varchar">, 
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
							<cfqueryparam value="File '#arguments.thestruct.thefilename#' in folder '#arguments.thestruct.folderpath#' could not be imported successfully" cfsqltype="cf_sql_varchar">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="false">
							)
						</cfquery>
						<cfset ftprename(ftpdata=o, oldfile="#arguments.thestruct.remote_file#", newfile="#arguments.thestruct.errordir#/#arguments.thestruct.thefilename#", stoponerror=true)>
						<cfset error = true>
					</cfif>
				</cfif>
			<!--- </cfthread> --->
			<!--- Wait for the download above to finish --->
			<!--- <cfthread action="join" name="#tt#" /> --->
			<!--- Get the filesize --->
			<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" returnvariable="orgsize">
			<!--- MD5 Hash --->
			<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
				<cfset var md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
			</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- Check for the same MD5 hash in the existing records --->
			<cfif checkformd5>
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
			<cfelse>
				<cfset var md5here = 0>
			</cfif>
			<!--- If file does not exsist continue else send user an eMail --->
			<cfif md5here EQ 0>
				<!--- Add to temp db --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#assets_temp
				(TEMPID,FILENAME,EXTENSION,DATE_ADD,FOLDER_ID,WHO,FILENAMENOEXT,PATH,file_id,host_id,thesize,md5hash)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#orgsize#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
				)
				</cfquery>
				<!--- We don't need to send an email --->
				<cfset arguments.thestruct.sendemail = false>
				<!--- Call the on_pre_process workflow --->
				<cfinvoke method="run_workflow" thestruct="#arguments.thestruct#" workflow_event="on_pre_process" />
				<!--- Create inserts --->
				<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
				<!--- Grab file --->
				<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
				<!--- Call the addasset function --->
				<!--- <cfthread intstruct="#arguments.thestruct#"> --->
				<cfinvoke method="addasset" thestruct="#arguments.thestruct#">
				<!--- </cfthread> --->
			<cfelse>
				<!--- RAZ-2810 Customise email message --->
				<!--- <cfset transvalues = arraynew()>
				<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
				<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
				<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
				<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#" isdup = "yes" filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
				 --->
				 <cfif isdefined("arguments.thestruct.sched_id")>
					 <!--- Delete from issue log if loggd as error --->
					<cfquery datasource="#application.razuna.datasource#">
					DELETE FROM #session.hostdbprefix#schedules_log WHERE sched_id_r = '#arguments.thestruct.sched_id#' AND sched_log_desc LIKE '%#arguments.thestruct.thefilename#%'
					AND notified = 'false'
					</cfquery>

					<!--- FInd duplicate records found in the Razuna system and record it in the log --->
					<!--- Images --->
					<cfinvoke component="images" method="checkmd5" md5hash="#md5hash#" returnvariable="qryimg" />
					<!--- videos --->
					<cfinvoke component="videos" method="checkmd5" md5hash="#md5hash#" returnvariable="qryvid" />
					<!--- Files --->
					<cfinvoke component="files" method="checkmd5" md5hash="#md5hash#" returnvariable="qrydoc" />
					<!--- Audios --->
					<cfinvoke component="audios" method="checkmd5" md5hash="#md5hash#" returnvariable="qryaud" />

					<cfif qryimg.recordcount NEQ 0>
						<cfset var dataqry = "qryimg">
					<cfelseif qryvid.recordcount NEQ 0>
						<cfset var dataqry = "qryvid">
					<cfelseif qryaud.recordcount NEQ 0>
						<cfset var dataqry = "qryaud">
					<cfelseif qrydoc.recordcount NEQ 0>
						<cfset var dataqry = "qrydoc">
					<cfelse>
						<cfset var dataqry = "qryimg">
					</cfif>
					<cfquery dbtype="query" name="getdups">
						SELECT * FROM #dataqry#
					</cfquery>
					<!--- Get duplicate file names and path --->
					<cfset var duplist = "">
					<cfloop query="getdups">
						<cfset var folders = "">
						<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#getdups.folder_id_r#" returnvariable="crumbs" />
						<cfloop list="#crumbs#" delimiters=";" index="i">
							<cfset folders = folders & "/#ListGetAt(i,1,"|")#">
						</cfloop>
						<cfset folders = folders & "/#getdups.name#<br/>">
						<cfset duplist = duplist & folders>
					</cfloop>

					<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#schedules_log
						(sched_log_id, sched_id_r, sched_log_user, sched_log_action, sched_log_date, 
						sched_log_time, sched_log_desc, host_id, notified)
						VALUES 
						(
						<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#arguments.thestruct.sched_id#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="Duplicate" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
						<cfqueryparam value="File '#arguments.thestruct.folderpath#/#arguments.thestruct.thefilename#' on FTP server could not be imported as the file already exists in Razuna at the following locations: <br/>#duplist#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="false">
						)
					</cfquery>
					<cftry>
					<cfset var dup= ftprename(ftpdata=o, oldfile="#arguments.thestruct.donedir#/#arguments.thestruct.thefilename#", newfile="#arguments.thestruct.errordir#/#arguments.thestruct.thefilename#", stoponerror=true)>
					<cfset error = true>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Error in function assets.addassetftp">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
					</cftry>
				</cfif>
			</cfif>
			<cfcatch type="any">
				<cfif isdefined("arguments.thestruct.sched_id")>
					<cftry>
						<!--- Insert error log --->
						<cfquery datasource="#application.razuna.datasource#">
							INSERT INTO #session.hostdbprefix#schedules_log
							(sched_log_id, sched_id_r, sched_log_user, sched_log_action, sched_log_date, 
							sched_log_time, sched_log_desc, host_id, notified)
							VALUES 
							(
							<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">, 
							<cfqueryparam value="#arguments.thestruct.sched_id#" cfsqltype="CF_SQL_VARCHAR">, 
							<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
							<cfqueryparam value="Error" cfsqltype="cf_sql_varchar">, 
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
							<cfqueryparam value="#cfcatch.message#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="false">
							)
						</cfquery>
						<cfset ftprename(ftpdata=o, oldfile="#arguments.thestruct.remote_file#", newfile="#arguments.thestruct.errordir#/#arguments.thestruct.thefilename#", stoponerror=true)>
						<cfset error = true>
					<cfcatch></cfcatch>
					</cftry>
				</cfif>
				<cfset ftpclose(o)>
				<cfset cfcatch.custom_message = "Error in function assets.addassetftp">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
	</cfloop>
	<!--- Delete error folder if no errors encountered --->
	<cfif !error AND isdefined("arguments.thestruct.sched_id")>
		<cftry>
			<cfset ftpremovedir(ftpdata=o, directory="#arguments.thestruct.errordir#", stoponerror=true)>
			<cfcatch></cfcatch>
		</cftry>
		
	</cfif>
	<!--- Close connection --->
	<cfset ftpclose(o)>
</cffunction>


<!--- INSERT FROM API --->
<cffunction name="addassetapi" output="false" access="public" returntype="string">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="arguments.thestruct.debug" default="0">
	<cfparam name="arguments.thestruct.isbinary" default="false">
	<cfparam name="arguments.thestruct.plupload" default="false">
	<cfparam name="arguments.thestruct.zip_extract" default="1">
	<cfparam name="arguments.thestruct.upl_template" default="0">
	<cfparam name="arguments.thestruct.metadata" default="0">
	<cfparam name="arguments.thestruct.av" default="0">
	<cfparam name="arguments.thestruct.dam" default="false">
	<cfparam name="session.currentupload" default="0">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<cfset var md5hash = "">
	<cfset var qry = "">
	<cfset arguments.thestruct.thejsonbody = "">
	<!--- Put HTTP referer into var --->
	<cfset arguments.thestruct.comingfrom = cgi.http_referer>
	<!--- If developer wants to debug  --->
	<cfif isBoolean(arguments.thestruct.debug) AND arguments.thestruct.debug>
		<cfinvoke component="debugme" method="email_dump" emailto="#arguments.thestruct.emailto#" emailfrom="server@razuna.com" emailsubject="debug apiupload" dump="#arguments.thestruct#">
	</cfif>
	<cftry>
		<!--- This is from the uploader in Razuna --->
		<cfif isBoolean(arguments.thestruct.plupload) AND arguments.thestruct.plupload>
			<cfset var thesession = true>
			<cfset var theuserid = session.theuserid>
		<!--- Below is for API uploads --->
		<cfelse>
			<!--- Check if this API is still called with the old method if so, use the old authentication --->
			<cfif structkeyexists(arguments.thestruct,"sessiontoken")>
				<!--- Set application variables. Needed for the checkdb method in API --->
				<cfset application.razuna.api.dsn = application.razuna.datasource>
				<cfset application.razuna.api.setid = 1>
				<cfset application.razuna.api.prefix[#arguments.thestruct.sessiontoken#] = session.hostdbprefix>
				<cfset application.razuna.api.hostid[#arguments.thestruct.sessiontoken#] = session.hostid>
				<!--- Check sessiontoken --->
				<cfinvoke component="global.api.authentication" method="checkdb" sessiontoken="#arguments.thestruct.sessiontoken#" returnvariable="thesession">
				<!--- Get the user id --->
				<cfquery datasource="#application.razuna.datasource#" name="qryuser">
				SELECT userid
				FROM webservices
				WHERE sessiontoken = <cfqueryparam value="#arguments.thestruct.sessiontoken#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset var theuserid = qryuser.userid>
			<!--- This is the new one with api_key --->
			<cfelse>		
				<cfparam name="thehostid" default="" />
				<!--- Check to see if api key has a hostid --->
				<cfif arguments.thestruct.api_key contains "-">
					<cfset var thehostid = listfirst(arguments.thestruct.api_key,"-")>
					<cfset var theapikey = listlast(arguments.thestruct.api_key,"-")>
				<cfelse>
					<cfset var theapikey = arguments.thestruct.api_key>
				</cfif>
				<!--- Set application variables. Needed for the checkdb method in API --->
				<cfset application.razuna.api.dsn = application.razuna.datasource>
				<cfset application.razuna.api.thedatabase = application.razuna.thedatabase>
				<cfset application.razuna.api.storage = application.razuna.storage>
				<cfset application.razuna.api.setid = 1>
				<cfset application.razuna.api.prefix[#theapikey#] = session.hostdbprefix>
				<cfset application.razuna.api.hostid[#theapikey#] = session.hostid>
				<cfset application.razuna.api.userid[#theapikey#] = session.theuserid>
				<cfset application.razuna.api.cachetoken[#theapikey#] = createuuid("")>
				<!--- Query --->
				<cfquery datasource="#application.razuna.datasource#" name="qry">
				SELECT u.user_id, gu.ct_g_u_grp_id grpid, ct.ct_u_h_host_id hostid
				FROM users u, ct_users_hosts ct, ct_groups_users gu
				WHERE user_api_key = <cfqueryparam value="#theapikey#" cfsqltype="cf_sql_varchar"> 
				AND u.user_id = ct.ct_u_h_user_id
				<cfif thehostid NEQ "">
					AND ct.ct_u_h_host_id = <cfqueryparam value="#thehostid#" cfsqltype="cf_sql_numeric">
				</cfif>
				AND gu.ct_g_u_user_id = u.user_id
				AND (
					gu.ct_g_u_grp_id = <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">
					OR
					gu.ct_g_u_grp_id = <cfqueryparam value="2" cfsqltype="CF_SQL_VARCHAR">
				)
				GROUP BY user_id, ct_g_u_grp_id, ct_u_h_host_id
				</cfquery>
				<cfif qry.recordcount EQ 0>
					<cfset var thesession = false>
				<cfelse>
					<cfset var thesession = true>
					<cfset var theuserid = qry.user_id>
				</cfif>
			</cfif>
		</cfif>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user wants to add metadata fields then collect them here --->
			<cfif arguments.thestruct.metadata EQ 1>
				<!--- Set array --->
				<cfset var metaarray = arraynew(2)>
				<cfset var metacounter = 1>
				<cfset var metaarraycf = arraynew(2)>
				<cfset var metacountercf = 1>
				<!--- Loop over the metadata fields, they all have a prefix of meta_ --->
				<cfloop collection="#arguments.thestruct#" item="thefield">
					<cfif thefield CONTAINS "meta_">
						<cfset metaarray[#metacounter#][1] = replacenocase(thefield,"meta_","","ONE")>
						<cfset metaarray[#metacounter#][2] = arguments.thestruct["#thefield#"]>
						<!--- Increase the array --->
						<cfset var metacounter = metacounter + 1>
					</cfif>
				</cfloop>
				<!--- Serialize it to JSON and put it into struct --->
				<cfset arguments.thestruct.assetmetadata = SerializeJSON(metaarray)>
				<!--- Get the custom metadata fields --->
				<cfloop collection="#arguments.thestruct#" item="thefield">
					<cfif thefield CONTAINS "metacf_">
						<cfset metaarraycf[#metacountercf#][1] = replacenocase(thefield,"metacf_","","ONE")>
						<cfset metaarraycf[#metacountercf#][2] = arguments.thestruct["#thefield#"]>
						<!--- Increase the array --->
						<cfset metacountercf = metacountercf + 1>
					</cfif>
				</cfloop>
				<!--- Serialize it to JSON and put it into struct --->
				<cfset arguments.thestruct.assetmetadatacf = SerializeJSON(metaarraycf)>
			</cfif>
			<cfset arguments.thestruct.tempid = createuuid("")>
			<!--- Put current id into session --->
			<cfset session.currentupload = session.currentupload & "," & arguments.thestruct.tempid>
			<!--- Create a unique name for the temp directory to hold the file --->
			<cfset arguments.thestruct.thetempfolder = "api#arguments.thestruct.tempid#">
			<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
			<!--- Create a temp directory to hold the file --->
			<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
			<!--- If we come from plupload or the value isbinary is true then we look for the binary --->
			<cfif arguments.thestruct.isbinary>
				<!--- Set the file as struct --->
				<cfset var thefile = structnew()>
				<!--- Set filename --->
				<cfset thefile.serverFile = arguments.thestruct.name>
				<cfset thefile.serverFileName = arguments.thestruct.name>
				<!--- Extension --->
				<cfset thefile.serverFileExt = lcase(listlast(thefile.serverFile,"."))>
				<!--- If the extension is longer then 9 chars --->
				<cfif len(thefile.serverFileExt) GT 9>
					<cfset thefile.serverFileExt = "txt">
				</cfif>
				<!--- Get Requestdata --->
				<cfset arguments.thestruct.thereqdata = GetHttpRequestData()>
				<!--- Get Content and write content to file --->
				<cfset var tt = arguments.thestruct.tempid>
				<cfthread name="#tt#" action="run" intstruct="#arguments.thestruct#">
					<cffile action="write" file="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.name#" output="#attributes.intstruct.thereqdata.content#">
				</cfthread>
				<!--- Join above thread --->
				<cfthread action="join" name="#tt#" />
				<!--- Get Size --->
				<cfset var thefileinfo = getfileinfo("#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#")>
				<cfset thefile.filesize = thefileinfo.size>
			<cfelse>
				<!--- Initilaize thefile as local var --->
				<cfset var thefile = "">
				<!--- If plupload --->
				<cfif arguments.thestruct.plupload>
					<cfset var thefilefield = "file">
				<cfelse>
					<cfset var thefilefield = "filedata">
					<!--- Check to ensure filedata parameter was passed properly --->
					<cfif !isdefined("filedata")>
					<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>Missing 'filedata' parameter</message>
</Response></cfoutput>
					</cfsavecontent>
					<cfreturn thexml>
					</cfif>
				</cfif>
				<!--- Upload file --->
				<cffile action="upload" destination="#arguments.thestruct.theincomingtemppath#" nameconflict="overwrite" filefield="#thefilefield#" result="thefile">
				<cfset thefile.serverFileExt = "#lcase(thefile.serverFileExt)#">
				<!--- If the extension is longer then 9 chars --->
				<cfif len(thefile.serverFileExt) GT 9>
					<cfset thefile.serverFileExt = "txt">
				</cfif>
				<cfif thefile.serverFileExt  eq 'zip'>
					<cfset var iszip = true>
				</cfif>
			</cfif>
			<!--- Rename the file so that we can remove any spaces --->
			<cfinvoke component="global.cfc.global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#thefile.serverFile#">
			<cfinvoke component="global.cfc.global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#thefile.serverFileName#">
			<cffile action="rename" source="#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
			<!--- MD5 Hash --->
			<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
				<cfset var md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
			</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- Check for the same MD5 hash in the existing records --->
			<cfif checkformd5>
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
			<cfelse>
				<cfset var md5here = 0>
			</cfif>

			<!--- If file does not exsist continue else send user an eMail --->
			<cfif md5here EQ 0>
				<!--- If we only have the folder_id as variable --->
				<cfif structkeyexists(arguments.thestruct,"folder_id")>
					<cfset arguments.thestruct.destfolderid = arguments.thestruct.folder_id>
				<cfelseif !structkeyexists(arguments.thestruct,"folder_id")>
					<cfset arguments.thestruct.folder_id = arguments.thestruct.destfolderid>
				</cfif>
				<cfset var checkfolder = "">
				<cfquery datasource="#application.razuna.datasource#" name="checkfolder">
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.destfolderid#">
					AND lower(in_trash) = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="f">
				</cfquery>
				<cfif checkfolder.recordcount EQ 0>
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>Specified folder '#arguments.thestruct.destfolderid#' does not exist</message>
</Response></cfoutput>
				</cfsavecontent>
				<cfreturn thexml />
				</cfif>
				<!--- Add to temp db --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#assets_temp
				(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, thesize, file_id, host_id, md5hash)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefile.serverFileExt#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.destfolderid#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theuserid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefile.filesize#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#md5hash#">
				)
				</cfquery>
				<!--- Put user id into session for later on --->
				<cfset session.theuserid = theuserid>
				<!--- We don't need to send an email --->
				<cfset arguments.thestruct.sendemail = false>
				<!--- Add the original file name in a session since it is stored as lower case in the temp DB --->
				<cfset arguments.thestruct.theoriginalfilename = thefile.serverFile>
				<!--- Call the on_pre_process workflow --->
				<cfinvoke method="run_workflow" thestruct="#arguments.thestruct#" workflow_event="on_pre_process" />
				<!--- Create inserts --->
				<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
				<!--- Grab file --->
				<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
				<cfif arraylen(getallthreads()) LT 100>
					<!--- Call the addasset function --->
					<cfthread intstruct="#arguments.thestruct#">
						<cfinvoke method="addasset" thestruct="#attributes.intstruct#">
					</cfthread>
				<cfelse>
					<cfinvoke method="addasset" thestruct="#arguments.thestruct#">
				</cfif>
				<!--- Get file type so we can return the type --->
				<cfquery datasource="#application.razuna.datasource#" name="fileType">
				SELECT type_type
				FROM file_types
				WHERE lower(type_id) = <cfqueryparam value="#lcase(thefile.serverFileExt)#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- set attributes of file structure --->
				<cfif fileType.recordCount GT 0>
					<cfset var thefiletype = fileType.type_type>
				<cfelse>
					<cfset var thefiletype = "other">
				</cfif>
				<!--- If this is a zip file then get tempid from temp table for zip file as the tempid is changed from original after extraction --->
				<cfif isdefined("iszip")>
					<cfquery datasource="#application.razuna.datasource#" name="gettempid">
					SELECT tempid
					FROM  #session.hostdbprefix#assets_temp
					WHERE lower(filename) = <cfqueryparam value="#lcase(arguments.thestruct.thefilename)#" cfsqltype="cf_sql_varchar">
					ORDER BY DATE_ADD DESC
					</cfquery>
					<cfset arguments.thestruct.tempid = gettempid.tempid>
				</cfif>

				<!--- Return Message --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>success</message>
<assetid>#xmlformat(arguments.thestruct.tempid)#</assetid>
<filetype>#xmlformat(thefiletype)#</filetype>
<comingfrom><![CDATA[#arguments.thestruct.comingfrom#]]></comingfrom>
<renamefilebody><![CDATA[#arguments.thestruct.thejsonbody#]]></renamefilebody>
</Response></cfoutput>
				</cfsavecontent>
				<!--- When the redirect param is here then --->
				<cfif structkeyexists(arguments.thestruct,"redirectto")>
					<!--- If additional params are passed --->
					<cfif structkeyexists(arguments.thestruct,"redirecttoparams")>
						<cfset var redirvar = "#arguments.thestruct.redirectto#?responsecode=0&message=success&assetid=#arguments.thestruct.tempid#&filetype=#thefiletype#&#arguments.thestruct.redirecttoparams#">
					<cfelse>
						<cfset var redirvar = "#arguments.thestruct.redirectto#?responsecode=0&message=success&assetid=#arguments.thestruct.tempid#&filetype=#thefiletype#">
					</cfif>
					<!--- Redirect --->
					<cflocation url="#redirvar#" addToken="yes">
				</cfif>
			<cfelse>
				<!--- Return Message --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>File already exists in Razuna</message>
<assetid>#xmlformat(arguments.thestruct.thefilename)#</assetid>
</Response></cfoutput>
				</cfsavecontent>
				<!--- RAZ-2810 Customise email message --->
				<cfset var transvalues = arraynew()>
				<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
				<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
				<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
				<!--- Send email with the duplicate asset --->
				<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#" isdup = "yes" filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
			</cfif>
		<!--- No session found --->
		<cfelse>
			<!--- When the redirect param is here then --->
			<cfif structkeyexists(arguments.thestruct,"redirectto")>
				<cflocation url="#arguments.thestruct.redirectto#?responsecode=1&message=nosession" addToken="yes">
			<cfelse>
				<cfinvoke component="global.api2.authentication" method="timeout" type="x" returnvariable="thexml">
			</cfif>
		</cfif>
		<!--- Catch --->
		<cfcatch type="any">
			<!--- When the redirect param is here then --->
			<cfif structkeyexists(arguments.thestruct,"redirectto")>
				<cflocation url="#arguments.thestruct.redirectto#?responsecode=1&message=htmleditformat(Upload failed #xmlformat(cfcatch.Detail)# #xmlformat(cfcatch.Message)#)" addToken="yes">
			<cfelse>
				<!--- Return Message --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
	<Response>
	<responsecode>1</responsecode>
	<message>Upload failed #xmlformat(cfcatch.Detail)# #xmlformat(cfcatch.Message)#</message>
	</Response></cfoutput>
				</cfsavecontent>
			</cfif>
			<cfset cfcatch.custom_message = "Error in API upload in function assets.addassetapi">
			<cfset errobj.logerrors(cfcatch,false)/>
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn thexml />
</cffunction>

<!--- Create Inserts --->
<cffunction name="create_inserts" output="true" access="public">
	<cfargument name="tempid" type="string">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var qry_file = "">
	<cfset var qry_mime = "">
	<cfparam default="" name="arguments.thestruct.uploadkind">
	<!--- Get the file --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_file">
	SELECT tempid, filename, extension, folder_id, file_id, link_kind
	FROM #session.hostdbprefix#assets_temp
	WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tempid#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cftry>
		<!--- Don't need to do any inserts for URL and versions --->
		<cfif qry_file.file_id EQ 0>
			<!--- Get the file type --->
			<cfquery dataSource="#application.razuna.datasource#" name="qry_mime">
			SELECT type_type
			FROM file_types
			WHERE lower(type_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(qry_file.extension)#">
			</cfquery>
			<!--- IMAGES --->
			<cfif qry_mime.type_type EQ "img">
				<!--- Add records to the DB - We do this here so that fast subsequent calls from the API work --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#images
				(img_id, host_id, folder_id_r, is_available, img_filename, img_create_time)
				VALUES(
				<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#qry_file.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
				<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
					<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry_file.filename#">
				</cfif>,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				)
				</cfquery>
				<!--- Create empty records in the table because we sometimes have images without XMP --->
				<cfloop list="#arguments.thestruct.langcount#" index="langindex">
					<!--- Insert --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#images_text
					(id_inc, img_id_r, lang_id_r, host_id)
					VALUES(
					<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				</cfloop>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#xmp
				(id_r)
				VALUES(
					<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Flush Cache --->
				<cfset resetcachetoken("images")>
			<!--- VIDEOS --->
			<cfelseif qry_mime.type_type EQ "vid">
				<!--- Insert record --->		
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#videos
				(vid_id, vid_name_org, vid_filename, host_id, folder_id_r, path_to_asset, is_available, vid_create_time)
				VALUES(
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry_file.tempid#">,
				<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
					<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry_file.filename#">
				</cfif>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry_file.filename#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry_file.folder_id#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry_file.folder_id#/vid/#qry_file.tempid#">,
				<cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				)
				</cfquery>
				<!--- Add the TEXTS to the DB. We have to hide this is if we are coming from FCK --->
				<cfif structkeyexists(arguments.thestruct,"langcount")>
					<cfloop list="#arguments.thestruct.langcount#" index="langindex">
						<cfif arguments.thestruct.uploadkind EQ "many">
							<cfset var desc="file_desc_" & "#countnr#" & "_" & "#langindex#">
							<cfset var keywords="file_keywords_" & "#countnr#" & "_" & "#langindex#">
							<cfset var title="file_title_" & "#countnr#" & "_" & "#langindex#">
						<cfelse>
							<cfset var desc="arguments.thestruct.file_desc_" & "#langindex#">
							<cfset var keywords="arguments.thestruct.file_keywords_" & "#langindex#">
							<cfset var title="arguments.thestruct.file_title_" & "#langindex#">
						</cfif>
						<cfif desc CONTAINS "#langindex#">
							<!--- check if form-vars are present. They will be missing if not coming from a user-interface (assettransfer, etc.) --->
							<cfif IsDefined(desc) and IsDefined(keywords) and IsDefined(title)>
								<cfquery datasource="#application.razuna.datasource#">
									INSERT INTO #session.hostdbprefix#videos_text
									(id_inc, vid_id_r, lang_id_r, vid_description, vid_keywords, vid_title, host_id)
									VALUES(
									<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
									<cfqueryparam value="#evaluate(desc)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#evaluate(keywords)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#evaluate(title)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
									)
								</cfquery>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
				<!--- Flush Cache --->
				<cfset resetcachetoken("videos")>
			<!--- AUDIOS --->
			<cfelseif qry_mime.type_type EQ "aud">
				<!--- Add record --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#audios
				(aud_id, is_available, folder_id_r, host_id, aud_create_time, aud_name)
				VALUES(
					<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="0">,
					<cfqueryparam value="#qry_file.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
						<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
					<cfelse>
						<cfqueryparam value="#qry_file.filename#" cfsqltype="cf_sql_varchar">
					</cfif>
				)
				</cfquery>
				<!--- Flush Cache --->
				<cfset resetcachetoken("audios")>
			<!--- DOCUMENTS --->
			<cfelse>
				<!--- Insert --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#files
				(file_id, is_available, folder_id_r, host_id, file_name, file_create_time)
				VALUES(
					<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#qry_file.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
						<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">,
					<cfelse>
						<cfqueryparam value="#qry_file.filename#" cfsqltype="cf_sql_varchar">,
					</cfif>
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					)
				</cfquery>
				<!--- Flush Cache --->
				<cfset resetcachetoken("files")>
			</cfif>
			<!--- Flush the rest of the cache --->
			<cfset resetcachetoken("folders")>
			<cfset resetcachetoken("search")> 
			<cfset resetcachetoken("general")>
		</cfif>
		<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function assets.create_inserts">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Return --->
</cffunction>

<!--- INSERT FROM LINK --->
<cffunction name="addassetlink" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam default="" name="arguments.thestruct.link_file_name">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<!--- If variables do not exist --->
	<cfif NOT structkeyexists(variables,"dsn")>
		<cfset variables.dsn = arguments.thestruct.dsn>
	</cfif>
	<cfif NOT structkeyexists(variables,"setid")>
		<cfset variables.setid = arguments.thestruct.setid>
	</cfif>
	<cfif NOT structkeyexists(variables,"database")>
		<cfset variables.database = arguments.thestruct.database>
	</cfif>
	<cftry>
		<cfset var md5hash = "">
		<!--- Create temp ID --->
		<cfset arguments.thestruct.tempid = createuuid("")>
		<!--- Get the extension of the file --->
		<cfset var thefilename = listlast(arguments.thestruct.link_path_url,"/\")>
		<cfset var theext = listlast(thefilename,".")>
		<cfset var thefilenamenoext = listfirst(thefilename,".")>
		<!--- If the extension is longer then 9 chars --->
		<cfif len(theext) GT 9>
			<cfset var theext = "txt">
		</cfif>
		<!--- If the user did not enter a filename we read the filename from the file --->
		<cfif arguments.thestruct.link_file_name NEQ "" AND arguments.thestruct.link_kind NEQ "lan">
			<cfset var thefilename = arguments.thestruct.link_file_name>
		</cfif>
		<!--- Replace any p or br in the textarea --->
		<cfset arguments.thestruct.link_path_url = Replace(arguments.thestruct.link_path_url, "#chr(10)##chr(13)#", "", "ALL")>
		<!--- If this is a video with embeeded player we set extension manually --->
		<cfif arguments.thestruct.link_kind EQ "urlvideo">
			<cfset arguments.thestruct.link_kind = "url">
			<cfset var theext = "mov">
		</cfif>
		<!--- If this is a local link --->
		<cfif arguments.thestruct.link_kind EQ "lan">
			<!--- OpenBD fileExists returns true for folderpath. So need to use directoryExists too --->
			<cfif NOT (fileExists("#arguments.thestruct.link_path_url#") and NOT directoryExists("#arguments.thestruct.link_path_url#")) >
				<cfoutput>file_not_found_error</cfoutput><cfabort>
			</cfif>	
			<!--- Get size --->
			<cfif NOT structkeyexists(arguments.thestruct,"orgsize")>
				<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.link_path_url#" returnvariable="orgsize">
			<cfelse>
				<cfset var orgsize = arguments.thestruct.orgsize>
			</cfif>
			<cfset arguments.thestruct.lanorgname = listlast(arguments.thestruct.link_path_url,"/\")>
			<!--- MD5 Hash --->
			<cfif FileExists("#arguments.thestruct.link_path_url#")>
				<cfset var md5hash = hashbinary("#arguments.thestruct.link_path_url#")>
			</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- Check for the same MD5 hash in the existing records --->
			<cfif checkformd5>
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
			<cfelse>
				<cfset var md5here = 0>
			</cfif>
		<!--- If a URL --->
		<cfelse>
			<cfset var orgsize = 0>
			<cfset var md5here = 0>
		</cfif>
		<!--- If file does not exsist continue else send user an eMail --->
		<cfif md5here EQ 0>
			<!--- Add to temp db --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#assets_temp
			(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, mimetype, thesize, file_id, link_kind, host_id, md5hash)
			VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilename#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#theext#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilenamenoext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.link_path_url#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#orgsize#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.link_kind#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
			)
			</cfquery>
			<!--- We don't need to send an email --->
			<cfset arguments.thestruct.sendemail = false>
			<!--- Create inserts --->
			<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
			<!--- Grab file --->
			<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
			<!--- Call the addasset function --->
			<!--- <cfthread intstruct="#arguments.thestruct#"> --->
				<cfinvoke method="addasset" thestruct="#arguments.thestruct#">
			<!--- </cfthread> --->
		<cfelse>
			<!--- RAZ-2810 Customise email message --->
			<cfset var transvalues = arraynew()>
			<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
			<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
			<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
			<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#" isdup = "yes" filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
		</cfif>
		<!--- Catch --->
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error from LINK upload in function assets.addassetlink">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn />
</cffunction>


<!--- This is the new threaded one --->
<cffunction name="addassetsendmail" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.sendemail" default="true">
	<cfparam name="arguments.thestruct.tempid" default="0">
	<cfparam name="arguments.thestruct.skip_event" default="">
	<cfset arguments.thestruct.qryfile = 0>
	<!--- Query the file to get filename and other stuff. This qry is also used within adding assets --->
	<cfif arguments.thestruct.tempid NEQ 0>
		<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qryfile">
		SELECT tempid, filename, extension, date_add, folder_id, who, filenamenoext, 
		path, mimetype, thesize, groupid, sched_id, sched_action, file_id, link_kind, md5hash
		FROM #session.hostdbprefix#assets_temp
		WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		ORDER BY extension
		</cfquery>
	</cfif>
	<!--- If we need to send an email --->
	<cfif arguments.thestruct.sendemail>
		<!--- Get the eMail from this user --->
		<cfquery datasource="#application.razuna.datasource#" name="qryuser">
		SELECT user_email
		FROM users
		WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
		</cfquery>
		<!--- Convert the now date to readable format --->
		<cfinvoke component="defaults" method="getdateformat" returnvariable="thedateformat" dsn="#application.razuna.datasource#">
		<!--- RAZ-2810 Customise email message --->
		<cfset var transvalues = arraynew()>
		<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
		<cfset transvalues[2] = "#dateformat(now(),"#thedateformat#")#">
		<cfset transvalues[3] = "#timeformat(now(),"HH:mm:sstt")#">
		<cfset transvalues[4] = "#arguments.thestruct.emailorgname#">
		<cfset transvalues[5] = "#ucase(arguments.thestruct.convert_to)#">
		<!--- The Message --->
		<!--- For adding asset --->
		<cfif arguments.thestruct.emailwhat EQ "start_adding">
			<cfinvoke component="defaults" method="trans" transid="start_adding_asset_subject" values="#transvalues#" returnvariable="start_adding_asset_sub" />
			<cfinvoke component="defaults" method="trans" transid="start_adding_asset_message" values="#transvalues#" returnvariable="start_adding_asset_msg" />
			<cfset var thesubject = "#start_adding_asset_sub#">
			<cfset var mailmessage = "#start_adding_asset_msg#">
		<!--- Finished adding asset --->
		<cfelseif arguments.thestruct.emailwhat EQ "end_adding">
			<cfinvoke component="defaults" method="trans" transid="end_adding_asset_subject" values="#transvalues#" returnvariable="end_adding_asset_sub" />
			<cfinvoke component="defaults" method="trans" transid="end_adding_asset_message" values="#transvalues#" returnvariable="end_adding_asset_msg" />
			<cfset var thesubject = "#end_adding_asset_sub#">
			<cfset var mailmessage = "#end_adding_asset_msg#">
		<!--- Start Converting --->
		<cfelseif arguments.thestruct.emailwhat EQ "start_converting">
			<cfinvoke component="defaults" method="trans" transid="start_converting_asset_subject" values="#transvalues#" returnvariable="start_converting_asset_sub" />
			<cfinvoke component="defaults" method="trans" transid="start_converting_asset_message" values="#transvalues#" returnvariable="start_converting_asset_msg" />
			<cfset var thesubject = "#start_converting_asset_sub#">
			<cfset var mailmessage = "#start_converting_asset_msg#">
		<!--- End Converting --->
		<cfelseif arguments.thestruct.emailwhat EQ "end_converting">
			<cfinvoke component="defaults" method="trans" transid="end_converting_asset_subject" values="#transvalues#" returnvariable="end_converting_asset_sub" />
			<cfinvoke component="defaults" method="trans" transid="end_converting_asset_message" values="#transvalues#" returnvariable="end_converting_asset_msg" />
			<cfset var thesubject = "#end_converting_asset_sub#">
			<cfset var mailmessage = "#end_converting_asset_msg#">
		</cfif>
		<!--- Send the email --->
		<cftry>
			<cfinvoke component="email" method="send_email" to="#qryuser.user_email#" subject="#thesubject#" themessage="#mailmessage#">
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error sending email in function assets.addassetemail">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
		</cftry>
	</cfif>
	<!--- Return --->	
	<cfreturn arguments.thestruct.qryfile>
</cffunction>

<!--- This is the new threaded one --->
<cffunction name="addasset" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if this is the very first upload for host --->
	<cfif not structKeyExists(session, "firstasset")>
		<cfquery datasource="#application.razuna.datasource#" name="checkasset">
			SELECT hashtag FROM  #session.hostdbprefix#images WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			UNION ALL
			SELECT hashtag FROM  #session.hostdbprefix#audios WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			UNION ALL
			SELECT hashtag FROM  #session.hostdbprefix#videos WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			UNION ALL
			SELECT hashtag FROM  #session.hostdbprefix#files WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif checkasset.recordcount EQ 0 OR (checkasset.recordcount EQ 1 AND checkasset.hashtag EQ '')>
			<cfset session.firstasset = true>
		<cfelse>
			<cfset session.firstasset = false>
		</cfif>
	</cfif>
	
	<!--- If very first upload then add a index task to run once --->

	<cfif session.firstasset>
		<cfif application.razuna.isp>
			<cfschedule action="update"
				task="RazLuceneIndexUpdate_#session.hostid#" 
				operation="HTTPRequest"
				url="#session.thehttp##cgi.http_host#/index.cfm?fa=c.w_lucene_update_index&host_id=#session.hostid#"
				startDate="#LSDateFormat(Now(), 'mm/dd/yyyy')#"
				startTime="#LSTimeFormat(dateadd('n',5,now()),'HH:mm tt')#"
				interval="once"
			>
		</cfif>
		<cfset session.firstasset = false>
	</cfif>

	<!--- Limit threads --->
	<cfif arraylen(getallthreads()) GT 200>
		<cfset createObject( "java", "java.lang.Runtime" ).getRuntime().gc()>
	</cfif>
	<!--- Call method to send email within that we also query the tempdb and return it here to pass it on --->
	<cfset arguments.thestruct.emailwhat = "start_adding">
	<cfset arguments.thestruct.dsn = application.razuna.datasource>
	<cfset arguments.thestruct.setid = application.razuna.setid>
	<cfset arguments.thestruct.database = application.razuna.thedatabase>
	<!--- If tempid exists we make sure it has no - --->
	<cfif structkeyexists(arguments.thestruct,"tempid")>
		<cfset arguments.thestruct.tempid = replace(arguments.thestruct.tempid,"-","","ALL")>
	</cfif>
	<!--- Thread --->
	<cfif arguments.thestruct.qryfile.tempid NEQ "">
		<cfthread name="addasset#arguments.thestruct.tempid#" intstruct="#arguments.thestruct#" action="run">
			<cfinvoke method="addassetthread" thestruct="#attributes.intstruct#" />
		</cfthread>
		<!--- Join above thread --->
		<cfthread action="join" name="addasset#arguments.thestruct.tempid#" />
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- 
INSERT INTO DB 
This is the main function called directly by a single upload else from addassetserver, addassetemail, addassetftp indirectly
--->
<cffunction name="addassetthread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Default values --->
	<cfparam default="0" name="arguments.thestruct.zip_extract">
	<cfparam default="" name="arguments.thestruct.fieldname">
	<cfparam default="" name="arguments.thestruct.uploadkind">
	<cfparam default="" name="arguments.thestruct.link_kind">
	<cfparam default="false" name="arguments.thestruct.importpath">
	<cfparam default="0" name="arguments.thestruct.upl_template">
	<cfparam default="0" name="arguments.thestruct.metadata">
	<cfparam default="" name="arguments.thestruct.assetmetadata">
	<cfparam default="" name="arguments.thestruct.assetmetadatacf">
	<cfset arguments.thestruct.theimagepath = "#arguments.thestruct.thepath#/images">
	<!--- If zip_extract is undefined --->
	<cfif arguments.thestruct.zip_extract EQ "" OR arguments.thestruct.zip_extract EQ "undefined">
		<cfset arguments.thestruct.zip_extract = 0>
	</cfif>

	<!--- Catch issues with file not being fully uploaded to server due to interruption in data transfer. Happens if you 'Re-start Upload' or close plupload window during data transfer and then re-open which cancels previous uploads in progress --->
	<cfif isdefined('arguments.thestruct.file_size')><!---  Check if file size reported by client via plupload is defined --->
		<cfset var filesize_onserver = getfileinfo("#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#").size> <!--- Get file size on server --->
		<!--- Compare file size on server to actual file size reported by client and if size error > 1% abort --->
		<cfif (1 - filesize_onserver/arguments.thestruct.file_size)*100 GT 1>
			<!--- Log to console --->
			<cfset console('Partial file upload: #arguments.thestruct.qryfile.filename#. Aborting.')>
			<!--- Delete leftover entries --->
			<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
				DELETE FROM #session.hostdbprefix#images WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
				DELETE FROM #session.hostdbprefix#audios WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
				DELETE FROM #session.hostdbprefix#videos WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
				DELETE FROM #session.hostdbprefix#files WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
			</cfquery>
			<cfabort>
		</cfif>
	</cfif>
	<!--- If this is zip file and extract is set to yes then try and read the file to ensure it is not corrupted --->
	<cfif arguments.thestruct.qryfile.extension EQ "zip" AND arguments.thestruct.zip_extract>
		<cftry>
			<cfset var zipinfo = "">
			<cfzip action="list" zipfile="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" variable="zipinfo"/>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error reading zip file '#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#'. Please ensure file is a valid zip archive."/>
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				<cfset var transvalues = arraynew()>
				<cfset transvalues[1] = "#arguments.thestruct.qryfile.filename#">
				<cfinvoke component="defaults" method="trans" transid="zip_not_added_subject" values="#transvalues#" returnvariable="zip_not_added_sub" />
				<cfinvoke component="defaults" method="trans" transid="zip_not_added_message" values="#transvalues#" returnvariable="zip_not_added_msg" />
				<cfinvoke component="email" method="send_email" subject="#zip_not_added_sub#" themessage="#zip_not_added_msg#">
				<!--- Delete leftover entries --->
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
					DELETE FROM #session.hostdbprefix#images WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
					DELETE FROM #session.hostdbprefix#audios WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
					DELETE FROM #session.hostdbprefix#videos WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
					DELETE FROM #session.hostdbprefix#files WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
				</cfquery>
				<cfabort>
			</cfcatch>
		</cftry>
	</cfif>

	<!--- Query to get the settings --->
	<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
	SELECT set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, set2_img_comp_width,
	set2_img_comp_heigth, set2_vid_preview_author, set2_vid_preview_copyright, set2_path_to_assets, set2_colorspace_rgb
	FROM #session.hostdbprefix#settings_2
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- If we store assets on the file system check if folder id exists in the assets path --->
	<cfif (application.razuna.storage EQ "local" AND arguments.thestruct.qryfile.link_kind NEQ "url") OR application.razuna.storage EQ "akamai">
		<cftry>
			<cfdirectory action="list" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#" name="mydir">
			<!--- Dir not found thus create it --->
			<cfcatch type="any">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/img" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/vid" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/aud" mode="775">
			</cfcatch>
		</cftry>
	</cfif>
	<!--- check if compressed file (ZIP) --->
	<cfif arguments.thestruct.qryfile.extension EQ "zip" AND arguments.thestruct.zip_extract AND arguments.thestruct.qryfile.link_kind EQ "">
		<!--- RAZ-2907 Extract the compressed zip file for bulk upload versions --->
		<cfif structKeyExists(arguments.thestruct,'extjs') AND arguments.thestruct.extjs EQ "T">
			<cfset var zipnameorg = arguments.thestruct.qryfile.filename>
			<cfinvoke method="extractFrom_versions_Zip" thestruct="#arguments.thestruct#">
			<cfset var returnid = 1>
			<cfset arguments.thestruct.thefile = zipnameorg>
		<cfelse>	
		<cfset var zipnameorg = arguments.thestruct.qryfile.filename>
		<cfinvoke method="extractFromZip" thestruct="#arguments.thestruct#">
		<cfset var returnid = 1>
		<cfset arguments.thestruct.thefile = zipnameorg>
		</cfif>
	<cfelse>
		<!--- Get and set file type and MIME content --->
		<cfquery datasource="#application.razuna.datasource#" name="fileType">
		SELECT type_type, type_mimecontent, type_mimesubcontent
		FROM file_types
		WHERE lower(type_id) = <cfqueryparam value="#lcase(arguments.thestruct.qryfile.extension)#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- set attributes of file structure --->
		<cfif fileType.recordCount GT 0>
			<cfset arguments.thestruct.thefiletype = fileType.type_type>
		<cfelse>
			<cfset arguments.thestruct.thefiletype = "other">
		</cfif>
		<!--- Now start the file mumbo jumbo --->
		<cfif fileType.type_type EQ "img">
			<!--- IMAGE UPLOAD (call method to process a img-file) --->
			<cfinvoke method="processImgFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
			<cfset arguments.thestruct.thefiletype = "img">
			<!--- Act on Upload Templates --->
			<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
				<cfset arguments.thestruct.upltemptype = "img">
				<cfset arguments.thestruct.file_id = returnid>
				<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
			</cfif>
		<cfelseif fileType.type_type EQ "vid">
			<!--- VIDEO UPLOAD (call method to process a vid-file) --->
			<cfinvoke method="processVidFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
			<cfset arguments.thestruct.thefiletype = "vid">
			<!--- Act on Upload Templates --->
			<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
				<cfset arguments.thestruct.upltemptype = "vid">
				<cfset arguments.thestruct.file_id = returnid>
				<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
			</cfif>
		<cfelseif fileType.type_type EQ "aud">
			<!--- AUDIO UPLOAD (call method to process a aud-file) --->
			<cfinvoke method="processAudFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
			<cfset arguments.thestruct.thefiletype = "aud">
			<!--- Act on Upload Templates --->
			<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
				<cfset arguments.thestruct.upltemptype = "aud">
				<cfset arguments.thestruct.file_id = returnid>
				<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
			</cfif>
		<cfelse>
			<!--- DOCUMENT UPLOAD (call method to process a doc-file) --->
			<cfinvoke method="processDocFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
			<cfset arguments.thestruct.thefiletype = "doc">
		</cfif>
		<!--- Put file_id in struct as fileid for plugin api --->
		<cfset arguments.thestruct.fileid = returnid>
		<cfset arguments.thestruct.file_name = arguments.thestruct.qryfile.filename>
		<cfset arguments.thestruct.folder_id = arguments.thestruct.qryfile.folder_id>
		<cfset arguments.thestruct.folder_action = false>
		<!--- Check on any plugin that call the on_file_add action --->
		<cfinvoke component="plugins" method="getactions" theaction="on_file_add" args="#arguments.thestruct#" />
		<cfset arguments.thestruct.folder_action = true>
		<!--- Check on any plugin that call the on_file_add action --->
		<cfinvoke component="plugins" method="getactions" theaction="on_file_add" args="#arguments.thestruct#" />
	</cfif>
	<!--- If we are coming from a scheduled task then... --->
	<cfif structkeyexists(arguments.thestruct,"sched")>
		<!--- Log Insert --->
		<cfinvoke component="scheduler" method="tolog" theschedid="#arguments.thestruct.sched_id#" theuserid="#session.theuserid#" theaction="Insert" thedesc="Added file #arguments.thestruct.qryfile.filename#">
		<!--- Remove in the temp db --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#assets_temp
		WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.tempid#">
		</cfquery>
		<!--- First only do this for assets with the same sched id --->
		<cfif arguments.thestruct.sched_id EQ arguments.thestruct.qryfile.sched_id AND fileExists("#arguments.thestruct.folderpath#/#arguments.thestruct.thefilenameoriginal#")>
			<cffile action="delete" file="#arguments.thestruct.folderpath#/#arguments.thestruct.thefilenameoriginal#">
		</cfif>
	</cfif>
	<!--- Remove record in DB and file system --->
	<cfinvoke method="removeasset" thestruct="#arguments.thestruct#">
	<cfif returnid NEQ 0>
		<!--- Call method to send email --->
		<cfset arguments.thestruct.emailwhat = "end_adding">
		<cfif structKeyExists(arguments.thestruct,'extjs') AND arguments.thestruct.extjs EQ 'T'>
			<cfset arguments.thestruct.thefiles = arguments.thestruct.qryfile.filename>
			<cfset arguments.thestruct.thefiles = arguments.thestruct.thefiles & ",">
			<cfloop list="#arguments.thestruct.thefiles#" index="i" delimiters=",">
				<cfset arguments.thestruct.thefilename = i>
				<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
			</cfloop>
		<cfelse>
		<cfif NOT structkeyexists(arguments.thestruct,"thefile")>
			<cfset arguments.thestruct.thefile = arguments.thestruct.qryfile.filename>
		</cfif>
		<cfset arguments.thestruct.thefile = arguments.thestruct.thefile & ",">
		<cfloop list="#arguments.thestruct.thefile#" index="i" delimiters=",">
			<cfset arguments.thestruct.thefilename = i>
			<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
		</cfloop>
	</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.qryfile.path>
</cffunction>

<!--- DELETE IN DB AND FILE SYSTEM -------------------------------------------------------------------->
<cffunction name="removeasset" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Thread --->
	<cfthread action="run" intvars="#arguments.thestruct#">
		<!--- Set time for remove --->
		<cfset removetime = DateAdd("h", -6, "#now()#")>
		<!--- Clear assets dbs from records which have no path_to_asset --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#images
		WHERE (path_to_asset IS NULL OR path_to_asset = '')
		AND img_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#videos
		WHERE (path_to_asset IS NULL OR path_to_asset = '')
		AND vid_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#files
		WHERE (path_to_asset IS NULL OR path_to_asset = '')
		AND file_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#audios
		WHERE (path_to_asset IS NULL OR path_to_asset = '')
		AND aud_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
		</cfquery>
		<!--- Select temp assets which are older then 6 hours --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT path as temppath, tempid
		FROM #session.hostdbprefix#assets_temp
		WHERE date_add < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
		AND path LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%dam/incoming%">
		AND path IS NOT NULL
		</cfquery>
		<!--- Loop trough the found records --->
		<cfloop query="qry">
			<!--- Delete in the DB --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tempid#">
			</cfquery>
			<!--- Delete on the file system --->
			<cfif directoryexists(temppath)>
				<cfdirectory action="delete" recurse="true" directory="#temppath#">
			</cfif>
		</cfloop>
		<cftry>
			<!--- Now check directory on the hard drive. This will fix issue with files that were not successfully uploaded thus missing in the temp db --->
			<cfdirectory action="list" directory="#attributes.intvars.thepath#/incoming" name="thedirs">
			<!--- Loop over dirs --->
			<cfloop query="thedirs">
				<cfif datelastmodified LT removetime AND directoryexists("#attributes.intvars.thepath#/incoming/#name#")>
					<cfdirectory action="delete" directory="#attributes.intvars.thepath#/incoming/#name#" recurse="true" mode="775">
				</cfif>
			</cfloop>
			<cfcatch type="any">
			</cfcatch>
		</cftry>
	</cfthread>
</cffunction>

<!--- PROCESS A DOCUMENT-FILE -------------------------------------------------------------------->
<cffunction name="processDocFile" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset arguments.thestruct.newid = 1>
	<!--- New ID --->
	<cfset arguments.thestruct.newid = arguments.thestruct.qryfile.tempid>
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- Set Params --->
	<cfset arguments.thestruct.gettemp = GetTempDirectory()>
	<cfset arguments.thestruct.file_meta = "">
	<cfset arguments.thestruct.pathorg = arguments.thestruct.qryfile.path>
	<cfset var ttpdf = Createuuid("")>
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset var cloud_url_2 = structnew()>
	<cfset var file_meta = "">
	<cfset var thesubject = "">
	<cfset var thekeywords = "">
	<cfset var theapplekeywords = "">
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<!--- Set executables and scripts --->
	<cfif arguments.thestruct.iswindows>
		<cfset arguments.thestruct.theimconvert = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
		<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<!--- Set scripts --->
		<cfset arguments.thestruct.thesh = "#arguments.thestruct.gettemp#/#ttpdf#.bat">
		<cfset arguments.thestruct.thesht = "#arguments.thestruct.gettemp#/#ttpdf#t.bat">
		<cfset arguments.thestruct.theshexs = "#arguments.thestruct.gettemp#/#ttpdf#exs.bat">
		<cfset arguments.thestruct.theshexk = "#arguments.thestruct.gettemp#/#ttpdf#exk.bat">
		<cfset arguments.thestruct.theshexak = "#arguments.thestruct.gettemp#/#ttpdf#exak.bat">
		<cfset arguments.thestruct.theshexmeta = "#arguments.thestruct.gettemp#/#ttpdf#exmeta.bat">
		<cfset arguments.thestruct.theshexmetaxmp = "#arguments.thestruct.gettemp#/#ttpdf#exmetaxmp.bat">
	<cfelse>
		<cfset arguments.thestruct.theimconvert = "#arguments.thestruct.thetools.imagemagick#/convert">
		<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<!--- Set scripts --->
		<cfset arguments.thestruct.thesh = "#arguments.thestruct.gettemp#/#ttpdf#.sh">
		<cfset arguments.thestruct.thesht = "#arguments.thestruct.gettemp#/#ttpdf#t.sh">
		<cfset arguments.thestruct.theshexs = "#arguments.thestruct.gettemp#/#ttpdf#exs.sh">
		<cfset arguments.thestruct.theshexk = "#arguments.thestruct.gettemp#/#ttpdf#exk.sh">
		<cfset arguments.thestruct.theshexak = "#arguments.thestruct.gettemp#/#ttpdf#exak.sh">
		<cfset arguments.thestruct.theshexmeta = "#arguments.thestruct.gettemp#/#ttpdf#exmeta.sh">
		<cfset arguments.thestruct.theshexmetaxmp = "#arguments.thestruct.gettemp#/#ttpdf#exmetaxmp.sh">
	</cfif>
	<!--- Set some more vars but only for PDF --->
	<cfif arguments.thestruct.qryfile.extension EQ "PDF" AND arguments.thestruct.qryfile.link_kind NEQ "url">
		<!--- If this is a linked asset --->
		<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
			<!--- Create var with temp directory to hold the thumbnail and images --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
			<cfset arguments.thestruct.theorgfileflat = "#arguments.thestruct.qryfile.path#[0]">
			<cfset arguments.thestruct.theorgfile = arguments.thestruct.qryfile.path>
			<cfset arguments.thestruct.theorgfileraw = arguments.thestruct.qryfile.path>
			<!--- The name for the pdf --->
			<cfset var getlast = listlast(arguments.thestruct.qryfile.path,"/\")>
			<cfset arguments.thestruct.thepdfimage = replacenocase(getlast,".pdf",".jpg","all")>
		<!--- For importpath --->
		<cfelseif arguments.thestruct.importpath NEQ "" AND arguments.thestruct.importpath>
			<!--- Create var with temp directory to hold the thumbnail and images --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
			<cfset arguments.thestruct.theorgfileflat = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#[0]">
			<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- The name for the pdf --->
			<cfset arguments.thestruct.thepdfimage = replacenocase(arguments.thestruct.qryfile.filename,".pdf",".jpg","all")>
			<!--- Create temp folder --->
			<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775" />
		<cfelse>
			<cfset arguments.thestruct.thetempdirectory = arguments.thestruct.qryfile.path>
			<cfset arguments.thestruct.theorgfileflat = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#[0]">
			<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- The name for the pdf --->
			<cfset arguments.thestruct.thepdfimage = replacenocase(arguments.thestruct.qryfile.filename,".pdf",".jpg","all")>
		</cfif>
	</cfif>
	<!--- If we are PDF we create thumbnail and images from the PDF --->
	<!--- RFS --->
	<cfif !application.razuna.rfs>
		<cfif arguments.thestruct.qryfile.extension EQ "PDF" AND arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- Create a temp folder to hold the PDF images --->
			<cfset arguments.thestruct.thepdfdirectory = "#arguments.thestruct.thetempdirectory#/#createuuid('')#/razuna_pdf_images">
			<!--- Create folder to hold the images --->
			<cfdirectory action="create" directory="#arguments.thestruct.thepdfdirectory#" mode="775">
			<cfset var resizeargs = "400x"> <!--- Set default preview size to 400x --->
			<cfset var thumb_width = arguments.thestruct.qrysettings.set2_img_thumb_width>
			<cfset var thumb_height = arguments.thestruct.qrysettings.set2_img_thumb_heigth>
			<!--- If both height and width are set then resize to exact height and width set. --->
			<cfif isnumeric(thumb_width) AND isnumeric(thumb_height)>
				<cfset resizeargs =  "#thumb_width#x#thumb_height#">
			<!--- If only height set then resize to given height preserving aspect ratio.  --->
			<cfelseif isnumeric(thumb_height)>
				<cfset resizeargs = "x#thumb_height#">
			<!--- If only width set then resize to given width preserving aspect ratio. --->
			<cfelseif isnumeric(thumb_width)>
				<cfset resizeargs = "#thumb_width#x">
			</cfif>
			<!--- Script: Create thumbnail --->
			<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theimconvert# -density 300 -quality 100  ""#arguments.thestruct.theorgfileflat#"" -resize #resizeargs# -colorspace sRGB -background white -flatten ""#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thepdfimage#""" mode="777">
			<!--- Script: Create images --->
			<cffile action="write" file="#arguments.thestruct.thesht#" output="#arguments.thestruct.theimconvert# -density 100 -quality 100 ""#arguments.thestruct.theorgfile#"" ""#arguments.thestruct.thepdfdirectory#/#arguments.thestruct.thepdfimage#""" mode="777">
			<!--- Execute --->
			<cfthread name="#ttpdf#" action="run" pdfintstruct="#arguments.thestruct#">
				<cfexecute name="#attributes.pdfintstruct.thesh#" timeout="900" />
				<cfif application.razuna.storage NEQ "amazon">
					<cfexecute name="#attributes.pdfintstruct.thesht#" timeout="900" />
				</cfif>
			</cfthread>
			<!--- Wait for thread to finish --->
			<cfthread action="join" name="#ttpdf#" />					
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
			<cffile action="delete" file="#arguments.thestruct.thesht#">
			<!--- If no PDF could be generated then copy the thumbnail placeholder --->
			<cfif NOT fileexists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thepdfimage#")>
				<cffile action="copy" source="#arguments.thestruct.rootpath#global/host/dam/images/icons/icon_pdf.png" destination="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thepdfimage#" mode="775">
			</cfif>
			<!--- RAZ-2480 : Setting link_path_url for the PDF type files --->
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.qryfile.path#">
			<cfelse>
				<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			</cfif>
		<!--- InDesign --->
		<cfelseif arguments.thestruct.qryfile.extension EQ "indd">
			<!--- Set vars --->
			<!--- Fix path if this is coming from lan --->
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				<cfset arguments.thestruct.qryfile.path = replace(arguments.thestruct.qryfile.path,listlast(arguments.thestruct.qryfile.path,'\/'),"","ALL")>
			</cfif>
			<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<cfset arguments.thestruct.thepdfimagename = "#arguments.thestruct.qryfile.filenamenoext#.jpg">
			<cfset arguments.thestruct.thepdfimage = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.thepdfimagename#">
			<!--- Write script --->
			<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 ""#arguments.thestruct.theorgfile#"" -PageImage -b -listitem 0 > ""#arguments.thestruct.thepdfimage#""" mode="777">
			<!--- Execute --->
			<cfthread name="#ttpdf#" action="run" intstruct="#arguments.thestruct#">
				<cfexecute name="#attributes.intstruct.thesh#" timeout="900" />
			</cfthread>
			<!--- Wait for thread to finish --->
			<cfthread action="join" name="#ttpdf#" />					
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				<!--- Reset path change we made above for lan --->
				<cfset arguments.thestruct.qryfile.path = arguments.thestruct.pathorg>
			</cfif>
		<!--- We are normal files --->
		<cfelse>
			<!--- Check the platform and then decide on the ImageMagick tag --->
			<cfif arguments.thestruct.iswindows>
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" timeout="60" variable="file_meta" charset="utf-8" />
				<!--- On LAN Put the path into this variable for the md5 hash --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
					<cfset arguments.thestruct.theorgfileraw = arguments.thestruct.qryfile.path>
					<cfset arguments.thestruct.qryfile.path = arguments.thestruct.qryfile.path>
				<cfelse>
					<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
					<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
				</cfif>
			<cfelse>
				<!--- Set scripts --->
				<cfset arguments.thestruct.thesh = "#arguments.thestruct.gettemp#/#ttpdf#.sh">
				<!--- On LAN --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
					<cfset arguments.thestruct.theorgfileraw = arguments.thestruct.qryfile.path>
					<cfset arguments.thestruct.qryfile.path = replace(arguments.thestruct.qryfile.path," ","\ ","all")>
					<cfset arguments.thestruct.qryfile.path = replace(arguments.thestruct.qryfile.path,"&","\&","all")>
					<cfset arguments.thestruct.qryfile.path = replace(arguments.thestruct.qryfile.path,"'","\'","all")>
				<cfelse>
					<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
					<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
				</cfif>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.qryfile.path#" mode="777" charset="utf-8">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="900" variable="file_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
		</cfif>
	</cfif>
	<!--- If this is a URL then reset the path --->
	<cfif arguments.thestruct.qryfile.link_kind EQ "url">
		<cfset arguments.thestruct.qryfile.path = arguments.thestruct.pathorg>
	</cfif>
	<!--- If we are a new version --->
	<cfif arguments.thestruct.qryfile.file_id NEQ 0>
		<cfset arguments.thestruct.qryfile.path = arguments.thestruct.pathorg>
		<!--- RAZ-2907 Call the component for Bulk upload versions --->
		<cfif structKeyExists(arguments.thestruct,'extjs') AND arguments.thestruct.extjs EQ "T">
			<!--- Call versions component to do the old versions thingy --->
			<cfinvoke component="versions" method="upload_old_versions" thestruct="#arguments.thestruct#">
		<cfelse>	
		<!--- Call versions component to do the versions thingy --->
		<cfinvoke component="versions" method="create" thestruct="#arguments.thestruct#">
		</cfif>
	<!--- This is for normal adding --->
	<cfelse>
		<!--- If there are metadata fields then add them here --->
		<cfif arguments.thestruct.metadata EQ 1>
			<!--- Check if API is called the old way --->
			<cfif structkeyexists(arguments.thestruct,"sessiontoken")>
				<cfinvoke component="global.api.asset" method="setmetadata">
					<cfinvokeargument name="sessiontoken" value="#arguments.thestruct.sessiontoken#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
					<cfinvokeargument name="assettype" value="doc">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
			<cfelse>
				<!--- API2 --->
				<cfinvoke component="global.api2.asset" method="setmetadata">
					<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
					<cfinvokeargument name="assettype" value="doc">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
				<!--- Add custom fields --->
				<cfinvoke component="global.api2.customfield" method="setfieldvalue">
					<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
					<cfinvokeargument name="field_values" value="#arguments.thestruct.assetmetadatacf#">
				</cfinvoke>
			</cfif>
		</cfif>
		<!--- Flush Cache --->
		<cfset resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")> 
		<cfset resetcachetoken("general")>
		<!--- Get Metadata for PDF --->
		<cfif (arguments.thestruct.qryfile.extension EQ "PDF" OR arguments.thestruct.qryfile.extension EQ "indd") AND arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- On Windows reparse the metadata again (doesnt work properly with the bat file) --->
			<cfif arguments.thestruct.isWindows>
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -b -subject ""#arguments.thestruct.theorgfile#""" timeout="60" variable="thesubject" />
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -keywords ""#arguments.thestruct.theorgfile#""" timeout="60" variable="thekeywords" />
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -applekeywords ""#arguments.thestruct.theorgfile#""" timeout="60" variable="theapplekeywords" />
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename ""#arguments.thestruct.theorgfile#""" timeout="60" variable="file_meta" />
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -X ""#arguments.thestruct.theorgfile#""" timeout="60" variable="arguments.thestruct.pdf_xmp" />
			<cfelse>
				<!--- Script: Exiftool Commands --->
				<cffile action="write" file="#arguments.thestruct.theshexs#" output="#arguments.thestruct.theexif# -fast -fast2 -b -subject ""#arguments.thestruct.theorgfile#""" mode="777" charset="utf-8">
				<cffile action="write" file="#arguments.thestruct.theshexk#" output="#arguments.thestruct.theexif# -fast -fast2 -XMP-PDF:keywords ""#arguments.thestruct.theorgfile#""" mode="777" charset="utf-8">
				<cffile action="write" file="#arguments.thestruct.theshexak#" output="#arguments.thestruct.theexif# -fast -fast2 -PDF:keywords ""#arguments.thestruct.theorgfile#""" mode="777" charset="utf-8">
				<cffile action="write" file="#arguments.thestruct.theshexmeta#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename ""#arguments.thestruct.theorgfile#""" mode="777" charset="utf-8">
				<cffile action="write" file="#arguments.thestruct.theshexmetaxmp#" output="#arguments.thestruct.theexif# -fast -fast2 -X ""#arguments.thestruct.theorgfile#""" mode="777" charset="utf-8">
				<!--- Execute scripts --->
				<cfexecute name="#arguments.thestruct.theshexs#" timeout="60" variable="thesubject" />
				<cfexecute name="#arguments.thestruct.theshexk#" timeout="60" variable="thekeywords" />
				<cfexecute name="#arguments.thestruct.theshexak#" timeout="60" variable="theapplekeywords" />
				<cfexecute name="#arguments.thestruct.theshexmeta#" timeout="60" variable="file_meta" />
				<cfexecute name="#arguments.thestruct.theshexmetaxmp#" timeout="60" variable="arguments.thestruct.pdf_xmp" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.theshexs#">
				<cffile action="delete" file="#arguments.thestruct.theshexk#">
				<cffile action="delete" file="#arguments.thestruct.theshexak#">
				<cffile action="delete" file="#arguments.thestruct.theshexmeta#">
				<cffile action="delete" file="#arguments.thestruct.theshexmetaxmp#">							
			</cfif>
			<!--- Parse PDF XMP and write to DB --->
			<cfif structKeyExists(arguments.thestruct,"pdf_xmp") AND arguments.thestruct.pdf_xmp NEQ "">
				<cfinvoke component="xmp" method="getpdfxmp" thestruct="#arguments.thestruct#" />
				<!--- Put Xmp custom metadata into custom fields --->
				<cfset arguments.thestruct.thesource = arguments.thestruct.theorgfile>
				<cfinvoke component="xmp" method="xmpToCustomFields" thestruct="#arguments.thestruct#" />
			</cfif>
			<!--- Grab the keywords --->
			<cfset var thekeywords = trim(listlast(thekeywords,":"))>
			<cfset var theapplekeywords = trim(listlast(theapplekeywords,":"))>
			<!--- If XMP keywords is empty take the PDF:Keywords var --->
			<cfif thekeywords EQ "">
				<cfset var thekeywords = theapplekeywords>
			</cfif>
			<!--- Append keywords and description to DB --->
			<cfif structkeyexists(arguments.thestruct,"langcount")>
				<cfloop list="#arguments.thestruct.langcount#" index="langindex">
					<!--- Update keywords and descriptions for api --->
					<cfif structkeyexists(arguments.thestruct,"api_key") AND arguments.thestruct.api_key NEQ ''>
					<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #session.hostdbprefix#files_desc
						SET 
						file_desc = <cfqueryparam value="#thesubject#" cfsqltype="cf_sql_varchar">,
						file_keywords = <cfqueryparam value="#thekeywords#" cfsqltype="cf_sql_varchar">	
						WHERE file_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">
					</cfquery>
					<cfelse>
					<!--- Insert Keywords and Descriptions --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#files_desc
					(id_inc, file_id_r, lang_id_r, file_desc, file_keywords, host_id)
					values(
					<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#thesubject#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#thekeywords#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<!--- Put file_meta into struct for api --->
		<cfset arguments.thestruct.file_meta = file_meta>
		<!--- append to the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#files
		SET
		folder_id_r = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
		file_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
		file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
		file_create_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
		file_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		file_owner = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
		file_type = <cfqueryparam value="#arguments.thestruct.thefiletype#" cfsqltype="cf_sql_varchar">, 
		file_name_noext = <cfqueryparam value="#arguments.thestruct.qryfile.filenamenoext#" cfsqltype="cf_sql_varchar">, 
		file_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">, 				
		file_online = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">, 
		file_name_org = 
			<cfif arguments.thestruct.link_kind EQ "lan">
				<cfqueryparam value="#arguments.thestruct.lanorgname#" cfsqltype="cf_sql_varchar">,
			<cfelse>
				<cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			</cfif>
		file_size = <cfqueryparam value="#arguments.thestruct.qryfile.thesize#" cfsqltype="cf_sql_varchar">, 
		link_path_url = <cfqueryparam value="#arguments.thestruct.qryfile.path#" cfsqltype="cf_sql_varchar">, 
		link_kind = <cfqueryparam value="#arguments.thestruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">, 
		host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">, 
		file_meta = <cfqueryparam value="#file_meta#" cfsqltype="cf_sql_varchar">,
		path_to_asset =  <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">,
		hashtag =  <cfqueryparam value="#arguments.thestruct.qryfile.md5hash#" cfsqltype="cf_sql_varchar">
		<cfif application.razuna.storage NEQ "local">
			,
			lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#" cfsqltype="cf_sql_varchar">
		</cfif>
		WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Get sharing options for folder so it can be applied to the asset --->
		<cfquery datasource="#application.razuna.datasource#" name="get_dl_params">
			SELECT share_dl_org 
			FROM #session.hostdbprefix#folders 
			WHERE folder_id = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Insert to share_options --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#share_options
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="doc" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="org" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#iif(get_dl_params.share_dl_org eq 't',1,0)#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Move the file to its own directory --->
		<cfif application.razuna.storage EQ "local" AND arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- Create folder with the asset id --->
			<cfif !directoryexists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#" mode="775">
			</cfif>
			<!--- Move the file from the temp path to this folder, but not for local link assets --->
			<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
				<cffile action="copy" source="#arguments.thestruct.theorgfileraw#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" mode="775">
			</cfif>
			<!--- If we are PDF we need to move the thumbnail and image as well --->
			<cfif arguments.thestruct.qryfile.extension EQ "PDF" AND !application.razuna.rfs>
				<!--- Move thumbnail --->
				<cffile action="move" source="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thepdfimage#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.thepdfimage#" mode="775">
				<!--- Create image folder --->
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/razuna_pdf_images" mode="775">
				<!--- List all images and then move them --->
				<cfdirectory action="list" directory="#arguments.thestruct.thepdfdirectory#" name="pdfjpgs">
				<cfloop query="pdfjpgs">
					<cffile action="move" source="#arguments.thestruct.thepdfdirectory#/#name#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/razuna_pdf_images/#name#" mode="775">
				</cfloop>
			<!--- InDesign --->
			<cfelseif arguments.thestruct.qryfile.extension EQ "indd" AND !application.razuna.rfs>
				<!--- Move thumbnail --->
				<cffile action="move" source="#arguments.thestruct.thepdfimage#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.thepdfimagename#" mode="775">
			</cfif>
		<!--- NIRVANIX --->
		<cfelseif application.razuna.storage EQ "nirvanix" AND arguments.thestruct.qryfile.link_kind NEQ "url">
			<cfset var ttu = createuuid("")>
			<cfthread name="#ttu#" action="run" upstruct="#arguments.thestruct#">
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.upstruct.qryfile.folder_id#/doc/#attributes.upstruct.newid#">
					<cfinvokeargument name="uploadfile" value="#attributes.upstruct.qryfile.path#">
					<cfinvokeargument name="nvxsession" value="#attributes.upstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for thread to finish --->
			<cfthread action="join" name="#ttu#" />	
			<!--- If we are PDF we need to upload the thumbnail and image as well --->
			<cfif arguments.thestruct.qryfile.extension EQ "PDF" AND !application.razuna.rfs>
				<cfset var ttut = createuuid("")>
				<cfthread name="#ttut#" action="run" upstruct="#arguments.thestruct#">
					<cfinvoke component="nirvanix" method="Upload">
						<cfinvokeargument name="destFolderPath" value="/#attributes.upstruct.qryfile.folder_id#/doc/#attributes.upstruct.newid#">
						<cfinvokeargument name="uploadfile" value="#attributes.upstruct.thetempdirectory#/#attributes.upstruct.thepdfimage#">
						<cfinvokeargument name="nvxsession" value="#attributes.upstruct.nvxsession#">
					</cfinvoke>
				</cfthread>
				<!--- Wait for thread to finish --->
				<cfthread action="join" name="#ttut#" />	
				<!--- List all images and then upload them --->
				<cfdirectory action="list" directory="#arguments.thestruct.thepdfdirectory#" name="pdfjpgs">
				<!--- Upload images --->
				<cfloop query="pdfjpgs">
					<cfinvoke component="nirvanix" method="Upload">
						<cfinvokeargument name="destFolderPath" value="/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/razuna_pdf_images">
						<cfinvokeargument name="uploadfile" value="#arguments.thestruct.thepdfdirectory#/#name#">
						<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
					</cfinvoke>
				</cfloop>
				<!--- Get signed URLS for the thumbnail --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.thepdfimage#" nvxsession="#arguments.thestruct.nvxsession#">
				<!--- Update DB  --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET 
				cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<!--- InDesign --->
			<cfelseif arguments.thestruct.qryfile.extension EQ "indd">
				<!--- Upload thumbnail --->
				<cfset var ttut = createuuid("")>
				<cfthread name="#ttut#" action="run" upstruct="#arguments.thestruct#">
					<cfinvoke component="nirvanix" method="Upload">
						<cfinvokeargument name="destFolderPath" value="/#attributes.upstruct.qryfile.folder_id#/doc/#attributes.upstruct.newid#">
						<cfinvokeargument name="uploadfile" value="#attributes.upstruct.thepdfimage#">
						<cfinvokeargument name="nvxsession" value="#attributes.upstruct.nvxsession#">
					</cfinvoke>
				</cfthread>
				<!--- Wait for thread to finish --->
				<cfthread action="join" name="#ttut#" />
				<!--- Get signed URLS for the thumbnail --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.thepdfimagename#" nvxsession="#arguments.thestruct.nvxsession#">
				<!--- Update DB  --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET 
				cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
			<!--- Get signed URLS for the file --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- Update DB  --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#files
			SET 
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
			WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<!--- AMAZON --->
		<cfelseif application.razuna.storage EQ "amazon" AND arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- Upload file --->
			<cfset var upd = Createuuid("")>
			<cfif arguments.thestruct.qryfile.extension EQ "indd">
				<cfset arguments.thestruct.theamzasset = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<cfelse>
				<cfset arguments.thestruct.theamzasset = "#arguments.thestruct.qryfile.path#">
			</cfif>
			<cfthread name="#upd#" action="run" intupstruct="#arguments.thestruct#">
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intupstruct.qryfile.folder_id#/doc/#attributes.intupstruct.newid#/#attributes.intupstruct.qryfile.filename#">
					<cfinvokeargument name="theasset" value="#attributes.intupstruct.theamzasset#">
					<cfinvokeargument name="awsbucket" value="#attributes.intupstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="#upd#" />
			<!--- If we are PDF we need to upload the thumbnail and image as well --->
			<cfif arguments.thestruct.qryfile.extension EQ "PDF" AND !application.razuna.rfs>
				<!--- Upload thumbnail --->		
				<cfset var updt = Createuuid("")>
				<cfthread name="#updt#" action="run" intuptstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Upload">
						<cfinvokeargument name="key" value="/#attributes.intuptstruct.qryfile.folder_id#/doc/#attributes.intuptstruct.newid#/#attributes.intuptstruct.thepdfimage#">
						<cfinvokeargument name="theasset" value="#attributes.intuptstruct.thetempdirectory#/#attributes.intuptstruct.thepdfimage#">
						<cfinvokeargument name="awsbucket" value="#attributes.intuptstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
				<cfthread action="join" name="#updt#" />
				<!--- Get signed URLS for the thumbnail --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.thepdfimage#" awsbucket="#arguments.thestruct.awsbucket#">
				<!--- List all images and then upload them --->
				<cfdirectory action="list" directory="#arguments.thestruct.thepdfdirectory#" name="pdfjpgs">
				<!--- Upload images --->
				<cfloop query="pdfjpgs">
					<cfinvoke component="amazon" method="Upload">
						<cfinvokeargument name="key" value="/#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/razuna_pdf_images/#name#">
						<cfinvokeargument name="theasset" value="#arguments.thestruct.thepdfdirectory#/#name#">
						<cfinvokeargument name="awsbucket" value="#arguments.thestruct.awsbucket#">
					</cfinvoke>
				</cfloop>
				<!--- Update DB  --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET 
				cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<!--- InDesign --->
			<cfelseif arguments.thestruct.qryfile.extension EQ "indd">
				<!--- Upload thumbnail --->		
				<cfset var updt = Createuuid("")>
				<cfthread name="#updt#" action="run" intuptstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Upload">
						<cfinvokeargument name="key" value="/#attributes.intuptstruct.qryfile.folder_id#/doc/#attributes.intuptstruct.newid#/#attributes.intuptstruct.thepdfimagename#">
						<cfinvokeargument name="theasset" value="#attributes.intuptstruct.thepdfimage#">
						<cfinvokeargument name="awsbucket" value="#attributes.intuptstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
				<cfthread action="join" name="#updt#" />
				<!--- Get signed URLS for the thumbnail --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.thepdfimagename#" awsbucket="#arguments.thestruct.awsbucket#">
				<!--- Update DB  --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET 
				cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
			<!--- Get signed URLS for the file --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfile.folder_id#/doc/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Update DB  --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#files
			SET 
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
			WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai" AND arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- Upload file --->
			<cfset var upd = Createuuid("")>
			<cfthread name="#upd#" action="run" intupstruct="#arguments.thestruct#">
				<cfinvoke component="akamai" method="Upload">
					<cfinvokeargument name="theasset" value="#attributes.intupstruct.qryfile.path#">
					<cfinvokeargument name="thetype" value="#attributes.intupstruct.akadoc#">
					<cfinvokeargument name="theurl" value="#attributes.intupstruct.akaurl#">
					<cfinvokeargument name="thefilename" value="#attributes.intupstruct.qryfile.filename#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="#upd#" />
		</cfif>
		<!--- Update DB to make asset available --->
		<cfif !application.razuna.rfs>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#files
			SET is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
			WHERE file_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
	</cfif>
	<!--- Log --->
	<cfinvoke component="extQueryCaching" method="log_assets">
		<cfinvokeargument name="theuserid" value="#session.theuserid#">
		<cfinvokeargument name="logaction" value="Add">
		<cfinvokeargument name="logdesc" value="Added: #arguments.thestruct.qryfile.filename#">
		<cfinvokeargument name="logfiletype" value="doc">
		<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
		<cfinvokeargument name="folderid" value="#arguments.thestruct.qryfile.folder_id#">
	</cfinvoke>
	<!--- RFS --->
	<cfif application.razuna.rfs>
		<cfset arguments.thestruct.assettype = "doc">	
		<cfinvoke component="rfs" method="notify" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- The return --->
	<cfreturn arguments.thestruct.newid />
</cffunction>

<!--- PROCESS A IMAGE-FILE ----------------------------------------------------------------------->
<cffunction name="processImgFile" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Set default values --->
	<cfparam name="arguments.thestruct.img_thumb"        default="">
	<cfparam name="arguments.thestruct.img_comp"         default="">
	<cfparam name="arguments.thestruct.img_comp_uw"      default="">
	<cfparam name="arguments.thestruct.groupnumber"      default="">
	<cfparam name="arguments.thestruct.publisher"        default="">
	<cfparam name="arguments.thestruct.img_thumb_width"  default="">
	<cfparam name="arguments.thestruct.img_thumb_heigth" default="">
	<cfparam name="arguments.thestruct.img_comp_width"   default="">
	<cfparam name="arguments.thestruct.img_comp_heigth"  default="">
	<cfparam name="arguments.thestruct.dsn"  			 default="#application.razuna.datasource#">
	<cfparam name="arguments.thestruct.hostid"  		 default="#session.hostid#">
	<cfparam name="arguments.thestruct.theuserid"  		 default="#session.theuserid#">
	<cfparam name="arguments.thestruct.storage"  		 default="#application.razuna.storage#">
	<cfparam name="arguments.thestruct.database"  		 default="#application.razuna.thedatabase#">
	<cfparam name="arguments.thestruct.hostdbprefix"  	 default="#session.hostdbprefix#">
	<!--- If we are a new version --->
	<cfif arguments.thestruct.qryfile.file_id NEQ 0>
		<!--- RAZ-2907 Call the component for Bulk upload versions --->
		<cfif structKeyExists(arguments.thestruct,'extjs') AND arguments.thestruct.extjs EQ "T">
			<!--- Call versions component to do the old versions thingy --->
			<cfinvoke component="versions" method="upload_old_versions" thestruct="#arguments.thestruct#">
		<cfelse>	
		<!--- Call versions component to do the versions thingy --->
		<cfinvoke component="versions" method="create" thestruct="#arguments.thestruct#">
		</cfif>
		<!--- Set the newid --->
		<cfset arguments.thestruct.newid = 1>
	<!--- For normal adding --->
	<cfelse>
		<cfset arguments.thestruct.newid = arguments.thestruct.qryfile.tempid>
		<!--- Call the import/imagemagick method --->
		<!--- <cfinvoke method="importimages" thestruct="#arguments.thestruct#"> --->
		<cfinvoke method="importimagesthread" thestruct="#arguments.thestruct#" />
		<!--- <cfthread name="importimagesthread#arguments.thestruct.newid#" action="run" intstruct="#arguments.thestruct#" priority="high">
			<cfinvoke method="importimagesthread" thestruct="#attributes.intstruct#" />
		</cfthread> --->
		<!--- If above return x we failed for the image --->
		<cfif arguments.thestruct.newid EQ 0>
			<!--- RAZ-2810 Customise email message --->
			<cfset transvalues = arraynew()>
			<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
			<cfinvoke component="defaults" method="trans" transid="image_not_added_subject" values="#transvalues#" returnvariable="image_not_added_sub" />
			<cfinvoke component="defaults" method="trans" transid="image_not_added_message" values="#transvalues#" returnvariable="image_not_added_msg" />
			<cfinvoke component="email" method="send_email" subject="#image_not_added_sub#" themessage="#image_not_added_msg#">	
			<!--- Log --->
			<cfset log_assets(theuserid=session.theuserid,logaction='Error',logdesc='Error: #arguments.thestruct.qryfile.filename# not recognized as image!',logfiletype='img')>
		<cfelse>
			<!--- Add remaining data to the image table --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images
			SET
			img_online = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
			img_owner = <cfqueryparam value="#arguments.thestruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
			img_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			img_create_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			img_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			img_custom_id = <cfqueryparam value="#arguments.thestruct.qryfile.filenamenoext#" cfsqltype="cf_sql_varchar">,
			img_in_progress = <cfqueryparam value="T" cfsqltype="cf_sql_varchar">,
			img_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			thumb_extension = <cfqueryparam value="#arguments.thestruct.qrysettings.set2_img_format#" cfsqltype="cf_sql_varchar">,
			<cfif !structKeyExists(arguments.thestruct,'upcRenditionNum') OR (structKeyExists(arguments.thestruct,'upcRenditionNum') AND (arguments.thestruct.upcRenditionNum NEQ 1 OR arguments.thestruct.fn_ischar))>
			link_path_url = <cfqueryparam value="#arguments.thestruct.qryfile.path#" cfsqltype="cf_sql_varchar">,
			</cfif>
			link_kind = <cfqueryparam value="#arguments.thestruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">,
			path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">
			<cfif !structKeyExists(arguments.thestruct,'upcRenditionNum')>
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				,
				img_filename_org = <cfqueryparam value="#arguments.thestruct.lanorgname#" cfsqltype="cf_sql_varchar">
			<cfelse>
				,
				img_filename_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif structkeyexists(arguments.thestruct.qryfile,"groupid") AND arguments.thestruct.qryfile.groupid NEQ "">
				,
				img_group = <cfqueryparam value="#arguments.thestruct.qryfile.groupid#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			</cfif>
			<!--- For cloud --->
			<cfif application.razuna.storage NEQ "local" AND arguments.thestruct.qryfile.link_kind EQ "">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Put below in thread --->
			<cfthread action="run" intstruct="#arguments.thestruct#">
				<!--- Get sharing option for folder so it can be applied to the asset --->
				<cfquery datasource="#application.razuna.datasource#" name="get_dl_params">
					SELECT share_dl_thumb, share_dl_org 
					FROM #session.hostdbprefix#folders 
					WHERE folder_id = <cfqueryparam value="#attributes.intstruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<!--- Check the UPC rendition upload --->
				<cfif structKeyExists(attributes.intstruct,'upcRenditionNum') AND (attributes.intstruct.upcRenditionNum NEQ 1 OR attributes.intstruct.fn_ischar)>
					 <!--- Add to shared options --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#share_options
					(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
					VALUES(
					<cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#attributes.intstruct.hostid#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#attributes.intstruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
					<cfif structKeyExists(attributes.intstruct,'qryGroupDetails') AND attributes.intstruct.qryGroupDetails.recordcount NEQ 0 >
						<cfqueryparam value="#attributes.intstruct.qryGroupDetails.id#" cfsqltype="cf_sql_varchar">,
					<cfelse>
						<cfqueryparam value="" null="true" cfsqltype="cf_sql_varchar">,
					</cfif>	
					<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				<cfelse>
				<!--- Add to shared options --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#share_options
				(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
				VALUES(
				<cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#attributes.intstruct.hostid#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#attributes.intstruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="thumb" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#iif(get_dl_params.share_dl_thumb eq 't',1,0)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#share_options
				(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
				VALUES(
				<cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#attributes.intstruct.hostid#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#attributes.intstruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="org" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#iif(get_dl_params.share_dl_org eq 't',1,0)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
				</cfif>
				<!--- If there are metadata fields then add them here --->
				<cfif structKeyExists(attributes.intstruct,'metadata') AND attributes.intstruct.metadata EQ 1>
					<!--- Check if API is called the old way --->
					<cfif structkeyexists(attributes.intstruct,"sessiontoken")>
						<cfinvoke component="global.api.asset" method="setmetadata">
							<cfinvokeargument name="sessiontoken" value="#attributes.intstruct.sessiontoken#">
							<cfinvokeargument name="assetid" value="#attributes.intstruct.newid#">
							<cfinvokeargument name="assettype" value="img">
							<cfinvokeargument name="assetmetadata" value="#attributes.intstruct.assetmetadata#">
						</cfinvoke>
					<cfelse>
						<!--- API2 --->
						<cfinvoke component="global.api2.asset" method="setmetadata">
							<cfinvokeargument name="api_key" value="#attributes.intstruct.api_key#">
							<cfinvokeargument name="assetid" value="#attributes.intstruct.newid#">
							<cfinvokeargument name="assettype" value="img">
							<cfinvokeargument name="assetmetadata" value="#attributes.intstruct.assetmetadata#">
						</cfinvoke>
						<!--- Add custom fields --->
						<cfinvoke component="global.api2.customfield" method="setfieldvalue">
							<cfinvokeargument name="api_key" value="#attributes.intstruct.api_key#">
							<cfinvokeargument name="assetid" value="#attributes.intstruct.newid#">
							<cfinvokeargument name="field_values" value="#attributes.intstruct.assetmetadatacf#">
						</cfinvoke>
					</cfif>
				</cfif>
				<!--- Log --->
				<cfinvoke component="extQueryCaching" method="log_assets">
					<cfinvokeargument name="theuserid" value="#attributes.intstruct.theuserid#">
					<cfinvokeargument name="logaction" value="Add">
					<cfinvokeargument name="logdesc" value="Added: #attributes.intstruct.qryfile.filename#">
					<cfinvokeargument name="logfiletype" value="img">
					<cfinvokeargument name="assetid" value="#attributes.intstruct.newid#">
					<cfinvokeargument name="folderid" value="#attributes.intstruct.qryfile.folder_id#">
				</cfinvoke>
			</cfthread>
			<!--- RFS --->
			<cfif application.razuna.rfs>
				<cfset arguments.thestruct.assettype = "img">
				<cfinvoke component="rfs" method="notify" thestruct="#arguments.thestruct#" />
			</cfif>
			<!--- Flush Cache --->
			<cfset resetcachetoken("images")>
			<cfset resetcachetoken("folders")>
			<cfset resetcachetoken("search")> 
			<cfset variables.cachetoken = resetcachetoken("general")>
		</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.newid />
</cffunction>

<!--- IMPORTIMAGES in a thread ---->
<cffunction name="importimages" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- <cfinvoke method="importimagesthread" thestruct="#arguments.thestruct#" /> --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="importimagesthread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- IMPORT INTO DB AND IMAGEMAGICK STUFF (called from the various image uploads components) ---->
<cffunction name="importimagesthread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- init function internal vars --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset var isAnimGIF = 0>
	<cfset var thesourcefile = "">
	<cfset var theimconverttarget = "">
	<cfset var theimconvertcompingtarget = "">
	<cfset var theplaceholderpic = arguments.thestruct.rootpath & "global/host/dam/images/placeholders/nopic.jpg">
	<cfset var theDBurl = "">
	<cfset var iLoop = "">
	<cfset var thenewnr = 0>
	<cfparam name="arguments.thestruct.img_meta" default="" />
	<cfset arguments.thestruct.dsn = application.razuna.datasource>
	<cfset arguments.thestruct.database = application.razuna.thedatabase>
	<cfset arguments.thestruct.hostid = session.hostid>
	<cfset arguments.thestruct.gettemp = GetTempDirectory()>
	<!--- At times the orignal filename is stored in a different var so check for it and put it in proper var --->
	<cfif isdefined("arguments.thestruct.thefilenameoriginal") AND NOT isdefined("arguments.thestruct.theoriginalfilename")>
		<cfset arguments.thestruct.theoriginalfilename = arguments.thestruct.thefilenameoriginal>
	</cfif>
	<cfif not isdefined("arguments.thestruct.theoriginalfilename") AND isdefined('arguments.thestruct.lanorgname')>
		<cfset arguments.thestruct.theoriginalfilename = arguments.thestruct.lanorgname>
	</cfif>
	<!--- Check the asset upload based on the UPC  --->
	<cfinvoke method="assetuploadupc" returnvariable="arguments.thestruct.upc_name" >
		<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
		<cfinvokeargument name="assetfrom" value="img">
	</cfinvoke>
	<cfif structKeyExists(arguments.thestruct,'upc_name') AND arguments.thestruct.upc_name NEQ ''>
		<cfset arguments.thestruct.image_name = arguments.thestruct.upc_name >
	</cfif>
	<!--- Random ID for script --->
	<cfset var imguuid = arguments.thestruct.newid>
	<!--- When we add a URL image we don't need to do the below --->
	<cfif arguments.thestruct.qryfile.link_kind NEQ "url">
		<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images
			SET
			<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
				img_filename = <cfqueryparam value="#arguments.thestruct.image_name#" cfsqltype="cf_sql_varchar">
			<cfelse>
				img_filename = <cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
		<!--- Grab stuff for exiftool and getting raw metadata from image --->
		<cfif arguments.thestruct.isWindows>
			<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
			<!--- Set scripts --->
			<cfset arguments.thestruct.thesh = "#arguments.thestruct.gettemp#/#imguuid#.bat">
		<cfelse>
			<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
			<!--- Set scripts --->
			<cfset arguments.thestruct.thesh = "#arguments.thestruct.gettemp#/#imguuid#.sh">
		</cfif>
		<!--- If linked asset then set source and filename different --->
		<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
			<cfif arguments.thestruct.isWindows>
				<cfset arguments.thestruct.thesource = """#arguments.thestruct.qryfile.path#""">
			<cfelse>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.qryfile.path," ","\ ","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"&","\&","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"'","\'","all")>
			</cfif>
			<!--- Create var with temp directory --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
			<!--- Create temp folder --->
			<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			<cfset arguments.thestruct.thesourceraw = arguments.thestruct.qryfile.path>
		<!--- If coming from a import path --->
		<cfelseif arguments.thestruct.importpath NEQ "">
			<!--- Double quote path so that exiftool will escape any special characters in folder names --->
			<cfset arguments.thestruct.thesource = """#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#""">
			<!--- Create var with temp directory --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
			<!--- Create temp folder --->
			<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			<cfset arguments.thestruct.thesourceraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
		<!--- For uploaded files or for scheduled tasks --->
		<cfelse>
			<cfif arguments.thestruct.isWindows>
				<cfset arguments.thestruct.thesource = """#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#""">
			<cfelse>
				<cfset arguments.thestruct.thesource = replacenocase("#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#"," ","\ ","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"&","\&","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"'","\'","all")>
			</cfif>
			<!--- Create var with temp directory --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.qryfile.path#">
			<cfset arguments.thestruct.thesourceraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
		</cfif>
		<!--- GET RAW METADATA --->
		<!--- <cfthread action="run" intstruct="#arguments.thestruct#" priority="low"> --->

			<!--- Write Script --->
			<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777" charset="utf-8">
			<!--- Execute Script --->
			<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="img_meta" />
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
			<!--- DB update --->

			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET
				<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
					img_filename_org = <cfqueryparam value="#arguments.thestruct.image_name#.#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
					<cfif structKeyExists(arguments.thestruct,'qryGroupDetails') AND arguments.thestruct.qryGroupDetails.recordcount NEQ 0 >
						img_group =  <cfqueryparam value="#arguments.thestruct.qryGroupDetails.id#" cfsqltype="cf_sql_varchar">,
					</cfif>
					<cfif arguments.thestruct.upcRenditionNum NEQ 1 OR arguments.thestruct.fn_ischar>
						img_custom_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">
					<cfelse>
						img_meta = <cfqueryparam value="#img_meta#" cfsqltype="cf_sql_varchar">,
						img_upc_number =  <cfqueryparam value="#arguments.thestruct.dl_query.upc_number#" cfsqltype="cf_sql_varchar"> 
					</cfif>
				<cfelse>
					img_filename_org = <cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">,
					img_meta = <cfqueryparam value="#img_meta#" cfsqltype="cf_sql_varchar">
				</cfif>
				WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">
				</cfquery>
			<!--- Try writing without metadata --->
			<cfcatch>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET
				<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
					img_filename_org = <cfqueryparam value="#arguments.thestruct.image_name#.#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
					<cfif structKeyExists(arguments.thestruct,'qryGroupDetails') AND arguments.thestruct.qryGroupDetails.recordcount NEQ 0 >
						img_group =  <cfqueryparam value="#arguments.thestruct.qryGroupDetails.id#" cfsqltype="cf_sql_varchar">,
					</cfif>
					<cfif arguments.thestruct.upcRenditionNum NEQ 1 OR arguments.thestruct.fn_ischar>
						img_custom_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">
					<cfelse>
						img_upc_number =  <cfqueryparam value="#arguments.thestruct.dl_query.upc_number#" cfsqltype="cf_sql_varchar"> 
					</cfif>
				<cfelse>
					img_filename_org = <cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
				</cfif>
				WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">
				</cfquery>
			</cfcatch>
			</cftry>
		<!--- </cfthread> --->
		<!--- Check if image is an animated GIF. Remove double quotes from path if present --->
		<cfset var isAnimGIF = isAnimatedGIF("#replace(arguments.thestruct.thesource,'"','','ALL')#", arguments.thestruct.thetools.imagemagick)>

		<!--- animated GIFs can only be converted to GIF --->
		<cfif isAnimGIF>
			<cfset QuerySetCell(arguments.thestruct.qrysettings, "set2_img_format", "gif", 1)>
		</cfif>
		<cfif !structKeyExists(arguments.thestruct,'qrysettings')>
			<!--- Query to get the settings --->
			<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
			SELECT set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, set2_img_comp_width,
			set2_img_comp_heigth, set2_vid_preview_author, set2_vid_preview_copyright, set2_path_to_assets, set2_colorspace_rgb
			FROM #session.hostdbprefix#settings_2
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- <cfset resizeImagett = createuuid()> --->
		<cfset arguments.thestruct.theplaceholderpic = theplaceholderpic>
		<cfset arguments.thestruct.width = arguments.thestruct.qrysettings.set2_img_thumb_width>
		<cfset arguments.thestruct.height = arguments.thestruct.qrysettings.set2_img_thumb_heigth>
		<cfset arguments.thestruct.destination = "#arguments.thestruct.thetempdirectory#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#">
		<cfif arguments.thestruct.isWindows>
			<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
			<cfset arguments.thestruct.destination = """#arguments.thestruct.destination#""">
		<cfelse>
			<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
			<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination," ","\ ","all")>
			<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination,"&","\&","all")>
			<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination,"'","\'","all")>
		</cfif>
		<!--- Parse keywords and description from XMP --->
		<cfinvoke component="xmp" method="xmpwritekeydesc" thestruct="#arguments.thestruct#" />
		<!--- Put Xmp custom metadata into custom fields --->
		<cfinvoke component="xmp" method="xmpToCustomFields" thestruct="#arguments.thestruct#" />
		<!--- Parse the Metadata from the image --->
		<cfthread name="xmp#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
			<cfinvoke component="xmp" method="xmpparse" thestruct="#attributes.intstruct#" returnvariable="thread.thexmp" />
		</cfthread>
		<!--- Wait for the parsing --->
		<cfthread action="join" name="xmp#arguments.thestruct.newid#" />
		<!--- Put the thread result into general struct --->
		<cfset arguments.thestruct.thexmp = cfthread["xmp#arguments.thestruct.newid#"].thexmp>
		<!--- resize original to thumb --->
		<cfinvoke method="resizeImage" thestruct="#arguments.thestruct#" />
		<!--- storing assets on file system --->
		<cfset arguments.thestruct.storage = application.razuna.storage>
		<!--- Write the Keywords and Description to the DB (if we are JPG we parse XMP and add them together) --->
		<cftry>
			<!--- Set Variable --->
			<cfset arguments.thestruct.assetpath = arguments.thestruct.qrysettings.set2_path_to_assets>
			<!--- Store XMP values in DB --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			UPDATE #session.hostdbprefix#xmp
			SET 
			asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="img">, 
			subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsubjectcode#">, 
			creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.creator#">, 
			title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.title#">, 
			authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.authorstitle#">, 
			captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.descwriter#">, 
			ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcaddress#">, 
			category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.category#">, 
			supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.categorysub#">, 
			urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.urgency#">,
			description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.description#">, 
			ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccity#">, 
			ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccountry#">, 
			location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptclocation#">, 
			ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptczip#">, 
			ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcemail#">, 
			ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcwebsite#">, 
			citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcphone#">, 
			intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcintelgenre#">, 
			instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcinstructions#">, 
			source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsource#">, 
			usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcusageterms#">, 
			copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copystatus#">, 
			transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcjobidentifier#">, 
			webstatement  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copyurl#">, 
			headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcheadline#">, 
			datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcdatecreated#">, 
			city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecity#">, 
			ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagestate#">, 
			country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountry#">, 
			countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountrycode#">, 
			scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcscene#">, 
			state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcstate#">, 
			credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccredit#">, 
			rights = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copynotice#">, 
			colorspace = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.colorspace#">, 
			xres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.xres#">, 
			yres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.yres#">, 
			resunit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.resunit#">, 
			host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			WHERE id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">
			</cfquery>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in images text table for jpg in function assets.importimagesthread"/>
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
		<!--- Move or upload to the right places --->
		<!--- If we are local --->
		<cfif arguments.thestruct.storage EQ "local">
			<!--- Create folder with the asset id --->
			<cfif NOT directoryexists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#" mode="775">
			</cfif>
			<!--- Move original image --->
			<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
				<cfif application.razuna.rfs OR arguments.thestruct.importpath NEQ "">
					<cfset arguments.thestruct.fileaction = "copy">
				<cfelse>
					<cfset arguments.thestruct.fileaction = "move">
				</cfif>
				<!--- <cffile action="#arguments.thestruct.fileaction#" source="#arguments.thestruct.thesourceraw#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" mode="775"> --->
				<cfthread name="upload#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
					<cffile action="#attributes.intstruct.fileaction#" source="#attributes.intstruct.thesourceraw#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#attributes.intstruct.hostid#/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#" mode="775">
				</cfthread>
				<!--- Wait for thread to finish --->
				<cfthread action="join" name="upload#arguments.thestruct.newid#" />
				<!--- Rename the UPC addtional rendition image --->
				<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
					<cfthread name="rename#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
						<cffile action="rename" source="#attributes.intstruct.qrysettings.set2_path_to_assets#/#attributes.intstruct.hostid#/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#attributes.intstruct.hostid#/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/#attributes.intstruct.image_name#.#attributes.intstruct.qryfile.extension#">
					</cfthread>
					<!--- Wait for thread to finish --->
					<cfthread action="join" name="rename#arguments.thestruct.newid#" />
				</cfif>
			</cfif>
			<!--- Move thumbnail --->
			<cfthread name="uploadt#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
				<cfif attributes.intstruct.qryfile.link_kind EQ "lan">
					<cffile action="move" source="#attributes.intstruct.destinationraw#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#attributes.intstruct.hostid#/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/thumb_#attributes.intstruct.newid#.#attributes.intstruct.qrysettings.set2_img_format#" mode="775">
				<cfelseif !application.razuna.rfs>
					<cffile action="move" source="#attributes.intstruct.destinationraw#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#attributes.intstruct.hostid#/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/thumb_#attributes.intstruct.newid#.#attributes.intstruct.qrysettings.set2_img_format#" mode="775">
				</cfif>
			</cfthread>
			<!--- Wait for thread to finish --->
			<cfthread action="join" name="uploadt#arguments.thestruct.newid#" />
			<!--- Get size of original and thumnail --->
			<cfset var orgsize = arguments.thestruct.qryfile.thesize>
			<cfif !application.razuna.rfs>
				<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" returnvariable="thumbsize">
			<cfelse>
				<!--- For renderingfarm we just set the thumbsize to 1 so we don't get errors doing inserts --->
				<cfset var thumbsize = 1>
			</cfif>
		<!--- NIRVANIX --->
		<cfelseif arguments.thestruct.storage EQ "nirvanix">
			<cfset var uplt = "u" & Createuuid("")>
			<!--- Upload Original Image --->
			<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
				<cftry>
					<cfinvoke component="nirvanix" method="Upload">
						<cfinvokeargument name="destFolderPath" value="/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#">
						<cfinvokeargument name="uploadfile" value="#arguments.thestruct.thesource#">
						<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
					</cfinvoke>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Error in uploading original image to Nirvanix in function assets.importimagesthread">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
			</cfif>
			<!--- Upload Thumbnail --->
			<cfif !application.razuna.rfs>
				<cftry>
					<cfthread name="upload#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.destination#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for thread to finish --->
					<cfthread action="join" name="upload#arguments.thestruct.newid#" />
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Error in uploading thumbnail image to Nirvanix in function assets.importimagesthread">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
				<!--- Get thumb file size --->
				<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.destination#" returnvariable="thumbsize">
				<!--- Get signed URL --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" nvxsession="#arguments.thestruct.nvxsession#">
			<cfelse>
				<cfset var thumbsize = 1>
				<cfset cloud_url.theurl = "">
			</cfif>
			<!--- Get size of original --->
			<cfset var orgsize = arguments.thestruct.qryfile.thesize>
			<!--- Get signed URLS for original --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" nvxsession="#arguments.thestruct.nvxsession#">
		<!--- AMAZON --->
		<cfelseif arguments.thestruct.storage EQ "amazon">
			<cftry>
				<!--- Upload Original Image --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfset var upt = Createuuid("")>
					<cfthread name="#upt#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thesourceraw#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
						<!--- Rename the UPC addtional rendition image --->
						<cfif structKeyExists(attributes.intstruct,'upcRenditionNum') AND attributes.intstruct.upcRenditionNum NEQ "">
							<cfpause interval="5" />
							<cfinvoke component="s3" method="renameObject">
								<cfinvokeargument name="oldBucketName" value="#attributes.intstruct.awsbucket#">
								<cfinvokeargument name="newBucketName" value="#attributes.intstruct.awsbucket#">
								<cfinvokeargument name="oldFileKey" value="#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#">
								<cfinvokeargument name="newFileKey" value="#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/#attributes.intstruct.image_name#.#attributes.intstruct.qryfile.extension#">
							</cfinvoke>
						</cfif>
					</cfthread>
					<cfthread action="join" name="#upt#" />
				</cfif>
				<!--- Upload Thumbnail --->
				<cfif !application.razuna.rfs>
					<cfset var uptn = Createuuid("")>
					<cfthread name="#uptn#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/thumb_#attributes.intstruct.newid#.#attributes.intstruct.qrysettings.set2_img_format#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.destinationraw#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#uptn#" />
					<!--- Get size thumnail --->
					<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.destination#" returnvariable="thumbsize">
					<!--- Get signed URLS for thumb --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" awsbucket="#arguments.thestruct.awsbucket#">
				<cfelse>
					<cfset var thumbsize = 1>
					<cfset cloud_url.theurl = "">
				</cfif>
				<!--- Get size of original --->
				<cfset var orgsize = arguments.thestruct.qryfile.thesize>
				<!--- Get signed URLS original --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#">
				<cfcatch type="any">
					<cfset cfcatch.custom_message = "Error in image upload to amazon in function assets.importimagesthread">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				</cfcatch>
			</cftry>
		<!--- AKAMAI --->
		<cfelseif arguments.thestruct.storage EQ "akamai">
			<!--- Create folder with the asset id --->
			<cfif NOT directoryexists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#" mode="775">
			</cfif>
			<cftry>
				<!--- Upload Original Image --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfset var upt = Createuuid("")>
					<cfthread name="#upt#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="akamai" method="Upload">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thesourceraw#">
							<cfinvokeargument name="thetype" value="#attributes.intstruct.akaimg#">
							<cfinvokeargument name="theurl" value="#attributes.intstruct.akaurl#">
							<cfinvokeargument name="thefilename" value="#attributes.intstruct.qryfile.filename#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upt#" />
				</cfif>
				<!--- Move thumbnail --->
				<cfthread name="uploadt#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
					<cfif attributes.intstruct.qryfile.link_kind EQ "lan">
						<cffile action="move" source="#attributes.intstruct.destinationraw#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#attributes.intstruct.hostid#/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/thumb_#attributes.intstruct.newid#.#attributes.intstruct.qrysettings.set2_img_format#" mode="775">
					<cfelseif !application.razuna.rfs>
						<cffile action="move" source="#attributes.intstruct.destinationraw#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#attributes.intstruct.hostid#/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/thumb_#attributes.intstruct.newid#.#attributes.intstruct.qrysettings.set2_img_format#" mode="775">
					</cfif>
				</cfthread>
				<!--- Wait for thread to finish --->
				<cfthread action="join" name="uploadt#arguments.thestruct.newid#" />
				<!--- Get size thumnail --->
				<cfif !application.razuna.rfs>
					<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" returnvariable="thumbsize">
				<cfelse>
					<!--- For renderingfarm we just set the thumbsize to 1 so we don't get errors doing inserts --->
					<cfset var thumbsize = 1>
				</cfif>
				<!--- Get size of original --->
				<cfset var orgsize = arguments.thestruct.qryfile.thesize>
				<cfcatch type="any">
					<cfset cfcatch.custom_message = "Error in image upload to akamai in function assets.importimagesthread">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Orgsize and thumbsize variables are not here --->
		<cfif NOT isdefined(orgsize)>
			<cfset var orgsize = arguments.thestruct.qryfile.thesize>
		</cfif>
		<cfif NOT isdefined(thumbsize)>
			<cfset var thumbsize = 0>
		</cfif>
		<!--- Update DB with the sizes from above --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		UPDATE #session.hostdbprefix#images
		SET 
		img_size = <cfqueryparam value="#orgsize#" cfsqltype="cf_sql_varchar">, 
		thumb_size = <cfqueryparam value="#thumbsize#" cfsqltype="cf_sql_varchar">,
		hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.md5hash#">
		<cfif !application.razuna.rfs>
			,
			is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
		</cfif>
		<!--- AMAZON --->
		<cfif arguments.thestruct.storage EQ "amazon" OR arguments.thestruct.storage EQ "nirvanix">
			,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">				
		</cfif>
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
		</cfquery>
	</cfif>
	<!--- Update is_available flag for URL asset --->
	<cfif !application.razuna.rfs AND arguments.thestruct.qryfile.link_kind EQ "url">
		<!--- Update DB with the sizes from above --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		UPDATE #session.hostdbprefix#images
		SET 
		is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
		</cfquery>
	</cfif>
	<!--- return --->
	<cfreturn />
</cffunction>

<!--- CHECK IF AN IMAGE IS AN ANIMATED GIF --->
<cffunction hint="CHECK IF AN IMAGE IS AN ANIMATED GIF" name="isAnimatedGIF" returntype="boolean">
<cfargument name="imagepath" required="yes" type="string" hint="Full path to the image-file, including filename and -ending">
<cfargument name="thepathim" required="yes" type="string" hint="Path to ImageMagick-folder">
<!--- declare function-internal variables --->
<cfset var theidentifyresult = "">
<cfset var thescript = createuuid()>
<!--- Go grab the platform --->
<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
<!--- check if file ends with ".gif" --->
<cfif Right(arguments.imagepath, 4) eq ".gif">
	<!--- Check the platform and then decide on the ImageMagick tag --->
	<cfif arguments.thestruct.isWindows>
		<cfset var theidentify = """#Arguments.thepathim#/identify.exe""">
		<cfset var thearguments = """#arguments.imagepath#""">
	<cfelse>
		<cfset var theidentify = "#Arguments.thepathim#/identify">
		<!--- Check to make sure paths are not already escaped --->
		<cfif findnocase('\ ', arguments.imagepath) EQ 0>
			<cfset var thearguments = replace(arguments.imagepath," ","\ ","all")>
		<cfelse>
			<cfset var thearguments =arguments.imagepath>
		</cfif>
		
		<cfif findnocase('\&', arguments.imagepath) EQ 0>
			<cfset var thearguments = replace(thearguments,"&","\&","all")>
		</cfif>

		<cfif findnocase("\'", arguments.imagepath) EQ 0>
			<cfset var thearguments = replace(thearguments,"'","\'","all")>
		</cfif>
	</cfif>
	<!--- get image information as string using identify (ImageMagick)
	<cfexecute name="#theidentify#" arguments="#arguments.imagepath#" timeout="5" variable="theidentifyresult" /> --->
	<cfset var thesh = gettempdirectory() & "/#thescript#.sh">
	<!--- On Windows a bat --->
	<cfif arguments.thestruct.isWindows>
		<cfset var thesh = gettempdirectory() & "/#thescript#.bat">
	</cfif>
	<!--- Write files --->
	<cffile action="write" file="#thesh#" output="#theidentify# #thearguments#" mode="777">
	<!--- Execute --->
	<cfexecute name="#thesh#" timeout="60" variable="theidentifyresult" />
	<!--- Delete scripts --->
	<cffile action="delete" file="#thesh#">
	<!--- Check if result from imagemagick contains [0]. For animated gifs output for all individual images that compromise the gif is returned as test.gif[0], test.gif[1] etc. So checking for existing of [0] means gif is animated --->
	<cfif theidentifyresult contains "[0]">
		<cfreturn 1>
	</cfif>
</cfif>
<cfreturn 0>
</cffunction>

<!--- RESIZE IMAGE ------------------------------------------------------------------------------->
<cffunction name="resizeImage" returntype="void" access="public" output="false">
	<cfargument name="thestruct" type="struct" required="true">
	<!--- RFS --->
	<cfif !application.razuna.rfs>
		<!--- ID for thread --->
		<cfset var tri = createuuid("")>
		<cfthread name="#tri#" intstruct="#arguments.thestruct#" action="run">
			<cfinvoke method="resizeImagethread" thestruct="#attributes.intstruct#" />
		</cfthread>
		<cfthread action="join" name="#tri#" timeout="240000" />
	</cfif>
</cffunction>

<!--- RESIZE IMAGE ------------------------------------------------------------------------------->
<cffunction name="resizeImagethread" returntype="void" access="public" output="false">
	<cfargument name="thestruct" type="struct" required="true">
	<cftry>
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
		<cfset var thecolorspace = "">
		<!--- Check the colorspace --->
		<cfif arguments.thestruct.qrysettings.set2_colorspace_rgb>
			<cfset var thecolorspace = "-colorspace sRGB">
		</cfif>
		<!--- RAZ-2877 : Set File name --->
		<cfif !structKeyExists(arguments.thestruct,'thefilename')>
			<cfset arguments.thestruct.thefilename = #arguments.thestruct.qryfile.filename#>
		</cfif>
		<!--- Get file extension --->
		<cfset var ext = right(arguments.thestruct.thefilename,3)>
		<!--- If extension is TGA then turn off alpha --->
		<cfif ext eq 'tga'>
			<cfset alpha = '-alpha off'>
		<cfelse>
			<cfset alpha = ''>
		</cfif>
		<!--- function internal variables --->
		<cfset var isAnimGIF = isAnimatedGIF(arguments.thestruct.thesource, arguments.thestruct.thetools.imagemagick)>
		<cfset var theimconvert = "">
		<cfset var theImgConvertParams = "#alpha# -resize #arguments.thestruct.width#x #thecolorspace#">
		<!--- validate input --->
		<cfif FileExists(arguments.thestruct.destination)>
			<!--- <cfthrow message="Destination-file already exists!"> --->
			<cffile action="delete" file="#arguments.thestruct.destination#" />
		</cfif>
		<!--- Check the platform and then decide on the ImageMagick/DCRaw tag --->
		<cfif arguments.thestruct.isWindows>
			<cfset arguments.thestruct.theimconvert = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
			<cfset arguments.thestruct.themogrify = """#arguments.thestruct.thetools.imagemagick#/mogrify.exe""">
			<cfset arguments.thestruct.thedcraw = """#arguments.thestruct.thetools.dcraw#/dcraw.exe""">
			<cfset arguments.thestruct.thexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfelse>
			<cfset arguments.thestruct.theimconvert = "#arguments.thestruct.thetools.imagemagick#/convert">
			<cfset arguments.thestruct.themogrify = "#arguments.thestruct.thetools.imagemagick#/mogrify">
			<cfset arguments.thestruct.thedcraw = "#arguments.thestruct.thetools.dcraw#/dcraw">
			<cfset arguments.thestruct.thexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		</cfif>
		<!--- ImageMagick: Create Thumbnail.
		Some images can not be converted thus we just copy the original so we have a thumbnail --->
		<cfset var reimtt = Createuuid("")>
		<!--- Write the sh script files --->
		<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#reimtt#.sh">
		<cfset arguments.thestruct.theshm = GetTempDirectory() & "/#reimtt#m.sh">
		<cfset arguments.thestruct.theshht = GetTempDirectory() & "/#reimtt#ht.sh">
		<cfset arguments.thestruct.theshwt = GetTempDirectory() & "/#reimtt#wt.sh">
		<!--- On Windows a .bat --->
		<cfif arguments.thestruct.iswindows>
			<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#reimtt#.bat">
			<cfset arguments.thestruct.theshm = GetTempDirectory() & "/#reimtt#m.bat">
			<cfset arguments.thestruct.theshht = GetTempDirectory() & "/#reimtt#ht.bat">
			<cfset arguments.thestruct.theshwt = GetTempDirectory() & "/#reimtt#wt.bat">
		</cfif>
		
		<!--- Set correct width and height parameters --->
		<!--- If both height and width are set then resize to exact height and width set. Aspect ratio ignored --->
		<cfif isnumeric(arguments.thestruct.width) AND isnumeric(arguments.thestruct.height)>
			<cfset theImgConvertParams = "#alpha# -resize #arguments.thestruct.width#x#arguments.thestruct.height# #thecolorspace#">
		<!--- If only height set then resize to given height preserving aspect ratio --->
		<cfelseif isnumeric(arguments.thestruct.height)>
			<cfset theImgConvertParams = "#alpha# -resize x#arguments.thestruct.height# #thecolorspace#">
		<!--- If only width set then resize to given width preserving aspect ratio  --->
		<cfelseif isnumeric(arguments.thestruct.width) >
			<cfset theImgConvertParams = "#alpha# -resize #arguments.thestruct.width#x #thecolorspace#">
		<!--- Default case shrink image to width of 400 preserving aspect ratio  --->
		<cfelse>
			<cfset theImgConvertParams = "#alpha# -resize 400x #thecolorspace#">
		</cfif>
		<!--- correct ImageMagick-convert params for animated GIFs --->
		<cfif isAnimGIF>
			<cfset var theImgConvertParams = "-coalesce " & theImgConvertParams>
		</cfif>
		<cfset arguments.thestruct.theimargumentsmog = "">
		<!--- Switch to create correct arguments to pass for executables --->
		<cfswitch expression="#arguments.thestruct.qryfile.extension#">
			<!--- If the file is a PSD, AI or EPS we have to layer it to zero --->
			<cfcase value="psd,eps,ai,png,tif,tiff">
				<cfset arguments.thestruct.theimarguments = "#arguments.thestruct.theimconvert# -density 300 #arguments.thestruct.thesource#[0] #theImgConvertParams# -background white -flatten #Arguments.thestruct.destination#">
			</cfcase>
			<!--- For RAW images we take dcraw --->
			<cfcase value="nef,x3f,arw,mrw,crw,cr2,3fr,ari,srf,sr2,bay,cap,iiq,eip,dcs,dcr,drf,k25,kdc,erf,fff,mef,mos,nrw,ptx,pef,pxn,r3d,raf,raw,rw2,rwl,dng,rwz">
				<cfset arguments.thestruct.theimarguments = "#arguments.thestruct.thedcraw# -c -e #arguments.thestruct.thesource# > #Arguments.thestruct.destination#">
				<cfset arguments.thestruct.theimargumentsmog = "#arguments.thestruct.themogrify# #theImgConvertParams# #Arguments.thestruct.destination#">
			</cfcase>
			<!--- For everything else --->
			<cfdefaultcase>
				<cfset arguments.thestruct.theimarguments = "#arguments.thestruct.theimconvert# #arguments.thestruct.thesource# #theImgConvertParams# #Arguments.thestruct.destination#">
			</cfdefaultcase>
		</cfswitch>
		<!--- Write script file to create thumbnail --->
		<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theimarguments#" mode="777">
		<cffile action="write" file="#arguments.thestruct.theshm#" output="#arguments.thestruct.theimargumentsmog#" mode="777">
		<!--- Convert the original --->
		<cfthread name="c#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
			<cfexecute name="#attributes.intstruct.thesh#" timeout="240000" />
		</cfthread>
		<!--- Wait until Thumbnail is done --->
		<cfthread action="join" name="c#arguments.thestruct.newid#" timeout="240000" />
		<!--- Convert for raw --->
		<cfthread name="m#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
			<cfexecute name="#attributes.intstruct.theshm#" timeout="240000" />
		</cfthread>
		<!--- Wait until Thumbnail is done --->
		<cfthread action="join" name="m#arguments.thestruct.newid#" timeout="240000" />
		<!--- Check if thumbail is here if not copy missing image --->
		<cfif !fileexists(arguments.thestruct.destinationraw)>
			<cffile action="copy" source="#arguments.thestruct.rootpath#global/host/dam/images/icons/image_missing.png" destination="#arguments.thestruct.destinationraw#" mode="775" nameConflict="Skip">
		</cfif>
		<!--- Get thumbnail sizes --->
		<cffile action="write" file="#arguments.thestruct.theshht#" output="#arguments.thestruct.theexif# -fast -fast2 -S -s -ImageHeight #arguments.thestruct.destination#" mode="777" charset="utf-8">
		<cffile action="write" file="#arguments.thestruct.theshwt#" output="#arguments.thestruct.theexif# -fast -fast2 -S -s -ImageWidth #arguments.thestruct.destination#" mode="777" charset="utf-8">
		<!--- Get height and width --->
		<cfexecute name="#arguments.thestruct.theshht#" timeout="60" variable="thumbheight" />
		<cfexecute name="#arguments.thestruct.theshwt#" timeout="60" variable="thumbwidth" />
		<!--- Exiftool on windows return the whole path with the sizes thus trim and get last --->
		<cfset var thumbheight = trim(listlast(thumbheight," "))>
		<cfset var thumbwidth = trim(listlast(thumbwidth," "))>

		<cftry>
		<cfif arguments.thestruct.qryfile.extension EQ "cr2">
			<cfset var orientation = "">
			<!--- Check orientation for CR2 images and rotate it properly if it is not properly rotated for viewing--->
			<cfexecute name="#arguments.thestruct.thexif#" arguments="-Orientation -n #arguments.thestruct.destination#" timeout="120" variable="orientation"/>
			<cfif orientation NEQ "" AND orientation contains "8">
				<cfexecute name="#arguments.thestruct.themogrify#" arguments="-rotate -90 #arguments.thestruct.destination#" timeout="120"/>
			<cfelseif orientation NEQ "" AND orientation contains "6">
				<cfexecute name="#arguments.thestruct.themogrify#" arguments="-rotate 90 #arguments.thestruct.destination#" timeout="120" />
			</cfif>
		</cfif>
		<cfcatch></cfcatch>
		</cftry>
		
		<!--- Remove the temp file sh --->
		<cffile action="delete" file="#arguments.thestruct.thesh#">
		<cffile action="delete" file="#arguments.thestruct.theshm#">
		<cffile action="delete" file="#arguments.thestruct.theshht#">
		<cffile action="delete" file="#arguments.thestruct.theshwt#">
		<!--- Sometimes identify does not get height and width thus we set it here --->
		<cfif arguments.thestruct.thexmp.orgwidth EQ "" OR NOT isnumeric(arguments.thestruct.thexmp.orgwidth)>
			<cfset arguments.thestruct.thexmp.orgwidth = 0>
		</cfif>
		<cfif arguments.thestruct.thexmp.orgheight EQ "" OR NOT isnumeric(arguments.thestruct.thexmp.orgheight)>
			<cfset arguments.thestruct.thexmp.orgheight = 0>
		</cfif>
		<cfif thumbwidth EQ "" OR NOT isnumeric(thumbwidth)>
			<cfset var thumbwidth = 0>
		</cfif>
		<cfif thumbheight EQ "" OR NOT isnumeric(thumbheight)>
			<cfset var thumbheight = 0>
		</cfif>
		<!--- Set original and thumbnail width and height --->
		<cfif (!structKeyExists(arguments.thestruct,'av') OR arguments.thestruct.av NEQ 1) OR (!structKeyExists(arguments.thestruct,'extjs') OR arguments.thestruct.extjs NEQ 'T')>
			<!--- Set original and thumbnail width and height --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#images
		SET
		thumb_width = <cfqueryparam value="#thumbwidth#" cfsqltype="cf_sql_numeric">, 
		thumb_height = <cfqueryparam value="#thumbheight#" cfsqltype="cf_sql_numeric">, 
		img_width = <cfqueryparam value="#arguments.thestruct.thexmp.orgwidth#" cfsqltype="cf_sql_numeric">, 
		img_height = <cfqueryparam value="#arguments.thestruct.thexmp.orgheight#" cfsqltype="cf_sql_numeric">
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		</cfif>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function assets.resizeImage">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Check for plattform --->
<cffunction name="isWindows" returntype="boolean" access="public" output="false">
	<!--- function internal variables --->
	<!--- function body --->
	<cfreturn FindNoCase("Windows", server.os.name)>
</cffunction>

<!--- GET FILE AND EXTENSION ------------------------------------------------------------------------->
<cffunction hint="GET FILE AND EXTENSION" name="getFileExtension" output="true" returntype="struct">
	<cfargument name="thefilename" default="" required="yes" type="string">
	<!--- Get the file extension --->
	<cfset fileNameExt.theExt  = "#lcase(listLast(listRest(arguments.thefilename, '.'), '.'))#">
	<!--- Get the file name --->
	<cfif fileNameExt.theExt NEQ "">
		<cfset var lenFile = #len(arguments.thefilename)# - #len(fileNameExt.theExt)# - 1>
		<cfset fileNameExt.theName = "#left(arguments.thefilename, lenFile)#">
	<cfelse>
		<cfset fileNameExt.theName = "#arguments.thefilename#">
	</cfif>
	<cfreturn fileNameExt>
</cffunction>

<!--- PROCESS A VIDEO-FILE ----------------------------------------------------------------------->
<cffunction name="processVidFile" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cfset arguments.thestruct.thisvid = structnew()>
	<cfparam name="arguments.thestruct.vid_online" default="F">
	<cfset arguments.thestruct.dsn = application.razuna.datasource>
	<cfset arguments.thestruct.database = application.razuna.thedatabase>
	<cfset arguments.thestruct.hostid = session.hostid>
	<cfset arguments.thestruct.theuserid = session.theuserid>
	<cfset arguments.thestruct.storage = application.razuna.storage>
	<cfset arguments.thestruct.theplaceholderpic = arguments.thestruct.rootpath & "global/host/dam/images/placeholders/novideo.png">
	<!--- At times the orignal filename is stored in a different var so check for it and put it in proper var --->
	<cfif isdefined("arguments.thestruct.thefilenameoriginal") AND NOT isdefined("arguments.thestruct.theoriginalfilename")>
		<cfset arguments.thestruct.theoriginalfilename = arguments.thestruct.thefilenameoriginal>
	</cfif>
	<!--- init function internal vars --->
	<cfset var theDBurl = "">
	<cfset var iLoop = "">
	<cfset var vid_meta = "">
	<cfset arguments.thestruct.vid_meta = "">
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- If we are a new version --->
	<cfif arguments.thestruct.qryfile.file_id NEQ 0>
		<!--- RAZ-2907 Call the component for Bulk upload versions --->
		<cfif structKeyExists(arguments.thestruct,'extjs') AND arguments.thestruct.extjs EQ "T">
			<!--- Call versions component to do the old versions thingy --->
			<cfinvoke component="versions" method="upload_old_versions" thestruct="#arguments.thestruct#">
		<cfelse>	
		<!--- Call versions component to do the versions thingy --->
		<cfinvoke component="versions" method="create" thestruct="#arguments.thestruct#">
		</cfif>
		<!--- Set the newid --->
		<cfset arguments.thestruct.thisvid.newid = 1>
		<cfset arguments.thestruct.newid = 1>
	<!--- For normal adding --->
	<cfelse>	
		<!--- Check the asset upload based on the UPC  --->
		<cfinvoke method="assetuploadupc" returnvariable="arguments.thestruct.upc_name" >
			<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
			<cfinvokeargument name="assetfrom" value="vid">
		</cfinvoke>
		<cfif structKeyExists(arguments.thestruct,'upc_name') AND arguments.thestruct.upc_name NEQ ''>
			<cfset arguments.thestruct.vid_name = arguments.thestruct.upc_name >
		</cfif>
		<!--- Create a new ID for the video --->
		<cfset arguments.thestruct.thisvid.newid = arguments.thestruct.qryfile.tempid>
		<cfset arguments.thestruct.newid = arguments.thestruct.qryfile.tempid>
		<!--- Put together the filenames --->
		<cfset arguments.thestruct.thisvid.theorgimage = replacenocase(arguments.thestruct.qryfile.filename,".#arguments.thestruct.qryfile.extension#",".jpg","one")>
		<!--- If filename does not contain an extension e.g. when the user specifies a filename in lieu of the actual filename then append with .jpg so ffmepg does not throw an error while creating thumbs --->
		<cfif arguments.thestruct.thisvid.theorgimage does not contain ".jpg">
			<cfset arguments.thestruct.thisvid.theorgimage = arguments.thestruct.thisvid.theorgimage & ".jpg">
		</cfif>
		<!--- All below only if NOT from a link --->
		<cfif arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- if importpath --->
			<cfif arguments.thestruct.importpath NEQ "">
				<!--- Create var with temp directory --->
				<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
				<!--- Create temp folder --->
				<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			</cfif>
			<!--- For LOCAL storage --->
			<cfif application.razuna.storage EQ "local">
				<!--- The final path of the asset --->
				<cfset arguments.thestruct.thisvid.finalpath = "#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#">
				<cfif arguments.thestruct.importpath NEQ "">
					<cfset arguments.thestruct.thetempdirectory = arguments.thestruct.thisvid.finalpath>
				<cfelse>
					<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.qryfile.path#">
				</cfif>
				<!--- Create the directory --->
				<cfdirectory action="create" directory="#arguments.thestruct.thisvid.finalpath#" mode="775">
				<!--- Move original (used to be in a thread) --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cffile action="copy" source="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" destination="#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#" mode="775">
				</cfif>
				<!--- Rename the UPC based upload audio --->
				<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
					<cffile action="rename" source="#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#" destination="#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.vid_name#.#arguments.thestruct.qryfile.extension#">
				</cfif>
			<!--- NIRVANIX / AMAZON /AKMAI --->
			<cfelseif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "akamai">
				<!--- Just assign the current path to the finalpath --->
				<cfset arguments.thestruct.thisvid.finalpath = "#arguments.thestruct.qryfile.path#">
				<cfif !arguments.thestruct.importpath>
					<cfset arguments.thestruct.thetempdirectory = arguments.thestruct.thisvid.finalpath>
				</cfif>
			</cfif>
			<!--- Create thumbnail --->
			<cfthread name="preview#arguments.thestruct.thisvid.newid#" intstruct="#arguments.thestruct#" action="run">
				<cfinvoke component="videos" method="create_previews" thestruct="#attributes.intstruct#">
			</cfthread>
			<!--- Wait --->
			<cfthread action="join" name="preview#arguments.thestruct.thisvid.newid#" />
			<!--- Check the platform and then decide on the ImageMagick tag --->
			<cfif arguments.thestruct.isWindows>
				<cfset arguments.thestruct.theidentify = """#arguments.thestruct.thetools.imagemagick#/identify.exe""">
				<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
				<cfset arguments.thestruct.theorg = """#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thisvid.theorgimage#""">
				<!--- If local link --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
					<cfset arguments.thestruct.theasset = """#arguments.thestruct.qryfile.path#""">
					<cfset arguments.thestruct.theassetraw = arguments.thestruct.qryfile.path>
				<cfelse>
					<cfset arguments.thestruct.theasset = """#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#""">
					<cfset arguments.thestruct.theassetraw = "#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#">
				</cfif>
			<cfelse>
				<cfset arguments.thestruct.theidentify = "#arguments.thestruct.thetools.imagemagick#/identify">
				<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
				<cfset arguments.thestruct.theorg = "#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thisvid.theorgimage#">
				<!--- If local link --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
					<cfset arguments.thestruct.theasset = "#arguments.thestruct.qryfile.path#">
					<cfset arguments.thestruct.theassetraw = arguments.thestruct.qryfile.path>
				<cfelse>
					<cfset arguments.thestruct.theasset = "#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#">
					<cfset arguments.thestruct.theassetraw = "#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#">
				</cfif>
				<cfset arguments.thestruct.theorg = replace(arguments.thestruct.theorg," ","\ ","all")>
				<cfset arguments.thestruct.theorg = replace(arguments.thestruct.theorg,"&","\&","all")>
				<cfset arguments.thestruct.theorg = replace(arguments.thestruct.theorg,"'","\'","all")>
				<cfset arguments.thestruct.theasset = replace(arguments.thestruct.theasset," ","\ ","all")>
				<cfset arguments.thestruct.theasset = replace(arguments.thestruct.theasset,"&","\&","all")>
				<cfset arguments.thestruct.theasset = replace(arguments.thestruct.theasset,"'","\'","all")>
			</cfif>
			<!--- Get image width --->
			<cfset var thescript = arguments.thestruct.thisvid.newid>
			<cfset arguments.thestruct.thesh = gettempdirectory() & "/#thescript#.sh">
			<cfset arguments.thestruct.thesht = gettempdirectory() & "/#thescript#t.sh">
			<cfset arguments.thestruct.theshex = gettempdirectory() & "/#thescript#ex.sh">
			<!--- On Windows a bat --->
			<cfif arguments.thestruct.isWindows>
				<cfset arguments.thestruct.thesh = gettempdirectory() & "/#thescript#.bat">
				<cfset arguments.thestruct.thesht = gettempdirectory() & "/#thescript#t.bat">
				<cfset arguments.thestruct.theshex = gettempdirectory() & "/#thescript#ex.bat">
			</cfif>
			<!--- Write files --->
			<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -S -s -ImageWidth #arguments.thestruct.theorg#" mode="777">
			<cffile action="write" file="#arguments.thestruct.thesht#" output="#arguments.thestruct.theexif# -fast -fast2 -S -s -ImageHeight #arguments.thestruct.theorg#" mode="777">
			<cffile action="write" file="#arguments.thestruct.theshex#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.theasset#" mode="777" charset="utf-8">
			<!--- Execute --->
			<cfif !application.razuna.rfs>
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="orgwidth" />
				<cfexecute name="#arguments.thestruct.thesht#" timeout="60" variable="orgheight" />
				<!--- Exiftool on windows return the whole path with the sizes thus trim and get last --->
				<cfset var orgwidth = trim(listlast(orgwidth," "))>
				<cfset var orgheight = trim(listlast(orgheight," "))>
				<cfset sleep(2000)>
			</cfif>
			<!--- Put Xmp custom metadata into custom fields --->
			<cfset arguments.thestruct.newid = arguments.thestruct.thisvid.newid>
			<cfset arguments.thestruct.thesource = arguments.thestruct.theasset>
			<cfinvoke component="xmp" method="xmpToCustomFields" thestruct="#arguments.thestruct#" />
			<!--- Get video metadata --->
			<cfexecute name="#arguments.thestruct.theshex#" timeout="60" variable="vid_meta" />
			<cfset arguments.thestruct.vid_meta = vid_meta>
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
			<cffile action="delete" file="#arguments.thestruct.thesht#">
			<cffile action="delete" file="#arguments.thestruct.theshex#">
			<!--- NIRVANIX --->
			<cfif application.razuna.storage EQ "nirvanix">
				<!--- Upload Movie Image --->
				<cfif !application.razuna.rfs>
					<cfset var upmi = Createuuid("")>
					<cfthread name="#upmi#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait --->
					<cfthread action="join" name="#upmi#" />
					<!--- Get signed URL --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.thisvid.theorgimage#" nvxsession="#arguments.thestruct.nvxsession#">
				</cfif>
				<!--- Upload Movie --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfset var upmt = Createuuid("")>
					<cfthread name="#upmt#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait --->
					<cfthread action="join" name="#upmt#" />
				</cfif>
				<!--- Get signed URLS for movie --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.qryfile.filename#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- AMAZON --->
			<cfelseif application.razuna.storage EQ "amazon">
				<!--- Upload Movie Image --->
				<cfif !application.razuna.rfs>
					<cfset var upmi = Createuuid("")>
					<cfthread name="#upmi#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmi#" />
					<!--- Get signed URL --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.thisvid.theorgimage#" awsbucket="#arguments.thestruct.awsbucket#">
				</cfif>
				<!--- Upload Movie --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfset var upmt = Createuuid("")>
					<cfthread name="#upmt#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmt#" />
					<!--- Rename the UPC addtional rendition image --->
					<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
					<cfpause interval="5" />
						<cfthread name="rename#upmt#" intupstruct="#arguments.thestruct#" action="run">
							<cfinvoke component="s3" method="renameObject">
								<cfinvokeargument name="oldBucketName" value="#attributes.intupstruct.awsbucket#">
								<cfinvokeargument name="newBucketName" value="#attributes.intupstruct.awsbucket#">
								<cfinvokeargument name="oldFileKey" value="#attributes.intupstruct.qryfile.folder_id#/vid/#attributes.intupstruct.thisvid.newid#/#attributes.intupstruct.qryfile.filename#">
								<cfinvokeargument name="newFileKey" value="#attributes.intupstruct.qryfile.folder_id#/vid/#attributes.intupstruct.thisvid.newid#/#attributes.intupstruct.vid_name#.#attributes.intupstruct.qryfile.extension#">
							</cfinvoke>
						</cfthread>
						<cfthread action="join" name="rename#upmt#" />
					</cfif>
				</cfif>
				<!--- Get signed URLS for movie --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- AKAMAI --->
			<cfelseif application.razuna.storage EQ "akamai">
				<!--- Upload Movie Image --->
				<!--- <cfif !application.razuna.rfs>
					<cfset upmi = Createuuid("")>
					<cfthread name="#upmi#" intstruct="#arguments.thestruct#">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmi#" />
				</cfif> --->
				<!--- Upload Movie --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfset var upmt = Createuuid("")>
					<cfthread name="#upmt#" intstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="akamai" method="Upload">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="thetype" value="#attributes.intstruct.akavid#">
							<cfinvokeargument name="theurl" value="#attributes.intstruct.akaurl#">
							<cfinvokeargument name="thefilename" value="#attributes.intstruct.qryfile.filename#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmt#" />
				</cfif>
			</cfif>
			<cfset var ts = arguments.thestruct.qryfile.thesize>
			<cfif !application.razuna.rfs>
				<cfif isnumeric(orgwidth)>
					<cfset var tw = orgwidth>
				<cfelse>
					<cfset var tw = 1>
				</cfif>
				<cfif isnumeric(orgheight)>
					<cfset var th = orgheight>
				<cfelse>
					<cfset var th = 1>
				</cfif>
			</cfif>
		<!--- We come from a link thus assign some variables --->
		<cfelseif arguments.thestruct.qryfile.link_kind EQ "url">
			<cfset var ts = 1>
			<cfset var tw = 1>
			<cfset var th = 1>
			<cfset var vid_meta = "">
		</cfif>
		<!--- Get sharing options for folder so it can be applied to the asset --->
		<cfquery datasource="#application.razuna.datasource#" name="get_dl_params">
			SELECT share_dl_org 
			FROM #session.hostdbprefix#folders 
			WHERE folder_id = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Set shared options --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#share_options
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.thisvid.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
		<cfqueryparam value="#arguments.thestruct.thisvid.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="vid" cfsqltype="cf_sql_varchar">,
		<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND (arguments.thestruct.upcRenditionNum NEQ 1 OR arguments.thestruct.fn_ischar)>
			<cfqueryparam value="#arguments.thestruct.qryfile.groupid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfelse>
		<cfqueryparam value="org" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#iif(get_dl_params.share_dl_org eq 't',1,0)#" cfsqltype="cf_sql_varchar">,
		</cfif>
		<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Add the rest of informations to the video db --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#videos
		SET
		vid_name_image = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thisvid.theorgimage#">,
		vid_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ts#">,
		vid_filename = <cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">,
		<cfif !application.razuna.rfs>
			vid_width = <cfqueryparam cfsqltype="cf_sql_numeric" value="#tw#">,
			vid_height = <cfqueryparam cfsqltype="cf_sql_numeric" value="#th#">,
		</cfif>
		<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
			vid_name_org = <cfqueryparam value="#arguments.thestruct.vid_name#.#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			<cfif structKeyExists(arguments.thestruct,'qryGroupDetails') AND arguments.thestruct.qryGroupDetails.recordcount NEQ 0 >
				vid_group =  <cfqueryparam value="#arguments.thestruct.qryGroupDetails.id#" cfsqltype="cf_sql_varchar">,
			</cfif>
			<cfif arguments.thestruct.upcRenditionNum EQ 1>
				vid_online = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.vid_online#">,
				vid_single_sale = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">,
				vid_is_new = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">,
				vid_selection = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">,
				vid_in_progress = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">,
				vid_upc_number =  <cfqueryparam value="#arguments.thestruct.dl_query.upc_number#" cfsqltype="cf_sql_varchar">,
			</cfif>
		<cfelse>
			vid_online = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.vid_online#">,
			vid_single_sale = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">,
			vid_is_new = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">,
			vid_selection = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">,
			vid_in_progress = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">,
			link_path_url = <cfqueryparam value="#arguments.thestruct.qryfile.path#" cfsqltype="cf_sql_varchar">,
			vid_meta = <cfqueryparam value="#vid_meta#" cfsqltype="cf_sql_varchar">,
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				vid_name_org = <cfqueryparam value="#arguments.thestruct.lanorgname#" cfsqltype="cf_sql_varchar">,
			<cfelse>
				vid_name_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			</cfif>
		</cfif>
		vid_custom_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thisvid.newid#">,
		vid_owner = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
		vid_create_date = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		vid_change_date = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		vid_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		vid_create_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		vid_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
		link_kind = <cfqueryparam value="#arguments.thestruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">,
		hashtag = <cfqueryparam value="#arguments.thestruct.qryfile.md5hash#" cfsqltype="cf_sql_varchar">
		<cfif !application.razuna.rfs>
			,
			is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif application.razuna.storage NEQ "local">
			,
			lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
		</cfif>
		WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.thisvid.newid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Check the audio from UPC or Not --->
		<cfif !structKeyExists(arguments.thestruct,'upcRenditionNum') OR (structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum EQ 1)>
		<!--- If there are metadata fields then add them here --->
		<cfif structkeyexists(arguments.thestruct,"metadata") AND arguments.thestruct.metadata EQ 1>
			<!--- Check if API is called the old way --->
			<cfif structkeyexists(arguments.thestruct,"sessiontoken")>
				<cfinvoke component="global.api.asset" method="setmetadata">
					<cfinvokeargument name="sessiontoken" value="#arguments.thestruct.sessiontoken#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.thisvid.newid#">
					<cfinvokeargument name="assettype" value="vid">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
			<cfelse>
				<!--- API2 --->
				<cfinvoke component="global.api2.asset" method="setmetadata">
					<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.thisvid.newid#">
					<cfinvokeargument name="assettype" value="vid">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
				<!--- Add custom fields --->
				<cfinvoke component="global.api2.customfield" method="setfieldvalue">
					<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
					<cfinvokeargument name="field_values" value="#arguments.thestruct.assetmetadatacf#">
				</cfinvoke>
			</cfif>
		</cfif>
		</cfif>
		<!--- Log --->
		<cfset log_assets(theuserid=session.theuserid,logaction='Add',logdesc='Added: #arguments.thestruct.qryfile.filename#',logfiletype='vid',assetid=arguments.thestruct.thisvid.newid,folderid='#arguments.thestruct.folder_id#')>
		<!--- Flush Cache --->
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("general")>
		<!--- RFS --->
		<cfif application.razuna.rfs>
			<cfset arguments.thestruct.newid = arguments.thestruct.thisvid.newid>
			<cfset arguments.thestruct.assettype = "vid">
			<cfinvoke component="rfs" method="notify" thestruct="#arguments.thestruct#" />
		</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.thisvid.newid />
</cffunction>

<!--- EXTRACT A COMPRESSED FILE (ZIP) ------------------------------------------------------------>
<cffunction name="extractFromZip" output="true" access="private">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<!--- Check if archive is a Razuna Versions archive in which cases already existing files are versioned. User must be admin to use this feature  --->
		<cfif arguments.thestruct.qryfile.filename contains 'RazunaVersions' AND (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())>
			<cfset var razver = true>
			<!--- Get folders in trash to omit later when checking for file exists in database query --->
			<cfinvoke component="global.cfc.folders" method="gettrashfolder" returnvariable="trashfolders">
			<cfset var trashfolderlist = listappend(-1,valuelist(trashfolders.id))>
			<!--- Look for subfolders of trash folders --->
			<cfloop query="trashfolders">
				<cfinvoke component="global.cfc.folders" method="getchildfolders" parentid = "#trashfolders.id#" returnvariable="sflist">
				<cfset trashfolderlist = listappend(trashfolderlist,sflist)>
			</cfloop>
		<cfelse>
			<cfset var razver = false>
		</cfif>
		<!--- Remove the ZIP file from the files DB. This is being created on normal file upload and is not needed --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#files
		WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
		</cfquery>
		<!--- Params --->
		<cfparam default="0" name="arguments.thestruct.upl_template">
		<cfset var thetemp = Createuuid("")>
		<!--- Extract ZIP --->
		<cfset var tzip = "zip" & thetemp>
		<cfthread name="#tzip#" intstruct="#arguments.thestruct#" action="run">
			<cfzip action="extract" zipfile="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#" destination="#attributes.intstruct.qryfile.path#" charset="utf-8">
		</cfthread>
		<cfthread action="join" name="#tzip#" />
		<!--- Get folder level of the folder we are in to create new folder --->
		<cfquery datasource="#application.razuna.datasource#" name="folders">
		SELECT folder_level, folder_main_id_r, folder_id_r
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- set root folder id to keep top folder during creating folder out of zip archive --->
		<cfset var rootfolderId = arguments.thestruct.qryfile.folder_id>
		<cfset var folderIdr = arguments.thestruct.qryfile.folder_id>
		<cfset var folderId = arguments.thestruct.qryfile.folder_id>
		<!---<cfset var folderlevel = folders.folder_level>--->
		<cfset var loopname = "">
		<!--- Loop over the zip directories and rename them if needed --->
		<cfset var ttf = "rec" & thetemp>
		<!--- <cfthread name="#ttf#" intstruct="#arguments.thestruct#"> --->
			<cfinvoke method="rec_renamefolders" thedirectory="#arguments.thestruct.qryfile.path#" />
		<!--- </cfthread> --->
		<!--- <cfthread action="join" name="#ttf#" /> --->
		<!--- Get directory again since the directory names could have changed from above --->
		<cfdirectory action="list" directory="#arguments.thestruct.qryfile.path#" name="thedir" recurse="true" type="dir">
		<!--- Sort the above list in a query because cfdirectory sorting sucks --->
		<cfquery dbtype="query" name="thedir">
		SELECT *
		FROM thedir
		WHERE name NOT LIKE '__MACOSX%'
		ORDER BY name
		</cfquery>
		<!--- Get folders within the unzip RECURSIVE --->
		<cfdirectory action="list" directory="#arguments.thestruct.qryfile.path#" name="thedirfiles" recurse="true" type="file">
		<!--- Sort the above list in a query because cfdirectory sorting sucks --->
		<cfquery dbtype="query" name="thedirfiles">
		SELECT *
		FROM thedirfiles
		WHERE size != 0
		AND attributes != 'H'
		AND name != 'thumbs.db'
		AND name NOT LIKE '.DS_STORE%'
		AND name NOT LIKE '__MACOSX%'
		ORDER BY name
		</cfquery>
		<!--- Create Directories --->
		<cfloop query="thedir">
			<cfset temp="">
			<cfset var folderlevel = "">
			<!--- Check how long the folder list is --->
			<cfset var namelistlen = listlen(name,FileSeparator())>
			<!--- If longer then 1 we need to get the folder_id_r of the previous folder --->
			<cfif namelistlen GT 1>
				<!--- Get the list entry at one higher then the current len --->
				<cfset var lenminusone = namelistlen - 1>
				<cfset var fnameforqry = ListGetAt(name, lenminusone, FileSeparator())>
				<!--- Query to get the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#" name="qryfidr">
				SELECT folder_id
				FROM #session.hostdbprefix#folders
				WHERE lower(folder_name) = <cfqueryparam value="#lcase(fnameforqry)#" cfsqltype="cf_sql_varchar">
				AND folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
				AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
				ORDER BY folder_create_time DESC
				</cfquery>
				<cfset var thedirlen = listLen(thedir.name, FileSeparator())-1>
				<cfset temp = rootfolderId>
				<cfloop index="i" from=1 to="#thedirlen#">
					<cfset folder_name = listGetAt(thedir.name, i, FileSeparator())>
					<cfquery name="qryGetFolderDetails" datasource="#application.razuna.datasource#">
					SELECT folder_id, folder_name, folder_level, folder_id_r
					FROM #session.hostdbprefix#folders 
					WHERE lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(folder_name)#">
					AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#temp#">
					AND folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
					ORDER BY folder_create_time DESC
					</cfquery>
					<cfset temp= qryGetFolderDetails.folder_id >
				</cfloop>
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qryfidr.folder_id#" returnvariable="crumbs" />
				<cfset var folderlevel = listlen(crumbs,";") + 1>
				<!--- Set the folder_id_r in var --->
				<!---<cfset var fidr = qryfidr.folder_id>--->
				<cfset var fidr = temp>
				<cfset var fname = listlast(name, FileSeparator())>
			<cfelse>
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#folders.folder_id_r#" returnvariable="crumbs" />
				<cfset var folderlevel = listlen(crumbs,";") + 1>
				<cfset var fname = name>
				<cfset var fidr = folderIdr>
			</cfif>			
			<!--- Set the new folderid --->
			<cfset var newfolderidinsert = createuuid("")>
			<!--- Add the Folder to DB --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#folders
			(folder_id, folder_name, folder_id_r, folder_main_id_r, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, host_id, folder_level)
			values (
			<cfqueryparam value="#newfolderidinsert#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#fname#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#fidr#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#folderlevel#" cfsqltype="cf_sql_numeric">
			)
			</cfquery>
			<!--- Apply custom setting to new folder --->
			<cfinvoke component="global.cfc.folders" method="apply_custom_shared_setting" folder_id="#newfolderidinsert#" />
			<!--- Add the workflow to the just created folder --->
			<cftry>
				<!--- Query for existing workflows --->
				<cfquery datasource="#application.razuna.datasource#" name="qry_wf">
				SELECT wf.wf_id_r, wa.wf_action
				FROM #session.hostdbprefix#workflow_folders wf, #session.hostdbprefix#workflow_actions wa
				WHERE wf.folder_id_r = <cfqueryparam value="#fidr#" cfsqltype="CF_SQL_VARCHAR">
				AND wa.wf_id_r = wf.wf_id_r
				AND lower(wa.wf_type) = <cfqueryparam value="wf_event" cfsqltype="CF_SQL_VARCHAR">
				AND wa.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Add workflows to just created folder --->
				<cfloop query="qry_wf">
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#workflow_folders
					(folder_id_r, wf_id_r)
					VALUES(
						<cfqueryparam value="#newfolderidinsert#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#wf_id_r#" cfsqltype="CF_SQL_VARCHAR">
					)
					</cfquery>
					<!--- Insert into plugin actions --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO plugins_actions
					(action, comp, func, args, p_id, host_id)
					VALUES(
						<cfqueryparam value="#wf_action#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="settings" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="executeWorkflow" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="wfid:#wf_id_r#,folderid:#newfolderidinsert#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="273ZRZ123RURWQEASD" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				</cfloop>
				<!--- Catch --->
				<cfcatch type="any">
					<cfset consoleoutput(true)>
					<cfset console(cfcatch)>
				</cfcatch>
			</cftry>
		</cfloop>
		<cfset resetcachetoken("folders")>
		<cfset sleep(2000)>
		<!--- Loop over ZIP-filelist to process with the extracted files with check for the file since we got errors --->
		<cfloop query="thedirfiles">
			<cfif fileexists("#directory#/#name#") >
				<cfset var temp="">
				<cfset var md5hash = "">
				<!--- Set Original FileName --->
				<cfset arguments.thestruct.theoriginalfilename = listlast(name,FileSeparator())>
				<cfset arguments.thestruct.thepathtoname = replacenocase(name,arguments.thestruct.theoriginalfilename,"","one")>
				<!--- Rename the file so that we can remove any spaces --->
				<cfinvoke component="global" method="convertname" returnvariable="newFileName" thename="#arguments.thestruct.theoriginalfilename#">
				<cffile action="rename" source="#directory#/#name#" destination="#directory#/#arguments.thestruct.thepathtoname#/#newFileName#">
				<!--- Detect file extension --->
				<cfinvoke method="getFileExtension" theFileName="#newFileName#" returnvariable="fileNameExt">
				<cfset var file = structnew()>
				<cfset file.fileSize = size>
				<cfset file.oldFileSize = size>
				<cfset file.dateLastAccessed = dateLastModified>
				<!--- Get and set file type and MIME content --->
				<cfquery datasource="#application.razuna.datasource#" name="fileType">
				SELECT type_type, type_mimecontent, type_mimesubcontent
				FROM file_types
				WHERE lower(type_id) = <cfqueryparam value="#lcase(fileNameExt.theext)#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- set attributes of file structure --->
				<cfif #fileType.recordCount# GT 0>
					<cfset arguments.thestruct.thefiletype = fileType.type_type>
				<cfelse>
					<cfset arguments.thestruct.thefiletype = "other">
				</cfif>
				<cfset arguments.thestruct.tempid = createuuid("")>
				<cfset arguments.thestruct.thefilename = newFileName>
				<cfset arguments.thestruct.thefilenamenoext = replacenocase("#newFileName#", ".#fileNameExt.theext#", "", "ALL")>
				<cfset arguments.thestruct.theincomingtemppath = "#directory#/#arguments.thestruct.thepathtoname#">
				<!--- MD5 Hash --->
				<cfif FileExists("#directory#/#arguments.thestruct.thepathtoname#/#newfilename#")>
					<cfset var md5hash = hashbinary("#directory#/#arguments.thestruct.thepathtoname#/#newfilename#")>
				</cfif>
				<!--- Check if we have to check for md5 records --->
				<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
				<!--- Check for the same MD5 hash in the existing records --->
				<cfif checkformd5>
					<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
				<cfelse>
					<cfset var md5here = 0>
				</cfif>
				<!--- If file does not exsist continue else send user an eMail --->
				<cfif md5here EQ 0>
					<!--- Check for the name which now contains the directory --->
					<cfset var thedirlen = listLen(name, FileSeparator()) - 1>
					<!--- If the above return 0 --->
					<cfif thedirlen EQ 0>
						<cfset var thedirlen = 1>
					</cfif>
					<!--- Get the directory name at the exact position in the list --->
					<cfset var thedirname = listGetAt(name, thedirlen, FileSeparator())>
					<!--- Get folder id with the name of the folder --->
					<cfquery datasource="#application.razuna.datasource#" name="qryfolderidmain">
					SELECT f.folder_id, f.folder_name,
					CASE
						WHEN EXISTS(
							SELECT s.folder_id
							FROM #session.hostdbprefix#folders s
							WHERE s.folder_id = f.folder_id_r
							AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						) THEN 1
						ELSE 0
					END AS ISHERE
					FROM #session.hostdbprefix#folders f
					WHERE lower(f.folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thedirname)#">
					AND f.folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
					<!---
					AND f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#rootfolderId#">
					--->
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND f.in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Subselect --->
					<cfquery dbtype="query" name="qryfolderid">
					SELECT *
					FROM qryfolderidmain
					WHERE ishere = 1
					</cfquery>
					
					<cfset temp = rootfolderId>
					<cfloop index="i" from=1 to="#thedirlen#">
						<cfset folder_name = listGetAt(thedirfiles.name, i, FileSeparator())>
						<cfquery name="qryGetFolderDetails" datasource="#application.razuna.datasource#">
						SELECT folder_id, folder_name 
						FROM #session.hostdbprefix#folders 
						WHERE lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(folder_name)#">
						AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#temp#">
						AND folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
						ORDER BY folder_create_time DESC
						</cfquery>
						<cfset temp = qryGetFolderDetails.folder_id>
					</cfloop>
					
					<!--- Put folder id into the general struct --->
					<cfif isDefined('temp') AND temp NEQ ''>
						<cfset arguments.thestruct.theid = temp>
					<cfelse>
						<cfset arguments.thestruct.theid = rootfolderId>
						<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.theincomingtemppath#">
						<!--- <cfset arguments.thestruct.fidr = 0> --->
					</cfif>
					<!--- Add to temp db --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#assets_temp
					(tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,thesize,file_id,host_id,md5hash)
					VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#fileNameExt.theext#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.theid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
					<cfif isnumeric(file.fileSize)>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#file.fileSize#">,
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="0">,
					</cfif>
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
					)
					</cfquery>
					<!--- Return IDs in a variable --->
					<!--- <cfset thetempids = arguments.thestruct.tempid & "," & thetempids> --->
					<!--- For each file we need query for the file --->
					<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qryfile">
					SELECT 
					tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, mimetype,
					thesize, groupid, sched_id, sched_action, file_id, link_kind, md5hash
					FROM #session.hostdbprefix#assets_temp
					WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>

					<!--- If this is a RazunaVersions.zip Archive then version existing files --->
					<cfif razver>
						<!--- Set file type --->
						<cfset arguments.thestruct.type = fileType.type_type>
						<cfif arguments.thestruct.type EQ ''>
							<cfset arguments.thestruct.type = 'doc'>
						</cfif>
						<!--- Check if  file exists in system --->
						<cfset var thefilename = listlast(name,FileSeparator())>
						<cfset var thefilename_noext = replacenocase(thefilename, '.' & lcase(fileNameExt.theext),'')>
						<cfif thefilename does not contain "RazunaVersions"> <!--- Omit the zip file itself --->
							<cfif arguments.thestruct.type eq 'img'>
								<cfset var colname = 'img'>
								<cfset var fileprefix = 'file'>
								<cfset var tblname = 'images'>
							<cfelseif arguments.thestruct.type eq 'aud'>
								<cfset var colname = 'aud'>
								<cfset var fileprefix = ''>
								<cfset var tblname = 'audios'>
							<cfelseif arguments.thestruct.type eq 'vid'>
								<cfset var colname = 'vid'>
								<cfset var fileprefix = 'file'>
								<cfset var tblname = 'videos'>
							<cfelse>
								<cfset var colname = 'file'>
								<cfset var fileprefix = ''>
								<cfset var tblname = 'files'>
							</cfif>
							
							<!--- Check if file already exists in which case we create a new version for it --->
							<cfquery name="filename_exists" datasource="#application.razuna.datasource#">
								SELECT #colname#_id id
								FROM #session.hostdbprefix##tblname#
								WHERE (lower(#colname#_#fileprefix#name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thefilename)#"> 
								OR (lower(#colname#_#fileprefix#name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thefilename_noext)#"> 
									AND #colname#_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(fileNameExt.theext)#">))
								AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
								<cfif findnocase(arguments.thestruct.type,'img,vid,aud')>
									AND (#colname#_group IS NULL OR #colname#_group ='')
								</cfif>
								AND folder_id_r NOT IN (<cfqueryparam value="#trashfolderlist#" cfsqltype="CF_SQL_VARCHAR" list="true">)
								AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
							</cfquery>
							<!--- Must be exactly one record of existing file, if multiple then skip as we can't figure out which one to attach version to in that case --->
							<cfif filename_exists.recordcount eq 1>
								<cfset arguments.thestruct.qryfile.file_id= filename_exists.id>
								<!--- If PDF then we generate images for the pages --->
								<cfif arguments.thestruct.qryfile.extension EQ "PDF" AND arguments.thestruct.qryfile.link_kind NEQ "url">
									<cfset arguments.thestruct.thetempdirectory = arguments.thestruct.theincomingtemppath>
									<cfset var ttpdf = Createuuid("")>
									<!--- If this is a linked asset --->
									<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
										<!--- Create var with temp directory to hold the thumbnail and images --->
										<cfset arguments.thestruct.theorgfileflat = "#arguments.thestruct.qryfile.path#[0]">
										<cfset arguments.thestruct.theorgfile = arguments.thestruct.qryfile.path>
										<cfset arguments.thestruct.theorgfileraw = arguments.thestruct.qryfile.path>
										<!--- The name for the pdf --->
										<cfset var getlast = listlast(arguments.thestruct.qryfile.path,"/\")>
										<cfset arguments.thestruct.thepdfimage = replacenocase(getlast,".pdf",".jpg","all")>
									<!--- For importpath --->
									<cfelseif arguments.thestruct.importpath NEQ "" AND arguments.thestruct.importpath>
										<!--- Create var with temp directory to hold the thumbnail and images --->
										<cfset arguments.thestruct.theorgfileflat = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#[0]">
										<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
										<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
										<!--- The name for the pdf --->
										<cfset arguments.thestruct.thepdfimage = replacenocase(arguments.thestruct.qryfile.filename,".pdf",".jpg","all")>
										<!--- Create temp folder --->
										<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775" />
									<cfelse>
										<cfset arguments.thestruct.theorgfileflat = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#[0]">
										<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
										<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
										<!--- The name for the pdf --->
										<cfset arguments.thestruct.thepdfimage = replacenocase(arguments.thestruct.qryfile.filename,".pdf",".jpg","all")>
									</cfif>
																
									<!--- Create a temp folder to hold the PDF images --->
									<cfset arguments.thestruct.thepdfdirectory = "#arguments.thestruct.thetempdirectory#/#createuuid('')#/razuna_pdf_images">
									<!--- Create folder to hold the images --->
									<cfdirectory action="create" directory="#arguments.thestruct.thepdfdirectory#" mode="775">
									 <cfset var resizeargs = "400x"> <!--- Set default preview size to 400x --->
									<cfset var thumb_width = arguments.thestruct.qrysettings.set2_img_thumb_width>
									<cfset var thumb_height = arguments.thestruct.qrysettings.set2_img_thumb_heigth>
									<!--- If both height and width are set then resize to exact height and width set. --->
									<cfif isnumeric(thumb_width) AND isnumeric(thumb_height)>
										<cfset resizeargs =  "#thumb_width#x#thumb_height#">
									<!--- If only height set then resize to given height preserving aspect ratio.  --->
									<cfelseif isnumeric(thumb_height)>
										<cfset resizeargs = "x#thumb_height#">
									<!--- If only width set then resize to given width preserving aspect ratio. --->
									<cfelseif isnumeric(thumb_width)>
										<cfset resizeargs = "#thumb_width#x">
									</cfif>
									<!--- Script: Create thumbnail --->
									<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theimconvert# -density 300 -quality 100  ""#arguments.thestruct.theorgfileflat#"" -resize #resizeargs# -colorspace sRGB -background white -flatten ""#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thepdfimage#""" mode="777">
									<!--- Script: Create images --->
									<cffile action="write" file="#arguments.thestruct.thesht#" output="#arguments.thestruct.theimconvert# -density 100 -quality 100 ""#arguments.thestruct.theorgfile#"" ""#arguments.thestruct.thepdfdirectory#/#arguments.thestruct.thepdfimage#""" mode="777">
									<!--- Execute --->
									<cfthread name="#ttpdf#" action="run" pdfintstruct="#arguments.thestruct#">
										<cfexecute name="#attributes.pdfintstruct.thesh#" timeout="900" />
										<cfif application.razuna.storage NEQ "amazon">
											<cfexecute name="#attributes.pdfintstruct.thesht#" timeout="900" />
										</cfif>
									</cfthread>
									<!--- Wait for thread to finish --->
									<cfthread action="join" name="#ttpdf#" />					
									<!--- Delete scripts --->
									<cffile action="delete" file="#arguments.thestruct.thesh#">
									<cffile action="delete" file="#arguments.thestruct.thesht#">
									<!--- If no PDF could be generated then copy the thumbnail placeholder --->
									<cfif NOT fileexists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thepdfimage#")>
										<cffile action="copy" source="#arguments.thestruct.rootpath#global/host/dam/images/icons/icon_pdf.png" destination="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thepdfimage#" mode="775">
									</cfif>
									<!--- RAZ-2480 : Setting link_path_url for the PDF type files --->
									<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
										<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.qryfile.path#">
									<cfelse>
										<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
									</cfif> 
								</cfif>
								<!--- End PDF --->
								<!--- Finally create the version --->
								<cfinvoke component="versions" method="create" thestruct="#arguments.thestruct#">
							 	<!--- Go back to top of loop --->
							 	<cfcontinue>
							</cfif>
						</cfif>
					</cfif>

					<!--- Create inserts --->
					<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
					<!--- Now start the file mumbo jumbo --->
					<cfif fileType.type_type EQ "img">
						<!--- IMAGE UPLOAD (call method to process a img-file) --->
						<cfinvoke method="processImgFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "img">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
							<cfset arguments.thestruct.upltemptype = "img">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelseif fileType.type_type EQ "vid">
						<!--- VIDEO UPLOAD (call method to process a vid-file) --->
						<cfinvoke method="processVidFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "vid">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
							<cfset arguments.thestruct.upltemptype = "vid">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelseif fileType.type_type EQ "aud">
						<!--- AUDIO UPLOAD (call method to process a vid-file) --->
						<cfinvoke method="processAudFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "aud">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
							<cfset arguments.thestruct.upltemptype = "aud">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelse>
						<!--- DOCUMENT UPLOAD (call method to process a doc-file) --->
						<cfinvoke method="processDocFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "doc">
					</cfif>
					<!--- Put file_id in struct as fileid for plugin api --->
					<cfset arguments.thestruct.fileid = returnid>
					<cfset arguments.thestruct.file_name = arguments.thestruct.thefilename>
					<cfset arguments.thestruct.folder_id = arguments.thestruct.qryfile.folder_id>
					<cfset arguments.thestruct.folder_action = false>
					<!--- Check on any plugin that call the on_file_add action --->
					<cfinvoke component="plugins" method="getactions" theaction="on_file_add" args="#arguments.thestruct#" />
					<cfset arguments.thestruct.folder_action = true>
					<!--- Check on any plugin that call the on_file_add action --->
					<cfinvoke component="plugins" method="getactions" theaction="on_file_add" args="#arguments.thestruct#" />
				<cfelse>
					<!--- RAZ-2810 Customise email message --->
					<cfset transvalues = arraynew()>
					<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
					<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
					<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
					<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#"  isdup = "yes" filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
				</cfif>
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function assets.extractFromZip">
			<cfset cfcatch.thestruct = arguments.thestruct>
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- Recursive function to rename folders from zip --->
<cffunction name="rec_renamefolders" output="false" access="public" returnType="void">
	<cfargument name="thedirectory" type="string">
	<!--- Set local var --->
	<cfset var thedir = "">
	<cfset var thedirlist = "">
	<!--- Get folders within the unzip --->
	<cfdirectory action="list" directory="#arguments.thedirectory#" name="thedirlist" recurse="true" type="dir">
	<!--- Sort the above list in a query because cfdirectory sorting sucks --->
	<cfquery dbtype="query" name="thedir">
	SELECT *
	FROM thedirlist
	WHERE name NOT LIKE '__MACOSX%'
	AND attributes != 'H'
	ORDER BY name
	</cfquery>
	<!--- Loop over the directories only to check for any foreign chars and convert it --->
	<cfloop query="thedir">
		<!--- All foreign chars are now converted, except the FileSeparator and - --->
		<cfset var d = Rereplacenocase(name,"[^0-9A-Za-z\_\-\#FileSeparator()#]","-","ALL")>
		<!--- Rename --->
		<cfif directoryExists("#directory#/#name#") AND "#directory#/#name#" NEQ "#directory#/#d#">
			<cfdirectory action="rename" directory="#directory#/#name#" newdirectory="#directory#/#d#">
			<!--- Call this method again since the folder name on the disk could have changed --->
			<cfinvoke method="rec_renamefolders" thedirectory="#arguments.thedirectory#">
		</cfif>
	</cfloop>
	<cfreturn />
</cffunction>

<!--- CREATE FOLDER FROM ZIP--->
<cffunction name="createfolderfromzip" output="true" access="private">
	<cfargument name="thestruct" type="struct">
	<!--- Check that the same folder does not already exist --->
	<!--- <cfquery datasource="#application.razuna.datasource#" name="ishere">
	SELECT folder_id
	FROM #session.hostdbprefix#folders
	WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.foldername)#" cfsqltype="cf_sql_varchar">
	AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- If not the same folder here continue else abort --->
	<cfif ishere.recordcount EQ 0> --->
		<!--- Create a new ID --->
		<cfset var newfolderid = createuuid("")>
		<!--- Add the Folder --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#folders
		(folder_id, folder_name, folder_level, folder_id_r, folder_main_id_r, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, host_id)
		values (
		<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.foldername#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.folderlevel#" cfsqltype="cf_sql_numeric">,
		<cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfif Val(arguments.thestruct.rid)>
			<cfqueryparam value="#arguments.thestruct.rid#" cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>,
		<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>
<!--- 	<cfelse>
		<cfset newfolderid = 0>
	</cfif> --->
	<cfreturn newfolderid />
</cffunction>

<!--- PROCESS A AUDIO-FILE -------------------------------------------------------------------->
<cffunction name="processAudFile" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset arguments.thestruct.newid = 1>
	<!--- Get new id --->
	<cfset arguments.thestruct.newid = arguments.thestruct.qryfile.tempid>
	<!--- Flush Cache --->
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfset resetcachetoken("general")> 
	<!--- Set vars --->
	<cfset arguments.thestruct.dsn = application.razuna.datasource>
	<cfset arguments.thestruct.database = application.razuna.thedatabase>
	<cfset arguments.thestruct.hostid = session.hostid>
	<cfset arguments.thestruct.hostdbprefix = session.hostdbprefix>
	<cfset arguments.thestruct.storage = application.razuna.storage>
	<cfset arguments.thestruct.theuserid = session.theuserid>
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- thread --->
	<cfset var tt = Createuuid("")>
	<!--- Params --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_2 = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<!--- At times the orignal filename is stored in a different var so check for it and put it in proper var --->
	<cfif isdefined("arguments.thestruct.thefilenameoriginal") AND NOT isdefined("arguments.thestruct.theoriginalfilename")>
		<cfset arguments.thestruct.theoriginalfilename = arguments.thestruct.thefilenameoriginal>
	</cfif>
	<!--- If we are a new version --->
	<cfif arguments.thestruct.qryfile.file_id NEQ 0>
		<!--- RAZ-2907 Call the component for Bulk upload versions --->
		<cfif structKeyExists(arguments.thestruct,'extjs') AND arguments.thestruct.extjs EQ "T">
			<!--- Call versions component to do the old versions thingy --->
			<cfinvoke component="versions" method="upload_old_versions" thestruct="#arguments.thestruct#">
		<cfelse>	
		<!--- Call versions component to do the versions thingy --->
		<cfinvoke component="versions" method="create" thestruct="#arguments.thestruct#">
		</cfif>
	<!--- This is for normal adding --->
	<cfelse>
		<!--- Check the asset upload based on the UPC  --->
		<cfinvoke method="assetuploadupc" returnvariable="arguments.thestruct.upc_name" >
			<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
			<cfinvokeargument name="assetfrom" value="aud">
		</cfinvoke>
		<cfif structKeyExists(arguments.thestruct,'upc_name') AND arguments.thestruct.upc_name NEQ ''>
			<cfset arguments.thestruct.aud_name = arguments.thestruct.upc_name >
		</cfif>
		<!--- Dont do this if the link_kind is a url --->
		<cfif arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- Set the correct path --->
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				<!--- Create var with temp directory --->
				<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
				<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#">
				<cfset arguments.thestruct.theorgfileraw = arguments.thestruct.qryfile.path>
				<!--- Create temp folder --->
				<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			<!--- if importpath --->
			<cfelseif arguments.thestruct.importpath NEQ "">
				<!--- Create var with temp directory --->
				<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
				<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
				<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
				<!--- Create temp folder --->
				<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			<cfelse>
				<cfset arguments.thestruct.thetempdirectory = arguments.thestruct.qryfile.path>
				<cfset arguments.thestruct.theorgfile = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
				<cfset arguments.thestruct.theorgfileraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			</cfif>
			<!--- Check the platform and then decide on the Exiftool tag --->
			<cfif arguments.thestruct.iswindows>
				<cfset arguments.thestruct.theexe = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
				<cfset arguments.thestruct.theexeff = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
			<cfelse>
				<cfset arguments.thestruct.theexe = "#arguments.thestruct.thetools.exiftool#/exiftool">
				<cfset arguments.thestruct.theexeff = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
			</cfif>
			<cfset arguments.thestruct.theorgfile4copy = arguments.thestruct.theorgfile>
			<cfset arguments.thestruct.filenamenoext4copy = arguments.thestruct.qryfile.filenamenoext>
			<cfset arguments.thestruct.theorgfile = arguments.thestruct.theorgfile>
			<!--- Write the script --->
			<cfset var thescript = Createuuid("")>
			<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.sh">
			<!--- On Windows a .bat --->
			<cfif arguments.thestruct.iswindows>
				<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.bat">
			</cfif>
			<!--- Write files --->
			<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexe# -g ""#arguments.thestruct.theorgfile#""" mode="777">
			<!--- Execute --->
			<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="idtags" />
			<!--- Set idtags into struct for API --->
			<cfset arguments.thestruct.aud_meta = idtags>
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
			<!--- Put Xmp custom metadata into custom fields --->
			<cfset arguments.thestruct.thesource = arguments.thestruct.theorgfile>
			<cfinvoke component="xmp" method="xmpToCustomFields" thestruct="#arguments.thestruct#" />
			<!--- RFS --->
			<cfif !application.razuna.rfs>
				<!--- Create WAV file if file is not already a WAV--->
				<cfif arguments.thestruct.qryfile.extension NEQ "wav">
					<!--- Write files --->
					<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexeff# -i ""#arguments.thestruct.theorgfile#"" ""#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.wav""" mode="777">
					<!--- Execute --->
					<cfset var tt = createuuid("")>
					<cfthread name="wav#tt#" intaudstruct="#arguments.thestruct#" action="run">
						<cfexecute name="#attributes.intaudstruct.thesh#" timeout="60" />
					</cfthread>
					<!--- Wait until the WAV is done --->
					<cfthread action="join" name="wav#tt#" />
					<!--- If WAV file not generated then throw error --->	
					<cfif !fileexists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.wav")>
						<cfthrow message="WAV file could not be created in assets.processaudfile">
					</cfif>	
					<!--- Delete scripts --->
					<cffile action="delete" file="#arguments.thestruct.thesh#">
				</cfif>
				<!--- If we are a local link and are NOT a MP3 we create one to be able to play it in the browser --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan" AND arguments.thestruct.qryfile.extension NEQ "mp3">
					<!--- Write files --->
					<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexeff# -i ""#arguments.thestruct.theorgfile#"" -ab 192k ""#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.mp3""" mode="777">
					<!--- Execute --->
					<cfset var tt = createuuid("")>
					<cfthread name="mp3#tt#" intaudstruct="#arguments.thestruct#" action="run">
						<cfexecute name="#attributes.intaudstruct.thesh#" timeout="60" />
					</cfthread>
					<!--- Wait until the MP3 is done --->
					<cfthread action="join" name="mp3#tt#" />
					<!--- If MP3 file not generated then throw error --->
					<cfif !fileexists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.mp3")>
						<cfthrow message="MP3 file could not be created in assets.processaudfile">
					</cfif>		
					<!--- Delete scripts --->
					<cffile action="delete" file="#arguments.thestruct.thesh#">
				<cfelseif arguments.thestruct.qryfile.link_kind EQ "lan" AND arguments.thestruct.qryfile.extension EQ "mp3">
					<cffile action="copy" source="#arguments.thestruct.theorgfile4copy#" destination="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.filenamenoext4copy#.mp3" mode="775">
				</cfif>
			</cfif>
		<!--- If link_kind is url --->
		<cfelse>
			<cfset var idtags = "">
		</cfif>
		<!--- append to the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#audios
		SET 
		folder_id_r = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">, 
		aud_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
		aud_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
		aud_create_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
		aud_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		aud_owner = <cfqueryparam value="#arguments.thestruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
		aud_type = <cfqueryparam value="#arguments.thestruct.thefiletype#" cfsqltype="cf_sql_varchar">, 
		aud_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">, 
		aud_size = <cfqueryparam value="#arguments.thestruct.qryfile.thesize#" cfsqltype="cf_sql_varchar">, 
		link_kind = <cfqueryparam value="#arguments.thestruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">, 
		<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
			aud_name = <cfqueryparam value="#arguments.thestruct.aud_name#" cfsqltype="cf_sql_varchar">,
			aud_name_org = <cfqueryparam value="#arguments.thestruct.aud_name#.#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			<cfif structKeyExists(arguments.thestruct,'qryGroupDetails') AND arguments.thestruct.qryGroupDetails.recordcount NEQ 0 >
				aud_group =  <cfqueryparam value="#arguments.thestruct.qryGroupDetails.id#" cfsqltype="cf_sql_varchar">,
			</cfif>
			<cfif arguments.thestruct.upcRenditionNum EQ 1>
				aud_upc_number =  <cfqueryparam value="#arguments.thestruct.dl_query.upc_number#" cfsqltype="cf_sql_varchar">,
			</cfif>
		<cfelse>
			aud_online = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">, 
			aud_name_org = 
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				<cfqueryparam value="#arguments.thestruct.lanorgname#" cfsqltype="cf_sql_varchar">
			<cfelse>
				<cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>,
			aud_meta = <cfqueryparam value="#idtags#" cfsqltype="cf_sql_varchar">, 
			link_path_url = <cfqueryparam value="#arguments.thestruct.qryfile.path#" cfsqltype="cf_sql_varchar">, 
		</cfif>
		aud_name_noext = <cfqueryparam value="#arguments.thestruct.qryfile.filenamenoext#" cfsqltype="cf_sql_varchar">, 
		host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">,
		path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">,
		hashtag = <cfqueryparam value="#arguments.thestruct.qryfile.md5hash#" cfsqltype="cf_sql_varchar">
		<cfif application.razuna.storage NEQ "local">
			, lucene_key = <cfqueryparam value="#arguments.thestruct.theorgfile#" cfsqltype="cf_sql_varchar">
		</cfif>
		WHERE aud_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Check the audio from UPC or NOT --->
		<cfif !structKeyExists(arguments.thestruct,'upcRenditionNum') OR (structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum EQ 1)>
		<!--- Add the TEXTS to the DB. We have to hide this if we are coming from FCK --->
		<cfif structkeyexists(arguments.thestruct,'fieldname') AND arguments.thestruct.fieldname NEQ "NewFile" AND structkeyexists(arguments.thestruct,"langcount")>
			<cfloop list="#arguments.thestruct.langcount#" index="langindex">
				<cfset var desc="arguments.thestruct.file_desc_" & "#langindex#">
				<cfset var keywords="arguments.thestruct.file_keywords_" & "#langindex#">
				<cfif desc CONTAINS "#langindex#">
					<!--- check if form-vars are present. They will be missing if not coming from a user-interface (assettransfer, etc.) --->
					<cfif IsDefined(desc) and IsDefined(keywords)>
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#audios_text
						(id_inc, aud_id_r, lang_id_r, 
						aud_description, aud_keywords, host_id)
						values(
						<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
						<cfqueryparam value="#evaluate(desc)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#evaluate(keywords)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
						)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		</cfif>
		<!--- Upload --->
		<cfif arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- Move the file to its own directory --->
			<cfif application.razuna.storage EQ "local">
				<!--- Create folder with the asset id --->
				<cfif !directoryexists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#")>
					<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#" mode="775">
				</cfif>
				<!--- Move the file from the temp path to this folder --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfif arguments.thestruct.importpath NEQ "">
						<cfset var theaction = "copy">
					<cfelse>
						<cfset var theaction = "move">
					</cfif>
					<cffile action="#theaction#" source="#arguments.thestruct.theorgfileraw#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" mode="775">
				</cfif>
				<!--- Move the WAV --->
				<cfif arguments.thestruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs AND fileExists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.filenamenoext4copy#.wav")>
					<cffile action="move" source="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.filenamenoext4copy#.wav" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.filenamenoext4copy#.wav" mode="775">
				</cfif>
				<!--- Move the MP3 but only if local asset link --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan" AND fileExists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.filenamenoext4copy#.mp3")>
					<cffile action="move" source="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.filenamenoext4copy#.mp3" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.filenamenoext4copy#.mp3" mode="775">
				</cfif>
				<!--- Rename the UPC based upload audio --->
				<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
					<cffile action="rename" source="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.aud_name#.#arguments.thestruct.qryfile.extension#">
				</cfif>
			<!--- NIRVANIX --->
			<cfelseif application.razuna.storage EQ "nirvanix">
				<!--- Unique --->
				<cfset var upa = Createuuid("")>
				<cfset var upaw = "w" & upa>
				<cfset var upam = "m" & upa>
				<!--- Upload file --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfthread name="#upa#" audupstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.audupstruct.qryfile.folder_id#/aud/#attributes.audupstruct.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.audupstruct.theorgfile#">
							<cfinvokeargument name="nvxsession" value="#attributes.audupstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upa#" />
				</cfif>
				<!--- Upload the WAV --->
				<cfif arguments.thestruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs AND fileExists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.wav")>
					<cfthread name="#upaw#" audupstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.audupstruct.qryfile.folder_id#/aud/#attributes.audupstruct.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.audupstruct.thetempdirectory#/#attributes.audupstruct.qryfile.filenamenoext#.wav">
							<cfinvokeargument name="nvxsession" value="#attributes.audupstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upaw#" />
				</cfif>
				<!--- Move the MP3 but only if local asset link --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan" AND fileExists("#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.mp3")>
					<cfthread name="#upam#" audupstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.audupstruct.qryfile.folder_id#/aud/#attributes.audupstruct.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.audupstruct.thetempdirectory#/#attributes.audupstruct.qryfile.filenamenoext#.mp3">
							<cfinvokeargument name="nvxsession" value="#attributes.audupstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upam#" />
				</cfif>
				<!--- Get signed URLS --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" nvxsession="#arguments.thestruct.nvxsession#">
				</cfif>
				<cfif arguments.thestruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs AND fileExists("#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.wav")>
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.wav" nvxsession="#arguments.thestruct.nvxsession#">
				</cfif>
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan" AND fileExists("#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.mp3")>
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_2" theasset="#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.mp3" nvxsession="#arguments.thestruct.nvxsession#">
				</cfif>
				<!--- Update DB --->
				<cfquery datasource="#application.razuna.dataSource#">
				UPDATE #session.hostdbprefix#audios
				SET 
				cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
				cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
				cloud_url_2 = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_2.theurl#">,
				cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
				WHERE aud_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				</cfquery>
			<!--- AMAZON --->
			<cfelseif application.razuna.storage EQ "amazon">
				<!--- Unique --->
				<cfset var upa = Createuuid("")>
				<cfset var upw = "w" & upa>
				<cfset var upmp = "m" & upa>
				<!--- Upload file --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfthread name="#upa#" audstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filename#">
							<cfinvokeargument name="theasset" value="#attributes.audstruct.theorgfile#">
							<cfinvokeargument name="awsbucket" value="#attributes.audstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upa#" />
				</cfif>
				<!--- Upload the WAV --->
				<cfif arguments.thestruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs>
					<cfthread name="#upw#" audstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.wav">
							<cfinvokeargument name="theasset" value="#attributes.audstruct.thetempdirectory#/#attributes.audstruct.qryfile.filenamenoext#.wav">
							<cfinvokeargument name="awsbucket" value="#attributes.audstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upw#" />
				</cfif>
				<!--- Move the MP3 but only if local asset link --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan" AND fileExists("/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.mp3")>
					<cfthread name="#upmp#" audstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#aattributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.mp3">
							<cfinvokeargument name="theasset" value="#attributes.audstruct.thetempdirectory#/#attributes.audstruct.qryfile.filenamenoext#.mp3">
							<cfinvokeargument name="awsbucket" value="#attributes.audstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmp#" />
				</cfif>
				<!--- Rename the UPC additional rendition image --->
				<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum NEQ "">
					<cfpause interval="5" />
					<cfthread name="rename#upa#" intupstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="s3" method="renameObject">
							<cfinvokeargument name="oldBucketName" value="#attributes.intupstruct.awsbucket#">
							<cfinvokeargument name="newBucketName" value="#attributes.intupstruct.awsbucket#">
							<cfinvokeargument name="oldFileKey" value="#attributes.intupstruct.qryfile.folder_id#/aud/#attributes.intupstruct.newid#/#attributes.intupstruct.qryfile.filename#">
							<cfinvokeargument name="newFileKey" value="#attributes.intupstruct.qryfile.folder_id#/aud/#attributes.intupstruct.newid#/#attributes.intupstruct.aud_name#.#attributes.intupstruct.qryfile.extension#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="rename#upa#" />
				</cfif>
				<!--- Get signed URLS --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#">
				</cfif>
				<cfif arguments.thestruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs AND fileExists("/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.wav")>
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.wav" awsbucket="#arguments.thestruct.awsbucket#">
				</cfif>
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan" AND fileExists("/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.mp3")>
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_2" key="#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.mp3" awsbucket="#arguments.thestruct.awsbucket#">
				</cfif>
				<!--- Update DB --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET 
				cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
				cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
				cloud_url_2 = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_2.theurl#">,
				cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
				WHERE aud_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				</cfquery>
			</cfif>
			<!--- AKAMAI --->
			<cfelseif application.razuna.storage EQ "akamai">
				<!--- Unique --->
				<cfset var upa = Createuuid("")>
				<cfset var upw = "w" & upa>
				<cfset var upmp = "m" & upa>
				<!--- Upload file --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfthread name="#upa#" audstruct="#arguments.thestruct#" action="run">
						<cfinvoke component="akamai" method="Upload">
							<cfinvokeargument name="theasset" value="#attributes.audstruct.theorgfile#">
							<cfinvokeargument name="thetype" value="#attributes.audstruct.akaaud#">
							<cfinvokeargument name="theurl" value="#attributes.audstruct.akaurl#">
							<cfinvokeargument name="thefilename" value="#attributes.audstruct.qryfile.filename#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upa#" />
				</cfif>
				<!--- Upload the WAV --->
				<!--- <cfif arguments.thestruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs AND fileExists("/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.wav")>
					<cfthread name="#upw#" audstruct="#arguments.thestruct#">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.wav">
							<cfinvokeargument name="theasset" value="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.wav">
							<cfinvokeargument name="awsbucket" value="#arguments.thestruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upw#" />
				</cfif> --->
				<!--- Move the MP3 but only if local asset link --->
				<!--- <cfif arguments.thestruct.qryfile.link_kind EQ "lan" AND fileExists("/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.mp3")>
					<cfthread name="#upmp#" audstruct="#arguments.thestruct#">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#arguments.thestruct.qryfile.folder_id#/aud/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filenamenoext#.mp3">
							<cfinvokeargument name="theasset" value="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.qryfile.filenamenoext#.mp3">
							<cfinvokeargument name="awsbucket" value="#arguments.thestruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmp#" />
				</cfif> --->
			</cfif>
		<!--- Update DB to make asset available --->
		<cfif !application.razuna.rfs>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#audios
			SET is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
			WHERE aud_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- Get sharing options for folder so it can be applied to the asset --->
		<cfquery datasource="#application.razuna.datasource#" name="get_dl_params">
			SELECT share_dl_org 
			FROM #session.hostdbprefix#folders 
			WHERE folder_id = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Set shared options --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#share_options
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">,
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="aud" cfsqltype="cf_sql_varchar">,
		<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND (arguments.thestruct.upcRenditionNum NEQ 1 OR arguments.thestruct.fn_ischar)>
			<cfqueryparam value="#arguments.thestruct.qryfile.groupid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfelse>
		<cfqueryparam value="org" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#iif(get_dl_params.share_dl_org eq 't',1,0)#" cfsqltype="cf_sql_varchar">,
		</cfif>
		<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Check the audio from UPC or Not --->
		<cfif !structKeyExists(arguments.thestruct,'upcRenditionNum') OR (structKeyExists(arguments.thestruct,'upcRenditionNum') AND arguments.thestruct.upcRenditionNum EQ 1)>
		<!--- If there are metadata fields then add them here --->
		<cfif structkeyexists(arguments.thestruct,"metadata") AND arguments.thestruct.metadata EQ 1>
			<!--- Check if API is called the old way --->
			<cfif structkeyexists(arguments.thestruct,"sessiontoken")>
				<cfinvoke component="global.api.asset" method="setmetadata">
					<cfinvokeargument name="sessiontoken" value="#arguments.thestruct.sessiontoken#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
					<cfinvokeargument name="assettype" value="aud">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
			<cfelse>
				<!--- API2 --->
				<cfinvoke component="global.api2.asset" method="setmetadata">
					<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
					<cfinvokeargument name="assettype" value="aud">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
				<!--- Add custom fields --->
				<cfinvoke component="global.api2.customfield" method="setfieldvalue">
					<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
					<cfinvokeargument name="field_values" value="#arguments.thestruct.assetmetadatacf#">
				</cfinvoke>
			</cfif>
		</cfif>
		</cfif>
		<!--- Log --->
		<cfinvoke component="extQueryCaching" method="log_assets">
			<cfinvokeargument name="theuserid" value="#arguments.thestruct.theuserid#">
			<cfinvokeargument name="logaction" value="Add">
			<cfinvokeargument name="logdesc" value="Added: #arguments.thestruct.qryfile.filename#">
			<cfinvokeargument name="logfiletype" value="aud">
			<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
			<cfinvokeargument name="folderid" value="#arguments.thestruct.qryfile.folder_id#">
		</cfinvoke>
		<!--- RFS --->
		<cfif application.razuna.rfs AND arguments.thestruct.qryfile.extension NEQ "wav" AND arguments.thestruct.newid NEQ 0>
			<cfset arguments.thestruct.assettype = "aud">
			<cfinvoke component="rfs" method="notify" thestruct="#arguments.thestruct#" />
		</cfif>
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("folders")>
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Return --->
	<cfreturn arguments.thestruct.newid />
</cffunction>

<!--- Get tempid record --->
<cffunction name="gettemprecord" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<cfset arguments.thestruct.tempid = replace(arguments.thestruct.tempid,"-","","ALL")>
	<cfquery datasource="#application.razuna.datasource#" name="q">
		<!--- Oracle --->
		<cfif application.razuna.thedatabase EQ "oracle">
			SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM (
				SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash 
				FROM #session.hostdbprefix#assets_temp
				WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
				AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
				ORDER BY date_add DESC
				)
			WHERE ROWNUM = 1
		<!--- H2 / MySQL --->
		<cfelseif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
			SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			ORDER BY date_add DESC
			Limit 1
		<cfelseif application.razuna.thedatabase EQ "mssql">
			SELECT TOP 1 tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			ORDER BY date_add DESC
		<!--- DB2 --->
		<cfelseif application.razuna.thedatabase EQ "db2">
			SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			ORDER BY date_add DESC
			FETCH FIRST 1 ROW ONLY
		</cfif>
	</cfquery>
	<cfreturn q />
</cffunction>

<!--- Activate Preview Image --->
<cffunction name="previewimageactivate" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset var cloud_url = structnew()>
	<cfset var thethumbheight = 0>
	<cfset var thethumbwidth = 0>
	<cfset var qry = "">
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<cfif arguments.thestruct.isWindows>
		<cfset var theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
	<cfelse>
		<cfset var theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
	</cfif>

		<cfif isdefined("arguments.thestruct.userendforpreview")>
		<cfset arguments.thestruct.tempid = createuuid()>
		<!--- Change tempid a bit --->
		<cfset arguments.thestruct.tempid = replace(arguments.thestruct.tempid,"-","","ALL")>
		<!--- Create a unique name for the temp directory to hold the file --->
		<cfset arguments.thestruct.thetempfolder   = "asset#arguments.thestruct.tempid#">
		<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
		<!--- Create a temp directory to hold the file --->
		<cfif !DirectoryExists(arguments.thestruct.theincomingtemppath)>
			<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
		</cfif>
		<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT '#arguments.thestruct.tempid#' tempid, av_link_url filename, asset_id_r file_id, '#arguments.thestruct.theincomingtemppath#' path, av_thumb_url,
			CASE 
			WHEN EXISTS (SELECT 1 FROM #session.hostdbprefix#images WHERE img_id = asset_id_r) THEN 'img'
			WHEN EXISTS (SELECT 1 FROM #session.hostdbprefix#videos WHERE vid_id = asset_id_r) THEN 'vid'
			WHEN EXISTS (SELECT 1 FROM #session.hostdbprefix#audios WHERE aud_id = asset_id_r) THEN 'aud'
			WHEN EXISTS (SELECT 1 FROM #session.hostdbprefix#files WHERE file_id = asset_id_r) THEN 'doc'
			END
			as type
			FROM #session.hostdbprefix#additional_versions
			WHERE av_id = <cfqueryparam value="#arguments.thestruct.av_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfset qry.filename = listlast(qry.filename,'/')>
		<!--- If file exists then copy else abort process --->
		<cfif fileExists("#arguments.thestruct.assetpath#/#session.hostid#/#qry.av_thumb_url#")>
			<cffile action="copy" source="#arguments.thestruct.assetpath#/#session.hostid#/#qry.av_thumb_url#" destination="#qry.path#/#qry.filename#">
		<cfelse>
			<cfabort>
		</cfif>
		<cfset arguments.thestruct.type = qry.type>
	<cfelse>
		<!--- Query the image --->
		<cfinvoke method="gettemprecord" thestruct="#arguments.thestruct#" returnVariable="qry" />
	</cfif>

	<!--- If record return zero records then abort --->
	<cfif qry.recordcount NEQ 0>
		<!--- Query existing record --->	
		<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qry_existing">
		SELECT path_to_asset
		<cfif arguments.thestruct.type EQ "vid">
			,
			vid_name_image
			FROM #session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry.file_id#">
		<cfelseif arguments.thestruct.type EQ "img">
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry.file_id#">
		<cfelseif arguments.thestruct.type EQ "doc">
			, file_name_noext
			FROM #session.hostdbprefix#files
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry.file_id#">
		</cfif>
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfset var setqry = "">
		<cfinvoke component="global.cfc.settings" method="getsettingsfromdam" returnvariable="setqry">
		<!--- Rename image on HD --->
		<cfif arguments.thestruct.type EQ "vid">
			<cfset arguments.thestruct.newname = arguments.thestruct.qry_existing.vid_name_image>
		<cfelseif arguments.thestruct.type EQ "img">
			<cfset arguments.thestruct.newname = "thumb_#qry.file_id#.#setqry.set2_img_format#">
		<cfelseif arguments.thestruct.type EQ "doc">
			<cfset arguments.thestruct.newname = arguments.thestruct.qry_existing.file_name_noext & ".jpg">
		</cfif>
		<cfset var newpath = replacenocase(qry.path, qry.filename, "", "all")>
		<cfset arguments.thestruct.thedest = newpath & "/" & arguments.thestruct.newname>
		<cffile action="rename" source="#qry.path#/#qry.filename#" destination="#arguments.thestruct.thedest#">
		<!--- Get width and height for thumbnail--->
		<cfexecute name="#theexif#" arguments="-S -s -ImageHeight #arguments.thestruct.thedest#" timeout="60" variable="thethumbheight" />
		<cfexecute name="#theexif#" arguments="-S -s -ImageWidth #arguments.thestruct.thedest#" timeout="60" variable="thethumbwidth" />
		<cfif isnumeric(thethumbheight) AND isnumeric(thethumbwidth)>
			<!--- Update database --->
			<cfif arguments.thestruct.type EQ "vid">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#videos
				SET vid_preview_width = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thethumbwidth#">,
				vid_preview_heigth = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thethumbheight#">
				WHERE vid_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.thestruct.type EQ "img">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET thumb_width = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(thethumbwidth)#">,
				thumb_height = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(thethumbheight)#">,
				thumb_extension = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#setqry.set2_img_format#">
				WHERE img_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfif>
		<!--- Upload or move to designated area --->
		<cfif application.razuna.storage EQ "local">
			<cffile action="move" source="#arguments.thestruct.thedest#" destination="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.newname#" mode="775">
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<cfset var upa = Createuuid("")>
			<cfthread name="#upa#" intstruct="#arguments.thestruct#" action="run">
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qry_existing.path_to_asset#/#attributes.intstruct.newname#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thedest#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="#upa#" />
			<!--- Get signed URLS --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.newname#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Update DB --->
			<cfif arguments.thestruct.type EQ "vid">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#videos
				SET cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE vid_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.thestruct.type EQ "img">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE img_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.thestruct.type EQ "doc">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE file_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfif>
		<!--- Remove record in DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#assets_temp
		WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
		</cfquery>
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("search")>
		<cfset resetcachetoken("files")>
		<cfset variables.cachetoken = resetcachetoken("general")>
	</cfif>
</cffunction>

<!--- Recreate Preview Image --->
<cffunction name="recreatepreviewimage" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset arguments.thestruct.hostid = session.hostid>
	<!--- <cfinvoke method="recreatepreviewimagethread" thestruct="#arguments.thestruct#" /> --->
	<cfthread intstruct="#arguments.thestruct#" action="run">
		<cfinvoke method="recreatepreviewimagethread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- Recreate Preview Image --->
<cffunction name="recreatepreviewimagethread" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var theargsdc = "x">
	<cfset var thecolorspace = "">
	<cfset var thethumbheight = 0>
	<cfset var thethumbwidth = 0>
	<!--- Check the colorspace --->
	<cfif arguments.thestruct.qry_settings_image.set2_colorspace_rgb>
		<cfset var thecolorspace = "-colorspace sRGB">
	</cfif>
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Check the platform and then decide on the ImageMagick tag --->
	<cfif arguments.thestruct.isWindows>
		<cfset var theexe = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
		<cfset var thedcraw = """#arguments.thestruct.thetools.dcraw#/dcraw.exe""">
		<cfset var themogrify = """#arguments.thestruct.thetools.imagemagick#/mogrify.exe""">
		<cfset var theffmpeg = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
		<cfset var theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
	<cfelse>
		<cfset var theexe = "#arguments.thestruct.thetools.imagemagick#/convert">
		<cfset var thedcraw = "#arguments.thestruct.thetools.dcraw#/dcraw">
		<cfset var themogrify = "#arguments.thestruct.thetools.imagemagick#/mogrify">
		<cfset var theffmpeg = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
		<cfset var theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
	</cfif>
	<!--- Loop over file id --->
	<cfloop list="#arguments.thestruct.file_id#" index="i" delimiters=",">
		<cftry>
			<cfset var cloud_url = structnew()>
			<!--- Get the ID and the type --->
			<cfset var theid = listfirst(i,"-")>
			<cfset var thetype = listlast(i,"-")>
			<!--- Create variables according to type --->
			<cfif thetype EQ "vid">
				<cfset var thedb = "#session.hostdbprefix#videos">
				<cfset var theflush = "#session.theuserid#_videos">
				<cfset var therecid = "vid_id">
				<cfset var thecolumns = "path_to_asset, vid_name_image, vid_name_org orgname, cloud_url_org">
				<cfset var theakatype = arguments.thestruct.akavid>
			<cfelseif thetype EQ "img">
				<cfset var thedb = "#session.hostdbprefix#images">
				<cfset var theflush = "#session.theuserid#_images">
				<cfset var therecid = "img_id">
				<cfset var thecolumns = "path_to_asset, folder_id_r, img_filename_org orgname, img_extension, img_filename, cloud_url_org">
				<cfset var theakatype = arguments.thestruct.akaimg>
			</cfif>
			<!--- Query current thumbnail info --->
			<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qry_existing">
			SELECT #thecolumns#
			FROM #thedb#
			WHERE #therecid# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- If the cloud_url_org column is empty skip it --->
			<cfif arguments.thestruct.qry_existing.cloud_url_org EQ "" AND (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix")>
				<cfset var conti = false>
			<cfelse>
				<cfset var conti = true>
			</cfif>
			<cfif conti>
				<!--- Create script files --->
				<cfset var thescript = Createuuid("")>
				<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.sh">
				<cfset arguments.thestruct.theshdc = GetTempDirectory() & "/#thescript#dc.sh">
				<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#thescript#w.sh">
				<!--- On Windows a .bat --->
				<cfif arguments.thestruct.iswindows>
					<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.bat">
					<cfset arguments.thestruct.theshdc = GetTempDirectory() & "/#thescript#dc.bat">
					<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#thescript#w.bat">
				</cfif>
				<!--- The path to original: different on local --->
				<cfif application.razuna.storage EQ "local">
					<cfset arguments.thestruct.filepath = "#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_existing.path_to_asset#/">
				<cfelse>
					<!--- temp dir --->
					<cfset arguments.thestruct.filepath = GetTempDirectory()>
				</cfif>
				<!--- Set filename with complete path --->
				<cfif thetype EQ "vid">
					<cfset arguments.thestruct.thumbname = arguments.thestruct.qry_existing.vid_name_image>
					<cfset arguments.thestruct.thumbpath = arguments.thestruct.filepath & arguments.thestruct.thumbname>
					<cfset var theargs = "#theffmpeg# -i #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname# -vframes 1 -f image2 -vcodec mjpeg #arguments.thestruct.thumbpath#">
				<cfelseif thetype EQ "img">
					<cfif  isdefined("arguments.thestruct.qry_existing.img_extension") AND arguments.thestruct.qry_existing.img_extension eq 'gif'>
						<cfset arguments.thestruct.thumbname = "thumb_#theid#.gif">
					<cfelse>
					<cfset arguments.thestruct.thumbname = "thumb_#theid#.#arguments.thestruct.qry_settings_image.set2_img_format#">
					</cfif>
					<cfset arguments.thestruct.thumbpath = arguments.thestruct.filepath & arguments.thestruct.thumbname>
					<cfset var resizeargs = "400x"> <!--- Set default preview size to 400x --->
					<cfset var thumb_width = arguments.thestruct.qry_settings_image.set2_img_thumb_width>
					<cfset var thumb_height = arguments.thestruct.qry_settings_image.set2_img_thumb_heigth>
					<!--- If both height and width are set then resize to exact height and width set.  --->
					<cfif isnumeric(thumb_width) AND isnumeric(thumb_height)>
						<cfset resizeargs =  "#thumb_width#x#thumb_height#">
					<!--- If only height set then resize to given height preserving aspect ratio.  --->
					<cfelseif isnumeric(thumb_height)>
						<cfset resizeargs = "x#thumb_height#">
					<!--- If only width set then resize to given width preserving aspect ratio. --->
					<cfelseif isnumeric(thumb_width)>
						<cfset resizeargs = "#thumb_width#x">
					</cfif>
					<!--- If extension is TGA then turn off alpha --->
					<cfif isdefined("arguments.thestruct.qry_existing.img_extension") AND arguments.thestruct.qry_existing.img_extension eq 'tga'>
						<cfset alpha = '-alpha off'>
					<cfelse>
						<cfset alpha = ''>
					</cfif>
					<!--- Create the args for conversion --->
					<cfswitch expression="#arguments.thestruct.qry_existing.img_extension#">
						<!--- If the file is a PSD, AI or EPS we have to layer it to zero --->
						<cfcase value="psd,eps,ai,png,tif">
							<cfset var theargs = "#theexe# -density 300 #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#[0] -resize #resizeargs# #thecolorspace# -flatten #arguments.thestruct.thumbpath#">
						</cfcase>
						<!--- For RAW images we take dcraw --->
						<cfcase value="nef,x3f,arw,mrw,crw,cr2,3fr,ari,srf,sr2,bay,cap,iiq,eip,dcs,dcr,drf,k25,kdc,erf,fff,mef,mos,nrw,ptx,pef,pxn,r3d,raf,raw,rw2,rwl,dng,rwz">
							<cfset var theargs = "#thedcraw# -c -e #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname# > #arguments.thestruct.thumbpath#">
							<cfset var theargsdc = "#themogrify# -resize #resizeargs# #thecolorspace# #arguments.thestruct.thumbpath#">
						</cfcase>
						<!--- For everything else --->
						<cfdefaultcase>
							<cfset var theargs = "#theexe# #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname# #alpha# -resize #resizeargs# #thecolorspace# #arguments.thestruct.thumbpath#">
						</cfdefaultcase>
					</cfswitch>
				</cfif>
				<!--- Write script file --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#theargs#" mode="777">
				<cffile action="write" file="#arguments.thestruct.theshdc#" output="#theargsdc#" mode="777">
				<!--- Local: Delete thumbnail --->
				<cfif application.razuna.storage EQ "local">
					<!--- Delete old thumb (if there) --->
					<cfif fileexists(arguments.thestruct.thumbpath)>
						<cffile action="delete" file="#arguments.thestruct.thumbpath#" />
					</cfif>
				<!--- Amazon & Nirvanix download file --->
				<cfelseif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
					<cfhttp url="#arguments.thestruct.qry_existing.cloud_url_org#" file="#arguments.thestruct.qry_existing.orgname#" path="#arguments.thestruct.filepath#"></cfhttp>
				<!--- Akamai --->
				<cfelseif application.razuna.storage EQ "akamai">
					<!--- Delete old thumb (if there) --->
					<cfif fileexists(arguments.thestruct.thumbpath)>
						<cffile action="delete" file="#arguments.thestruct.thumbpath#" />
					</cfif>
					<!--- Download original --->
					<cfhttp url="#arguments.thestruct.akaurl##arguments.thestruct.theakatype#/#arguments.thestruct.qry_existing.orgname#" file="#arguments.thestruct.qry_existing.orgname#" path="#arguments.thestruct.filepath#"></cfhttp>
				</cfif>
				<!--- Convert image to thumbnail --->
				<cfthread name="con#thescript#" intstruct="#arguments.thestruct#" action="run">
					<cfexecute name="#attributes.intstruct.thesh#" timeout="60" />
				</cfthread>
				<!--- Wait --->
				<cfthread action="join" name="con#thescript#" />
				<!--- For RAW image additionally use mogrify --->
				<cfthread name="con2#thescript#" intstruct="#arguments.thestruct#" action="run">
					<cfexecute name="#attributes.intstruct.theshdc#" timeout="60" />
				</cfthread>
				
				<cftry>
				<cfif arguments.thestruct.qry_existing.img_extension EQ "cr2">
					<cfset var orientation = "">
					<!--- Check orientation for CR2 images and rotate it properly if it is not properly rotated for viewing--->
					<cfexecute name="#theexif#" arguments="-Orientation -n #arguments.thestruct.thumbpath#" timeout="120" variable="orientation"/>
					<cfif orientation NEQ "" AND orientation contains "8">
						<cfexecute name="#themogrify#" arguments="-rotate -90 #arguments.thestruct.thumbpath#" timeout="120" />
					<cfelseif orientation NEQ "" AND orientation contains "6">
						<cfexecute name="#themogrify#" arguments="-rotate 90 #arguments.thestruct.thumbpath#" timeout="120" />
					</cfif>
				</cfif>
				<cfcatch></cfcatch>
				</cftry>
				<!--- Wait --->
				<cfthread action="join" name="con2#thescript#" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
				<cffile action="delete" file="#arguments.thestruct.theshdc#">
				<!--- Amazon: upload file --->
				<cfif application.razuna.storage EQ "amazon">
					<cfthread name="upload#thescript#" intstruct="#arguments.thestruct#" action="run">
						<!--- Upload Thumbnail --->
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qry_existing.path_to_asset#/#attributes.intstruct.thumbname#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thumbpath#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for thread to finish --->
					<cfthread action="join" name="upload#thescript#" />
					<!--- Get signed URLS --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.thumbname#" awsbucket="#arguments.thestruct.awsbucket#">
					<!--- Update DB --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #thedb#
					SET cloud_url = <cfqueryparam value="#cloud_url.theurl#" cfsqltype="cf_sql_varchar">
					WHERE #therecid# = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Remove the original and thumbnail --->
					<cfif fileexists("#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#")>
						<cffile action="delete" file="#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#" />
					</cfif>
					<!--- Delete old thumb (if there) --->
					<cfif fileexists(arguments.thestruct.thumbpath)>
						<cffile action="delete" file="#arguments.thestruct.thumbpath#" />
					</cfif>
				<!--- Akamai --->
				<cfelseif application.razuna.storage EQ "akamai">
					<!--- Movie thumbnail to local directory --->
					<cffile action="move" destination="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.thumbname#" source="#arguments.thestruct.thumbpath#" mode="775" />
					<!--- Remove the original --->
					<cfif fileexists("#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#")>
						<cffile action="delete" file="#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#" />
					</cfif>
				</cfif>

				<!--- Get width and height for thumbnail--->
				<cfexecute name="#theexif#" arguments="-S -s -ImageHeight #arguments.thestruct.thumbpath#" timeout="60" variable="thethumbheight" />
				<cfexecute name="#theexif#" arguments="-S -s -ImageWidth #arguments.thestruct.thumbpath#" timeout="60" variable="thethumbwidth" />
				
				<cfif thetype eq 'vid'>
					<cfset var thumb_prefix = "vid">
				<cfelse>
					<cfset var thumb_prefix = "thumb">
				</cfif>
				<cfif isnumeric(thethumbwidth) AND isnumeric(thethumbheight)>
					<!--- Update DB with appropriate thumb height and width from XMP data --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #thedb#
					SET #thumb_prefix#_width = <cfqueryparam value="#thethumbwidth#" cfsqltype="cf_sql_integer">,
					#thumb_prefix#_height = <cfqueryparam value="#thethumbheight#" cfsqltype="cf_sql_integer">
					WHERE #therecid# = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
				</cfif>
			</cfif>
			<cfcatch type="all">
				<cfset cfcatch.custom_message = "Error in function assets.recreatepreviewimagethread">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Process Upload Template --->
<cffunction name="process_upl_template" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset arguments.thestruct.convert_to = "">
	<cfset arguments.thestruct.convert = true>
	<cfset arguments.thestruct.convert_wm_jpg = "">
	<cfset arguments.thestruct.convert_wm_gif = "">
	<cfset arguments.thestruct.convert_wm_png = "">
	<cfset arguments.thestruct.convert_wm_tif = "">
	<cfset arguments.thestruct.convert_wm_bmp = "">
	<cfset arguments.thestruct.qry_settings_image = arguments.thestruct.qrysettings>
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT upl_temp_field, upl_temp_value, upl_temp_type, upl_temp_format
	FROM #session.hostdbprefix#upload_templates_val
	WHERE upl_temp_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upltemptype#">
	AND upl_temp_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_template#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfloop query="qry">
		<cfif upl_temp_field EQ "convert_to">
			<cfset arguments.thestruct.convert_to = upl_temp_value & "," & arguments.thestruct.convert_to>
		</cfif>
		<cfif upl_temp_field EQ "convert_wm_#upl_temp_format#">
			<cfset "arguments.thestruct.convert_wm_#upl_temp_format#" = upl_temp_value >
		</cfif>
	</cfloop>
	<!--- Images --->
	<cfif arguments.thestruct.upltemptype EQ "img">
		<cfinvoke component="images" method="convertImage" thestruct="#arguments.thestruct#" />
	<!--- Videos --->
	<cfelseif arguments.thestruct.upltemptype EQ "vid">
		<cfinvoke component="videos" method="convertvideothread" thestruct="#arguments.thestruct#" />
	<!--- Audios --->
	<cfelseif arguments.thestruct.upltemptype EQ "aud">
		<cfinvoke component="audios" method="convertaudiothread" thestruct="#arguments.thestruct#" />
	</cfif>
</cffunction>

<!--- Process Upload Additional versions --->
<cffunction name="addassetav" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.frompath" default="false">
	<cfparam name="arguments.thestruct.thesize" default="false">
	<cfset arguments.thestruct.newid = createuuid("")>
	<cfset arguments.thestruct.thewidth = 0>
	<cfset arguments.thestruct.theheight = 0>
	<cfset arguments.thestruct.av_thumb_url ="">
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- For API additional rendition OR version --->
	<cfif structkeyexists(arguments.thestruct,'destfolderid') AND arguments.thestruct.destfolderid NEQ ''>
		<cfset arguments.thestruct.folder_id = arguments.thestruct.destfolderid>
		<cfset file_field = "filedata">
	<cfelse>
		<cfset file_field = "file">
	</cfif>
	<cfset var thefile = structNew()>
	<!--- Create a unique name for the temp directory to hold the file --->
	<cfif !arguments.thestruct.frompath>
		<cfset arguments.thestruct.thetempfolder = "api#arguments.thestruct.newid#">
		<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
		<!--- Create a temp directory to hold the file --->
		<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
		<!--- Upload file --->
		<cffile action="upload" destination="#arguments.thestruct.theincomingtemppath#" nameconflict="overwrite" filefield="#file_field#" result="thefile">
		<!--- File Extension --->
		<cfset thefile.serverFileExt = lcase(thefile.serverFileExt)>
		<!--- File Size --->
		<cfset arguments.thestruct.thesize = thefile.fileSize>
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global.cfc.global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#thefile.serverFile#">
		<cffile action="rename" source="#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
	<cfelse>
		<cfset arguments.thestruct.thetempfolder = "api#arguments.thestruct.newid#">
		<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
		<!--- Create a temp directory to hold the file --->
		<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
		<!--- Upload file --->
		<cffile action="copy" source="#arguments.thestruct.thedir#/#arguments.thestruct.thefilename#" destination="#arguments.thestruct.theincomingtemppath#" nameconflict="overwrite" filefield="#file_field#" result="thefile">
		<!--- File Extension --->
		<cfset thefile.serverFileExt = arguments.thestruct.theextension>
		<!--- File Name --->
		<cfset thefile.serverFile = arguments.thestruct.thefilename>
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global.cfc.global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#thefile.serverFile#">
		<cffile action="rename" source="#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
	</cfif>
	<!--- Get and set file type and MIME content --->
	<cfquery datasource="#application.razuna.datasource#" name="fileType">
	SELECT type_type, type_mimecontent, type_mimesubcontent
	FROM file_types
	WHERE lower(type_id) = <cfqueryparam value="#lcase(thefile.serverFileExt)#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<!--- set attributes of file structure --->
	<cfif fileType.recordCount GT 0>
		<cfset arguments.thestruct.thefiletype = fileType.type_type>
	<cfelse>
		<cfset arguments.thestruct.thefiletype = "doc">
	</cfif>
	<!--- If img or vid we get the h and w --->
	<cfif arguments.thestruct.thefiletype EQ "img" OR arguments.thestruct.thefiletype EQ "vid">
		<!--- The tool paths --->
		<cfinvoke component="settings" method="get_tools" returnVariable="thetools" />
		<!--- According to win or lin --->
		<cfif arguments.thestruct.iswindows>
			<cfset var theexe = """#thetools.exiftool#/exiftool.exe""">
			<!--- Get width and height --->
			<cfexecute name="#theexe#" arguments="-S -s -imagewidth #arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" variable="arguments.thestruct.thewidth" timeout="30" />
			<cfexecute name="#theexe#" arguments="-S -s -ImageHeight #arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" variable="arguments.thestruct.theheight" timeout="30" />
		<cfelse>
			<cfset var theexe = thetools.exiftool & "/exiftool">
			<!--- Set scripts --->
			<cfset var theshw = "#GetTempDirectory()#/w#arguments.thestruct.newid#.sh">
			<cfset var theshh = "#GetTempDirectory()#/h#arguments.thestruct.newid#.sh">
			<!--- On LAN --->
			<cfset var theserverfile = "#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
			<cfset var theserverfile = replace(theserverfile," ","\ ","all")>
			<cfset var theserverfile = replace(theserverfile,"&","\&","all")>
			<cfset var theserverfile = replace(theserverfile,"'","\'","all")>
			<!--- Write Script --->
			<cffile action="write" file="#theshw#" output="#theexe# -S -s -imagewidth #theserverFile#" mode="777">
			<cffile action="write" file="#theshh#" output="#theexe# -S -s -ImageHeight #theserverFile#" mode="777">
			<!--- Execute Script --->
			<cfexecute name="#theshw#" timeout="900" variable="arguments.thestruct.thewidth" />
			<cfexecute name="#theshh#" timeout="900" variable="arguments.thestruct.theheight" />
			<!--- Delete scripts --->
			<cffile action="delete" file="#theshw#">
			<cffile action="delete" file="#theshh#">
		</cfif>
		<!--- Trim --->
		<cfset arguments.thestruct.thewidth = trim(arguments.thestruct.thewidth)>
		<cfset arguments.thestruct.theheight = trim(arguments.thestruct.theheight)>
		<cfif not isnumeric(arguments.thestruct.thewidth)>
			<cfset arguments.thestruct.thewidth = 0>
		</cfif>
		<cfif not isnumeric(arguments.thestruct.theheight)>
			<cfset arguments.thestruct.theheight = 0>
		</cfif>
	</cfif>
	<!--- MD5 Hash --->
	<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#")>
		<cfset arguments.thestruct.md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#")>
	</cfif>
	<!--- Query to get the settings --->
	<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qrysettings">
	SELECT set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, set2_img_comp_width,
	set2_img_comp_heigth, set2_vid_preview_author, set2_vid_preview_copyright, set2_path_to_assets, set2_colorspace_rgb 
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.setid#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- animated GIFs can only be converted to GIF --->
	<cfif Right(arguments.thestruct.thefilename, 4) eq ".gif">
		<cfset QuerySetCell(arguments.thestruct.qrysettings, "set2_img_format", "gif", 1)>
	</cfif>
	<cfset var theplaceholderpic = arguments.thestruct.rootpath & "global/host/dam/images/placeholders/nopic.jpg">
	<cfset arguments.thestruct.theplaceholderpic = theplaceholderpic>
	<cfset arguments.thestruct.width = arguments.thestruct.qrysettings.set2_img_thumb_width>
	<cfset arguments.thestruct.height = arguments.thestruct.qrysettings.set2_img_thumb_heigth>
	<cfset arguments.thestruct.thesource = "#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
	<cfset arguments.thestruct.destination = "#arguments.thestruct.theincomingtemppath#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#">
	<cfset arguments.thestruct.qryfile.extension = arguments.thestruct.qrysettings.set2_img_format>
	<cfif arguments.thestruct.isWindows>
		<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
		<cfset arguments.thestruct.destination = """#arguments.thestruct.destination#""">
		<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
	<cfelse>
		<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
		<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination," ","\ ","all")>
		<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination,"&","\&","all")>
		<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination,"'","\'","all")>
	</cfif>
	
	<!--- Parse keywords and description from XMP --->
	<cfinvoke component="xmp" method="xmpwritekeydesc" thestruct="#arguments.thestruct#" />
	<!--- Put Xmp custom metadata into custom fields --->
	<cfinvoke component="xmp" method="xmpToCustomFields" thestruct="#arguments.thestruct#" />
	<!--- Parse the Metadata from the image --->
	<cfthread name="xmp#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" action="run">
		<cfinvoke component="xmp" method="xmpparse" thestruct="#attributes.intstruct#" returnvariable="thread.thexmp" />
	</cfthread>
	<!--- Wait for the parsing --->
	<cfthread action="join" name="xmp#arguments.thestruct.newid#" />
	<!--- Put the thread result into general struct --->
	<cfset arguments.thestruct.thexmp = cfthread["xmp#arguments.thestruct.newid#"].thexmp>

	<!--- Create thumbnail if image file --->
	<cfif arguments.thestruct.thefiletype eq 'img'>
		<cfinvoke method="resizeImage" thestruct="#arguments.thestruct#" />
	</cfif>

	<!--- <cfif arguments.thestruct.thefiletype eq 'vid'>
		<cfset arguments.thestruct.thisvid.finalpath =
		<cfinvoke component="videos" method="create_previews" thestruct="#arguments.thestruct#">
	</cfif> --->

	<!--- If we are local --->
	<cfif application.razuna.storage EQ "local">
		<!--- Create folder with the asset id --->
		<cfif NOT directoryexists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#")>
			<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#" mode="775">
		</cfif>
		<!--- If we coming from import path we copy instead of move --->
		<cfif !arguments.thestruct.frompath>
			<cfset var theaction = "move">
		<cfelse>
			<cfset var theaction = "copy">
		</cfif>
		<!--- Move original image --->
		<cffile action="#theaction#" source="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#" mode="775">
		
		<cfif arguments.thestruct.thefiletype eq 'img'>
			<!--- Move thumb image --->
			<cffile action="#theaction#" source="#arguments.thestruct.theincomingtemppath#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" mode="775">
		</cfif>
		
		<!--- Set the URL --->
		<cfset arguments.thestruct.av_link_url = "/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#">
		<!--- thumb URL --->
		<cfset arguments.thestruct.av_thumb_url = "/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#">
	<!--- AMAZON --->
	<cfelseif application.razuna.storage EQ "amazon">
		<cfset var upt = Createuuid("")>
		<cfthread name="#upt#" intstruct="#arguments.thestruct#" action="run">
			<cfinvoke component="amazon" method="Upload">
				<cfinvokeargument name="key" value="/#attributes.intstruct.folder_id#/#attributes.intstruct.thefiletype#/#attributes.intstruct.newid#/#attributes.intstruct.thefilename#">
				<cfinvokeargument name="theasset" value="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.thefilename#">
				<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
			</cfinvoke>
		</cfthread>
		<cfthread action="join" name="#upt#" />

		<cfif arguments.thestruct.thefiletype eq 'img'>
			<!--- Upload thumbnail --->
			<cfset var uptn = Createuuid("")>
			<cfthread name="#uptn#" intstruct="#arguments.thestruct#" action="run">
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.folder_id#/#attributes.intstruct.thefiletype#/#attributes.intstruct.newid#/thumb_#attributes.intstruct.newid#.#attributes.intstruct.qrysettings.set2_img_format#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.destinationraw#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="#uptn#" />
			<!--- Get signed URLS for thumb --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_thumb" key="#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Set the thumb URL --->
			<cfset arguments.thestruct.av_thumb_url = cloud_url_thumb.theurl>
		</cfif>
		<!--- Get signed URLS for original --->
		<cfinvoke component="amazon" method="signedurl" returnVariable="cloudurl" key="#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#" awsbucket="#arguments.thestruct.awsbucket#">
		<!--- Set the URL --->
		<cfset arguments.thestruct.av_link_url = cloudurl.theurl>
	<!--- Akamai --->
	<cfelseif application.razuna.storage EQ "akamai">
		<cfset var upt = Createuuid("")>
		<cfthread name="#upt#" intstruct="#arguments.thestruct#" action="run">
			<cfinvoke component="akamai" method="Upload">
				<cfinvokeargument name="theasset" value="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.thefilename#">
				<cfinvokeargument name="thetype" value="#attributes.intstruct.akaimg#">
				<cfinvokeargument name="theurl" value="#attributes.intstruct.akaurl#">
				<cfinvokeargument name="thefilename" value="#attributes.intstruct.thefilename#">
			</cfinvoke>
		</cfthread>
		<cfthread action="join" name="#upt#" />
		<!--- Set the URL --->
		<cfset arguments.thestruct.av_link_url = "/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#">
	</cfif>
	<!--- Set values for function call below --->
	<cfset arguments.thestruct.av_link = "0">
	<cfset arguments.thestruct.av_link_title = thefile.serverFile>
	<cfset arguments.thestruct.file_id = session.asset_id_r>
	<cfset arguments.thestruct.type = arguments.thestruct.thefiletype>
	<!--- Add Asset to db --->
	<cfinvoke component="global" method="save_add_versions_link">
		<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
	</cfinvoke>
	<!--- Return Message --->
	<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>success</message>
<assetid>#xmlformat(arguments.thestruct.newid)#</assetid>
<filetype>#xmlformat(arguments.thestruct.type)#</filetype>
</Response></cfoutput>
	</cfsavecontent>
	<!--- Return --->
	<cfreturn thexml />
</cffunction>

<!--- UPDATER: INSERT FROM PATH --->
<cffunction name="addassetpath_updater" output="true" access="public">
	<cfargument name="thestruct" type="struct">

	<cfset consoleoutput(true)>
	<cfset console("count: " & application.razuna.uploadcount)>

	<!--- Conditional loop on uploadercount --->
	<cfloop condition = "application.razuna.uploadcount GTE 3">
	    <cfset sleep(2000)>
	    <cfset console("count within while: " & application.razuna.uploadcount)>
	</cfloop>
	<!--- Increase uploadercount --->
	<cfset application.razuna.uploadcount = application.razuna.uploadcount + 1>

	<cftry>

		<!--- The tool paths --->
		<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
		<cfset arguments.thestruct.theimconvert = "#arguments.thestruct.thetools.imagemagick#/convert">
		<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset arguments.thestruct.theexeff = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
		<!--- Filter out hidden dirs --->
		<!--- <cfloop query="thefiles"> --->
			<cfset var md5hash = "">
			<cfset var filepath = "">
			<cfset var thedir = "">
			<cfset var filename = "">
			<cfset var extension = "">
			<!--- Params --->
			<cfset var filepath = arguments.thestruct.file_path>
			<cfset var thedir = arguments.thestruct.folder_path>
			<cfset var filename_org = trim(arguments.thestruct.filename_org)>
			<cfset var filename = listlast(filepath,FileSeparator())>
			<cfset var filename_noext = listfirst(filename,".")>
			<cfset var extension = listlast(filename,".")>

			<!--- Get MD5 hash --->
			<cfset var md5hash = hashbinary("#filepath#")>
			<!--- Check in file type for extension --->
			<cfquery datasource="#application.razuna.datasource#" name="fileType">
			SELECT type_type
			FROM file_types
			WHERE lower(type_id) = <cfqueryparam value="#lcase(extension)#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- According to type we query db --->
			<cfif fileType.type_type EQ "img">
				<cfset var db = "images">
				<cfset var type = "image">
				<cfset var type_type = "img">
				<cfset var colname = "img_filename">
				<cfset var colid = "img_id">
				<cfset var colname_org = "img_filename_org">
				<cfset var columns = "img_id as fileid, img_filename, folder_id_r">
			<cfelseif fileType.type_type EQ "vid">
				<cfset var db = "videos">
				<cfset var type = "video">
				<cfset var type_type = "vid">
				<cfset var colname = "vid_filename">
				<cfset var colid = "vid_id">
				<cfset var colname_org = "vid_name_org">
				<cfset var columns = "vid_id as fileid, vid_filename, folder_id_r">
			<cfelseif fileType.type_type EQ "aud">
				<cfset var db = "audios">
				<cfset var type = "audio">
				<cfset var type_type = "aud">
				<cfset var colname = "aud_name">
				<cfset var colid = "aud_id">
				<cfset var colname_org = "aud_name_org">
				<cfset var columns = "aud_id as fileid, aud_name, folder_id_r">
			<cfelse>
				<cfset var type_type = "doc">
				<cfset var db = "files">
				<cfset var type = "document">
				<cfset var colname = "file_name">
				<cfset var colid = "file_id">
				<cfset var colname_org = "file_name_org">
				<cfset var columns = "file_id as fileid, file_name, folder_id_r">
			</cfif>
			<!--- Now check db for same hashtag --->
			<cfquery datasource="#application.razuna.datasource#" name="samefile">
			SELECT #columns#
			FROM #session.hostdbprefix##db#
			WHERE hashtag = <cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
			OR lower(#colname#) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(filename_org)#">
			</cfquery>
			<!--- If found then --->
			<cfif samefile.recordcount NEQ 0>
				<!--- Loop over record because user could have the ame file in differen folder --->
				<cfloop query="samefile">
					<!--- Store path to file --->
					<cfset var path_to_file = "#arguments.thestruct.assetpath#/#session.hostid#/#folder_id_r#/#type_type#/#fileid#">
					<!--- Create directory first --->
					<cftry>
						<cfdirectory action="create" directory="#path_to_file#" mode="775">
						<!--- Error out --->
						<cfcatch type="any">
							<cfset consoleoutput(true)>
							<cfset console('Error on creating folder for file #filename#')>
						</cfcatch>
					</cftry>
					<!--- Thread --->
					<!--- Let's move file on file system --->
					<!--- <cfthread name="#tt#" action="run" intstruct="#arguments.thestruct#"> --->
						<cfset consoleoutput(true)>
						<cfset console("copy:" & filepath & " to " & "#path_to_file#/#filename#")>
						<cffile action="copy" source="#filepath#" destination="#path_to_file#/#filename#" mode="775">
					<!--- </cfthread> --->
					<!--- Wait for thread to finish --->
					<!--- <cfthread action="join" name="#tt#" />	 --->
					<!--- Run the filecleanup --->
					<!--- <cfinvoke component="global" method="convertname" returnvariable="filename_renamed" thename="#filename#">
					<cfinvoke component="global" method="convertname" returnvariable="filename_renamed_noext" thename="#filename_noext#"> --->
					<!--- Update DB --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix##db#
					SET
					#colname_org# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#filename#">,
					path_to_asset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#folder_id_r#/#type_type#/#fileid#">
					WHERE #colid# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#">
					</cfquery>
					<!--- Do the rename action on the file --->
					<!--- Thread --->
					<!--- <cfthread name="#tt#" action="run" intstruct="#arguments.thestruct#"> --->
						<!--- <cffile action="rename" source="#path_to_file#/#filename#" destination="#path_to_file#/#filename_renamed#"> --->
					<!--- </cfthread> --->
					<!--- Wait for thread to finish --->
					<!--- <cfthread action="join" name="#tt#" />	 --->
					<!--- Create preview --->
					<cfif type_type EQ "img" OR type_type EQ "vid">
						<cfset arguments.thestruct.file_id = fileid & "-" & type_type>
						<!--- Call recreate function --->
						<cfinvoke method="recreatepreviewimagethread" thestruct="#arguments.thestruct#" />
					<!--- For Files --->
					<cfelseif type_type EQ "doc">
						<!--- Set scripts --->
						<cfset var ttpdf = Createuuid("")>
						<cfset var thesh = "#GetTempDirectory()#/#ttpdf#.sh">
						<cfset var thesht = "#GetTempDirectory()#/#ttpdf#t.sh">
						<!--- PDF --->
						<cfif extension EQ "pdf">
							<cfset var thepdfimage = replacenocase(filename,".pdf",".jpg","all")>
							<cfset var theorgfileflat = "#path_to_file#/#filename#[0]">
							<cfset var theorgfile = "#path_to_file#/#filename#">
							<!--- Create folder --->
							<cfset var pdf_path = "#path_to_file#/razuna_pdf_images">
							<cftry>
								<cfdirectory action="create" directory="#pdf_path#" mode="775">
								<cfcatch type="any"></cfcatch>
							</cftry>
							<cfset var resizeargs = "400x"> <!--- Set default preview size to 400x --->
							<cfset var thumb_width = arguments.thestruct.qry_settings_image.set2_img_thumb_width>
							<cfset var thumb_height = arguments.thestruct.qry_settings_image.set2_img_thumb_heigth>
							<!--- If both height and width are set then resize to exact height and width set. Aspect ratio ignored --->
							<cfif isnumeric(thumb_width) AND isnumeric(thumb_height)>
								<cfset var resizeargs =  "#thumb_width#x">
							<!--- If only height set then resize to given height preserving aspect ratio.  --->
							<cfelseif isnumeric(thumb_height)>
								<cfset var resizeargs = "x#thumb_height#">
							<!--- If only width set then resize to given width preserving aspect ratio. --->
							<cfelseif isnumeric(thumb_width)>
								<cfset var resizeargs = "#thumb_width#x">
							</cfif>
							<!--- Script: Create thumbnail --->
							<cffile action="write" file="#thesh#" output="#arguments.thestruct.theimconvert# -density 300 -quality 100  #theorgfileflat# -resize #resizeargs# -colorspace sRGB -background white -flatten #path_to_file#/#thepdfimage#" mode="777">
							<!--- Script: Create images --->
							<cffile action="write" file="#thesht#" output="#arguments.thestruct.theimconvert# -density 100 -quality 100 #theorgfile# #pdf_path#/#thepdfimage#" mode="777">
							<!--- Execute --->
							<!--- <cfthread name="#ttpdf#" action="run" pdfintstruct="#arguments.thestruct#"> --->
								<cfexecute name="#thesh#" timeout="900" />
								<cfexecute name="#thesht#" timeout="900" />
							<!--- </cfthread> --->
							<!--- Wait for thread to finish --->
							<!--- <cfthread action="join" name="#ttpdf#" />					 --->
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
							<cffile action="delete" file="#thesht#">
							<!--- If no PDF could be generated then copy the thumbnail placeholder --->
							<cfif NOT fileexists("#path_to_file#/#thepdfimage#")>
								<cffile action="copy" source="#arguments.thestruct.rootpath#global/host/dam/images/icons/icon_pdf.png" destination="#path_to_file#/#thepdfimage#" mode="775">
							</cfif>
						<!--- InDesign --->
						<cfelseif extension EQ "indd">
							<!--- Set vars --->
							<cfset var indd_thumb = "#filename_noext#.jpg">
							<!--- Write script --->
							<cffile action="write" file="#thesh#" output="#arguments.thestruct.theexif# -fast -fast2 #path_to_file#/#filename# -PageImage -b -listitem 0 > #path_to_file#/#indd_thumb#" mode="777">
							<!--- Execute --->
							<!--- <cfthread name="#ttpdf#" action="run" intstruct="#arguments.thestruct#"> --->
								<cfexecute name="#thesh#" timeout="900" />
							<!--- </cfthread> --->
							<!--- Wait for thread to finish --->
							<!--- <cfthread action="join" name="#ttpdf#" />					 --->
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
						</cfif>
					<!--- For Audios --->
					<cfelseif type_type EQ "aud">
						<!--- Set scripts --->
						<cfset var ttpdf = Createuuid("")>
						<cfset var thesh = "#GetTempDirectory()#/#ttpdf#.sh">
						<cfset var thesht = "#GetTempDirectory()#/#ttpdf#t.sh">
						<!--- Create WAV file if file is not already a WAV--->
						<cfif extension NEQ "wav">
							<!--- Write files --->
							<cffile action="write" file="#thesh#" output="#arguments.thestruct.theexeff# -i #path_to_file#/#filename# #path_to_file#/#filename_noext#.wav" mode="777">
							<!--- Execute --->
							<cfset tt = createuuid("")>
							<!--- <cfthread name="wav#tt#" intaudstruct="#arguments.thestruct#" action="run"> --->
								<cfexecute name="#thesh#" timeout="60" />
							<!--- </cfthread> --->
							<!--- Wait until the WAV is done --->
							<!--- <cfthread action="join" name="wav#tt#" /> --->
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
						</cfif>
						<!--- If we are a local link and are NOT a MP3 we create one to be able to play it in the browser --->
						<cfif extension NEQ "mp3">
							<!--- Write files --->
							<cffile action="write" file="#thesh#" output="#arguments.thestruct.theexeff# -i #path_to_file#/#filename# -ab 192k #path_to_file#/#filename_noext#.mp3" mode="777">
							<!--- Execute --->
							<!--- <cfthread name="mp3#tt#" intaudstruct="#arguments.thestruct#" action="run"> --->
								<cfexecute name="#thesh#" timeout="60" />
							<!--- </cfthread> --->
							<!--- Wait until the MP3 is done --->
							<!--- <cfthread action="join" name="mp3#tt#" /> --->
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
						</cfif>
					</cfif>
					<!--- Log it --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO log_uploader
					(api_key, file_name, file_type, date_upload, file_status, host_id, hashtag)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.apikey#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#filename_org#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#type#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="success">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
					)
					</cfquery>
				</cfloop>
			<!--- Filename can not be found --->
			<cfelse>
				<!--- Log it --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO log_uploader
				(api_key, file_name, file_type, date_upload, file_status, file_comment, host_id)
				VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.apikey#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#filename_org#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#type#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="error">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="File not found. Please upload within Razuna!">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.host_id#">
				)
				</cfquery>
			</cfif>
		<!--- </cfloop> --->
		
		<cfcatch type="any">
			<!--- Decrease uploadercount --->
			<cfset application.razuna.uploadcount = application.razuna.uploadcount - 1>
			<cfset consoleoutput(true)>
			<cfset console('There was an error')>
			<cfrethrow>
		</cfcatch>

	</cftry>

	<!--- Decrease uploadercount --->
	<cfset application.razuna.uploadcount = application.razuna.uploadcount - 1>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH --->
<cffunction name="addassetpath" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Params --->
	<cfset arguments.thestruct.userid = session.theuserid>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Read the name of the root folder --->
	<cfset arguments.thestruct.folder_name = listlast(arguments.thestruct.folder_path,"/\")>
	<!--- Since we come from the uploader we dont create the folder --->
	<cfif !arguments.thestruct.nofolder>
		<!--- Check to see if folder already exists and use existing if present else add folder --->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
	<cfelse>
		<!--- Set the folder id  --->
		<cfset new_folder_id = arguments.thestruct.theid>
	</cfif>
	<!--- Feedback --->
	<cfoutput>List files of this folder...<br><br></cfoutput>
	<cfflush>
	<!--- Now add all assets of this folder --->
	<cfdirectory action="list" directory="#arguments.thestruct.folder_path#" name="thefiles" type="file">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thefiles">
	SELECT *
	FROM thefiles
	WHERE attributes != 'H'
	</cfquery>
	<!--- Feedback --->
	<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
	<cfflush>
	<!--- New folder id into struct --->
	<cfset arguments.thestruct.new_folder_id = new_folder_id>
	<cfobject component="global.cfc.global" name="gobj">
	<!--- Loop over the assets --->
	<cfloop query="thefiles">
		<!--- Feedback --->
		<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
		<cfflush>
		<!--- Params --->
		<cfset arguments.thestruct.filepath = directory & "/" & name>
		<cfset arguments.thestruct.thedir = directory>
		<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
		<cfset arguments.thestruct.orgsize = size>
		<!--- Now add the asset --->
		<cfif thefiles.recordcount LT 10>
			<cfset var upt = Createuuid("")>
			<cfthread name="#upt#" intstruct="#arguments.thestruct#" action="run">
				<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
			</cfthread>
			<cfthread action="join" name="#upt#" />
		<cfelse>
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfif>
	</cfloop>
	<!--- Since we come from upload we can remove the directory --->
	<cfif !arguments.thestruct.nofolder>
	<!--- Feedback --->
	<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
	<cfflush>
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.folder_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Call rec function --->
	<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
		<!--- Feedback --->
		<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
		<cfflush>
		<!--- folder_id into theid --->
		<cfset arguments.thestruct.theid = new_folder_id>
		<!--- Call function --->
		<cfinvoke method="addassetpath2" thestruct="#arguments.thestruct#">
	</cfif>
	<!--- Feedback --->
	<cfoutput><span style="color:green;font-weight:bold;">Successfully added all folders and assets!</span><br><br></cfoutput>
	<cfflush>
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 2 --->
<cffunction name="addassetpath2" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		
		<!--- Add the folder if it doesn't already exist--->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<cftry>
			<!--- Now add all assets of this folder --->
			<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
			<!--- Filter out hidden dirs --->
			<cfquery dbtype="query" name="thefiles">
			SELECT *
			FROM thefiles
			WHERE attributes != 'H'
			</cfquery>
			<!--- Feedback --->
			<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
			<cfflush>
			<!--- New folder id into struct --->
			<cfset arguments.thestruct.new_folder_id = new_folder_id>

			<cfobject component="global.cfc.global" name="gobj">
			<!--- Loop over the assets --->
			<cfloop query="thefiles">
				<!--- Feedback --->
				<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
				<cfflush>
				<!--- Params --->
				<cfset arguments.thestruct.filepath = directory & "/" & name>
				<cfset arguments.thestruct.thedir = directory>
				<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
				<cfset arguments.thestruct.orgsize = size>
				<!--- Now add the asset --->
				<cfif thefiles.recordcount LT 10>
					<cfthread intstruct="#arguments.thestruct#" action="run">
						<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
					</cfthread>
				<cfelse>
					<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
				</cfif>
			</cfloop>
			<!--- Feedback --->
			<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
			<cfflush>
			<!--- Check if folder has subfolders if so add them recursively --->
			<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
			<!--- Filter out hidden dirs --->
			<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
			SELECT *
			FROM thedir
			WHERE attributes != 'H'
			</cfquery>
			<cfset arguments.thestruct.folderpath = arguments.thestruct.folder_path>
			<cfset arguments.thestruct.thisfolderid = arguments.thestruct.theid>
			<cfset arguments.thestruct.thislevel = arguments.thestruct.level>
			<!--- Call rec function --->
			<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
				<!--- Feedback --->
				<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
				<cfflush>
				<!--- folder_id into theid --->
				<cfset arguments.thestruct.theid = new_folder_id>
				<!--- Add directory to the folder_path --->
				<cfset arguments.thestruct.folder_path = directory & "/#name#">
				<!--- Call function --->
				<cfinvoke method="addassetpath3" thestruct="#arguments.thestruct#">
			</cfif>
			<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath>
			<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid>
			<cfset arguments.thestruct.level = arguments.thestruct.thislevel>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function assets.addassetpath2">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 3 --->
<cffunction name="addassetpath3" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder if it doesn't already exist--->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cftry>
			<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
			<!--- Filter out hidden dirs --->
			<cfquery dbtype="query" name="thefiles">
			SELECT *
			FROM thefiles
			WHERE attributes != 'H'
			</cfquery>
			<!--- Feedback --->
			<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
			<cfflush>
			<!--- New folder id into struct --->
			<cfset arguments.thestruct.new_folder_id = new_folder_id>
			<cfobject component="global.cfc.global" name="gobj">
			<!--- Loop over the assets --->
			<cfloop query="thefiles">
				<!--- Feedback --->
				<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
				<cfflush>
				<!--- Params --->
				<cfset arguments.thestruct.filepath = directory & "/" & name>
				<cfset arguments.thestruct.thedir = directory>
				<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
				<cfset arguments.thestruct.orgsize = size>
				<!--- Now add the asset --->
				<cfif thefiles.recordcount LT 10>
					<cfthread intstruct="#arguments.thestruct#" action="run">
						<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
					</cfthread>
				<cfelse>
					<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
				</cfif>
			</cfloop>
			<!--- Feedback --->
			<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
			<cfflush>
			<!--- Check if folder has subfolders if so add them recursively --->
			<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
			<!--- Filter out hidden dirs --->
			<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
			SELECT *
			FROM thedir
			WHERE attributes != 'H'
			</cfquery>
			<cfset arguments.thestruct.folderpath2 = arguments.thestruct.folder_path>
			<cfset arguments.thestruct.thisfolderid2 = arguments.thestruct.theid>
			<cfset arguments.thestruct.thislevel2 = arguments.thestruct.level>
			<!--- Call rec function --->
			<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
				<!--- Feedback --->
				<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
				<cfflush>
				<!--- folder_id into theid --->
				<cfset arguments.thestruct.theid = new_folder_id>
				<!--- Add directory to the folder_path --->
				<cfset arguments.thestruct.folder_path = directory & "/#name#">
				<!--- Call function --->
				<cfinvoke method="addassetpath4" thestruct="#arguments.thestruct#">
			</cfif>
			<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath2>
			<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid2>
			<cfset arguments.thestruct.level = arguments.thestruct.thislevel2>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function assets.addassetpath3">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 4 --->
<cffunction name="addassetpath4" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder if it doesn't already exist--->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<cfobject component="global.cfc.global" name="gobj">
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfif thefiles.recordcount LT 10>
				<cfthread intstruct="#arguments.thestruct#" action="run">
					<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
				</cfthread>
			<cfelse>
				<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath3 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid3 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel3 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath5" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath3>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid3>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel3>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 5 --->
<cffunction name="addassetpath5" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder if it doesn't already exist--->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<cfobject component="global.cfc.global" name="gobj">
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfif thefiles.recordcount LT 10>
				<cfthread intstruct="#arguments.thestruct#" action="run">
					<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
				</cfthread>
			<cfelse>
				<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath4 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid4 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel4 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath6" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath4>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid4>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel4>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 6 --->
<cffunction name="addassetpath6" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder if it doesn't already exist--->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<cfobject component="global.cfc.global" name="gobj">
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfif thefiles.recordcount LT 10>
				<cfthread intstruct="#arguments.thestruct#" action="run">
					<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
				</cfthread>
			<cfelse>
				<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath5 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid5 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel5 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath7" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath5>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid5>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel5>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 7 --->
<cffunction name="addassetpath7" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder if it doesn't already exist--->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<cfobject component="global.cfc.global" name="gobj">
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfif thefiles.recordcount LT 10>
				<cfthread intstruct="#arguments.thestruct#" action="run">
					<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
				</cfthread>
			<cfelse>
				<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath6 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid6 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel6 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath8" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath6>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid6>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel6>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 8 --->
<cffunction name="addassetpath8" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder if it doesn't already exist--->
		<cfset var chkfolder  = "">
		<cfquery datasource="#application.razuna.datasource#" name="chkfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = 'F'
		</cfquery>
		<!--- If only one folder with same name found then use that else create a new folder --->
		<cfif chkfolder.recordcount EQ 1>
			<cfparam name="arguments.thestruct.langcount" default="1" />
			<cfset new_folder_id = chkfolder.folder_id>
		<cfelse>
			<!--- Add the folder --->
			<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		</cfif>
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<cfobject component="global.cfc.global" name="gobj">
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#gobj.convertbytes(size)#)<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfif thefiles.recordcount LT 10>
				<cfthread intstruct="#arguments.thestruct#" action="run">
					<cfinvoke method="addassetpathfiles" thestruct="#attributes.intstruct#" />
				</cfthread>
			<cfelse>
				<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfloop>
		<!---
			<!--- Feedback --->
			<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
			<cfflush>
			<!--- Check if folder has subfolders if so add them recursively --->
			<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
			<!--- Filter out hidden dirs --->
			<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
			SELECT *
			FROM thedir
			WHERE attributes != 'H'
			</cfquery>
			<cfset arguments.thestruct.folderpath3 = arguments.thestruct.folder_path>
			<cfset arguments.thestruct.thisfolderid3 = arguments.thestruct.theid>
			<cfset arguments.thestruct.thislevel3 = arguments.thestruct.level>
			<!--- Call rec function --->
			<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
				<!--- Feedback --->
				<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
				<cfflush>
				<!--- folder_id into theid --->
				<cfset arguments.thestruct.theid = new_folder_id>
				<!--- Add directory to the folder_path --->
				<cfset arguments.thestruct.folder_path = directory & "/#name#">
				<!--- Call function --->
				<!--- <cfinvoke method="addassetpath5" thestruct="#arguments.thestruct#"> --->
			</cfif>
			<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath3>
			<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid3>
			<cfset arguments.thestruct.level = arguments.thestruct.thislevel3>
		--->
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Add assets from import path --->
<cffunction name="addassetpathfiles" output="true">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<cfset var md5hash = "">
		<cfset var md5here = "">
		<!--- Create a unique name for the temp directory to hold the file --->
		<cfset arguments.thestruct.tempid = createuuid("")>
		<!--- Get file extension --->
		<cfset var theextension = listlast("#arguments.thestruct.filename#",".")>
		<!--- Get extension --->
		<cfset var namenoext = replacenocase("#arguments.thestruct.filename#",".#theextension#","","All")>
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#arguments.thestruct.filename#">
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#namenoext#">
		<!--- Do the rename action on the file --->
		<cffile action="rename" source="#arguments.thestruct.filepath#" destination="#arguments.thestruct.thedir#/#arguments.thestruct.thefilename#">
		<!--- If the extension is longer then 9 chars --->
		<cfif len(theextension) GT 9>
			<cfset var theextension = "txt">
		</cfif>
		<!--- Store the original filename --->
		<cfset arguments.thestruct.thefilenameoriginal = arguments.thestruct.filename>
		<!--- UPC --->
		<cfset arguments.thestruct.theoriginalfilename = arguments.thestruct.thefilename >
		<cfset arguments.thestruct.folder_id = arguments.thestruct.new_folder_id>
		<!--- MD5 Hash --->
		<cfif FileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thefilename#")>
			<cfset var md5hash = hashbinary("#arguments.thestruct.thedir#/#arguments.thestruct.thefilename#")>
		</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- If duplicate record check is turned on then search through entire system else only search in folder --->
			<cfif checkformd5> 
				<cfset var checkinfolder = "" >
			<cfelse>
				<cfset var checkinfolder = arguments.thestruct.folder_id>
			</cfif>
			<!--- Check for the same MD5 hash in the existing records --->
			<!--- Put a lock around it as this in a thread and without it duplicate files are sometimes possible as the checks run simultaenously--->
 			<cflock  scope="session" type="exclusive" timeout="10">
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" checkinfolder="#checkinfolder#"/>
			</cflock>
			<!--- If file does not exist then add --->
			<cfif md5here EQ 0>
				<!--- Add to temp db --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#assets_temp
				(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, file_id, host_id, thesize, md5hash)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.new_folder_id#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thedir#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.orgsize#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
				)
				</cfquery>
				<!--- We don't need to send an email --->
				<cfset arguments.thestruct.sendemail = false>
				<!--- We set that this is from this function --->
				<cfset arguments.thestruct.importpath = true>
				<!--- Create inserts --->
				<cfinvoke method="create_inserts" tempid="#arguments.thestruct.tempid#" thestruct="#arguments.thestruct#" />
				<!--- Grab file --->
				<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
				<!--- Call the addasset function --->
				<!--- <cfthread intstruct="#arguments.thestruct#"> --->
					<cfinvoke method="addasset" thestruct="#arguments.thestruct#">
				<!--- </cfthread> --->
			<cfelse>
				<!--- Send out email if duplicate check is turned on  --->
				<cfif checkinfolder EQ "">
					<!--- RAZ-2810 Customise email message --->
					<cfset transvalues = arraynew()>
					<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
					<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
					<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
					<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#" isdup = "yes" filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
				</cfif>
			</cfif>
		<cfcatch type="any">
			<cfoutput><span style="color:red;font-weight:bold;">The file "#arguments.thestruct.filename#" could not be proccessed!</span><br />#cfcatch.detail#<br /></cfoutput>
			<!--- <cfset cfcatch.custom_message = "The file '#arguments.thestruct.filename#' could not be proccessed in function assets.addassetpathfiles!">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch,false)/> --->
		</cfcatch>
	</cftry>
</cffunction>

<!--- Check for existing MD5 mash records --->
<cffunction name="checkmd5" output="false">
	<cfargument name="md5hash" type="string">
	<cfargument name="checkinfolder" type="string" required="false" default = "" hint="check only in this folder if specified">
	<!--- Param --->
	<cfset var rec = 0>
	<!--- Images --->
	<cfinvoke component="images" method="checkmd5" md5hash="#arguments.md5hash#" checkinfolder="#arguments.checkinfolder#" returnvariable="qryimg" />
	<!--- videos --->
	<cfinvoke component="videos" method="checkmd5" md5hash="#arguments.md5hash#" checkinfolder="#arguments.checkinfolder#" returnvariable="qryvid" />
	<!--- Files --->
	<cfinvoke component="files" method="checkmd5" md5hash="#arguments.md5hash#" checkinfolder="#arguments.checkinfolder#" returnvariable="qrydoc" />
	<!--- Audios --->
	<cfinvoke component="audios" method="checkmd5" md5hash="#arguments.md5hash#" checkinfolder="#arguments.checkinfolder#" returnvariable="qryaud" />
	<!--- Put each result into var --->
	<cfset var rec = qryimg.recordcount>
	<cfif !rec>
		<cfset var rec = qryvid.recordcount>
	</cfif>
	<cfif !rec>
		<cfset var rec = qrydoc.recordcount>
	</cfif>
	<cfif !rec>
		<cfset var rec = qryaud.recordcount>
	</cfif>
	<!--- Return --->
	<cfreturn rec />
</cffunction>

<!--- Import from path for additional renditions --->
<cffunction name="add_av_from_path" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset arguments.thestruct.folder_id = arguments.thestruct.theid>
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Feedback --->
	<cfoutput>List files of this folder...<br><br></cfoutput>
	<cfflush>
	<!--- Now add all assets of this folder --->
	<cftry>
		<cfdirectory action="list" directory="#arguments.thestruct.folder_path#" name="thefiles" type="file" />
		<cfcatch type="any">
			<cfoutput>
				<h2 style="color:red;">Oops, an error occured. Please make sure Razuna is able to read from your path!</h2>
				<p>Details: #cfcatch.detail#</p>
				<p>#cfcatch.message#</p>
			</cfoutput>
			<cfset cfcatch.custom_message = "Error in function assets.add_av_from_path">	
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			<cfflush>
			<cfabort>
		</cfcatch>
	</cftry>
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thefiles">
	SELECT *
	FROM thefiles
	WHERE attributes != 'H'
	</cfquery>
	<!--- Feedback --->
	<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
	<cfflush>
	<!--- Loop over the assets --->
	<cfloop query="thefiles">
		<!--- Feedback --->
		<cfoutput>#currentRow#. Adding: #listlast(name,FileSeparator())# (#size#KB)<br></cfoutput>
		<cfflush>
		<!--- Params --->
		<cfset arguments.thestruct.frompath = true>
		<cfset arguments.thestruct.filepath = directory & "/" & name>
		<cfset arguments.thestruct.thedir = directory>
		<cfset arguments.thestruct.thefilename = listlast(name,FileSeparator())>
		<cfset arguments.thestruct.thesize = size>
		<cfset arguments.thestruct.theextension = listLast(name,".")>
		<!--- Now add the asset --->
		<cfif thefiles.recordcount LT 10>
			<cfthread name="uploadpath#currentrow#" intstruct="#arguments.thestruct#" action="run">
				<cfinvoke method="addassetav" thestruct="#attributes.intstruct#" />
			</cfthread>
			<!--- Wait for the parsing --->
			<cfthread action="join" name="uploadpath#currentrow#" />
		<cfelse>
			<cfinvoke method="addassetav" thestruct="#arguments.thestruct#" />
		</cfif>
	</cfloop>
	<!--- Feedback --->
	<cfoutput><span style="color:green;font-weight:bold;">Successfully added the asset(s)!</span><br><br></cfoutput>
	<cfflush>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Run Workflow --->
<cffunction name="run_workflow" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<cfargument name="workflow_event" type="string">
	<!--- Check if we need to skip the on_pre_process event --->
	<cfif listFind(arguments.thestruct.skip_event, arguments.workflow_event) EQ 0>
		<!--- Call the on_pre_process workflow --->
		<cfset arguments.thestruct.folder_action = true>
		<!--- Check on any plugin that call the on_pre_process action --->
		<cfinvoke component="plugins" method="getactions" theaction="#arguments.workflow_event#" args="#arguments.thestruct#" returnvariable="return_pre_process" />
		<!--- Evaluate the return from the plugin call above --->
		<cfif structKeyExists(return_pre_process,"pcfc")>
			<cfloop list="#return_pre_process.pcfc#" delimiters="," index="i">
				<cfset var er = evaluate("return_pre_process." & i & ".rename_file_return")>
				<cfset arguments.thestruct.thejsonbody = er.jsonbody>
				<cfif er.thefilename NEQ "">
					<cfset arguments.thestruct.thefilename = er.thefilename>
				</cfif>
				<cfif er.thefilenamenoext NEQ "">
					<cfset arguments.thestruct.theoriginalfilename = er.thefilenamenoext>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>
<!--- RAZ - 2907 EXTRACT A COMPRESSED FILE (ZIP) for version bulk upload--->
<cffunction name="extractFrom_versions_Zip" output="true" access="private">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<!--- Remove the ZIP file from the files DB. This is being created on normal file upload and is not needed --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#files
		WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
		</cfquery>
		<!--- Params --->
		<cfparam default="0" name="arguments.thestruct.upl_template">
		<cfset var thetemp = Createuuid("")>
		<!--- Extract ZIP --->
		<cfset var tzip = "zip" & thetemp>
		<cfthread name="#tzip#" intstruct="#arguments.thestruct#" action="run">
			<cfzip action="extract" zipfile="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#" destination="#attributes.intstruct.qryfile.path#" charset="utf-8">
		</cfthread>
		<cfthread action="join" name="#tzip#" />
		<!--- Get folder level of the folder we are in to create new folder --->
		<cfquery datasource="#application.razuna.datasource#" name="folders">
		SELECT folder_level, folder_main_id_r, folder_id_r
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- set root folder id to keep top folder during creating folder out of zip archive --->
		<cfset var rootfolderId = arguments.thestruct.qryfile.folder_id>
		<cfset var folderIdr = arguments.thestruct.qryfile.folder_id>
		<cfset var folderId = arguments.thestruct.qryfile.folder_id>
		<!---<cfset var folderlevel = folders.folder_level>--->
		<cfset var loopname = "">
		<!--- Loop over the zip directories and rename them if needed --->
		<cfset var ttf = "rec" & thetemp>
		<!--- <cfthread name="#ttf#" intstruct="#arguments.thestruct#"> --->
			<cfinvoke method="rec_renamefolders" thedirectory="#arguments.thestruct.qryfile.path#" />
		<!--- </cfthread> --->
		<!--- <cfthread action="join" name="#ttf#" /> --->
		<!--- Get directory again since the directory names could have changed from above --->
		<cfdirectory action="list" directory="#arguments.thestruct.qryfile.path#" name="thedir" recurse="true" type="dir">
		<!--- Sort the above list in a query because cfdirectory sorting sucks --->
		<cfquery dbtype="query" name="thedir">
		SELECT *
		FROM thedir
		WHERE name NOT LIKE '__MACOSX%'
		AND name NOT LIKE '.zip%'
		ORDER BY name
		</cfquery>
		<!--- Get folders within the unzip RECURSIVE --->
		<cfdirectory action="list" directory="#arguments.thestruct.qryfile.path#" name="thedirfiles" recurse="true" type="file">
		<!--- Sort the above list in a query because cfdirectory sorting sucks --->
		<cfquery dbtype="query" name="thedirfiles">
		SELECT *
		FROM thedirfiles
		WHERE size != 0
		AND attributes != 'H'
		AND name != 'thumbs.db'
		AND name NOT LIKE '.DS_STORE%'
		AND name NOT LIKE '__MACOSX%'
		AND name NOT LIKE '%.zip%'
		ORDER BY name
		</cfquery>
		<!--- Create Directories --->
		<cfloop query="thedir">
			<cfset temp="">
			<cfset var folderlevel = "">
			<!--- Check how long the folder list is --->
			<cfset var namelistlen = listlen(name,FileSeparator())>
			<!--- If longer then 1 we need to get the folder_id_r of the previous folder --->
			<cfif namelistlen GT 1>
				<!--- Get the list entry at one higher then the current len --->
				<cfset var lenminusone = namelistlen - 1>
				<cfset var fnameforqry = ListGetAt(name, lenminusone, FileSeparator())>
				<!--- Query to get the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#" name="qryfidr">
				SELECT folder_id
				FROM #session.hostdbprefix#folders
				WHERE lower(folder_name) = <cfqueryparam value="#lcase(fnameforqry)#" cfsqltype="cf_sql_varchar">
				AND folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
				AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfset var thedirlen = listLen(thedir.name, FileSeparator())-1>
				<cfset temp = rootfolderId>
				<cfloop index="i" from=1 to="#thedirlen#">
					<cfset folder_name = listGetAt(thedir.name, i, FileSeparator())>
					<cfquery name="qryGetFolderDetails" datasource="#application.razuna.datasource#">
					SELECT folder_id, folder_name, folder_level, folder_id_r
					FROM #session.hostdbprefix#folders 
					WHERE lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(folder_name)#">
					AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#temp#">
					AND folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<cfset temp= qryGetFolderDetails.folder_id >
				</cfloop>
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#qryfidr.folder_id#" returnvariable="crumbs" />
				<cfset var folderlevel = listlen(crumbs,";") + 1>
				<!--- Set the folder_id_r in var --->
				<!---<cfset var fidr = qryfidr.folder_id>--->
				<cfset var fidr = temp>
				<cfset var fname = listlast(name, FileSeparator())>
			<cfelse>
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#folders.folder_id_r#" returnvariable="crumbs" />
				<cfset var folderlevel = listlen(crumbs,";") + 1>
				<cfset var fname = name>
				<cfset var fidr = folderIdr>
			</cfif>			
			
		</cfloop>
		<cfset resetcachetoken("folders")>
		<cfset sleep(2000)>
		<!--- Loop over ZIP-filelist to process with the extracted files with check for the file since we got errors --->
		<cfloop query="thedirfiles">
			<cfif fileexists("#directory#/#name#") >
				<cfset var temp="">
				<cfset var md5hash = "">
				<!--- Set Original FileName --->
				<cfset arguments.thestruct.theoriginalfilename = listlast(name,FileSeparator())>
				<cfset arguments.thestruct.thepathtoname = replacenocase(name,arguments.thestruct.theoriginalfilename,"","one")>
				<!--- Rename the file so that we can remove any spaces --->
				<cfinvoke component="global" method="convertname" returnvariable="newFileName" thename="#arguments.thestruct.theoriginalfilename#">
				<cffile action="rename" source="#directory#/#name#" destination="#directory#/#arguments.thestruct.thepathtoname#/#newFileName#">
				<!--- Detect file extension --->
				<cfinvoke method="getFileExtension" theFileName="#newFileName#" returnvariable="fileNameExt">
				<cfset var file = structnew()>
				<cfset file.fileSize = size>
				<cfset file.oldFileSize = size>
				<cfset file.dateLastAccessed = dateLastModified>
				<!--- Get and set file type and MIME content --->
				<cfquery datasource="#application.razuna.datasource#" name="fileType">
				SELECT type_type, type_mimecontent, type_mimesubcontent
				FROM file_types
				WHERE lower(type_id) = <cfqueryparam value="#lcase(fileNameExt.theext)#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- set attributes of file structure --->
				<cfif #fileType.recordCount# GT 0>
					<cfset arguments.thestruct.thefiletype = fileType.type_type>
				<cfelse>
					<cfset arguments.thestruct.thefiletype = "other">
				</cfif>
				<cfset arguments.thestruct.tempid = createuuid("")>
				<cfset arguments.thestruct.thefilename = newFileName>
				<cfset arguments.thestruct.thefolder_name = "asset#arguments.thestruct.tempid#">
				<cfset arguments.thestruct.thefilenamenoext = replacenocase("#newFileName#", ".#fileNameExt.theext#", "", "ALL")>
				<cfset arguments.thestruct.theincomingtemptomovepath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thefolder_name#">
				<cfset arguments.thestruct.theincomingtemppath = "#directory#/#arguments.thestruct.thepathtoname#">
				<!--- Create a temp directory to hold the file --->
				<cfif !DirectoryExists(arguments.thestruct.theincomingtemptomovepath)>
					<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemptomovepath#" mode="775">
				</cfif>
				<!--- Copy the file into the temp dir --->
				<cfif !FileExists("#arguments.thestruct.theincomingtemptomovepath#/#arguments.thestruct.thefilename#")>
					<cffile action="copy" source="#directory#/#arguments.thestruct.thepathtoname#/#newFileName#" destination="#arguments.thestruct.theincomingtemptomovepath#/#arguments.thestruct.thefilename#" mode="775">
				</cfif>
				<!--- MD5 Hash --->
				<cfif FileExists("#directory#/#arguments.thestruct.thepathtoname#/#newfilename#")>
					<cfset var md5hash = hashbinary("#directory#/#arguments.thestruct.thepathtoname#/#newfilename#")>
				</cfif>
				<!--- Check if we have to check for md5 records --->
				<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
				<!--- Check for the same MD5 hash in the existing records --->
				<cfif checkformd5>
					<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
				<cfelse>
					<cfset var md5here = 0>
				</cfif>
				<!--- If file does not exsist continue else send user an eMail --->
				<cfif md5here EQ 0>
					<!--- Check for the name which now contains the directory --->
					<cfset var thedirlen = listLen(name, FileSeparator()) - 1>
					<!--- If the above return 0 --->
					<cfif thedirlen EQ 0>
						<cfset var thedirlen = 1>
					</cfif>
					<!--- Get the directory name at the exact position in the list --->
					<cfset var thedirname = listGetAt(name, thedirlen, FileSeparator())>
					<!--- Get folder id with the name of the folder --->
					<cfquery datasource="#application.razuna.datasource#" name="qryfolderidmain">
					SELECT f.folder_id, f.folder_name,
					CASE
						WHEN EXISTS(
							SELECT s.folder_id
							FROM #session.hostdbprefix#folders s
							WHERE s.folder_id = f.folder_id_r
							AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						) THEN 1
						ELSE 0
					END AS ISHERE
					FROM #session.hostdbprefix#folders f
					WHERE lower(f.folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thedirname)#">
					AND f.folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
					<!---
					AND f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#rootfolderId#">
					--->
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND f.in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Subselect --->
					<cfquery dbtype="query" name="qryfolderid">
					SELECT *
					FROM qryfolderidmain
					WHERE ishere = 1
					</cfquery>
					
					<cfset temp = rootfolderId>
					<cfloop index="i" from=1 to="#thedirlen#">
						<cfset folder_name = listGetAt(thedirfiles.name, i, FileSeparator())>
						<cfquery name="qryGetFolderDetails" datasource="#application.razuna.datasource#">
						SELECT folder_id, folder_name 
						FROM #session.hostdbprefix#folders 
						WHERE lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(folder_name)#">
						AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#temp#">
						AND folder_main_id_r = <cfqueryparam value="#folders.folder_main_id_r#" cfsqltype="cf_sql_varchar">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
						</cfquery>
						<cfset temp = qryGetFolderDetails.folder_id>
					</cfloop>

					<!--- Put folder id into the general struct --->
					<cfif isDefined('temp') AND temp NEQ ''>
						<cfset arguments.thestruct.theid = temp>
					<cfelse>
						<cfset arguments.thestruct.theid = rootfolderId>
						<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.theincomingtemppath#">
						<!--- <cfset arguments.thestruct.fidr = 0> --->
					</cfif>
					
					<!--- Add to temp db --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#assets_temp
					(tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,thesize,file_id,host_id,md5hash)
					VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#fileNameExt.theext#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.theid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemptomovepath#">,
					<cfif isnumeric(file.fileSize)>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#file.fileSize#">,
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="0">,
					</cfif>
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
					)
					</cfquery>
					<!--- Return IDs in a variable --->
					<!--- <cfset thetempids = arguments.thestruct.tempid & "," & thetempids> --->
					<!--- For each file we need query for the file --->
					<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qryfile">
					SELECT 
					tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, mimetype,
					thesize, groupid, sched_id, sched_action, file_id, link_kind, md5hash
					FROM #session.hostdbprefix#assets_temp
					WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Now start the file mumbo jumbo --->
					<cfif fileType.type_type EQ "img">
						<!--- IMAGE UPLOAD (call method to process a img-file) --->
						<cfinvoke method="processImgFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "img">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
							<cfset arguments.thestruct.upltemptype = "img">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelseif fileType.type_type EQ "vid">
						<!--- VIDEO UPLOAD (call method to process a vid-file) --->
						<cfinvoke method="processVidFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "vid">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
							<cfset arguments.thestruct.upltemptype = "vid">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelseif fileType.type_type EQ "aud">
						<!--- AUDIO UPLOAD (call method to process a vid-file) --->
						<cfinvoke method="processAudFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "aud">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined" AND returnid NEQ "">
							<cfset arguments.thestruct.upltemptype = "aud">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelse>
						<!--- DOCUMENT UPLOAD (call method to process a doc-file) --->
						<cfinvoke method="processDocFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<cfset arguments.thestruct.thefiletype = "doc">
					</cfif>
				<cfelse>
					<!--- RAZ-2810 Customise email message --->
					<cfset transvalues = arraynew()>
					<cfset transvalues[1] = "#arguments.thestruct.thefilename#">
					<cfinvoke component="defaults" method="trans" transid="file_already_exist_subject" values="#transvalues#" returnvariable="file_already_exist_sub" />
					<cfinvoke component="defaults" method="trans" transid="file_already_exist_message" values="#transvalues#" returnvariable="file_already_exist_msg" />
					<cfinvoke component="email" method="send_email" subject="#file_already_exist_sub#" themessage="#file_already_exist_msg#"  isdup = "yes" filename="#arguments.thestruct.thefilename#" md5hash="#md5hash#">
				</cfif>
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function assets.extractFromZip">
			<cfset cfcatch.thestruct = arguments.thestruct>
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- UPC upload --->
<cffunction name="assetuploadupc" output="true" >
	<cfargument name="thestruct" type="struct" required="true" >
	<cfargument name="assetfrom" type="string" required="true" >
	<!--- param --->
	<cfparam name="arguments.thestruct.upc_name" default="" >
	<cfparam name="arguments.thestruct.theoriginalfilename" default="" >
	<!--- Get settings dam details --->
	<cfinvoke component="settings" method="getsettingsfromdam" returnvariable="prefs">
	<!--- Get current user UPC Details  --->
	<cfinvoke component="groups_users" method="getGroupsOfUser" returnvariable="arguments.thestruct.qry_GroupsOfUser" >
		<cfinvokeargument name="user_id" value="#session.theuserid#">
		<cfinvokeargument name="host_id" value="#session.hostid#">
		<cfinvokeargument name="check_upc_size" value="true">
	</cfinvoke>
	<!--- Check the current folder having label text as upc --->
	<cfinvoke component="labels" method="getlabels" theid="#arguments.thestruct.folder_id#" thetype="folder" checkUPC="true" returnvariable="arguments.thestruct.qry_labels">
	<!--- Check if last char is alphabet --->
	<cfset var fn_first = listfirst(arguments.thestruct.theoriginalfilename,".")>
	<cfset var fn_last_char = right(fn_first,1)> 
	<cfif refindnocase('[a-z]',fn_last_char)>
		<cfset var fn_ischar = true>
	<cfelse>
		<cfset fn_ischar = false>
	</cfif>
	<!--- Put in arguments scope so it can be passed to parent methods --->
	<cfset arguments.thestruct.fn_ischar = fn_ischar>
	<cfif fn_ischar>
		<cfset var fn_first_1 = left(fn_first,len(fn_first)-1) > <!--- remove last char from filename --->
	<cfelse>
		<cfset var fn_first_1 = fn_first >
	</cfif>
	<!--- Check the UPC option is enabled --->
	<cfif prefs.set2_upc_enabled AND listLen(arguments.thestruct.theoriginalfilename,".") EQ 3 AND isNumeric(fn_first_1) AND isNumeric(listgetat(arguments.thestruct.theoriginalfilename,2,'.')) AND arguments.thestruct.qry_GroupsOfUser.recordcount AND arguments.thestruct.qry_labels NEQ ''>
		<cfset arguments.thestruct.checkUFName=listDeleteAt(arguments.thestruct.theoriginalfilename,listLen(arguments.thestruct.theoriginalfilename,"."),".")>
		<cfif Find(".", '#arguments.thestruct.checkUFName#') NEQ 0 >
			<cfset arguments.thestruct.checkURNum = listlast('#arguments.thestruct.checkUFName#','.')>
			<cfif isNumeric(arguments.thestruct.checkURNum)>
				<cfset arguments.thestruct.upcFileName = arguments.thestruct.checkUFName >
				<!--- Remove character if present before grabbing UPC --->
				<cfif fn_ischar>
					<cfset arguments.thestruct.dl_query.upc_number = listfirst('#replace(arguments.thestruct.upcFileName,fn_last_char,"","ONE")#','.') >
				<cfelse>
					<cfset arguments.thestruct.dl_query.upc_number = listfirst('#arguments.thestruct.upcFileName#','.') >
				</cfif>
				<cfset arguments.thestruct.upcRenditionNum = arguments.thestruct.checkURNum >
			</cfif>
		</cfif> 
		<cfif structKeyExists(arguments.thestruct,'upcRenditionNum') AND (arguments.thestruct.upcRenditionNum NEQ 1 OR fn_ischar)>
			<cfif arguments.assetfrom EQ 'img'>
				<cfset field_name = 'img_id'>
				<cfset table_name = '#session.hostdbprefix#images'>
				<cfset check_field_name = 'img_upc_number'>
			<cfelseif arguments.assetfrom EQ 'aud'>
				<cfset field_name = 'aud_id'>
				<cfset table_name = '#session.hostdbprefix#audios'>
				<cfset check_field_name = 'aud_upc_number'>
			<cfelseif arguments.assetfrom EQ 'vid'>
				<cfset field_name = 'vid_id'>
				<cfset table_name = '#session.hostdbprefix#videos'>
				<cfset check_field_name = 'vid_upc_number'>
			</cfif>
			<!--- Get original asset to which this rendition will be associated --->
			<cfquery name="arguments.thestruct.qryGroupDetails" datasource="#application.razuna.datasource#">
				SELECT #field_name# as id
				FROM #table_name# 
				WHERE #check_field_name# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.dl_query.upc_number#">
				AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfinvoke component="folders" method="Extract_UPC" returnvariable="extract_upcnumber">
				<cfinvokeargument name="thestruct" value="#arguments.thestruct#" />
				<cfinvokeargument name="sUPC" value="#arguments.thestruct.dl_query.upc_number#">
				<cfinvokeargument name="iUPC_Option" value="#arguments.thestruct.qry_GroupsOfUser.upc_size#">
			</cfinvoke>
			<cfinvoke component="folders" method="Find_Manuf_String" returnvariable="arguments.thestruct.folder_name">
				<cfinvokeargument name="strManuf_UPC" value="#extract_upcnumber#">
			</cfinvoke>
			<cfinvoke component="folders" method="Find_Prod_String" returnvariable="arguments.thestruct.upc_name">
				<cfinvokeargument name="strManuf_UPC" value="#extract_upcnumber#">
			</cfinvoke>
			<cfif fn_ischar>
				<cfset arguments.thestruct.upc_name = '#arguments.thestruct.upc_name##fn_last_char#.#arguments.thestruct.upcRenditionNum#'>
			<cfelse>
				<cfset arguments.thestruct.upc_name = '#arguments.thestruct.upc_name#.#arguments.thestruct.upcRenditionNum#'>
			</cfif>
		<cfelse>
			<cfset arguments.thestruct.qryGroupDetails = queryNew('id')>
			<cfset arguments.thestruct.upc_name = arguments.thestruct.upcFileName>
		</cfif>
	</cfif>
	<!--- return --->
	<cfreturn arguments.thestruct.upc_name />
</cffunction>

<!--- Get all asset from folder --->
<cffunction name="swap_rendition_original" output="false" returntype="void" hint="swaps an additional rendition for the original">
	<cfargument name="thestruct" type="struct">

	<!--- Move reset cache to top. It looks like at times it doesn't trigger properly when at bottom --->
	<cfset resetcachetoken('files')>
	<cfset resetcachetoken('folders')>
	<cfset resetcachetoken('general')>

	<!--- Get information for additional rendition  --->
	<cfquery name="avinfo" datasource="#application.razuna.datasource#">
		SELECT av_id, asset_id_r, folder_id_r, av_type, av_link_title, av_link_url, av_link, thesize, thewidth, theheight, hashtag, av_thumb_url
		FROM #session.hostdbprefix#additional_versions
		WHERE av_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Get information for original asset  --->
	<cfset field_id = 'file_id'>
	<cfset table_name = '#session.hostdbprefix#files'>
	<cfset col_names = 'file_id as assetid, folder_id_r,file_type as type, file_name as filename,file_extension as ext, file_name_noext as filename_noext, file_name_org as filename_org, file_size as size, path_to_asset, cloud_url,cloud_url_org, hashtag'>
	<cfquery name="assetinfo" datasource="#application.razuna.datasource#">
		SELECT #col_names#
		FROM #table_name#
		WHERE #field_id# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#avinfo.asset_id_r#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Swap assets in the tables --->
	<cfquery name="avinfo_del" datasource="#application.razuna.datasource#">
		DELETE
		FROM #session.hostdbprefix#additional_versions
		WHERE av_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Update av info with original asset info --->
	<cfif application.razuna.storage EQ 'amazon'>
		<cfset var link_url = '#assetinfo.cloud_url_org#'>
		<cfset var path2asset =  '#avinfo.folder_id_r & '/doc/'  & avinfo.av_id#'>
		<cfset var cloud_url_org  = avinfo.av_link_url>
	<cfelse>
		<cfset var link_url = '/#assetinfo.path_to_asset#/#assetinfo.filename_org#'>
		<!--- repalce any trailing or leading slashes alogn with taking of the filename from path  --->
		<cfset var path2asset =  '#rereplace(rereplace(replacenocase(avinfo.av_link_url,listlast(avinfo.av_link_url,'/'),''),'^/',''),'/$','')#'>
		<cfset var cloud_url_org = ''>
	</cfif>
	<cfquery name="assetinfo_insert_av" datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#additional_versions (av_id, asset_id_r, folder_id_r, av_type, av_link_title, av_link_url, thesize, hashtag,host_id, av_link)
		VALUES('#avinfo.av_id#','#assetinfo.assetid#','#assetinfo.folder_id_r#','#assetinfo.type#','#assetinfo.filename_org#','#link_url#','#assetinfo.size#','#assetinfo.hashtag#','#session.hostid#','0')
	</cfquery>
	<!--- Update original asset info with av info --->
	<cfquery name="avinfo_asset_update" datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#files
		SET 
		file_type = '#avinfo.av_type#',
		file_name = '#listfirst(listlast(avinfo.av_link_url,'/'),'?')#',
		file_extension = '#listlast(listfirst(listlast(avinfo.av_link_url,'/'),'?'),'.')#',
		file_name_org =   '#listfirst(listlast(avinfo.av_link_url,'/'),'?')#',
		file_name_noext = '#replacenocase(listfirst(listlast(avinfo.av_link_url,'/'),'?'), '.' & listlast(listfirst(listlast(avinfo.av_link_url,'/'),'?'),'.'),'')#',
		file_size = '#avinfo.thesize#',
		path_to_asset = '#path2asset#',
		cloud_url_org = '#cloud_url_org#',
		hashtag = '#avinfo.hashtag#'
		WHERE 
		#field_id# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#avinfo.asset_id_r#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Update renditions with proper id --->
	<cfquery name="avinfo_update_rends" datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#additional_versions
		SET asset_id_r = '#assetinfo.assetid#'
		WHERE 
		asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#avinfo.asset_id_r#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>

	<!--- Flush cache again --->
	<cfset resetcachetoken('files')>
	<cfset resetcachetoken('folders')>
	<cfset resetcachetoken('general')>

</cffunction>
 
</cfcomponent>
