<!--- open this file in a web browser to run the tests   --->

	<!--- <cfset testsuite = new mxunit.framework.TestSuite() />
	--->
	<cfset testsuite = createObject("component", "mxunit.framework.TestSuite") />
	
<cfsetting requesttimeout="0">

	<cfscript>
	
	application.razuna.api.akatoken = "";
	application.razuna.api.awskey	= "";
	application.razuna.api.awskeysecret	= "";
	application.razuna.api.awslocation	= "";
	application.razuna.api.dsn	= "razuna_testsuite";
	application.razuna.api.dynpath	= "/razuna";
	application.razuna.api.isp	= "false";
	application.razuna.api.lucene	= "global.cfc.lucene";
	application.razuna.api.nvxappkey	= "";
	application.razuna.api.nvxurlservices	= "http://services.nirvanix.com";
	application.razuna.api.rfs	= "FALSE";
	application.razuna.api.setid	= 1;
	application.razuna.api.storage	= "local";
	application.razuna.api.thedatabase	= "mysql";
	application.razuna.api.thehttp	= "http://";
	application.razuna.api.theurl	= "http://localhost:8080/assets/";
	application.razuna.api.thispath	= "D:\projects\razuna_openBD\webapps\razuna\global\api2";
	
	application.razuna.theschema = "razuna_testsuite";
	dbStruct.dsn = "razuna_testsuite";
	dbStruct.host_db_prefix = "raz1_";
	dbStruct.theschema = "razuna_testsuite";
	//dbStruct.fromimport = 1;


	mysqlCFC = createObject("component", "global.cfc.db_mysql");

	session.firsttime.database = "razuna_testsuite";
	session.firsttime.db_schema = "razuna_testsuite";



	temp = mysqlCFC.clearall();
	temp = mysqlCFC.setup(dbStruct);
	temp = mysqlCFC.create_host(dbStruct);
	
	// Create some sample data for the unit testing
	mysqlDataCFC = createObject("component", "db_mysql_data");
	temp = mysqlDataCFC.insertDummyData(dbStruct);

</cfscript>

	<cfdirectory action="list" directory="#getDirectoryFromPath( getCurrentTemplatePath() )#api2" name="tests" recurse="true" filter="*.cfc">
	
	<cfloop query="tests">
		<cfset filepath = Replace( Right( directory, Len( directory ) - FindNoCase( "tests", directory ) - 5 ), "\", ".", "all" ) />
		
		
		
		<cfset testSuite.addAll( "_tests." & filepath & "." & Replace( name, ".cfc", "" ) ) />
	</cfloop>
	
	
	<cfset results = testsuite.run() />
	
	<cfoutput>#ReplaceNoCase( results.getResultsOutput( "html" ), "/api2", "api2", "ALL" )#</cfoutput>

	
	
	<div class="bodypad">
		<!---<cfdump var="#results.getResults()#" label="Debug">--->
	</div>

<cfscript>
	// Flush the test suite DB 
	//temp = mysqlCFC.clearall();

</cfscript>	
