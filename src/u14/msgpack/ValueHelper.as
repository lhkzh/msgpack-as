package u14.msgpack
{
	
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.getQualifiedClassName;

	public class ValueHelper
	{
		private static var s_buffer:ByteArray = new ByteArray();
		public static function toByte(n:int):int{
			s_buffer.writeByte(n);
			s_buffer.position=0;
			var m:int = s_buffer.readByte();
			s_buffer.clear();
			return m;
		}	
		
		public static function toStringBytes(str:String):ByteArray{
			var buffer:ByteArray = new ByteArray();
			buffer.writeUTFBytes(str);
			buffer.position = 0;
			return buffer;
		}
		
		
		public static const MAX_4BIT:int = 0xf;
		public static const MAX_5BIT:int = 0x1f;
		public static const MAX_7BIT:int = 0x7f;
		public static const MAX_8BIT:int = 0xff;
		//	public static const MAX_15BIT:int = 0x7fff;
		public static const MAX_16BIT:int = 0xffff;
		public static const MIN_16BIT:int = -32768;//-(1 << 15);
		//	public static const MAX_31BIT:int = 0x7fffffff;
		public static const MAX_32BIT:uint = 0xffffffff;
		
		public static function readUint(buffer:IDataInput):Number
		{
			//4294967296 = Math.pow(2, 32)
			var h:Number = buffer.readUnsignedInt();
			var l:Number = buffer.readUnsignedInt();
			var num:Number = 0;
			if(buffer.endian==Endian.BIG_ENDIAN){
				num = h * 4294967296 + l;
			}else{
				num = l * 4294967296 + h;
			}
			return num;
//			var a:int = buffer.readUnsignedInt();
//			var b:int = buffer.readUnsignedInt();
//			var little:Boolean = buffer.endian==Endian.LITTLE_ENDIAN;
//			return Long.fromBits(little?a:b, little?b:a, false).toNumber();
		}
		
		public static function writeUint(buffer:IDataOutput, num:Number):void{
			var h:Number,l:Number;
			if(num<4294967296){
				h = 0;l=num;
			}else{
				h = int(num/4294967296);
				l = num - h*4294967296;
			}
			var b:Boolean = buffer.endian==Endian.BIG_ENDIAN;
			buffer.writeUnsignedInt(b ? h:l);
			buffer.writeUnsignedInt(b ? l:h);
		}
		
		public static function writeInt64(buffer:IDataOutput, num:Number):IDataOutput{
			var value:Long = Long.fromNumber(num);
			var little:Boolean = buffer.endian==Endian.LITTLE_ENDIAN;
			buffer.writeInt(little ? value.lowBits:value.highBits);
			buffer.writeInt(little ? value.highBits:value.lowBits);
			return buffer;
		}	
		public static function readInt64(buffer:IDataInput):Number{
			var a:int = buffer.readInt();
			var b:int = buffer.readInt();
			var little:Boolean = buffer.endian==Endian.LITTLE_ENDIAN;
			return Long.fromBits(little?a:b, little?b:a, false).toNumber();
		}
		
		public static function isVector(v:*):Boolean
		{
			return getQualifiedClassName(v).lastIndexOf("::Vector")>0;
		}
		public static function isObject(v:*):Boolean{
			return v is Object && getQualifiedClassName(v)=="Object";
		}
		public static function toMap(obj:Object):Object
		{
			var map:Object = {};
			if(!isObject(obj)){
				var className:String = AsAcc.getClassName(obj);
				map["#@#"] = className;
				var list:Array = AsAcc.findAccList(obj, AsAcc.READ);
				for each(var acc:AsAcc in list){
					map[acc.name] = obj[acc.name];
				}
			}else{
				for(var k:String in obj){
					var v:Object = obj[k];
					map[k] = toBase(v);
				}
			}
			return map;
		}
		public static function fromMap(obj:Object):*{
			if(obj.hasOwnProperty("#@#")){
				var className:String = obj["#@#"];
				if(className.length>0){
					try{
						var clazz:Class = AsAcc.getClass(className);
						if(clazz!=null){
							var ins:* = new clazz();
							var list:Array = AsAcc.findAccList(clazz, AsAcc.WRITE);
							for each(var acc:AsAcc in list){
								if(obj.hasOwnProperty(acc.name)){
									ins[acc.name] = obj[acc.name];
								}
							}
							return ins;
						}
					}catch(e:Error){
						trace(e);
					}
				}
			}
			return obj;
		}
		private static function toBase(v:*):Object{
			if(isSimple(v)){
				return v;
			}else{
				if(v is Array || isVector(v)){
					var arr:Array = [];
					var size:int = v.length;
					for(var i:int=0;i<size;i++){
						arr.push(toBase(v[i]));
					}
					return arr;
				}else{
					return toMap(v);
				}
			}
		}
		private static function isSimple(v:*):Boolean{
			if(v==null)return true;
			if(v is Number)return true;
			if(v is String)return true;
			if(v is Boolean)return true;
			if(v is XML)return true;
			if(v is XMLList)return true;
			if(v is Date)return true;
			return false;
		}
	}
}