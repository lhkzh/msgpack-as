package u14.msgpack
{
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	public class MessageUnPacker
	{
		public static function unpack(buffer:IDataInput):Object{
			var value:int = buffer.readByte();
			/*if (value < 0) {
				throw new RangeError("No more input available when expecting a value");
			}*/
			if(Code.isFixInt(value)) {
				return value;
			}
			else if(Code.isFixedArray(value)){
				return unpackList(value & 0x0f, buffer);
			}
			else if(Code.isFixedMap(value)){
				return unpackMap(value & 0x0f, buffer);
			}
			else if (Code.isFixStr(value)){
				return unpackString(value & 0x1f, buffer);
			} 
			else if (Code.isFixedRaw(value)){
				return unpackBinary(value & 0x1f, buffer);
			} 
			else{
				switch (value) {
					case Code.NIL:
						return null;
					case Code.FALSE:
						return false;
					case Code.TRUE:
						return true;
					case Code.FLOAT32:
						return buffer.readFloat();
						case Code.FLOAT64:
						return buffer.readDouble();
						
						case Code.INT8: // signed int 8
						return buffer.readByte();
						case Code.INT16:
						return buffer.readShort();
						case Code.INT32:
						return buffer.readInt();
						case Code.INT64: // signed int 64
							return ValueHelper.readInt64(buffer);
						case Code.UINT8:{ // unsigned int 8
							var u8:int = buffer.readByte();
							if(u8 < 0) {
								return (u8 & 0xFF);
							}
							else {
								return u8;
							}
						}
						case Code.UINT16:{ // unsigned int 16
							var u16:int = buffer.readShort();
							if(u16 < 0) {
								return u16 & 0xFFFF;
							}
							else {
								return u16;
							}
						}
						case Code.UINT32:{ // unsigned int 32
							var u32:int = buffer.readInt();
							if(u32 < 0) {
								return (u32 & 0x7fffffff) + 0x80000000;
							} else {
								return u32;
							}
						}
						case Code.UINT64:{ // unsigned int 64
							var u64:Number = ValueHelper.readInt64(buffer);
							return u64;
						}
					case Code.ARRAY16:
						return unpackList(buffer.readShort() & ValueHelper.MAX_16BIT, buffer);
					case Code.ARRAY32:
						return unpackList(buffer.readInt(), buffer);
						
					case Code.MAP16:
						return unpackMap(buffer.readShort() & ValueHelper.MAX_16BIT, buffer);
					case Code.MAP32:
						return unpackMap(buffer.readInt(), buffer);
						
					case Code.STR8:
						return unpackString(buffer.readByte() & 0xff, buffer);
					case Code.STR16:
						return unpackString(buffer.readShort() & ValueHelper.MAX_16BIT, buffer);
					case Code.STR32:
						return unpackString(buffer.readInt(), buffer);
						
					case Code.BIN8:
						return unpackBinary(buffer.readByte() & 0xff, buffer);
					case Code.BIN16:
						return unpackBinary(buffer.readShort() & ValueHelper.MAX_16BIT, buffer);
					case Code.BIN32:
						return unpackBinary(buffer.readInt(), buffer);
				}
			}
			throw new IllegalOperationError("Not implements Msgpack Head:"+value);
			return null;
		}
		protected static function unpackMap(size:int, buffer:IDataInput):Object {
			if (size < 0){
				throw new RangeError("Map to unpack too small!");
			}
			var ret:Object = {};
			for (var i:int = 0; i < size; ++i) {
				var key:Object = unpack(buffer);
				var value:Object = unpack(buffer);
				ret[key] = value;
			}
			if(MsgPack.supportXClass){
				return ValueHelper.fromMap(ret);
			}else{
				return ret;
			}
		}
		protected static function unpackList(size:int, buffer:IDataInput):Object{
			if (size<0){
				throw new RangeError("Array to unpack too small!");
			}
			var ret:Array = [];
			for (var i:int = 0; i < size; ++i) {
				ret.push(unpack(buffer));
			}
			return ret;
		}
		protected static function unpackString(size:int, buffer:IDataInput):String {
			if (size < 0){
				throw new RangeError("String to unpack too small!");
			}
			if(size==0)return "";
			var data:ByteArray = new ByteArray();
			buffer.readBytes(data,0,size);
			return new String(data);
		}
		protected static function unpackBinary(size:int, buffer:IDataInput):ByteArray{
			if (size < 0){
				throw new RangeError("Binary to unpack too small!");
			}
			var data:ByteArray = new ByteArray();
			if(size==0){
				return data;
			}
			buffer.readBytes(data,0,size);
			data.position = 0;
			return data;
		}
	}
}