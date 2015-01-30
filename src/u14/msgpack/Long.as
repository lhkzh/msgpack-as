package u14.msgpack
{
	/**
	 * @see https://github.com/dcodeIO/Long.js
	 * @author zhangheng,Daniel Wirtz <dcode@dcode.io>
	 */	
	public class Long
	{
		/**
		 * The low 32 bits as a signed value.
		 * @type {number}
		 * @expose
		 */
		private var low:int;
		/**
		 * The high 32 bits as a signed value.
		 * @type {number}
		 * @expose
		 */
		private var high:int;
		/**
		 * Whether unsigned or not.
		 * @type {boolean}
		 * @expose
		 */
		private var unsigned:Boolean;
		
		/**
		 * Constructs a 64 bit two's-complement integer, given its low and high 32 bit values as *signed* integers.
		 * See the from* functions below for more convenient ways of constructing Longs.
		 * @exports Long
		 * @class A Long class for representing a 64 bit two's-complement integer value.
		 * @param {number} low The low (signed) 32 bits of the long
		 * @param {number} high The high (signed) 32 bits of the long
		 * @param {boolean=} unsigned Whether unsigned or not, defaults to `false` for signed
		 * @constructor
		 */
		public function Long(low:int, high:int, unsigned:Boolean) {
			this.low = low|0;
			this.high = high|0;
			this.unsigned = !!unsigned;
		}
		
		/**
		 * A cache of the Long representations of small integer values.
		 * @type {!Object}
		 * @inner
		 */
		private static var INT_CACHE:Object = {};
		/**
		 * A cache of the Long representations of small unsigned integer values.
		 * @type {!Object}
		 * @inner
		 */
		private static var UINT_CACHE:Object = {};		
		/**
		 * Returns a Long representing the given 32 bit integer value.
		 * @param {number} value The 32 bit integer in question
		 * @param {boolean=} unsigned Whether unsigned or not, defaults to `false` for signed
		 * @returns {!Long} The corresponding Long value
		 * @expose
		 */
		public static function fromInt(value:int, unsigned:Boolean=false):Long{
			var obj:Long, cachedObj:Long;
			if (!unsigned) {
				value = value | 0;
				if (-128 <= value && value < 128) {
					cachedObj = INT_CACHE[value];
					if (cachedObj)
						return cachedObj;
				}
				obj = new Long(value, value < 0 ? -1 : 0, false);
				if (-128 <= value && value < 128)
					INT_CACHE[value] = obj;
				return obj;
			} else {
				value = value >>> 0;
				if (0 <= value && value < 256) {
					cachedObj = UINT_CACHE[value];
					if (cachedObj)
						return cachedObj;
				}
				obj = new Long(value, (value | 0) < 0 ? -1 : 0, true);
				if (0 <= value && value < 256)
					UINT_CACHE[value] = obj;
				return obj;
			}
		}
		
		/**
		 * Returns a Long representing the given value, provided that it is a finite number. Otherwise, zero is returned.
		 * @param {number} value The number in question
		 * @param {boolean=} unsigned Whether unsigned or not, defaults to `false` for signed
		 * @returns {!Long} The corresponding Long value
		 * @expose
		 */
		public static function fromNumber(value:Number, unsigned:Boolean=false):Long{
			unsigned = !!unsigned;
			if (isNaN(value) || !isFinite(value))
				return Long.ZERO;
			if (!unsigned && value <= -TWO_PWR_63_DBL)
				return Long.MIN_VALUE;
			if (!unsigned && value + 1 >= TWO_PWR_63_DBL)
				return Long.MAX_VALUE;
			if (unsigned && value >= TWO_PWR_64_DBL)
				return Long.MAX_UNSIGNED_VALUE;
			if (value < 0)
				return Long.fromNumber(-value, unsigned).negate();
			return new Long((value % TWO_PWR_32_DBL) | 0, (value / TWO_PWR_32_DBL) | 0, unsigned);
		}
		/**
		 * Returns a Long representing the 64 bit integer that comes by concatenating the given low and high bits. Each is
		 * assumed to use 32 bits.
		 * @param {number} lowBits The low 32 bits
		 * @param {number} highBits The high 32 bits
		 * @param {boolean=} unsigned Whether unsigned or not, defaults to `false` for signed
		 * @returns {!Long} The corresponding Long value
		 * @expose
		 */
		public static function fromBits(lowBits:int, highBits:int, unsigned:Boolean):Long{
			return new Long(lowBits, highBits, unsigned);
		}
		
		/**
		 * @type {number}
		 * @const
		 * @inner
		 */
		private static var TWO_PWR_16_DBL:Number = 1 << 16;
		/**
		 * @type {number}
		 * @const
		 * @inner
		 */
		private static var TWO_PWR_24_DBL:Number = 1 << 24;
		/**
		 * @type {number}
		 * @const
		 * @inner
		 */
		private static var TWO_PWR_32_DBL:Number = TWO_PWR_16_DBL * TWO_PWR_16_DBL;
		/**
		 * @type {number}
		 * @const
		 * @inner
		 */
		private static var TWO_PWR_64_DBL:Number = TWO_PWR_32_DBL * TWO_PWR_32_DBL;
		/**
		 * @type {number}
		 * @const
		 * @inner
		 */
		private static var TWO_PWR_63_DBL:Number = TWO_PWR_64_DBL / 2;
		/**
		 * @type {!Long}
		 * @const
		 * @inner
		 */
		private static const TWO_PWR_24:Long = Long.fromInt(TWO_PWR_24_DBL);		
		
		/**
		 * Signed zero.
		 * @type {!Long}
		 * @expose
		 */
		private static const ZERO:Long = Long.fromInt(0);
		/**
		 * Unsigned zero.
		 * @type {!Long}
		 * @expose
		 */
		private static const UZERO:Long = Long.fromInt(0, true);
		/**
		 * Signed one.
		 * @type {!Long}
		 * @expose
		 */
		private static const ONE:Long = Long.fromInt(1);
		/**
		 * Unsigned one.
		 * @type {!Long}
		 * @expose
		 */
		private static const UONE:Long = Long.fromInt(1, true);
		/**
		 * Signed negative one.
		 * @type {!Long}
		 * @expose
		 */
		private static const NEG_ONE:Long = Long.fromInt(-1);
		/**
		 * Maximum signed value.
		 * @type {!Long}
		 * @expose
		 */
		private static const MAX_VALUE:Long = Long.fromBits(0xFFFFFFFF|0, 0x7FFFFFFF|0, false);
		/**
		 * Maximum unsigned value.
		 * @type {!Long}
		 * @expose
		 */
		private static const MAX_UNSIGNED_VALUE:Long = Long.fromBits(0xFFFFFFFF|0, 0xFFFFFFFF|0, true);
		/**
		 * Minimum signed value.
		 * @type {!Long}
		 * @expose
		 */
		private static const MIN_VALUE:Long = Long.fromBits(0, 0x80000000|0, false);
		
		/**
		 * Converts the Long to a 32 bit integer, assuming it is a 32 bit integer.
		 * @returns {int}
		 * @expose
		 */
		public function toInt():int{
			return this.unsigned ? this.low >>> 0 : this.low;
		}
		/**
		 * Converts the Long to a the nearest floating-point representation of this value (double, 53 bit mantissa).
		 * @return {Number}
		 * @expose
		 */
		public function toNumber():Number{
			if (this.unsigned) {
				return ((this.high >>> 0) * TWO_PWR_32_DBL) + (this.low >>> 0);
			}
			return this.high * TWO_PWR_32_DBL + (this.low >>> 0);
		}
		/**
		 * Gets the high 32 bits as a signed integer.
		 * @returns {int} Signed high bits
		 * @expose
		 */
		public function get highBits():int{
			return this.high;
		}
		/**
		 * Gets the high 32 bits as an unsigned integer.
		 * @returns {uint} Unsigned high bits
		 * @expose
		 */
		public function get highBitsUnsigned():uint{
			return this.high >>> 0;
		}
		/**
		 * Gets the low 32 bits as a signed integer.
		 * @returns {int} Signed high bits
		 * @expose
		 */
		public function get lowBits():int{
			return this.low;
		}
		/**
		 *  Gets the low 32 bits as an unsigned integer.
		 * @returns {uint} Unsigned high bits
		 * @expose
		 */
		public function get lowBitsUnsigned():uint{
			return this.low >>> 0;
		}
		
		
		/**
		 * Tests if this Long's value equals zero.
		 * @returns {boolean}
		 * @expose
		 */
		public function isZero():Boolean{
			return this.high === 0 && this.low === 0;
		}
		/**
		 * Tests if this Long's value is negative.
		 * @returns {boolean}
		 * @expose
		 */
		public function isNegative():Boolean{
			return !this.unsigned && this.high < 0;
		}
		/**
		 * Tests if this Long's value is positive.
		 * @returns {boolean}
		 * @expose
		 */
		public function isPositive():Boolean{
			return this.unsigned || this.high >= 0;
		}
		/**
		 * Tests if this Long's value is odd.
		 * @returns {boolean}
		 * @expose
		 */
		public function isOdd():Boolean{
			return (this.low & 1) === 1;
		}
		/**
		 * Tests if this Long's value is even.
		 * @returns {boolean}
		 * @expose
		 */
		public function isEven():Boolean{
			return (this.low & 1) === 0;
		}
		
		/**
		 * Converts this Long to signed.
		 * @returns {!Long} Signed long
		 * @expose
		 */
		public function toSigned():Long {
			if (!this.unsigned)
				return this;
			return new Long(this.low, this.high, false);
		}
		/**
		 * Converts this Long to unsigned.
		 * @returns {!Long} Unsigned long
		 * @expose
		 */
		public function toUnsigned():Long {
			if (this.unsigned)
				return this;
			return new Long(this.low, this.high, true);
		}
		
		/**
		 * Tests if this Long's value equals the specified's.
		 * @param {!Long|number|string} other Other value
		 * @returns {boolean}
		 * @expose
		 */
		public function equals(other:Long):Boolean{
			if (this.unsigned !== other.unsigned && (this.high >>> 31) === 1 && (other.high >>> 31) === 1)
				return false;
			return this.high === other.high && this.low === other.low;
		}

		/**
		 * Negates this Long's value.
		 * @returns {!Long} Negated Long
		 * @expose
		 */
		public function negate():Long{
			if (!this.unsigned && this.equals(Long.MIN_VALUE))
				return Long.MIN_VALUE;
			return this.not().add(Long.ONE);
		}
		/**
		 * Returns the bitwise NOT of this Long.
		 * @returns {!Long}
		 * @expose
		 */
		public function not():Long{
			return Long.fromBits(~this.low, ~this.high, this.unsigned);
		}
		/**
		 * Returns the sum of this and the specified Long.
		 * @param {!Long|number|string} addend Addend
		 * @returns {!Long} Sum
		 * @expose
		 */
		public function add(addend:Long):Long{
			// Divide each number into 4 chunks of 16 bits, and then sum the chunks.
			var a48:Number = this.high >>> 16;
			var a32:Number = this.high & 0xFFFF;
			var a16:Number = this.low >>> 16;
			var a00:Number = this.low & 0xFFFF;
			var b48:Number = addend.high >>> 16;
			var b32:Number = addend.high & 0xFFFF;
			var b16:Number = addend.low >>> 16;
			var b00:Number = addend.low & 0xFFFF;
			var c48:Number = 0, c32:Number = 0, c16:Number = 0, c00:Number = 0;
			c00 += a00 + b00;
			c16 += c00 >>> 16;
			c00 &= 0xFFFF;
			c16 += a16 + b16;
			c32 += c16 >>> 16;
			c16 &= 0xFFFF;
			c32 += a32 + b32;
			c48 += c32 >>> 16;
			c32 &= 0xFFFF;
			c48 += a48 + b48;
			c48 &= 0xFFFF;
			return Long.fromBits((c16 << 16) | c00, (c48 << 16) | c32, this.unsigned);
		}
	}
}