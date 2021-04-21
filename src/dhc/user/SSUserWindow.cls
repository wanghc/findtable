/// SS User Window(1455)
Class dhc.user.SSUserWindow Extends %Persistent [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlTableName = SS_UserWindow, StorageStrategy = SQLStorage ]
{

/// Childsub
Property WINChildsub As %Float [ InitialExpression = {$INCREMENT(^SST("SSUSR",$PIECE(%d(0),$CHAR(1)),"WIN",0))}, SqlColumnNumber = 2, SqlFieldName = WIN_Childsub ];

/// Data
Property WINData As %String(COLLATION = "Exact", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = WIN_Data ];

/// Height
Property WINHeight As %Float [ SqlColumnNumber = 7, SqlFieldName = WIN_Height ];

/// Index
Property WINIndex As %String(COLLATION = "Exact", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = WIN_Index ];

/// Left Coord
Property WINLeftCoord As %Float [ SqlColumnNumber = 5, SqlFieldName = WIN_LeftCoord ];

/// Window Name
Property WINName As %String(COLLATION = "Exact", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 3, SqlFieldName = WIN_Name ];

/// SS_User Parent Reference
Relationship WINParRef As dhc.user.SSUser [ Cardinality = parent, Inverse = ChildSSUserWindow, Required, SqlFieldName = WIN_ParRef ];

/// Top Coord
Property WINTopCoord As %Float [ SqlColumnNumber = 4, SqlFieldName = WIN_TopCoord ];

/// Visible
Property WINVisible As %String(DISPLAYLIST = ",Yes,No", MAXLEN = 3, TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 8, SqlFieldName = WIN_Visible ];

/// Width
Property WINWidth As %Float [ SqlColumnNumber = 6, SqlFieldName = WIN_Width ];

Index RowIDBasedIDKeyIndex On WINChildsub [ IdKey, PrimaryKey, Unique ];

Storage SQLStorage
{
<SQLMap name="DataMaster">
<Data name="WIN_Data">
<Delimiter>"^"</Delimiter>
<Piece>8</Piece>
</Data>
<Data name="WIN_Height">
<Delimiter>"^"</Delimiter>
<Piece>5</Piece>
</Data>
<Data name="WIN_Index">
<Delimiter>"^"</Delimiter>
<Piece>7</Piece>
</Data>
<Data name="WIN_LeftCoord">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Data name="WIN_Name">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="WIN_TopCoord">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="WIN_Visible">
<Delimiter>"^"</Delimiter>
<Piece>6</Piece>
</Data>
<Data name="WIN_Width">
<Delimiter>"^"</Delimiter>
<Piece>4</Piece>
</Data>
<Global>^SST</Global>
<RowIdSpec name="1">
<Expression>{L2}</Expression>
<Field>SS_User.SSUSR_RowId</Field>
</RowIdSpec>
<RowIdSpec name="2">
<Expression>{L4}</Expression>
<Field>WIN_Childsub</Field>
</RowIdSpec>
<Structure>delimited</Structure>
<Subscript name="1">
<Expression>"SSUSR"</Expression>
</Subscript>
<Subscript name="2">
<Expression>{SS_User.SSUSR_RowId}</Expression>
</Subscript>
<Subscript name="3">
<Expression>"WIN"</Expression>
</Subscript>
<Subscript name="4">
<Expression>{WIN_Childsub}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<SqlRowIdName>WIN_RowID</SqlRowIdName>
<StreamLocation>^User.SSUserWindowS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
