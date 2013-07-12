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
<cfsavecontent variable="razunablogcache" >
<cfoutput>
<!--- Fetch the Razuna Blog Feed --->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<cfif arrayisempty(blogss)>
		<tr>
			<td>Connection to blog.razuna.com is currently not available</td>
		</tr>
	<cfelse>
		<cfloop index="x" from="1" to="#arrayLen(blogss)#">
			<tr>
				<td><a href="#blogss[x].link#" target="_blank">#blogss[x].title#</a></td>
			</tr>
		</cfloop>
	</cfif>
</table>
</cfoutput>
</cfsavecontent>
<!--- Save the results in the Application scope. --->
<cflock scope="Application" type="Exclusive" timeout=30>
    <cfset Application.razunablogcache = razunablogcache>
</cflock>

<!--- Use the Application scope variable to display the sale items. --->
<cflock scope="Application" timeout="20" type="readonly">
    <cfoutput>#Application.razunablogcache#</cfoutput>
</cflock>