package u14.msgpack
{
	import flash.utils.ByteArray;

	/**
	 * msgpack-协议头
	 * @author zhangheng
	 */	
	internal class Code
	{
		
		public static function isFixInt(b:int):Boolean{
			var v:int = b & 0xFF;
			return v <= 0x7f || v >= 0xe0;
		}
		
		public static function isPosFixInt(b:int):Boolean{
			return (b & POSFIXINT_MASK) == 0;
		}
		
		public static function isNegFixInt(b:int):Boolean{
			return (b & NEGFIXINT_PREFIX) == NEGFIXINT_PREFIX;
		}
		private static var $_e0:int=ValueHelper.toByte(0xe0);
		public static function isFixStr(b:int):Boolean {
			return (b & $_e0) == Code.FIXSTR_PREFIX;
		}
		private static var $_f0:int=ValueHelper.toByte(0xf0);
		public static function isFixedArray(b:int):Boolean{
			return (b & $_f0) == Code.FIXARRAY_PREFIX;
		}
		
		public static function isFixedMap(b:int):Boolean{
			return (b & $_e0) == Code.FIXMAP_PREFIX;
		}
		
		public static function isFixedRaw(b:int):Boolean{
			return (b & $_e0) == Code.FIXSTR_PREFIX;
		}
		
		public static const POSFIXINT_MASK:int = ValueHelper.toByte(0x80);
		
		public static const FIXMAP_PREFIX:int = ValueHelper.toByte(0x80);
		public static const FIXARRAY_PREFIX:int = ValueHelper.toByte(0x90);
		public static const FIXSTR_PREFIX:int = ValueHelper.toByte(0xa0);
		
		public static const NIL:int = ValueHelper.toByte(0xc0);
		public static const NEVER_USED:int = ValueHelper.toByte(0xc1);
		public static const FALSE:int = ValueHelper.toByte(0xc2);
		public static const TRUE:int = ValueHelper.toByte(0xc3);
		public static const BIN8:int = ValueHelper.toByte(0xc4);
		public static const BIN16:int = ValueHelper.toByte(0xc5);
		public static const BIN32:int = ValueHelper.toByte(0xc6);
		public static const EXT8:int = ValueHelper.toByte(0xc7);
		public static const EXT16:int = ValueHelper.toByte(0xc8);
		public static const EXT32:int = ValueHelper.toByte(0xc9);
		public static const FLOAT32:int = ValueHelper.toByte(0xca);
		public static const FLOAT64:int = ValueHelper.toByte(0xcb);
		public static const UINT8:int = ValueHelper.toByte(0xcc);
		public static const UINT16:int = ValueHelper.toByte(0xcd);
		public static const UINT32:int = ValueHelper.toByte(0xce);
		public static const UINT64:int = ValueHelper.toByte(0xcf);
		
		public static const INT8:int = ValueHelper.toByte(0xd0);
		public static const INT16:int = ValueHelper.toByte(0xd1);
		public static const INT32:int = ValueHelper.toByte(0xd2);
		public static const INT64:int = ValueHelper.toByte(0xd3);
		
		public static const FIXEXT1:int = ValueHelper.toByte(0xd4);
		public static const FIXEXT2:int = ValueHelper.toByte(0xd5);
		public static const FIXEXT4:int = ValueHelper.toByte(0xd6);
		public static const FIXEXT8:int = ValueHelper.toByte(0xd7);
		public static const FIXEXT16:int = ValueHelper.toByte(0xd8);
		
		public static const STR8:int = ValueHelper.toByte(0xd9);
		public static const STR16:int = ValueHelper.toByte(0xda);
		public static const STR32:int = ValueHelper.toByte(0xdb);
		
		public static const ARRAY16:int = ValueHelper.toByte(0xdc);
		public static const ARRAY32:int = ValueHelper.toByte(0xdd);
		
		public static const MAP16:int = ValueHelper.toByte(0xde);
		public static const MAP32:int = ValueHelper.toByte(0xdf);
		
		public static const NEGFIXINT_PREFIX:int = ValueHelper.toByte(0xe0);
		
	}
}