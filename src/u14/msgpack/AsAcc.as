package u14.msgpack
{
	
	import flash.system.ApplicationDomain;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	/**
	 * as-类解析
	 * @author zhangheng
	 */	
	public class AsAcc
	{
		private static var cache:Dictionary = new Dictionary();
		private static function __clearCache(clzz:Object, xml:XML):void
		{
			if(System["disposeXML"] is Function)
				System["disposeXML"](xml);
			delete cache[clzz];
		}
		
		public static function getClassName(cls:Object):String
		{
			var name:String = getQualifiedClassName(cls);
			return name.replace("::",".");
		}
		public static function getSimpleClassName(cls:Object):String
		{
			var n:String = getQualifiedClassName(cls);
			return n.indexOf("::")>0 ? n.split("::")[1]:n;
		}
		public static function getClass(className:String, domain:ApplicationDomain=null):Class
		{
			domain = domain==null? ApplicationDomain.currentDomain:domain;
			if(!domain.hasDefinition(className)){
				return null;
			}
			return domain.getDefinition(className) as Class;
		}
		public static function fromClassName(className:String, domain:ApplicationDomain=null):*
		{
			return new (getClass(className,domain))();
		}
		
		public static const READ:int = 1;
		public static const WRITE:int = 2;
		public static const READ_OR_WRITE:int = 3;
		public static const READ_AND_WRITE:int = 0;
		
		public static var flashAcc:Boolean = false;
//		public static var flashImport:Vector.<String> = new Vector.<String>("x","y","z","scaleX","scaleY","scaleZ","alpha");
		
		public static function findAccList(clss:Object, type:int=6):Array
		{
			var clss_Class:*=flash.utils.getDefinitionByName(getQualifiedClassName(clss));
			if(clss_Class!=null && clss_Class!=clss){
				clss = clss_Class;
			}
			var arr:Array=cache[clss];
			if(arr==null){
				var xml:XML = describeType(clss);
				if(xml.toString()==""){
					return [];
				}
				if(xml.@base=="Class"){
					xml = xml.factory[0];
				}
				setTimeout(__clearCache,15000,clss,xml);
				//			var properties:XMLList = clss is Class ? xml.factory.accessor : xml.accessor;
				var properties:XMLList = xml.accessor;
				arr=[];
				var node:XML;
				for each (node in properties) {
					if(!flashAcc){
						if(String(node.@declaredBy).indexOf("flash.")==0){
							continue;
						}
					}
					arr.push(new AsAcc(node));
				}
				properties = xml.variable;
				for each (node in properties) {
					if(!flashAcc){
						if(String(node.@declaredBy).indexOf("flash.")==0){
							continue;
						}
					}
					arr.push(new AsAcc(node));
				}
				cache[clss] = arr;
			}
			if(type==READ_OR_WRITE){
				return arr;
			}
			var retArr:Array = [];
			for each(var acc:AsAcc in arr){
				if(type==READ && !acc.readAble){
					continue;
				}
				if(type==WRITE && !acc.writeAble){
					continue;
				}
				if(type==READ_AND_WRITE && !(acc.writeAble && acc.readAble)){
					continue;
				}
				retArr.push(acc);
			}
			return retArr;
		}
		public static function findAccMap(clss:Object, type:int=6):Object
		{
			var arr:Array = findAccList(clss, type);
			var obj:Object = {};
			for each(var acc:AsAcc in arr){
				obj[acc.name] = acc;
			}
			return obj;
		}
		
		private static function fixClassName(n:String):String
		{
//			if(n.indexOf("__AS3__.vec")==0 && n.indexOf("&lt;")){
//				n = n.replace("&lt;","<");
//			}
			return n.replace("&lt;","<");
		}
		
		private var _name:String;
		private var _readAble:Boolean;
		private var _writeAble:Boolean;
		private var _type:String;
		
		public function AsAcc(xml:XML)
		{
			_name = xml.@name;
			var ta:String = xml.@access;
			if(ta==""){
				_readAble = true;
				_writeAble = true;
			}else{
				_readAble = ta=="readwrite" || ta=="readonly";
				_writeAble = ta=="readwrite" || ta=="writeonly";
			}
			_type = fixClassName(xml.@type);
		}
		
		
		public function get name():String
		{
			return _name;
		}
		/**
		 * 是否可读
		 * @return 
		 */		
		public function get readAble():Boolean
		{
			return _readAble;
		}
		/**
		 * 是否可写
		 * @return 
		 */		
		public function get writeAble():Boolean
		{
			return _writeAble;
		}
		/**
		 * 类型
		 * @return 
		 */		
		public function get type():String
		{
			return _type;
		}
		
		public function toString():String
		{
//			return _name;
			return '{name:'+_name+",type:"+_type+"}";
		}
		
	}
}