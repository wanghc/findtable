/// author: wanghc
/// date: 2011-09-23
/// desc: 写query的时候不用去写四个方法了,用类代码生成来实现编译时生成Excute,fetch,Close
Class dhc.websys.Query Extends %Query [ Not ProcedureBlock ]
{

ClassMethod Close(ByRef qHandle As %Binary) As %Status [ CodeMode = generator, PlaceAfter = Execute, ProcedureBlock = 1, ServerOnly = 1 ]
{
		$$$GENERATE(" Set repid=$LIST(qHandle,2)")
 		$$$GENERATE(" Kill ^CacheTemp(repid)")
 		$$$GENERATE(" QUIT $$$OK")
		Quit $$$OK
}

ClassMethod Execute(ByRef qHandle As %Binary) As %Status [ CodeMode = generator, ProcedureBlock = 1, ServerOnly = 1 ]
{
		Set %code=0
		#; don't generate any code if it not for a query
		If %mode="method" Quit $$$OK
		#; %mode is "propertymethod" for a valid query. We don't have any way currently to detect a misuse of a query class
		If '$$$comMemberDefined(%class,$$$cCLASSquery,%property) Quit $$$OK
		#; Reset the formal list to the query declaration:
		#; write inputArgs
		$$$comSubMemberKeyGetLvar(formal,%class,$$$cCLASSquery,%property,$$$cQUERYmethod,%method,$$$cMETHformalspecparsed)
		$$$comMemberKeyGetLvar(qformal,%class,$$$cCLASSquery,%property,$$$cQUERYformalspecparsed)
		$$$comSubMemberKeySet(%class,$$$cCLASSquery,%property,$$$cQUERYmethod,%method,$$$cMETHformalspecparsed,formal_qformal)
		Set sc=$$SetOneQueryMeth^%occQuery(%class,%property,%method) Quit:$$$ISERR(sc) sc

		#; Initialize qHandle...
		$$$GENERATE(" Set repid=$I(^CacheTemp)")
		$$$GENERATE(" If $g(ind)="""" Set ind=1")
		#; copy code to Excute
		$$$comMemberKeyGetLvar(query,%class,$$$cCLASSquery,%property,$$$cQUERYsqlquery)
		Set qline=0
		For i=1:1:$LENGTH(query,$$$NL) Set line=$PIECE(query,$$$NL,i) If line'="" Set qline=qline+1,qline(qline)=line
		For i=1:1:qline-1 $$$GENERATE($CHAR(9,9)_qline(i))
		If qline {
			$$$GENERATE($CHAR(9,9)_qline(qline))
		}
		$$$GENERATE(" Set qHandle=$lb(0,repid,0)")
		$$$GENERATE(" QUIT $$$OK")
		Quit $$$OK
}

ClassMethod Fetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ CodeMode = generator, PlaceAfter = Execute, ProcedureBlock = 1, ServerOnly = 1 ]
{
		$$$GENERATE(" Set AtEnd=$LIST(qHandle,1)")
		$$$GENERATE(" Set repid=$LIST(qHandle,2)")
		$$$GENERATE(" Set ind=$LIST(qHandle,3)")
		$$$GENERATE(" Set ind=$o(^CacheTemp(repid,ind))")
		$$$GENERATE(" If ind="""" { // if there are no more rows, finish fetching")
		$$$GENERATE(" Set AtEnd=1")
		$$$GENERATE(" Set Row=""""")
		$$$GENERATE(" }Else{ // fetch row")
		$$$GENERATE(" Set Row=^CacheTemp(repid,ind)")
		$$$GENERATE(" }")
		$$$GENERATE(" s qHandle=$lb(AtEnd,repid,ind)")
		$$$GENERATE(" QUIT $$$OK")
		Quit $$$OK
}

}
