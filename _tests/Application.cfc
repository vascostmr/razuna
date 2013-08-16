component{

	this.applicationroot = ReReplace( getDirectoryFromPath( getCurrentTemplatePath() ), "_tests.$", "", "all" );
	this.name = ReReplace( "[^W]", this.applicationroot & "_tests", "", "all" );
	this.sessionmanagement = true;
	
	/* 
	this.mappings[ "/CFSelenium" ] = this.applicationroot & "CFSelenium\"; 
	*/
	//this.mappings[ "/mxunit" ] = this.applicationroot & "mxunit/";
	this.mappings[ "/api2" ] = this.applicationroot & "_tests/api2/";
	
	//writeDump(this.mappings);abort;
	
}