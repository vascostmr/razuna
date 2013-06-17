<cfcomponent>
	<!--- Datasource Get config --->
	<cffunction name="getConfig" output="false" returntype="struct" hint="Returns a struct representation of the OpenBD server configuration (bluedragon.xml)">
		<cfset var admin = "" />
			<cflock scope="Server" type="readonly" timeout="5">
				<cfset admin = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").getConfig().getCFMLData() />
			</cflock>
		<cfreturn admin.server />
	</cffunction>
	
	<!--- Datasource Set config --->
	<cffunction name="setConfig" output="false"  >
		 <cfargument name="admin" type="struct" required="true" />
		 	<cfset xmlConfig = createObject("java", "com.naryx.tagfusion.xmlConfig.xmlCFML").init(arguments.admin) />
			<cfset success = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").writeXmlFile(xmlConfig) />
	</cffunction>
</cfcomponent>