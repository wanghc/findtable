/*!
http:js.clicki.cn
@author wanghc
*@date 2011-09-01
*@desc Common method, Handle browser differences
*/
/**
*ie console=undefined 
*/
(function(){
	if ("undefined" === typeof console){		
		var emptyFn = function(){}; 
		console = {
			log: emptyFn,
			debug: emptyFn,
			info: emptyFn,
			warn: emptyFn,
			error: emptyFn,
			assert: emptyFn,
			dir: emptyFn,
			dirxml: emptyFn,
			trace: emptyFn,
			group: emptyFn,
			groupCollapsed: emptyFn,
			time: emptyFn,
			timeEnd: emptyFn,
			profile: emptyFn,
			profileEnd: emptyFn,
			count: emptyFn,
			clear: emptyFn
		};
	}
	var Level = {
        DEBUG: 1,
        INFO: 2,
        WARN: 3,
        ERROR: 4
    };

    var Logger = function () {
        this.level = Level.DEBUG;
    };
    Logger.prototype = {
        log: function (msg) {
            try { console.log(msg); } catch (ex) { }
        },
        debug: function (msg) {
            if (this.level <= Level.DEBUG) {
                this.log(msg);
				console.trace();
            }
        },
        info: function (msg) {
            if (this.level <= Level.INFO) {
                this.log(msg);
            }
        },
        warn: function (msg) {
            if (this.level <= Level.WARN) {
                console.warn(msg);
				console.trace();
            }
        },
        error: function (msg) {
            if (this.level <= Level.ERROR) {
                this.log(msg);
				console.trace();
            }
        }
    };
	logger = new Logger();
})();
String.prototype.trim = function(){
	return this.replace(/(^\s+)|(\s+$)/g,"");
}
DHC = {
	verison : '1.0',
	isIE: (function () {
		var ua = navigator.userAgent.toLowerCase(), check = function (r) {	return r.test(ua); }, DOC = document, isOpera = check(/opera/), isIE = !isOpera && check(/msie/);
		return isIE;
	})(),
	emptyFn : function () {},
	/**
	*@param {Object} aim
	*@param {Object} src
	*@desc  {src} copy of the property to {aim} 
	*/
	copy : function ( aim, src ) {
		for (var p in src) {		
			if ("object" === typeof src[p]) {
				DHC.copy (aim[p], src[p]);
			}else{
				if (!aim[p]) aim[p] = src[p];
			}
		}
	},
	/*!
	var Mixin = function() {};
	Mixin.prototype = {
  		serialize: function() {
    		var output = [];
    		for(key in this) {
    	  		output.push(key + ': ' + this[key]);
    		}
    		return output.join(', ');
  		}
	};
	augment(Author, Mixin);
	var author = new Author('Ross Harmes', ['JavaScript Design Patterns']);
	var serializedString = author.serialize(); 
	*/
	augment: function (receivingClass, givingClass) {
		if(arguments[2]) { // Only give certain methods.
  		  	for(var i = 2, len = arguments.length; i < len; i++) {
  			  	receivingClass.prototype[arguments[i]] = givingClass.prototype[arguments[i]];
  		  	}
  		}else { // Give all methods.
	    	for(methodName in givingClass.prototype) { 
	    		if(!receivingClass.prototype[methodName]) {
	        		receivingClass.prototype[methodName] = givingClass.prototype[methodName];
	      		}
	    	}	
  		}
	},
	/*!
	*@author: wanghc
	*@date: 10:20 2011/11/11
	*@desc prototype inheritance
	var Person = {
  	 	name: 'default name',
  		getName: function() {
	  		return this.name;
	  	}
	};
	var Auther = DHC.clone( Person );
	
	var auther = DHC.clone( Auther );
	var name = auther.getName();
	*/
	clone : function ( object ) {
		function F() {};
		F.prototype = object;
		return new F;	//<=> new F ()
	},	
	/*!
	*@author: wanghc
	*@date: 10:21 2011/11/11
	*@desc class inheritance
	function Person(name) {
  		this.name = name;
	}
	Person.prototype.getName = function() {
  		return this.name;
	}
	function Author(name, books) {
  		Author.superclass.constructor.call(this, name);
  		this.books = books;
	}
	DHC.extend(Author, Person);
	Author.prototype.getBooks = function() {
	  return this.books;
	};
	*/
	extend : function(subClass, superClass) {
		var F = function() {};
		F.prototype = superClass.prototype;
		subClass.prototype = new F();
		subClass.prototype.constructor = subClass;
		subClass.superclass = superClass.prototype;
		if(superClass.prototype.constructor == Object.prototype.constructor) {
			superClass.prototype.constructor = superClass;
		}
	},
	createOption : function(value,text,o){
		if(arguments.length<3) o = document.createElement("option");
		o.value = value;
		DHC.isIE ? (o.innerText = text) : (o.text = text)  ; //ie->innerText, ff->text	
		return o;
	},	
	/**
	*@param {Object/json} evalue  	{s:student} <=> <option value="s">student</option> 
	*@param {Object} config  		PropertyObject of Html<select>
	*/
	createSelectElement : function(evalue,config){
		var select = document.createElement("select");	
		var v = evalue || {};
		for (var i in v){	
			select.appendChild(DHC.createOption(i,evalue[i]));		
		}
		DHC.copy(select,config)
		return select;
	},
	/**
	*@param {HTMLDOM} o
	*@return {Array} [left,top]
	*@desc get absolute position of {o}
	*/
	getOffset : function(o){
		ntLeft = o.offsetLeft ;
		ntTop = o.offsetTop + o.offsetHeight ;
		while(o = o.offsetParent){
			ntLeft += o.offsetLeft;
			ntTop += o.offsetTop;
		}
		return [ntLeft,ntTop];		
	},
	/**
	*@param {HTMLDOM} o 
	*@param {Array} xy
	*/
	setOffset : function (o,xy){
		DHC.isIE ? o.style.pixelLeft = xy[0] : o.style.left = xy[0] ; 
		DHC.isIE ? o.style.pixelTop = xy[1] : o.style.top = xy[1] ;
	},
	addEventListener : function(obj,type,fn){
		//if(!obj) {logger.warn("method addEventListener : arg0 is null!"); return};
		if(!obj) {return};
		if("function" !== typeof fn) return;
		if(obj.length){			
			for(var i =0,len = obj.length; i<len ; i++) this.addEventListener(obj[i],type,fn);
		}else if("object" === typeof obj){			
			DHC.isIE ?  obj.attachEvent("on"+type,fn) : obj.addEventListener(type,fn,false);   // useCapture = false
		}
	},
	removeEventListener : function(obj,type,fn){
		if(!obj) {return};
		if("function" !== typeof fn) return;
		DHC.isIE ? obj.detachEvent("on"+type,fn) : obj.removeEventListener(type,fn,false);
	},
	eventCancel : function(){
		if (window.event)
			window.event.cancelBubble=true;
		return false;
	},
	getElementsByClassName : function (searchClass,node,tag) {
		if(document.getElementsByClassName){
			return (node || document).getElementsByClassName(searchClass)
		}else{
			  node = node || document;
			  tag = tag || "*";
			  var classes = searchClass.split(" "),
			  elements = (tag === "*" && node.all)? node.all : node.getElementsByTagName(tag),
			  patterns = [],
			  current,
			  match;
			  var i = classes.length;
			  while(--i >= 0){
				patterns.push(new RegExp("(^|\\s)" + classes[i] + "(\\s|$)"));
			  }
			  var j = elements.length;
			  while(--j >= 0){
				current = elements[j];
				match = false;
				for(var k=0, kl=patterns.length; k<kl; k++){
				  match = patterns[k].test(current.className);
				  if (!match)  break;
				}
				if (match)  result.push(current);
			  }
			  return result;
		}
	 },
	getParentElement : function (obj) {
		return DHC.isIE ? obj.parentElement : obj.parentNode;
	},
	getEvent: function (e){
		return e || window.event;
	},
	getTarget : function (e){
		return DHC.isIE ? e.srcElement : e.target;
	},
	stopPropagation: function (e){
		if (e.stopPropagation){
			e.stopPropagation();
		}else{
			e.cancleBubble = true;
		}
	},
	preventDefault: function (e){
		if (e.preventDefault){
			e.preventDefault();
		}else{
			e.returnValue = false;
		}
	},
	stopEvent: function (e){
		this.stopPropagation(e);
		this.preventDefault(e);		
	},
	getRow : function (eSrc){
		if (eSrc) {
			while(eSrc && eSrc.tagName != "TR") {if (eSrc.tagName == "TH") break; eSrc = this.getParentElement(eSrc);}			
		};
		return eSrc;
	},
	getTable : function (eSrc) {
		if ((eSrc)&&(eSrc.tagName)) while(eSrc && eSrc.tagName != "TABLE") {eSrc = this.getParentElement(eSrc);}
		return eSrc;
	},
	/**
	*By "xpath" find domlist 
	*@param {HTMLDOM} el
	*@param {String} xpath
	*/
	evaluate : function(el,xpath){
		if (DHC.isIE){
			el.setProperty("SelectionLanguage","XPath");
			return el.selectNodes(xpath);
		}else{
			var r = [];			
			var nodes = document.evaluate(xpath, el, null, XPathResult.ANY_TYPE,null);
			var result = nodes.iterateNext();
			while (result){		
				r.push(result);
				result = nodes.iterateNext();
			}
			return r;
		}
	},
 	getKeyCode : function (e) {
		return window.event ? window.event.keyCode : e.which;
	},
	isAltKey : function(e){
		return window.event ? window.event.altKey : e.altKey;
	},
	isCtrlKey : function(e){
		return window.event ? window.event.ctrlKey : e.ctrlKey;
	},
	/**
	*get HTMLDOM Object value
	*@param: {Object | HTMLDOM} obj
	*<talbe><td>-->LABEL
	*/
	getValue : function (obj){
		if (!obj) return "" ;
		var v = "";
		if(!obj.tagName) return "";
		switch (obj.tagName){
			case "INPUT":
				v = obj.value;
				if(obj.type=="checkbox"){
					v = obj.checked;			
				}else if(obj.type=="select-one"){
					v = obj.options[obj.selectedIndex].text
				}
				break;
			case "LABEL":			
				v = obj.innerText || obj.textContent;	//table-td  IE-innerText ff-textContent
				break;
			case "SELECT":
				v = obj.options[obj.selectedIndex].value;
				break;
			default:
				v = obj.value || obj.textContent;
				break;
		}
		if ("undefined" == typeof v) v="";
		return v;
	},
	/**
	*@param {String | HTMLDOM} obj    dom.id | dom
	*@param {String} type  EventType    ex: "click"
	*fire typeEvent of {obj} 
	*/
	fireEvent : function (obj, type){		
		//eval("document.getElementById(\""+id+"\")." + type + "();"); //--> fire a.href a.onclick
		if("string" === typeof obj) obj = document.getElementById(obj);
		
		//not fire a.href, but fire a.onclick
		if(DHC.isIE) {  
			obj.fireEvent("on"+type);  
		}else{
			var evt = document.createEvent('HTMLEvents');  
			evt.initEvent(type,true,true);  
			obj.dispatchEvent(evt);  
		}		
	},
	/**
	*@param {String} id
	*/
	setFocus2 : function (id) {
		var obj = document.getElementById(id);
		if (obj) {
			try {
				obj.focus();
				//obj.select();
			} catch(e) {}
		}
	},
	/**
	*@param {String} id
	*/
	setFocus : function (id){
		setTimeout('DHC.setFocus2(\"'+id+'\")',50);		
	},
	getXhr : function () {
		if(DHC.isIE){
			try {
				return new ActiveXObject("Microsoft.XMLHTTP");
 			} catch (e) {
				try {
 		 			 return new ActiveXObject("Msxml2.XMLHTTP");
				} catch (E) {
					alert(E);
				}
			}
		}else{
			return new XMLHttpRequest();
		}
	},
	jsonToUrl: function (json) {
		var rtn = "zDataTimeStampID=" + Math.floor(Math.random()*100);	//url add timestamp
		if ( ("object" !== typeof json) || (json == {}) ) return rtn; 		
		for ( var i in json ){
			rtn += "&" + i + "=" + encodeURIComponent(json[i]) ;
		}
		return rtn ;
	},
	/**
	*@author: wanghc
	*@date: 
	*jQuery
	*/
	parseJSON: function (data) {
		//var pre = "{} && "
		var pre="";
		data = DHC.trim( data );
		return window.JSON && window.JSON.parse ? window.JSON.parse( pre + data ) : ( new Function("return " + (pre+data)) )();
		//return eval('(' + data + ')');
		//RFC 4627 中给出的检查 JSON 字符串的方法
		//var my_JSON_object = !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(data.replace(/"(\\.|[^"\\])*"/g, ''))) && eval('(' + data + ')');
		return json;
	},
	trim: function (str) {
		return str.replace(/(^\s+)|(\s+$)/g,"");
	},
	/*!
	*@author: wanghc
	*@date: 
	*@desc: ie: document.body.onload / onreadystatechange, ff: DOMContentLoaded
	*If the DOM is already ready,fn go
	*ref jQuery
	*ie: onreadystatechange="complete" image/iframe loaded	--slow
	*ff: DOMContentLoaded     dom parsed					--fast			
	*/
	onReady: function (fn){		
		if( "function" === typeof fn ) {			
			if ( DHC.isIE ) {		
				document.attachEvent("onreadystatechange", function() {
					if ( document.readyState === "complete" ) {
						fn.call( document );
					}
				});			
			}else{
				document.addEventListener( "DOMContentLoaded", fn, false );
			}	 		
		}	
	},
	loadXML : function (xmlstr){
		if(DHC.isIE){
			var xmlDoc = new ActiveXObject('Msxml2.DOMDocument');
			return xmlDoc.loadXML(xmlstr);
		}else{
			return (new DOMParser()).parseFromString(xmlstr);
		}
	},
	loadXMLFile : function (xmlfile){
   		if (DHC.isIE){
        	xmlDoc = new ActiveXObject('Msxml2.DOMDocument');
        	xmlDoc.async=false;
        	xmlDoc.load(xmlfile);
			return xmlDoc;
    	}else if (document.implementation && document.implementation.createDocument){
       		var xmlhttp = new window.XMLHttpRequest();
       	 	xmlhttp.open("GET",xmlfile,false);        	
        	xmlhttp.send(null);
        	xmlDoc = xmlhttp.responseXML.documentElement;   
			return xmlDoc;			
    	}else{
        	alert( '未做与该浏览器的兼容！');
    	}
	},
	setTextAreaPlace : function(textBox,start,end){
		//如果是Firefox(1.5)的话，方法很简单
        if(typeof(textBox.selectionStart) == "number"){
            textBox.selectionStart = start;
            textBox.selectionEnd = end;
        }else if(document.selection){	//下面是IE(6.0)的方法，麻烦得很，还要计算上'/n'
            var sel = textBox.createTextRange();
	        sel.moveStart('character',start);
	        sel.collapse();
	        sel.select();	        
        }
        DHC.setFocus(textBox.id);
        return ;
	},
	getTextAreaPlace : function (textBox){
        //如果是Firefox(1.5)的话，方法很简单
        if(typeof(textBox.selectionStart) == "number"){
            start = textBox.selectionStart;
            end = textBox.selectionEnd;
        }else if(document.selection){	//下面是IE(6.0)的方法，麻烦得很，还要计算上'/n'
            var range = document.selection.createRange();
            if(range.parentElement().id == textBox.id){
                // create a selection of the whole textarea
                var range_all = document.body.createTextRange();
                range_all.moveToElementText(textBox);
                //两个range，一个是已经选择的text(range)，一个是整个textarea(range_all)
                //range_all.compareEndPoints() 比较两个端点，如果range_all比range更往左(further to the left)，则                //返回小于0的值，则range_all往右移一点，直到两个range的start相同。
                // calculate selection start point by moving beginning of range_all to beginning of range
                for (start=0; range_all.compareEndPoints("StartToStart", range) < 0; start++)
                    range_all.moveStart('character', 1);
                // get number of line breaks from textarea start to selection start and add them to start
                // 计算一下/n
                for (var i = 0; i <= start; i ++){
                    if (textBox.value.charAt(i) == '/n')
                        start++;
                }
                // create a selection of the whole textarea
                 var range_all = document.body.createTextRange();
                 range_all.moveToElementText(textBox);
                 // calculate selection end point by moving beginning of range_all to end of range
                 for (end = 0; range_all.compareEndPoints('StartToEnd', range) < 0; end ++)
                     range_all.moveStart('character', 1);
                     // get number of line breaks from textarea start to selection end and add them to end
                     for (var i = 0; i <= end; i ++){
                         if (textBox.value.charAt(i) == '/n')
                             end ++;
                     }
                }
            }
        return [start,end];
    }

};
/*!
*@param {json} config {url: "xx.csp", data: {query: "DHCPatient"}, type:"GET", dataType: "json", async: true, success: function handler(obj){}}	
**-------------------------------
**handler(obj){} 
**dataType: "" 		obj->XMLHTTPRequest.innerText
**dataType: "json"  obj->eval(xhr.innerText)
**dataType: "xhr"   obj->XMLHTTPRequest
**--------------------------------
*@desc see jquery's $.ajax method
*/
DHC.Ajax = {version: 1.0};
DHC.Ajax.req = function ( config ) {
		var req = DHC.getXhr();;
		if ( req ) { 			
			var type = config.type || "GET";	
			var url = config.url || "#";	
			var data = config.data || {} ;	//json
			var dataType = config.dataType || "";	//requesttext json request
			var async = config.async || true;			
			data = DHC.jsonToUrl( data );
			req.onreadystatechange = function ( XMLHttpRequestProgressEvent ) {					
				if(req.readyState == 4) {
				    if(req.status != 200 ){
						alert(" status != 200 "+req.statusText+" status "+req.status); 
						return null ; 
					}
					var succfun = config.success || DHC.emptyFn;
					if (async && succfun != DHC.emptyFn){					
						var result = req.responseText ;
				        if (dataType == "xhr"){
							succfun ( req );
						}else if (dataType == "json"){
							succfun ( DHC.parseJSON( result ) );
						}else{
							succfun ( result );
						}
					}
				}
			};			
			if ( type === "GET" ) {
				req.open("GET", url + "?" + data,async);
				if(DHC.isIE){req.send();}
				else{req.send(null);}
			}else{
				req.open("POST",url,async);
				req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				req.send(data);
			}
			if( async ){
				return null;
			}
			if(req.readyState == 4) {
				if(r.status == 200 ){
					return req.responseText;
				}
			}
			return null
		}
}
/**
*DHC.Tip is tip Div
*@param {Object/json} 
**@config {String} className  default="tipDiv"

*@property {boolean} active default=true->Function of TipObject is Enabled
*@property {HTMLDOM} div	new DHC.Tip().div
*@desc: Tip layer 
*/
DHC.Tip = function ( config ){
	this.active = true ;
	this.div = null;	
	this.div = document.createElement("div");
	this.div.style.display = "none";
	this.div.zIndex = 12;
	this.div.className = arguments.length>0 ? (config.className || "tipDiv") : "tipDiv";					
	document.body.appendChild(this.div);	
};

DHC.Tip.prototype = {	
	/**
	*@param {HTMLDOM} dom
	*@desc Under the TipObjectLayer  into {dom} 
 	*/
	renderTo : function (dom){
		var type = typeof dom ;		
		if( "object" === type ) {						
			DHC.setOffset(this.div, DHC.getOffset(dom));
			this.div.style.position = "absolute";
			this.srcDom = dom; 
		}	
	},
	/**
	*@param: {String} text  The content of display
	*@param: {Array} xy   [x,y] The position 
	*/
	show : function (text,xy){
		if(!this.active) return ;
		if("undefined" !== typeof text && text) this.div.innerText = text;
		if("undefined" !== typeof xy && (xy instanceof Array)) {
			this.div.style.pixelLeft = xy[0] ; 
			this.div.style.pixelTop = xy[1];
			this.div.style.position = "absolute";
		}
		this.div.style.display = "" ;
		this.isShow = true;
	},
	hide : function (){
		if(!this.active) return ;	
		this.div.style.display = "none";
		this.isShow = false;		
	},
	/**
	*@desc abort function of tipObject
	*/
	abort : function (){
		this.active = false;
	},
	/**
	*@desc resume function of tipObject
	*/
	resume : function (){
		this.active = true;
	},
	/**
	*@param {Object/json} evalue {value1: text1,value2: text2}
	*@param {Object} config {style: {width: 100},size: 12}	PropertyObject of Html<Select> 
	*@desc create ComboBox Object <=> Html<select/>.  eventHander(key=EnterKey,Upkey,dblclick)
	*
	*/
	addSelect : function( evalue,config ){
		var tmp = this;
		tmp.select = DHC.createSelectElement( evalue,config );
		tmp.div.appendChild (tmp.select);
		if( "undefined" === typeof tmp.srcDom ) {throw("在用addSelect方法前,先renderTo下")};
		DHC.addEventListener (tmp.select,"keyup", function (t){
			var k = DHC.getKeyCode(t);
			if(k === 13){
				if(tmp.SelectedEnterCallBack){
					tmp.SelectedEnterCallBack.call(tmp,tmp.select);
				}else{
					if(!tmp.SelectedAddText) {
						tmp.srcDom.value = tmp.select.value;
					}										
				}
				tmp.hide();
				DHC.setFocus(tmp.srcDom.id);
			}else if(k === 38 && tmp.select.selectedIndex === 0){	//38 up key
				DHC.setFocus(tmp.srcDom.id);
			}
		})
		DHC.addEventListener (tmp.select,"dblclick", function (e) {			
			if(tmp.SelectedEnterCallBack){
				tmp.SelectedEnterCallBack.call(tmp,tmp.select);
			}else{
				if(!tmp.SelectedAddText) tmp.srcDom.value = tmp.select.value;				
			}
			tmp.hide();
			DHC.setFocus(tmp.srcDom.id);
		});
		DHC.addEventListener(tmp.srcDom,"focus",function(e){
			tmp.isFocus = true;
		});	
		DHC.addEventListener(tmp.srcDom,"blur",function(e){			
			tmp.isFocus = false;
			setTimeout(function(a){
					return function() {if(!a.isFocus) a.hide()};
			}(tmp), 30);
		});
		DHC.addEventListener(tmp.select,"focus",function(e){				
			tmp.isFocus = true;
		});		
		DHC.addEventListener(tmp.select,"blur",function(e){				
			tmp.isFocus = false;
			setTimeout(function(a){
				return function() {if(!a.isFocus) a.hide()};
			}(tmp), 30);
		});
	},
	/**
	 * 传入数组解析出html
	 * @param {Array} arr   下拉框的数组
	 * @param {String} preValue 匹配值	 
	 */
	setArrayStore : function(arr, preValue){
		this.filterWord = preValue;
		this.arrStore = arr;
		this.doFilter();		
	},
	updatePreValue: function(preValue){
		this.filterWord = preValue;
		this.doFilter();
	},
	doFilter : function(){		
		var word = this.filterWord || "";
		var upperLastValue = word.toUpperCase();
		var tmpobj={};
		var arr = this.arrStore;
		if(arr.length){
			for (var i = 0; i<=arr.length-1; i++) {
			 	if(arr[i].toUpperCase().indexOf(upperLastValue)>-1){		 		
			 		tmpobj[arr[i]] = arr[i];
			 	}
			};
		}
		this.updateSelect(tmpobj);
	},
	/**
	*update TipObject.select.value list
	*@param {Object/Json} evalue  
	*{value1: text1,value2: text2}
	*<=>
	*<select>
	*<option value='value1'>text1</option>
	*<option value='value2'>text2</option>
	*</select>
	*/
	updateSelect : function(evalue){	
		//if("string" ===  typeof evalue) evalue = eval("("+evalue+")"); //eval function is not safe
		if("object" !== typeof evalue) return ;	
		var options = this.select.getElementsByTagName("option");	
		var len = options.length;	
		while(len){
			this.select.removeChild(options[len-1]);
			len--;
		}
		var count = 0;	
		for (var i in evalue){
			if(count<100){		
				this.select.appendChild(DHC.createOption(i,evalue[i]));
				count++;
			}else{
				return ;
			}			
		}
	}
};

DHC.isIE?Array.prototype.indexOf=function(o, from){
    var len = this.length;
    from = from || 0;
    from += (from < 0) ? len : 0;
    for (; from < len; ++from){
        if(this[from] === o){
            return from;
        }
    }
    return -1;
}:""

DHC.AutoCompleter = function(){
	
}