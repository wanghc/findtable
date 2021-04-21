/*!
*@author wanghc
*@date
*@desc table handler
*<table>
*<tr> <td> <input id='className'/>               </td>  <td> <input id='indexName'/>             </td> </tr>
*<tr> <td> <label id='classNamez1'>PAAdm</label> </td>  <td> <label id='indexNamez1'>User</label> </td></tr>
*</table>
*input inputid
*label inputidzRowNo 
*/
var DHCTable = { 
	version: 1.0,
	filterFun: function (tbl,id,value){
		//document.body.style.cursor="wait";
		var rows = tbl.rows;
		var len = rows.length;
		var cell,cellValue ;
		var regexp, flag ;
		value = value.toUpperCase() ;
		try{
			if(value.indexOf(".") > -1) {regexp = new RegExp(value); flag = 1;}
			if(value.indexOf("*") > -1) {regexp = new RegExp(value); flag = 1;}
			if(value.indexOf("^") > -1) {regexp = new RegExp(value); flag = 1;}
			if(value.indexOf("$") > -1) {regexp = new RegExp(value); flag = 1;}		
			if(value.indexOf("?") > -1) {regexp = new RegExp(value); flag = 1;}
			if(value.indexOf("+") > -1) {regexp = new RegExp(value); flag = 1;}
		}catch(e){		
			alert(value+" 写法不是正确,/t请写入正确的正则表达式!");
			return;
		}
		while( --len > 1 ){		
			cell = document.getElementById( id+"z"+(len-1) );		
			cellValue = DHC.getValue(cell);
			if( value === "" || value === "*" ){
				rows[len].style.display = "";	 
				continue;
			}				
			if(!flag){	//not contain . * ^ $ ? +
				if ((value === cellValue.toUpperCase())){		
					rows[len].style.display = "";		
				}else{
					rows[len].style.display = "none";	
			}	
			}else{		//contain . * ^ $ ? +
				if(regexp.test(cellValue.toUpperCase())){
					rows[len].style.display = "";
				}else{
					rows[len].style.display = "none";
				} 
			}			
		}
		//document.body.style.cursor="auto";
		//loadTip.hide();
	},
	filterTalbe : function ( tbl,inputRow ) {
		var cells = inputRow.cells ;
		var len = cells.length ;		
		var colNoArr = [];		//value of inputDOMObject is not null column no Array
		var colValueArr = [];	//value of inputDOMObject is not null input value Array
		var i,j,noNullColLen,v,rows;
		for (i = 0 ; i < len ; i++)	{			
			if( cells[i].children.length > 0 ) {
				v = cells[i].children[0].value
				if ( v !== "" ){
					colValueArr.push( new RegExp(v.toUpperCase()) );
					colNoArr.push( i );	//value of inputObj  is not null 
				} 				
			}
		}
		//each rows
		rows = tbl.rows ;
		len = rows.length;
		noNullColLen = colNoArr.length ;
		if ( noNullColLen == 0 ) {
			while( --len > -1 ) rows[len].style.display = "";	//1->-1. 分成二个列表
			return ;			
		}	
		while( --len > -1 ){					//1->0 . 分成二个列表	    		
			for(j = 0 ; j < noNullColLen ; j++ ){		
				td = rows [len].cells[ colNoArr[j] ]
				cellValue = DHC.getValue( td.children[0] ).toUpperCase();
				if( !colValueArr[j].test( cellValue ) ){ 
					rows[len].style.display = "none";
					break; 
				}				
				rows[len].style.display = "";
			}			
		} 		
	},
	/*!
	*@author: wanghc
	*@date: 15:32 2011/11/7
	*@desc filter data
	*/
	tableEnterKeyupHandler : function (e){
		var keycode = DHC.getKeyCode(e) ;
		var input = DHC.getTarget( e );
		var row = DHC.getRow( input );
		var tbl = DHC.getTable( row );
		var len = tbl.rows.length;		
		var index = 0;
		if( keycode === 13) {			
			if ( input.tagName == "INPUT" ){				
				//DHCTable.filterFun(tbl,input.id,input.value);	
				DHCTable.filterTalbe( tbl,row );
			}
		}else if( keycode == 40 ) {
			//down key											
			if ( "undefined" != typeof tbl.preSelectedRow ) {
				index = tbl.preSelectedRow.rowIndex + 1;				
				if ( index < len && index > 0 ) DHCTable.selectRow(tbl.rows[index]);
			}						
		}else if ( keycode==38 ){
			//up key
			if ( "undefined" != typeof tbl.preSelectedRow ) {
				index = tbl.preSelectedRow.rowIndex - 1;	
				if (index < len && index > 0 ) DHCTable.selectRow(tbl.rows[index]);
			}						
		}
	},
	/*!
	*@author: wanghc
	*@date: 11:35 2011/11/8
	*@desc 
	*/
	selectRow : function ( row ){
		var tbl = DHC.getTable( row );
		if ( "undefined" != typeof tbl.preSelectedRow ) {
			tbl.preSelectedRow.className = tbl.preSelectedRowClass ; // 烣复以前的样式
		}
		tbl.preSelectedRow = row;
		tbl.preSelectedRowClass = row.className || "";
		row.className = "RowSelColor";
		if(DHC.isIE) row.setActive();
		row.focus();
	},
	/*!
	*@author: wanghc
	*@date: 15:32 2011/11/7
	*@desc table selectable row
	*/
	tableClickRowHandler : function (e){
		var src = DHC.getTarget(e);
		var row = DHC.getRow(src);
		if(row){		
			DHCTable.selectRow(row);
		}	
	}
}
