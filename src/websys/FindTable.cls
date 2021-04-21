Class FindTable Extends %CSP.Page{

// Parameter CSPURL = "/dthealth/web/csp/websys.Broker.cls";
Parameter CHARSET = "utf-8";
ClassMethod OnPage() As %Status
{
    Write "<body>hello</body>"
	Quit $$$OK
}
ClassMethod OnPreHTTP() As %Boolean
{
 	Quit $$$OK
}
}