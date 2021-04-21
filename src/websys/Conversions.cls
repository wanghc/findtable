Class websys.Conversions Extends %Library.RegisteredObject [ Not Abstract, ClassType = "" ]
{

ClassMethod IsValidClassName(classname As %Library.String) As %Library.Boolean
{
	Quit:(classname="") 0
	If $DATA(^oddDEF(classname)) Quit 1
	Quit 0
}

ClassMethod IsValidMethodName(classname As %Library.String, methodname As %Library.String) As %Library.Boolean
{
	Quit:((classname="")||(methodname="")) 0
	If $DATA(^oddDEF(classname,"m",methodname)) Quit 1
	Set myobj=##class(%Dictionary.CompiledMethod).%OpenId(classname_"||"_methodname,0)
	Set myrtn=0
	If ($ISOBJECT(myobj)){
		Set myobj=""
		Set myrtn = 1
	}
	Quit myrtn
}

}
