/// CT Location               (CTLOC,7)
Class User.CTLoc Extends %Persistent [ ClassType = persistent, Not ProcedureBlock, SqlTableName = CT_Loc, StorageStrategy = SQLStorage ]
{

/// Location Code
Property CTLOCCode As %String(COLLATION = "AlphaUp", MAXLEN = 100, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = CTLOC_Code ];

/// Location Description
Property CTLOCDesc As %String(COLLATION = "AlphaUp", MAXLEN = 220, TRUNCATE = 1) [ SqlColumnNumber = 3, SqlFieldName = CTLOC_Desc ];

/// Des Ref to GLCCC (Cost Center)
Property CTLOCGLCCC As %String [ SqlColumnNumber = 4, SqlFieldName = CTLOC_GLCCC ];

/// Location Password
Property CTLOCPassword As %String(COLLATION = "AlphaUp", MAXLEN = 8, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = CTLOC_Password ];

/// Ward Flag
Property CTLOCWardFlag As %String(DISPLAYLIST = ",Yes,No", MAXLEN = 3, TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 6, SqlFieldName = CTLOC_WardFlag ];

/// Address
Property CTLOCAddress As %String(COLLATION = "AlphaUp", MAXLEN = "", TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = CTLOC_Address ];

/// Active Flag
Property CTLOCActiveFlag As %String(DISPLAYLIST = ",Yes,No", MAXLEN = 3, TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 8, SqlFieldName = CTLOC_ActiveFlag ];

Storage SQLStorage
{
<ExtentSize>100000</ExtentSize>
<SqlIdExpression>$i(^CTLOC(0))</SqlIdExpression>
<SQLMap name="DataMasterCTLOC">
<Data name="CTLOC_ActiveFlag">
<Delimiter>"^"</Delimiter>
<Piece>8</Piece>
</Data>
<Data name="CTLOC_Address">
<Delimiter>"^"</Delimiter>
<Node>"ADDR"</Node>
<Piece>7</Piece>
</Data>
<Data name="CTLOC_Code">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="CTLOC_Desc">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="CTLOC_GLCCC">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Data name="CTLOC_Password">
<Delimiter>"^"</Delimiter>
<Piece>4</Piece>
</Data>
<Data name="CTLOC_WardFlag">
<Delimiter>"^"</Delimiter>
<Piece>5</Piece>
</Data>
<Global>^CTLOC</Global>
<RowIdSpec name="1">
<Expression>{L1}</Expression>
<Field>CTLOC_RowID</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>{CTLOC_RowID}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<SQLMap name="IndexCTLOCCode">
<Global>^CTLOC</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L4}</Expression>
<Field>CTLOC_RowID</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>0</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>"Code"</Expression>
</Subscript>
<Subscript name="3">
<AccessType>sub</AccessType>
<Expression>CTLOC_Code</Expression>
</Subscript>
<Subscript name="4">
<AccessType>sub</AccessType>
<Expression>{CTLOC_RowID}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SQLMap name="IndexCTLOCDesc">
<Global>^CTLOC</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L4}</Expression>
<Field>CTLOC_RowID</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>0</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>"Desc"</Expression>
</Subscript>
<Subscript name="3">
<AccessType>sub</AccessType>
<Expression>CTLOC_Desc</Expression>
</Subscript>
<Subscript name="4">
<AccessType>sub</AccessType>
<Expression>{CTLOC_RowID}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SqlRowIdName>CTLOC_RowID</SqlRowIdName>
<StreamLocation>^User.CTLocS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
