Class dhc.user.SSUser Extends %Persistent [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlTableName = SS_User, StorageStrategy = SQLStorage ]
{

Relationship ChildSSUserWindow As dhc.user.SSUserWindow [ Cardinality = children, Inverse = WINParRef ];

Relationship ChildSSUserDepartFunction As dhc.user.SSUserDepartFunction [ Cardinality = children, Inverse = DFParRef ];

Relationship ChildSSUserSettings As dhc.user.SSUserSettings [ Cardinality = children, Inverse = SETParRef ];

/// Initials 
Property SSUSRInitials As %String(COLLATION = "AlphaUp", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = SSUSR_Initials ];

/// Name
Property SSUSRName As %String(COLLATION = "AlphaUp", MAXLEN = 40, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = SSUSR_Name ];

/// SSUSR_Password
Property SSUSRPassword As %String(COLLATION = "Exact", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = SSUSR_Password ];

/// DEs Ref to CTLOC
Property SSUSRDefaultDeptDR As dhc.user.CTLoc [ SqlColumnNumber = 7, SqlFieldName = SSUSR_DefaultDept_DR ];

Storage SQLStorage
{
<ExtentSize>100000</ExtentSize>
<SqlIdExpression>$i(^SSU("SSUSR",0))</SqlIdExpression>
<SQLMap name="DataMasterSSUSR">
<Data name="SSUSR_DefaultDept_DR">
<Delimiter>"^"</Delimiter>
<Piece>4</Piece>
</Data>
<Data name="SSUSR_Initials">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="SSUSR_Name">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="SSUSR_Password">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Global>^SSU</Global>
<RowIdSpec name="1">
<Expression>{L2}</Expression>
<Field>SSUSR_RowId</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>"SSUSR"</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>{SSUSR_RowId}</Expression>
<StartValue>1</StartValue>
<StopValue>999999999</StopValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<SQLMap name="IndexSSUSRInitials">
<Data name="SSUSR_Initials">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Global>^SSU</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L4}</Expression>
<Field>SSUSR_RowId</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>"SSUSR"</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>0</Expression>
</Subscript>
<Subscript name="3">
<AccessType>sub</AccessType>
<Expression>"SSUSR_Initials"</Expression>
</Subscript>
<Subscript name="4">
<AccessType>sub</AccessType>
<Expression>{SSUSR_RowId}</Expression>
<StartValue>1</StartValue>
<StopValue>999999999</StopValue>
</Subscript>
<Type>index</Type>
</SQLMap>
<SQLMap name="IndexSSUSRName">
<Data name="SSUSR_Name">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Global>^SSU</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L5}</Expression>
<Field>SSUSR_RowId</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>"SSUSR"</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>0</Expression>
</Subscript>
<Subscript name="3">
<AccessType>sub</AccessType>
<Expression>"SSUSR_Name"</Expression>
</Subscript>
<Subscript name="4">
<AccessType>sub</AccessType>
<Expression>$$ALPHAUP({SSUSR_Name})</Expression>
</Subscript>
<Subscript name="5">
<AccessType>sub</AccessType>
<Expression>{SSUSR_RowId}</Expression>
<StartValue>1</StartValue>
<StopValue>999999999</StopValue>
</Subscript>
<Type>index</Type>
</SQLMap>
<SqlRowIdName>SSUSR_RowId</SqlRowIdName>
<StreamLocation>^User.SSUserS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
