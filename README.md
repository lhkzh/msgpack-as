as3 msgpack 序列化 A msgpack as3 implements [ActionScript3]
支持
null, Boolean, int,uint,Number, Object,String,ByteArray
Array,Vector.<?>
不支持循环引用

@see
https://github.com/msgpack/msgpack-java

Message Pack specification: https://github.com/msgpack/msgpack/blob/master/spec.md

@useage
import u14.msgpack.MsgPack;
			MsgPack.pack(value);
			MsgPack.unpack(bytes);
			
			
			var bytes:ByteArray = null;
			bytes = MsgPack.pack(null);
			trace("null:", MsgPack.unpack(bytes)==null);
			bytes = MsgPack.pack(true);
			trace("bool:", MsgPack.unpack(bytes)==true);
			bytes = MsgPack.pack(520);
			trace("int:", MsgPack.unpack(bytes)==520);
			bytes = MsgPack.pack(520.1314);
			trace("number:", MsgPack.unpack(bytes)==520.1314);
			bytes = MsgPack.pack("hello,world!");
			trace("string:", MsgPack.unpack(bytes)=="hello,world!");
			var map:Object = {uid:200,nick:"jack",age:22};
			bytes = MsgPack.pack(map);
			trace("map:",JSON.stringify(MsgPack.unpack(bytes))==JSON.stringify(map), JSON.stringify(map));
			var arr:Array = [2,33,"44",55.0,{two:"two"}];
			bytes = MsgPack.pack(arr);
			trace("array:",JSON.stringify(MsgPack.unpack(bytes))==JSON.stringify(arr), JSON.stringify(arr));
