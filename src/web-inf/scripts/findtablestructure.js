var tip,pnObj,ntObj,getTableNameListAjax;
//setTimeout用来实现延迟加载,每次访问后台前:比较值与当前值相同(oldValue===newValue)。
var timeoutId ;
var tableNameFocusHandler = function(){
	if(tip.select.length>0) tip.show();
}
/**表名框输入处理函数
*ie 内这种形式的函数要在用之前写
*/
var tableNameKeyUpHandler = function (t){	
	var code = DHC.getKeyCode(t);	
	if((code >= 65 && code <= 90) || (code >= 97 && code <= 122) || code === 8){	//A-Z a-z backspace				
		var pnvalue = pnObj.value.replace (/"/g,"").replace(/,/g,"");
		var ntvalue = ntObj.value.replace (/"/g,"").replace(/,/g,"");
		if(pnvalue === "" || ntvalue === "") {
			tip.updateSelect({});
			tip.hide();
			return ;
		}
		timeoutId = setTimeout("getTableNameList(\""+pnvalue+"\",\""+ ntvalue +"\")",300);
		// getTableNameListCallback($.ajax({url:"../csp/dhctt.request.csp", async: false,data: data, dataType: "json"}).responseText);
	}else if(code === 40){	//向下键头
		if(tip.isShow){
			tip.select.focus();
			tip.select.selectedIndex = 0;
		}else{
			tip.show();
		}
	}else if(code === 13){
		//回车时,查找
		tip.hide();						
		//DHC.fireEvent("find","click");
	}
}
/**
*实现延迟查询
*/
var getTableNameList = function(oldPnValue,oldTnValue){
		if(oldPnValue === pnObj.value && oldTnValue === ntObj.value){						
			var data = {
				packageName: oldPnValue, 
				tableName: oldTnValue,
				act:'getTalbeNameList'
			};
			//$.ajax({url:"../csp/dhctt.request.csp",data: data, dataType: "json",success: getTableNameListCallback });	//Jquery--off			
			DHC.Ajax.req({url: "request.csp",dataType: "json",success: getTableNameListCallback, data: data});
			clearTimeout(timeoutId);
		}
	    if(tip) tip.show();		
		return;
}
var getTableNameListCallback = function (text){	
	tip.updateSelect(text);	
	tip.show();
}
/**
*@author: wanghc
*@date: 
*ie: document.body.onload = inject;
*ff: document.body.onload = inject();
*so document.body.onload = new Function ('inject()');
*document.body.onload = function (){ ..code};
*$(fun)
*/
DHC.onReady(function (){
	tip = new DHC.Tip();	
	ntObj = document.getElementById("tableName");		
	pnObj = document.getElementById("packageName");
	var tnwidth = ntObj.offsetWidth + "px";	   	
	tip.renderTo(ntObj);
	tip.addSelect({},{
		style: {width: tnwidth},
		size: 12
	});		
	DHC.addEventListener(ntObj,"keyup", tableNameKeyUpHandler);
	//DHC.addEventListener(ntObj,"blur", tableNameBlurHandler);
	//DHC.addEventListener(ntObj,"focus", tableNameFocusHandler);
});