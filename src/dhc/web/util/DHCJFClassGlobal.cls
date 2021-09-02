/// author:wanghc
/// date:  2009-11-12
/// desc:  查询表的各属性
Class dhc.web.util.DHCJFClassGlobal Extends %RegisteredObject [ Not ProcedureBlock ]
{
ClassMethod Init() As %Status
{
	new $namespace
	set $namespace="%SYS"
	set Status=##Class(Config.Startup).Get(.Properties)
	set Url=":52773/web-inf/findglobal.csp"
	if Status set Url=":"_$g(Properties("WebServerPort"),52773)_"/web-inf/findglobal.csp" 
	write !!,"load in browser http://"_$zconvert($zu(110),"L")_Url,!
	quit $$$OK
}
ClassMethod GetUserRowid(packageName, className)
{
	New (className,packageName)
	Set name="ID"
	Quit:'##class(%Dictionary.ClassDefinition).%ExistsId(packageName_"."_className) name
	Set dsd = ##class(%Dictionary.ClassDefinition).%OpenId(packageName_"."_className,0)
	If dsd.ClassType="persistent" {
		If (dsd.SqlRowIdName'=""){
			Set name = dsd.SqlRowIdName		
		}Else{
			If ((dsd.Storages)&&(dsd.Storages.Count()>0) && (dsd.Storages.GetAt(1).SqlRowIdName'="")){
				Set name=dsd.Storages.GetAt(1).SqlRowIdName
			}
		}
	}
	Do dsd.%Close()
	Set dsd=""
	Quit name
}

/// @param: class All Name   websys.menu, PA_Adm
/// @return: 表名!包名!类名!主索引名
/// User包下的实体类可以省略User
/// w ##class(web.Util.DHCJFClassGlobal).GetTableInfo("SQLUSER.CT_PAYMODE")
/// w ##class(web.Util.DHCJFClassGlobal).GetTableInfo("SQLUser.DHC_MedAdvRepNotes")
ClassMethod GetTableInfo(SchemaTable)
{
	New (SchemaTable)
	If ($LENGTH(SchemaTable,".")>1){
		Set Schema = $PIECE(SchemaTable,".")
		Set Table = $PIECE(SchemaTable,".",2)
	}Else{
		Set Schema = $SYSTEM.SQL.DefaultSchema()		
		Set Table = SchemaTable
	}
	Do ..RegulateTable(.Schema,.Table,.classAllName)
	If $GET(classAllName)'=""{
		Set className = $PIECE(classAllName,".",$LENGTH(classAllName,"."))
		Set packageName = $PIECE(classAllName,".",1,$LENGTH(classAllName,".")-1)
		Set dataMasterName=""
		Set rs = ##class(%ResultSet).%New("web.Util.DHCJFClassGlobal:SelectMaster")	
		Do rs.Execute(packageName,className)
		While rs.Next(){
			If (rs.Get("type")="data"){
				Set dataMasterName = rs.Get("indexMasterData")			
			}
		}	
		Quit Schema_"."_Table_"!"_packageName_"!"_className_"!"_dataMasterName
	}
	Quit ""
}

ClassMethod GetPropertyPiece(classAllName, propertyField)
{
	New (classAllName,propertyField)	
	Set (propertyName,propertyNode,propertyDeli,propertyPiece,propertyType,propertyColumn)=""
	Set packageName = $PIECE(classAllName,".",1,$LENGTH(classAllName,".")-1)
	Set className = $PIECE(classAllName,".",$LENGTH(classAllName,"."))
	Set rs = ##class(%ResultSet).%New("web.Util.DHCJFClassGlobal:SelectProperty")
	Do rs.Execute(packageName,className,"")
	While(rs.Next()){
		If rs.Get("propertyField") = propertyField {
			Set propertyName=rs.Get("propertyName")
			Set propertyNode=rs.Get("propertyNode")
			Set propertyDeli=$TRANSLATE(rs.Get("propertyDeli"),"""","")
			Set propertyPiece=rs.Get("propertyPiece")
			Set propertyType= rs.Get("propertyType")
			Set propertyColumn=rs.Get("propertyColumn")
		}
	}
	Quit propertyName_"!"_propertyNode_"!"_propertyDeli_"!"_propertyPiece_"!"_propertyType_"!"_propertyColumn
}

/// @param: {String} Schema SQLUser
/// @param: {String} Table  PA_Adm
/// @param: {String}	Filed "PAADM_PAPMI_DR"
ClassMethod GetREFTable(Schema, Table, Filed) [ Private ]
{
	New (Schema,Table,Filed)
	Set SchemaName = ""
	Set TableName = ""
	Set rs = ##class(%ResultSet).%New("web.Util.DHCJFClassGlobal:SelectColumn")
	Set tSC = rs.Execute(Schema, Table,Filed)
	If $$$ISERR(tSC) Quit
	Do rs.Next()
	Set Type = rs.Data("Type")
	Do rs.Close()
	Set rs=""
	Quit Type
}

/// @param: {String} Schema SQLUser
/// @param: {String} Table  PA_Adm
/// @param: {String}	Filed "PAADM_PAPMI_DR->PAPMI_Sex_DR->CT"
ClassMethod GetREF(Schema = "SQLUser", Table, Filed)
{
	New (Schema,Table,Filed)
	Set Len = $LENGTH(Filed,"->")
	Set SchemaName = Schema
	Set TableName = Table
	For j=1:1:Len-1 {
		Set Col = $PIECE(Filed,"->",j)
		Set SchemaTableName = ..GetREFTable(SchemaName,TableName,Col)
		Set SchemaName = $PIECE(SchemaTableName,".",1)
		Set TableName = $PIECE(SchemaTableName,".",2)
	}
	Quit SchemaName_"."_TableName
}

/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectColumn","SQLUser","PA_Adm","")
/// input: Schema名,表名,列前缀名
Query SelectColumn(Schema As %String, Table As %String, preColumn As %String) As dhc.websys.Query(ROWSPEC = "Column:%String,Type:%String")
{
}

ClassMethod SelectColumnExecute(ByRef qHandle As %Binary, Schema As %String, Table As %String, preColumn As %String) As %Status
{
	New (qHandle,Schema,Table,preColumn)
	//s ^Temp("wanghc","selectColumn")=Schema_","_Table_","_preColumn
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
    If Schema="" Set Schema = $SYSTEM.SQL.DefaultSchema()
    If Table="" Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK
    Do ..RegulateTable(.Schema,.Table)
    If 11'=$DATA(^oddSQL(Schema,Table)) Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK	
	Set tTableType = $$$GetTableTypeFromTableName(Schema,Table)
	Set UpPreColumn = $ZCONVERT(preColumn,"U")
	Set len = $LENGTH(preColumn)
	If tTableType = 1 {
		Set tRS = ##class(%ResultSet).%New("%SQL.Manager.Catalog:Fields")
		Set tSC = tRS.Execute(Schema, Table)
		If $$$ISERR(tSC) Quit
		While (tRS.Next()) {
			Continue:$ZCONVERT($EXTRACT(tRS.Data("FIELD_NAME"),1,len),"U")'=UpPreColumn
			Set ^CacheTemp(repid,ind)=$LISTBUILD(tRS.Data("FIELD_NAME"),tRS.Data("REFERENCE_TO"))
		 	Set ind=ind+1
		}
		Do tRS.Close()
		Set tRS = ""	
	}Else{
	    Set tabid = $ORDER(^oddSQL(Schema,Table,"tsql",1,""))
	    If tabid="" Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK
	    Set colid = "" For  Set colid = $ORDER(^oddTSQL(tabid,"col",colid)) Quit:colid=""  Do 
	    .Set Column = $LISTGET(^(colid),6)
	    .Quit:$ZCONVERT($EXTRACT(Column,1,len),"U")'=UpPreColumn
	    .Set Data=$LISTBUILD(Column)
	 	.Set ^CacheTemp(repid,ind)=Data
	 	.Set ind=ind+1
	}
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectTable","SQLUser","PA_")
/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectTable","SQLUser","DHC_PhSendMsg")
/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectTable","SQLUser","DHCMedAdvRepNotes")
/// input: Schema名,表的前缀名
Query SelectTable(Schema As %String = "SQLUser", preTable As %String = "") As dhc.websys.Query(ROWSPEC = "Schema:%String,Table:%String,ClassName:%String")
{
}

ClassMethod SelectTableExecute(ByRef qHandle As %Binary, Schema As %String = "SQLUser", preTable As %String = "") As %Status
{
	
	New (qHandle,Schema,preTable)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
    If Schema="" {
	    Set Schema = $SYSTEM.SQL.DefaultSchema()
    }Else {
	    Do ..RegulateSchema(.Schema)
	}
    Set UpPreTable = $ZCONVERT(preTable,"U")
    Set len = $LENGTH(preTable)
    Set table = ""
    For  Set table = $ORDER(^oddSQL(Schema,table)) Quit:table=""  Do    
    .Quit:11'=$DATA(^oddSQL(Schema,table))
    .Quit:$LISTGET(^oddSQL(Schema,table),4)'="TABLE"
    .Quit:$ZCONVERT($EXTRACT(table,1,len),"U")'=UpPreTable
    .Set className = $$$GetExtentNameFromTableName(Schema,table)
    .Set Data=$LISTBUILD(Schema,table,className)
 	.Set ^CacheTemp(repid,ind)=Data
 	.Set ind=ind+1
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
}

/// @data 2013-04-20
/// input: Schema前缀名
Query SelectSchema(preSchema As %String = "") As dhc.websys.Query(ROWSPEC = "Schema:%String")
{
}

ClassMethod SelectSchemaExecute(ByRef qHandle As %Binary, preSchema As %String = "") As %Status
{
	New (qHandle,preSchema)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
    Set UpPreSchema = $ZCONVERT(preSchema,"U")
    Set len = $LENGTH(preSchema)
    Set schema = "" ;$o(^oddPROC(preSchema),-1)
    For  Set schema = $ORDER(^rINDEXSQL("schema",schema)) Quit:schema=""  Do
    .Quit:$ZCONVERT($EXTRACT(schema,1,len),"U")'=UpPreSchema
    .Set Data=$LISTBUILD(^rINDEXSQL("schema",schema))
 	.Set ^CacheTemp(repid,ind)=Data
 	.Set ind=ind+1
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
}

/*
ClassMethod SelectPackage(superPackageName As %String) As %ResultSet
{
	Set result = ##class(%ResultSet).%New("%Dictionary.PackageDefinitionQuery:SubPackage")
	d result.Execute(superPackageName)
	while(result.Next()){
		w result.Data("Name"),!
	}
	q result
}*/
/// input: 包名,类名(按开头字母查询)
/// desc : 只查询前十个类
Query SelectClass(packageName As %String, preClassName As %String) As %Query(ROWSPEC = "className:%String:类名")
{
}

/// 开始用$order有大小写的问题,处理不是很好.全循环效率差不多
ClassMethod SelectClassExecute(ByRef qHandle As %Binary, packageName As %String, preClassName As %String) As %Status
{
	New (qHandle,packageName,preClassName)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
    Kill PLIST
	If preClassName=""  Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK
	;拿到所有表名
	Set sog=$SYSTEM.OBJ.GetPackageList(.PLIST,packageName,"")
	Do:('sog) $SYSTEM.Status.DisplayError(sog)
	
	Set len = $LENGTH(preClassName)
	Set name="",currentClassCnt=0
	For  Set name=$ORDER(PLIST(name)) Quit:(name="")||(currentClassCnt>10)  Do
	.Set allName=$PIECE(name,packageName_".",2)
	.Set preName=$EXTRACT(allName,1,len)
	.Quit:($ZCONVERT(preName,"U")'=$ZCONVERT(preClassName,"U"))  
	.Set outClassName=allName
	.Set currentClassCnt=currentClassCnt+1
	.Do OutputRowClass
	Kill PLIST
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
OutputRowClass
	Set Data=$LISTBUILD(outClassName)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
}

ClassMethod SelectClassClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SelectClassExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SelectClassFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SelectClassExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$ORDER(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
	 	Set Row=""
 	}
 	Else      {				// fetch row
 		Set Row=^CacheTemp(repid,ind)
 	}
 	// Save QHandle
 	Set qHandle=$LISTBUILD(AtEnd,repid,ind)
	Quit $$$OK
}

Query SelectGlobal(preGlobalName As %String) As %Query(ROWSPEC = "globalName:%String")
{
}

ClassMethod SelectGlobalExecute(ByRef qHandle As %Binary, preGlobalName As %String) As %Status
{
	New (qHandle,preGlobalName)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
    If preGlobalName="" 	Set qHandle=$LISTBUILD(0,repid,0)	Quit $$$OK
    If $LENGTH(preGlobalName,"^")=1 Set preGlobalName="^"_preGlobalName
    Set preGlobalName=$ZCONVERT(preGlobalName,"U")
	Set len=$LENGTH(preGlobalName)
	Set result = ##class(%ResultSet).%New("%Studio.Global:GlobalList")
 	Do result.Execute("","")
 	While (result.Next()) {
		//Selects Subscript , Value , Data , ValueFormat, SubscriptFormat 
		Set globalName=result.Data("Subscript")
		If preGlobalName=$ZCONVERT($EXTRACT(globalName,1,len),"U") Do
		.Do OutputRowGlobal  
	}
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
OutputRowGlobal
	Set Data=$LISTBUILD($GET(globalName))
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
}

ClassMethod SelectGlobalClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SelectGlobalExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SelectGlobalFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SelectGlobalExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$ORDER(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
	 	Set Row=""
 	}
 	Else      {				// fetch row
 		Set Row=^CacheTemp(repid,ind)
 	}
 	// Save QHandle
 	Set qHandle=$LISTBUILD(AtEnd,repid,ind)
	Quit $$$OK
}

/// 查询某包下所有global及对应信息
/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectGlobalInfo","websys")
Query SelectGlobalInfo(PackageName As %String = "") As dhc.websys.Query(ROWSPEC = "SubScriptString:%String:Gloabl名称,Database:%String:数据库,IndexType:%String:索引类型,ClassAllName:%String:类名,TableName:%String:表名,createDate:%String:CreateDate,Mdata:%String")
{
}

ClassMethod SelectGlobalInfoExecute(ByRef qHandle As %Binary, PackageName As %String = "") As %Status
{
	New (qHandle,PackageName,%request,%session)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1
    
    Set curNS =  $NAMESPACE
    ZNspace "%sys"
    Kill ^||Temp,^||Sort
    Merge ^||Temp("Databases")=^CONFIG("Databases")
    	
    Set PackageNameLen = $LENGTH(PackageName)
	;------ %Dictionary.StorageSQLMapDefinition.Master ---
	Set classAllName="" For  Set classAllName = $ORDER(^oddDEF(classAllName)) Quit:classAllName=""  Do
	.Quit:classAllName["%"
	.Quit:classAllName["Ens."
	.Quit:classAllName["EnsLib."
	.Quit:(PackageName'="")&&($EXTRACT(classAllName,1,PackageNameLen)'=PackageName)
	.Set myStorageName = $GET(^oddDEF(classAllName,59))
	.Set mySuperClassName = $GET(^oddDEF(classAllName,60))
	.Quit:(mySuperClassName'["Persistent")
	.Set storageName="" For  Set storageName = $ORDER(^oddDEF(classAllName,"s",storageName)) Quit:storageName=""  Do
	..;Default
	..If ($DATA(^oddDEF(classAllName,"s","Default"))=11) && ($DATA(^oddDEF(classAllName,"s","Default",24))=1) Do
	...Set TableName = classAllName
	...Set allGlobal = ^oddDEF(classAllName,"s","Default",24)
	...Set createDate = $ZDATE(^oddDEF(classAllName,64),3)
	...Set global = $PIECE(allGlobal,"(")
	...If global="{%%PARENT}" Do 
	....Set parentGlobalName=..SelectParentGlobal(classAllName)
	....Set global=$PIECE(parentGlobalName,"(")
	...If allGlobal["(" Set SubScriptString=global_"("_$PIECE(allGlobal,"(",2)
	...If allGlobal'["(" Set SubScriptString=global
	...Set IndexType = "Default data"
	...Set Mdata=global_"(0)"
	...Do OutputRowClassByGlobal2
	...; 默认索引
	...Set IndexType = "Default index"
	...Set global = $EXTRACT(global,1,$LENGTH(global)-1)_"I"
	...Do OutputRowClassByGlobal2	
	..Quit:$DATA(^oddDEF(classAllName,"s","Default"))
	..;SQLStore
	..Set sqlmapName="" For  Set sqlmapName = $ORDER(^oddDEF(classAllName,"s",storageName,"S",sqlmapName)) Quit:sqlmapName=""  Do
	...Set global=$GET(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,24),$GET(^%qCacheObjectKey(1,"S",24)))
	...Quit:global=""
	...Set createDate = $ZDATE(^oddDEF(classAllName,64),3)
	...Set TableName=$SELECT($DATA(^oddDEF(classAllName,58))#2:^(58),1:$GET(^%qCacheObjectKey(1,"c",58)))
	...Set IndexType=$GET(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,5),$GET(^%qCacheObjectKey(1,"S",5)))
	...Set SubScriptString=""
	...;s subScriptName="" f  s subScriptName=$o(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,"B",subScriptName)) q:subScriptName=""  d
	...;.s Expression=$g(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,"B",subScriptName,24),$g(^%qCacheObjectKey(1,"B",24)))
	...;.i SubScriptString="" s SubScriptString=Expression
	...;.e  s SubScriptString=SubScriptString_"，"_Expression
	...;s:SubScriptString'="" SubScriptString=global_"("_SubScriptString_")"
	...Set Mdata=$GET(^oddDEF(classAllName,"s",storageName,28))
	...Do OutputRowClassByGlobal2
	
	Set db=""
	For  Set db =$ORDER(^||Temp("glb",db)) Quit:db=""  Do
	.Set global = ""
	.For  Set global = $ORDER(^||Temp("glb",db,global)) Quit:global=""  Do
 	..Set cn = ""
 	..For  Set cn=$ORDER(^||Temp("glb",db,global,cn)) Quit:cn=""  Do
 	...Set it = $PIECE(^||Temp("glb",db,global,cn),"^",1)
 	...Set tn = $PIECE(^||Temp("glb",db,global,cn),"^",2)
 	...Set createDate = $PIECE(^||Temp("glb",db,global,cn),"^",3)
 	...Set Mdata = $PIECE(^||Temp("glb",db,global,cn),"^",4,$LENGTH(^||Temp("glb",db,global,cn),"^"))
 	...If $EXTRACT(Mdata,1,3)="$i(" Set Mdata = $PIECE(Mdata,"$i(",2),Mdata = $EXTRACT(Mdata,1,$LENGTH(Mdata)-1)
 	...Set Mdata = $TRANSLATE(Mdata,$CHAR(10,13),"")
 	...Set Data = $LISTBUILD("^"_global,db,it,cn,tn,createDate,Mdata)
 	...Set ^CacheTemp(repid,ind)=Data
	...Set ind=ind+1
	..Quit:$DATA(^||Temp("glb",db,global))>1 //有对应的表结构不输出空
	..Set Data=$LISTBUILD("^"_global,db,"","","")
 	..Set ^CacheTemp(repid,ind)=Data
 	..Set ind=ind+1
	// 把global名与表名一致，但database不一样的处理下
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
OutputRowClassByGlobal2
	If $LENGTH(global)>1,classAllName'=""{
		/*set dbind="",datastr=""
		for {
			set database1 = $O(^||Temp("glb2",$e(global,2,),dbind))
			quit:database1=""
			if datastr="" Set datastr=database1
			else  Set datastr=datastr_"，"_database1
		}
		
		if (datastr="") s datastr="无数据"
		*/
		// a?1"PAC".A
		//B:global["ARCIM"
		Set cpfg = "",database="DHC-DATA"
		For {
			Set cpfg = $ORDER(gmap(cpfg))
			Quit:cpfg=""
			If cpfg["*"{
				Break:global["ARCIM"
				If (($EXTRACT(global,2,$LENGTH(cpfg)))_"*")=cpfg{
					Set database = gmap(cpfg)
					Quit
				}
			}Else{
				If ($EXTRACT(global,2,)=cpfg){
					Set database = gmap(cpfg)
					Quit 
				}
			}
		}
		If global="^OEORD" ,IndexType="index" Set database="DHC-ORDINDEX"
		Set ^||Temp("glb",database,$EXTRACT(global,2,),classAllName)=IndexType_"^"_TableName_"^"_createDate_"^"_Mdata
	}
	Quit 
	/*if global'="" {
		set database = $O(^||Temp("glb2",$e(global,2,),""))
		//有表名对照的去掉
		if (database'=""),(global'="") k ^||Temp("glb",database,global)
		if (database="") s database="未找到Database"
		;set Data=$lb(SubScriptString,database,IndexType,classAllName,TableName)
		set Data=$lb(global,database,IndexType,classAllName,TableName)
	 	Set ^CacheTemp(repid,ind)=Data
	 	Set ind=ind+1
	}
	quit*/
}

/*
ClassMethod SelectGlobalInfoExecute(ByRef qHandle As %Binary, PackageName As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1
    s curNS =  $namespace
    zn "%sys"
    m ^||Temp("Databases")=^CONFIG("Databases")
    zn curNS
    Set result = ##class(%ResultSet).%New("%SYS.GlobalQuery:DirectoryList")
    if $d(^||Temp("Databases")) { //2010 db
    	Set dataname=""
	    for {
	    	Set dataname=$o(^||Temp("Databases",dataname))
	    	Quit:dataname=""
	    	Continue:(dataname'["DHC")
	    	Set databasedir=$p(^||Temp("Databases",dataname),",",1)
	    	Do result.Execute(databasedir,"","*",0)
	    	While (result.Next()) {
				set globalName=result.Data("Name")
				set globalBlock=result.Data("PointerBlock")
				Set ^||Temp("glb",dataname,globalName)=globalBlock 
				Set ^||Temp("glb2",globalName,dataname)=globalBlock 
			}
	    }
    }
 		
    s PackageNameLen = $l(PackageName)
	;------ %Dictionary.StorageSQLMapDefinition.Master ---
	s classAllName="" f  s classAllName = $o(^oddDEF(classAllName)) q:classAllName=""  d
	.q:classAllName["%"
	.q:classAllName["Ens."
	.q:classAllName["EnsLib."
	.q:(PackageName'="")&&($e(classAllName,1,PackageNameLen)'=PackageName)
	.s myStorageName = $g(^oddDEF(classAllName,59))
	.s mySuperClassName = $g(^oddDEF(classAllName,60))
	.q:(mySuperClassName'["Persistent")
	.s storageName="" f  s storageName = $o(^oddDEF(classAllName,"s",storageName)) q:storageName=""  d
	..;Default
	..i ($d(^oddDEF(classAllName,"s","Default"))=11) && ($d(^oddDEF(classAllName,"s","Default",24))=1) d
	...s TableName = classAllName
	...s allGlobal = ^oddDEF(classAllName,"s","Default",24)
	...s global = $p(allGlobal,"(")
	...if global="{%%PARENT}" d 
	....set parentGlobalName=..SelectParentGlobal(classAllName)
	....set global=$p(parentGlobalName,"(")
	...if allGlobal["(" s SubScriptString=global_"("_$P(allGlobal,"(",2)
	...if allGlobal'["(" s SubScriptString=global
	...s IndexType = "Default data"
	...;b ;
	...do OutputRowClassByGlobal2
	..q:$d(^oddDEF(classAllName,"s","Default"))
	..;SQLStore
	..s sqlmapName="" f  s sqlmapName = $o(^oddDEF(classAllName,"s",storageName,"S",sqlmapName)) q:sqlmapName=""  d
	...s global=$g(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,24),$g(^%qCacheObjectKey(1,"S",24)))
	...q:global=""
	...s TableName=$s($d(^oddDEF(classAllName,58))#2:^(58),1:$g(^%qCacheObjectKey(1,"c",58)))
	...s IndexType=$g(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,5),$g(^%qCacheObjectKey(1,"S",5)))
	...s SubScriptString=""
	...s subScriptName="" f  s subScriptName=$o(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,"B",subScriptName)) q:subScriptName=""  d
	....s Expression=$g(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,"B",subScriptName,24),$g(^%qCacheObjectKey(1,"B",24)))
	....i SubScriptString="" s SubScriptString=Expression
	....e  s SubScriptString=SubScriptString_"，"_Expression
	...s:SubScriptString'="" SubScriptString=global_"("_SubScriptString_")"
	...do OutputRowClassByGlobal2
	
	set db=""
	for  set db =$O(^||Temp("glb",db)) quit:db=""  d
	.set global = ""
	.for  set global = $O(^||Temp("glb",db,global)) quit:global=""  d
	..set Data=$lb("^"_global,db,"","","")
 	..Set ^CacheTemp(repid,ind)=Data
 	..Set ind=ind+1
 
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
OutputRowClassByGlobal2
	if global'="" {
		set database = $O(^||Temp("glb2",$e(global,2,),""))
		//有表名对照的对掉
		if (database'=""),(global'="") k ^||Temp("glb",database,global)
		if (database="") s database="无数据"
		;set Data=$lb(SubScriptString,database,IndexType,classAllName,TableName)
		set Data=$lb(global,database,IndexType,classAllName,TableName)
	 	Set ^CacheTemp(repid,ind)=Data
	 	Set ind=ind+1
	}
	quit
}
*/
/// so slow
/// s sog=$System.OBJ.GetPackageList(.PLIST,""_PackageName_"","*")
/// Do:('sog) $system.Status.DisplayError(sog)
/// for  s ClassAllName=$o(PLIST(ClassAllName)) q:ClassAllName=""  D
/// .set dcd = ##class(%Dictionary.ClassDefinition).%OpenId(ClassAllName)
/// .set TableName=dcd.SqlTableName
/// .set dsd=dcd.Storages
/// .set dsdCount=dsd.Count()
/// 	.for j=1:1:dsdCount  d
/// 	..s sqlMapsID=dsd.GetAt(j).SQLMaps
/// 	..s sqlMapsCount=sqlMapsID.Count()
/// 	..for i=1:1:sqlMapsCount d
/// 	...set sqlMapID=sqlMapsID.GetAt(i)
/// 	...set global=sqlMapID.Global
/// 	...quit:$ZCVT($e(global,1,GlobalNameLen),"U")'=GlobalName
/// 	...set IndexType=sqlMapID.Type
/// 	...set indexName=sqlMapID.Name
/// 	...set SubScriptString=global_..getIndexSubStr(sqlMapID.Subscripts)
/// 	...do OutputRowClassByGlobal
/// 	.s dcd=""	
/// 没有索引,只能遍历所用表,除非自己建表表,但没有实时性
Query SelectClassByGlobal(PackageName As %String, GlobalName As %String) As %Query(ROWSPEC = "ClassAllName:%String,TableName:%String,SubScriptString:%String,IndexType:%String")
{
}

ClassMethod SelectClassByGlobalExecute(ByRef qHandle As %Binary, PackageName, GlobalName As %String) As %Status
{
	New (qHandle,PackageName,GlobalName)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
    If GlobalName="" Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK
    Set GlobalName=$ZCONVERT(GlobalName,"U")
    If $LENGTH(GlobalName,"^")=1 Set GlobalName="^"_GlobalName
    Set GlobalNameLen=$LENGTH(GlobalName)
    Set PackageNameLen = $LENGTH(PackageName)
	;------ %Dictionary.StorageSQLMapDefinition.Master ---
	Set classAllName="" For  Set classAllName = $ORDER(^oddDEF(classAllName)) Quit:classAllName=""  Do
	.;q:(PackageNameLen>0)&&($e(classAllName,1,PackageNameLen)'=PackageName)
	.Set storageName="" For  Set storageName = $ORDER(^oddDEF(classAllName,"s",storageName)) Quit:storageName=""  Do
	..;Default
	..If ($DATA(^oddDEF(classAllName,"s","Default"))=11) && ($DATA(^oddDEF(classAllName,"s","Default",24))=1) Do
	...Set TableName = classAllName
	...Set global = ^oddDEF(classAllName,"s","Default",24)
	...Set SubScriptString = ^oddDEF(classAllName,"s","Default",24)
	...Quit:$ZCONVERT($EXTRACT(global,1,GlobalNameLen),"U")'=GlobalName
	...Set IndexType = "Default data"
	...Do OutputRowClassByGlobal
	..Quit:$DATA(^oddDEF(classAllName,"s","Default"))
	..;SQLStore
	..Set sqlmapName="" For  Set sqlmapName = $ORDER(^oddDEF(classAllName,"s",storageName,"S",sqlmapName)) Quit:sqlmapName=""  Do
	...Set global=$GET(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,24),$GET(^%qCacheObjectKey(1,"S",24)))
	...Quit:global=""
	...Quit:$ZCONVERT($EXTRACT(global,1,GlobalNameLen),"U")'=GlobalName
	...Set TableName=$SELECT($DATA(^oddDEF(classAllName,58))#2:^(58),1:$GET(^%qCacheObjectKey(1,"c",58)))
	...Set IndexType=$GET(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,5),$GET(^%qCacheObjectKey(1,"S",5)))
	...Set SubScriptString=""
	...Set subScriptName="" For  Set subScriptName=$ORDER(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,"B",subScriptName)) Quit:subScriptName=""  Do
	....Set Expression=$GET(^oddDEF(classAllName,"s",storageName,"S",sqlmapName,"B",subScriptName,24),$GET(^%qCacheObjectKey(1,"B",24)))
	....If SubScriptString="" Set SubScriptString=Expression
	....Else  Set SubScriptString=SubScriptString_","_Expression
	...Set:SubScriptString'="" SubScriptString=global_"("_SubScriptString_")"
	...Do OutputRowClassByGlobal
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
OutputRowClassByGlobal
	Set Data=$LISTBUILD(classAllName,TableName,SubScriptString,IndexType)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
}

ClassMethod SelectClassByGlobalClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SelectClassByGlobalExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SelectClassByGlobalFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SelectClassByGlobalExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$ORDER(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
	 	Set Row=""
 	}
 	Else      {				// fetch row
 		Set Row=^CacheTemp(repid,ind)
 	}
 	// Save QHandle
 	Set qHandle=$LISTBUILD(AtEnd,repid,ind)
	Quit $$$OK
}

ClassMethod SelectChild(packageName As %String, className As %String) As %String
{
	Break ;1
	New (packageName,className)
	If className="" Quit ""
	Set childNameStr=""
	Set rs = ##class(%ResultSet).%New("%Dictionary.PropertyDefinition:Summary")
	Do rs.Execute(packageName_"."_className)
	While(rs.Next()) {
		Set propertyName=rs.Data("Name")
		Set propId=packageName_"."_className_"||"_propertyName
		Set propObj=##class(%Dictionary.PropertyDefinition).%OpenId(propId,0)
   	  	Quit:propObj=""
   	  	If propObj.Cardinality="children" Do
   	  	.Set childName=$PIECE(propObj.Type,".",$LENGTH(propObj.Type,"."))
   	  	.If $GET(childNameStr)="" Do
   	  	..Set childNameStr=childName
   	  	.Else  Do
   	  	..Set childNameStr=childNameStr_"^"_childName
   	}
   	Quit $GET(childNameStr)
}

ClassMethod SelectParentGlobal(classAllName)
{
	New (classAllName)
	
	Set SubPackageName=$PIECE(classAllName,".",1,$LENGTH(classAllName,".")-1)
	Set parentTableName=SubPackageName_"."_..SelectParent(SubPackageName,$PIECE(classAllName,".",$LENGTH(classAllName,".")))
	Set parentGlobalName=$GET(^oddDEF(parentTableName,"s","Default",24))
	If parentGlobalName["{%%PARENT}"{
		Quit ..SelectParentGlobal(parentTableName)
	}Else{
		Quit parentGlobalName
	}
}

ClassMethod SelectParent(packageName As %String, className As %String) As %String
{
	New (packageName,className)
	Quit:className="" ""
	Set parentClass=""
	Set rs = ##class(%ResultSet).%New("%Dictionary.PropertyDefinition:Summary")
	Do rs.Execute(packageName_"."_className)
	While(rs.Next()) {
		Set propertyName=rs.Data("Name")
		Set propId=packageName_"."_className_"||"_propertyName
		Set propObj=##class(%Dictionary.PropertyDefinition).%OpenId(propId,0)
   	  	Quit:propObj=""
   	  	If propObj.Cardinality="parent" Do
   	  	.Set parentClass=$PIECE(propObj.Type,".",$LENGTH(propObj.Type,"."))
   	}
   	Quit $GET(parentClass)
}

/// 描述:    得到主索引或索引的subString
/// 返回:    subString:   (0,"BillDate",{PBDO_BillDate},{PBDO_RowId})
/// 入参:    subScripts
/// [Previously private]
ClassMethod getIndexSubStr(subScripts)
{
	New (subScripts)
	Set subCnt=subScripts.Count(),subString="("
	For k=1:1:subCnt {
				Set subScript=subScripts.GetAt(k)	
				Set expr=subScript.Expression
				Set subString=subString_""_expr_","
	}
	Set $EXTRACT(subString,$LENGTH(subString))=""   //去掉最后的逗号
	Quit subString_")"
}

ClassMethod getMasterIndexName(packageName As %String, className As %String)
{
    New (packageName,className,%request,%session)
	Set classAllName=packageName_"."_className
	Set masterIndexName=""
	Set dcd = ##class(%Dictionary.ClassDefinition).%OpenId(classAllName,0)
	If (dcd){
		Set dsd=dcd.Storages
		Set dsdCount=dsd.Count()
		For j=1:1:dsdCount {
			#dim sdItem as %Dictionary.StorageDefinition
			Set sdItem = dsd.GetAt(j)
			If sdItem.Type["CacheStorage" Set masterIndexName = sdItem.DefaultData
			// CacheSQLStorage, IRIS->%Storage.SQL
			If sdItem.Type["SQL"{  
				Set sqlMapsID=dsd.GetAt(j).SQLMaps
				Set sqlMapsCount=sqlMapsID.Count()
				For i=1:1:sqlMapsCount {
					Set sqlMapID=sqlMapsID.GetAt(i)
					Set type=sqlMapID.Type
					Set indexName=sqlMapID.Name
					If type="data" Set masterIndexName=indexName
				}	
			}
		}
	}
	Quit masterIndexName
}

/// input: 包名,类名
/// desc:  查询表的结构
/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectMaster","websys","Menu")
/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectMaster","User","DHCPhSend")
/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectMaster","User","DHCMedAdvRepNotes")
Query SelectMaster(packageName As %String, className As %String) As %Query(ROWSPEC = "type:%String:索引类型,indexName:%String:索引名,indexMasterData:%String:索引结构")
{
}

ClassMethod SelectMasterExecute(ByRef qHandle As %Binary, packageName As %String, className As %String) As %Status
{
	New (qHandle,packageName,className,%request,%session)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
	Set classAllName=packageName_"."_className
	Set dcd = ##class(%Dictionary.ClassDefinition).%OpenId(classAllName,0)
	If (dcd="")  Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK
	Set dsd=dcd.Storages
	Set dsdCount=dsd.Count()
	Set storageType="%CacheSQLStorage"
	For j=1:1:dsdCount 	Do
	.Set storage = dsd.GetAt(j)
	.Set storageType = storage.Type	; %Dictionary.CacheClassname
	.;2011-11-18 把默认结构也查询出来
	.If storageType [ "CacheStorage" Do
	..Set storageIndexMasterData=storage.IndexLocation
	..Set storageDatas = storage.Data		;%Dictionary.StorageDataDefinition
	..Set storageDatasCount = storageDatas.Count()
	..For y=1:1:storageDatasCount Do
	...Set storageData=storageDatas.GetAt(y)
	...Set storageDataValue=storageData.Values	;%Dictionary.StorageDataValueDefinition
	...Set storageDataValueCount=storageDataValue.Count()
	...Set type = "data"	
	...Set indexName=storageData.Name
	...Set storageStructure=storageData.Structure
	...If storageStructure="node"  Set indexMasterData=storage.DataLocation_"(ID,0)="_storageData.Attribute
	...Else  Do
	....Set indexSub=""
	....For x=1:1:storageDataValueCount Do
	.....If indexSub'="" Set indexSub=indexSub_","_storageDataValue.GetAt(x).Value
	.....Else  Set indexSub=storageDataValue.GetAt(x).Value
	....Set indexMasterData=storage.DataLocation_"(ID)=$LB("_indexSub_")"
	...Do OutputRowMaster
	.Else  Do 
	..Set sqlMapsID = storage.SQLMaps
	..Set sqlMapsCount=sqlMapsID.Count()
	..For i=1:1:sqlMapsCount Do
	...Set sqlMapID=sqlMapsID.GetAt(i)
	...Set type=sqlMapID.Type
	...Set indexName=sqlMapID.Name
	...Set indexSub=..getIndexSubStr(sqlMapID.Subscripts)
	...Set indexMasterData=sqlMapID.Global_indexSub
	...Do OutputRowMaster
	If storageType'["CacheStorage" Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK
	Set indexDefinitions = dcd.Indices
	Set indicesCount = indexDefinitions.Count()
	For i=1:1:indicesCount Do
	.Set indexDefinition = indexDefinitions.GetAt(i)
	.Set type="Index"
	.Set indexName=indexDefinition.Name
	.Set indexMasterData = storageIndexMasterData_"("""_indexName_""","_indexDefinition.Properties_",ID)"
	.Do OutputRowMaster
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
OutputRowMaster
	Set Data=$LISTBUILD($GET(type),$GET(indexName),$GET(indexMasterData))
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
}

ClassMethod SelectMasterClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SelectMasterExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SelectMasterFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SelectMasterExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$ORDER(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
	 	Set Row=""
 	}
 	Else      {				// fetch row
 		Set Row=^CacheTemp(repid,ind)
 	}
 	// Save QHandle
 	Set qHandle=$LISTBUILD(AtEnd,repid,ind)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectProperty","User","PAAdm","")
/// d ##class(%ResultSet).RunQuery("web.Util.DHCJFClassGlobal","SelectProperty","websys","Menu","")
Query SelectProperty(packageName As %String, className As %String, masterIndexName As %String) As %Query(ROWSPEC = "propertyName:%String,propertyNode:%String,propertyDeli:%String,propertyPiece:%String,propertyType:%String,propertyField:%String,propertyColumn:%String,propertyDesc:%String")
{
}

ClassMethod SelectPropertyExecute(ByRef qHandle As %Binary, packageName As %String, className As %String, masterIndexName As %String) As %Status
{
	New (qHandle,packageName,className,masterIndexName,%request,%session)
	Set repid=$INCREMENT(^CacheTemp)
    If $GET(ind)="" Set ind=1	
	If (packageName="")||(className="") Set qHandle=$LISTBUILD(0,repid,0) Quit $$$OK
	Set classAllName=packageName_"."_className
	
	Set StorageName=$ORDER(^oddDEF(classAllName,"s",""))
	If StorageName="" Set StorageName="SQLStorage"
	If (masterIndexName="") {
		Set masterIndexName=..getMasterIndexName(packageName,className)
	}
	Set storageType =$GET(^oddDEF(classAllName,"s",StorageName,5)) //"%Library.CacheStorage"
	Set rsltSt = ##class(%ResultSet).%New("%Dictionary.PropertyDefinition:Summary")
	Do rsltSt.Execute(classAllName)
	While(rsltSt.Next()) {
		Set (propertyName,propertyNode,propertyDeli,propertyPiece,propertyType,propertyField,propertyColumn)=""
		Set propertyName=rsltSt.Data("Name")
		Set propertyId=classAllName_"||"_propertyName
		Set propObj=##class(%Dictionary.PropertyDefinition).%OpenId(propertyId,0)
		Set propertyType=propObj.Type
		If ($LENGTH(propertyType,".")=1)&&($LENGTH(propertyType,"%")=1) Set propertyType="User."_propertyType
		Set propertyField=propObj.SqlFieldName
		Set propertyColumn=propObj.SqlColumnNumber
		Set propertyDesc = propObj.Description
		Set ssmddID=classAllName_"||"_StorageName_"||"_masterIndexName_"||"_propertyField
		If (storageType["CacheStorage"){
			Set ssmddName = ""
			For {
				Set ssmddName = $ORDER(^oddDEF(classAllName,"s",StorageName,"D",masterIndexName,"V",ssmddName))
				Quit:ssmddName=""
				Set ssmddValue = $GET(^oddDEF(classAllName,"s",StorageName,"D",masterIndexName,"V",ssmddName,21))
				//w ssmddName_","_ssmddValue_","_propertyName_"..."
				Quit:ssmddValue=propertyName
			}
			Set propertyNode=""
			Set propertyDeli="$lg"
			Set propertyPiece=ssmddName
		}Else{
			Set ssmdd=##class(%Dictionary.StorageSQLMapDataDefinition).%OpenId(ssmddID,0)
			If (ssmdd'="") {
				Set propertyNode=ssmdd.Node
				Set propertyDeli=ssmdd.Delimiter
				Set propertyPiece=ssmdd.Piece
				
			}
		}
		Do OutputRowProperty
	}
	Set qHandle=$LISTBUILD(0,repid,0)
	Quit $$$OK
OutputRowProperty
	Set Data=$LISTBUILD(propertyName,propertyNode,propertyDeli,propertyPiece,propertyType,propertyField,propertyColumn,propertyDesc)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
}

ClassMethod SelectPropertyClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SelectPropertyExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SelectPropertyFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SelectPropertyExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$ORDER(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
	 	Set Row=""
 	}
 	Else      {				// fetch row
 		Set Row=^CacheTemp(repid,ind)
 	}
 	// Save QHandle
 	Set qHandle=$LISTBUILD(AtEnd,repid,ind)
	Quit $$$OK
}

/// 校正scheme
/// SQLUSER-SQLUser
ClassMethod RegulateSchema(ByRef Schema As %String) As %Status
{
	New (Schema)
	If Schema="" Set Schema =$SYSTEM.SQL.DefaultSchema() Quit $$$OK
    Set rs = ##class(%ResultSet).%New("web.Util.DHCJFClassGlobal:SelectSchema")
	Set tSC = rs.Execute(Schema)
	If $$$ISERR(tSC) Quit $$$OK
	Do rs.Next()
	Set Schema = rs.Data("Schema")
	Do rs.Close()
	Set rs=""
	Quit $$$OK
}

ClassMethod RegulateTable(ByRef Schema As %String, ByRef Table As %String, ByRef ClassName As %String)
{
	New (Schema,Table,ClassName)
	Set tRS = ##class(%ResultSet).%New("web.Util.DHCJFClassGlobal:SelectTable")
	Set tSC = tRS.Execute($GET(Schema), $GET(Table))
	If $$$ISERR(tSC) Quit ""
	Set TClassName="",TSchema="",TTable=""
	While( tRS.Next()){
		Set TTable = tRS.Data("Table")
		
		If ($ZCONVERT(TTable,"U")=$ZCONVERT($GET(Table),"U")){
			Set TSchema = tRS.Data("Schema")
			Set TClassName = tRS.Data("ClassName")
			Quit 
		}
	}
	Do tRS.Close()
	Set tRS=""
	If (TSchema'="") Set Table=TTable,ClassName=TClassName,Schema=TSchema
	Quit $$$OK
}

ClassMethod GetAllMdataInfo()
{
	New 
	Set cn = "" For  Set cn=$ORDER(^oddDEF(cn))  Quit:cn=""  Do
	.Quit:($EXTRACT(cn,1)="%")
	.;Quit:(^oddDEF(cn,60)'="%Persistent")
	.Quit:$DATA(^oddDEF(cn,"s"))=0
	.Set sn = $ORDER(^oddDEF(cn,"s",""))						;$g(^oddDEF(cn,59)) ;
	.Quit:$GET(^oddDEF(cn,"s",sn,5))["CacheStorage"
	.Set sqlIdExp = $GET(^oddDEF(cn,"s",sn,28))				 ;="$i(^mdata(""DHCCOURSE""))"
	.If sqlIdExp["^mdata" Do
	..Set $EXTRACT(sqlIdExp,2) = "g"
	..Set maxMDATA = @sqlIdExp
	..Set tn = $GET(^oddDEF(cn,58))
	..If tn'="" Do
	...Set tstat = ##class(%SQL.Statement).%New()
	...Set sc = tstat.%Prepare("select max(%id) As maxId from SQLUser."_tn)
	...Set rset = tstat.%Execute()
	...Do rset.%Next()
	...Write:rset.%SQLCODE=0 "表:"_tn_"MaxRowId="_rset.maxId,",MaxMdata="_maxMDATA,!
	..
}

}
