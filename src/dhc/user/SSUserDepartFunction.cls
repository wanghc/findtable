/// SS User DF Settings(1459)
Class dhc.user.SSUserDepartFunction Extends %Persistent [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlTableName = SS_UserDepartFunction, StorageStrategy = SQLStorage ]
{

/// Childsub
Property DFChildsub As %Float [ InitialExpression = {$INCREMENT(^SST("SSUSR",$PIECE(%d(0),$CHAR(1)),"DF",0))}, SqlColumnNumber = 2, SqlFieldName = DF_Childsub ];

/// Column
Property DFColumn As %String(COLLATION = "Exact", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = DF_Column ];

/// SS_User Parent Reference
Relationship DFParRef As dhc.user.SSUser [ Cardinality = parent, Inverse = ChildSSUserDepartFunction, Required, SqlFieldName = DF_ParRef ];

/// TableName
Property DFTableName As %String(COLLATION = "AlphaUp", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 3, SqlFieldName = DF_TableName ];

/// Column Width
Property DFWidth As %String(COLLATION = "Exact", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = DF_Width ];

Index RowIDBasedIDKeyIndex On DFChildsub [ IdKey, PrimaryKey, Unique ];

Storage SQLStorage
{
<SQLMap name="DataMaster">
<Data name="DF_Column">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="DF_TableName">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="DF_Width">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Global>^SST</Global>
<RowIdSpec name="1">
<Expression>{L2}</Expression>
<Field>SS_User.SSUSR_RowId</Field>
</RowIdSpec>
<RowIdSpec name="2">
<Expression>{L4}</Expression>
<Field>DF_Childsub</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<Expression>"SSUSR"</Expression>
</Subscript>
<Subscript name="2">
<Expression>{SS_User.SSUSR_RowId}</Expression>
</Subscript>
<Subscript name="3">
<Expression>"DF"</Expression>
</Subscript>
<Subscript name="4">
<Expression>{DF_Childsub}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<SqlRowIdName>DF_RowId</SqlRowIdName>
<StreamLocation>^User.SSUserDepartFunctionS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
