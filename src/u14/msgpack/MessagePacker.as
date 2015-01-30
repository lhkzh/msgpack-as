package u14.msgpack
{
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;

	public class MessagePacker
	{
		public static function pack(v:*, out:IDataOutput):IDataOutput{
			if(v==null){
				out.writeByte(Code.NIL);
			}else if(v is Boolean){
				packBoolean(v, out);
			}
			else if(v is Number){
				packNumber(v, out);
			}else if(v is Date){
				packInteger((v as Date).time, out);
			}
			else if(v is String){
				packString(v, out);
			}else if(v is XML || v is XMLList){
				var b:Boolean = XML.prettyPrinting;
				XML.prettyPrinting = false;
				packString(v, out);
				XML.prettyPrinting = b;
			}
			else if(v is IDataInput){
				packBinary(v, out);
			}else if(v is Array){
				packArray(v, out);
			}else if(ValueHelper.isVector(v)){
				packArray(v, out);
			}else{
				if(MsgPack.supportXClass){
					packMap(ValueHelper.toMap(v), out);
				}else{
					packMap(v, out);
				}
			}
			return out;
		}		
		
		public static function packNil(out:IDataOutput):IDataOutput{
			out.writeByte(Code.NIL);
			return out;
		}
		public static function packBoolean(v:Boolean, out:IDataOutput):IDataOutput{
			out.writeByte(v ? Code.TRUE : Code.FALSE);
			return out;
		}
		public static function packInteger(v:Number, out:IDataOutput):IDataOutput{
			if (v < -32) {//-(1 << 5)
				if (v < ValueHelper.MIN_16BIT) {
					if (v < int.MIN_VALUE) {
						out.writeByte(Code.INT64);
						ValueHelper.writeInt64(out, v);
					}else {
						out.writeByte(Code.INT32);
						out.writeInt(v);
					}
				} else {
					//if (v < -(1 << 7)) {
					if(v<-128){
						out.writeByte(Code.INT16);
						out.writeShort(v);
					} else {
						out.writeByte(Code.INT8);
						out.writeByte(v);
					}
				}
			} else if (v <= ValueHelper.MAX_7BIT) {
				// fixnum
				out.writeByte(v);
			} else {
				if (v <= ValueHelper.MAX_16BIT) {
					if (v <= ValueHelper.MAX_8BIT) {
						out.writeByte(Code.UINT8);
						out.writeByte(v);
					} else {
						out.writeByte(Code.UINT16);
						out.writeShort(v);
					}
				} else {
					if (v <= ValueHelper.MAX_32BIT) {
						out.writeByte(Code.UINT32);
						out.writeInt(v);
					} else {
						out.writeByte(Code.UINT64);
						ValueHelper.writeInt64(out, v);
					}
				}
			}
			return out;
		}
		
		public static function packNumber(v:Number, out:IDataOutput):IDataOutput{
			if(isNaN(v)){
				out.writeByte(Code.FLOAT32);
				out.writeInt(2143289344);
				return out;
			}
			if(v is uint){
				return packInteger(v, out);
			}else if(v is int){
				return packInteger(v, out);
			}else if(v.toString().lastIndexOf(".")<0){
				return packInteger(v, out);
			}
			out.writeByte(Code.FLOAT64);
			out.writeDouble(v);
			return out;
		}
		
		public static function packString(str:String, out:IDataOutput):IDataOutput{
			var bin:ByteArray = ValueHelper.toStringBytes(str);
			var len:int = bin.length;
			if(len <= ValueHelper.MAX_5BIT) {
				out.writeByte((Code.FIXSTR_PREFIX | len));
			} else if(len <= ValueHelper.MAX_8BIT) {
				out.writeByte(Code.STR8);
				out.writeByte(len);
			} else if(len <= ValueHelper.MAX_16BIT) {
				out.writeByte(Code.STR16);
				out.writeShort(len);
			} else {
				out.writeByte(Code.STR32);
				out.writeInt(len);
			}
			out.writeBytes(bin);
			return out;
		}
		public static function packBinary(bin:IDataInput, out:IDataOutput):IDataOutput{
			var len:int = bin.bytesAvailable;
			if(len <= ValueHelper.MAX_8BIT) {
				out.writeByte(Code.BIN8);
				out.writeByte(len);
			} else if(len <= ValueHelper.MAX_16BIT) {
				out.writeByte(Code.BIN16);
				out.writeShort(len);
			} else {
				out.writeByte(Code.BIN32);
				out.writeInt(len);
			}
			if(bin is ByteArray){
				out.writeBytes(bin as ByteArray);
			}else{
				var bytes:ByteArray = new ByteArray();
				bin.readBytes(bytes,0,len);
				out.writeBytes(bytes);
			}
			return out;
		}
		
		public static function packMap(map:Object, out:IDataOutput):IDataOutput{
			var keysNum:int = 0;
			for(var ak:* in map){
				keysNum++;
			}
			packMapHeader(keysNum, out);
			for(var k:* in map){
				pack(k, out);
				pack(map[k], out);
			}
			return out;
		}
		
		public static function packArray(arr:*, out:IDataOutput):IDataOutput{
			var size:uint = arr.length;
			packArrayHeader(size, out);
			for(var i:uint=0;i<size;i++){
				pack(arr[i], out);
			}
			return out;
		}
		
		private static function packArrayHeader(size:int, out:IDataOutput):IDataOutput{
			if(size <= ValueHelper.MAX_4BIT) {
				out.writeByte((Code.FIXARRAY_PREFIX | size));
			} else if(size <= ValueHelper.MAX_16BIT) {
				out.writeByte(Code.ARRAY16);
				out.writeShort(size);
			} else {
				out.writeByte(Code.ARRAY32);
				out.writeInt(size);
			}
			return out;
		}
		private static function packMapHeader(size:int, out:IDataOutput):IDataOutput{
			if(size <= ValueHelper.MAX_4BIT) {
				out.writeByte((Code.FIXMAP_PREFIX | size));
			} else if(size <=ValueHelper.MAX_16BIT) {
				out.writeByte(Code.MAP16);
				out.writeShort(size);
			} else {
				out.writeByte(Code.MAP32);
				out.writeInt(size);
			}
			return out;
		}
		
	}
}