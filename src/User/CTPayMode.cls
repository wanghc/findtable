/// CT Payment Mode          (CTPM,199)
Class User.CTPayMode Extends %Persistent [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlTableName = CT_PayMode, StorageStrategy = SQLStorage ]
{

Parameter EXTENTSIZE = 6;

/// Payment Mode
Property CTPMCode As %String(COLLATION = "AlphaUp", MAXLEN = 15, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = CTPM_Code ];

/// Payment Mode Description
Property CTPMDesc As %String(COLLATION = "AlphaUp", MAXLEN = 220, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = CTPM_Desc ];

/// Not Used Flag
Property CTPMNotUseFlag As %String(DISPLAYLIST = ",Yes,No", MAXLEN = 3, TRUNCATE = 1, VALUELIST = ",Y,N") [ InitialExpression = "N", Required, SqlColumnNumber = 4, SqlFieldName = CTPM_NotUseFlag ];

/// Payment Group 
Property CTPMGrpCode As %String(DISPLAYLIST = ",Cash,Card,Cheque,DirectPayment", MAXLEN = 13, TRUNCATE = 1, VALUELIST = ",CH,CC,CQ,DP") [ SqlColumnNumber = 5, SqlFieldName = CTPM_GrpCode ];

/// Date From
Property CTPMDateFrom As %Date [ SqlColumnNumber = 6, SqlFieldName = CTPM_DateFrom ];

/// Date To
Property CTPMDateTo As %Date [ SqlColumnNumber = 7, SqlFieldName = CTPM_DateTo ];

/// ChangeGiven
Property CTPMChangeGiven As %String(DISPLAYLIST = ",Yes,No", MAXLEN = 3, TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 8, SqlFieldName = CTPM_ChangeGiven ];

Index CTPMCodeUnqIdx1 On CTPMCode [ Unique ];

Storage SQLStorage
{
<ExtentSize>100000</ExtentSize>
<Property name="CTPMChangeGiven">
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="CTPMCode">
<Selectivity>1</Selectivity>
</Property>
<Property name="CTPMDateFrom">
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="CTPMDateTo">
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="CTPMDesc">
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="CTPMGrpCode">
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="CTPMNotUseFlag">
<Selectivity>50.0000%</Selectivity>
</Property>
<SqlIdExpression>$i(^CT("CTPM",0))</SqlIdExpression>
<SQLMap name="DataMasterCTPM">
<Data name="CTPM_ChangeGiven">
<Delimiter>"^"</Delimiter>
<Piece>7</Piece>
</Data>
<Data name="CTPM_Code">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="CTPM_DateFrom">
<Delimiter>"^"</Delimiter>
<Piece>5</Piece>
</Data>
<Data name="CTPM_DateTo">
<Delimiter>"^"</Delimiter>
<Piece>6</Piece>
</Data>
<Data name="CTPM_Desc">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="CTPM_GrpCode">
<Delimiter>"^"</Delimiter>
<Piece>4</Piece>
</Data>
<Data name="CTPM_NotUseFlag">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Global>^CT</Global>
<RowIdSpec name="1">
<Expression>{L2}</Expression>
<Field>CTPM_RowId</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>"CTPM"</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>{CTPM_RowId}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<SQLMap name="IndexCTPMCode">
<Global>^CT</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L5}</Expression>
<Field>CTPM_RowId</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>"CTPM"</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>0</Expression>
</Subscript>
<Subscript name="3">
<AccessType>sub</AccessType>
<Expression>"Code"</Expression>
</Subscript>
<Subscript name="4">
<AccessType>sub</AccessType>
<Expression>$$ALPHAUP({CTPM_Code})</Expression>
</Subscript>
<Subscript name="5">
<AccessType>sub</AccessType>
<Expression>{CTPM_RowId}</Expression>
<StartValue>1</StartValue>
<StopValue>999999999</StopValue>
</Subscript>
<Type>index</Type>
</SQLMap>
<SQLMap name="IndexCTPMDesc">
<Global>^CT</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L5}</Expression>
<Field>CTPM_RowId</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<AccessType>sub</AccessType>
<Expression>"CTPM"</Expression>
</Subscript>
<Subscript name="2">
<AccessType>sub</AccessType>
<Expression>0</Expression>
</Subscript>
<Subscript name="3">
<AccessType>sub</AccessType>
<Expression>"Desc"</Expression>
</Subscript>
<Subscript name="4">
<AccessType>sub</AccessType>
<Expression>$$ALPHAUP({CTPM_Desc})</Expression>
</Subscript>
<Subscript name="5">
<AccessType>sub</AccessType>
<Expression>{CTPM_RowId}</Expression>
<StartValue>1</StartValue>
<StopValue>999999999</StopValue>
</Subscript>
<Type>index</Type>
</SQLMap>
<SqlRowIdName>CTPM_RowId</SqlRowIdName>
<StreamLocation>^User.CTPayModeS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
