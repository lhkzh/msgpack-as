package u14.msgpack
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	/**
	 * msgpack操作类
	 * @author zhangheng
	 */	
	public class MsgPack
	{
		/**
		 * 是否支持bean类
		 * @default true 
		 */		
		public static var supportXClass:Boolean = true;
		
		public static function pack(data:Object):ByteArray{
			var b:ByteArray = packTo(data, new ByteArray()) as ByteArray;
			b.position = 0;
			return b;
		}
		
		public static function packTo(data:Object, toOut:IDataOutput):IDataOutput{
			return MessagePacker.pack(data, toOut);
		}
		public static function unpack(bytes:ByteArray):*{
			return MessageUnPacker.unpack(bytes);
		}
		public static function parse(stream:IDataInput):*{
			return MessageUnPacker.unpack(stream);
		}
	}
}