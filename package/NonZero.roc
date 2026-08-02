## A number checked to be non-zero, generic over the number type.
##
## ```
## Ok(meaning_of_life) = NonZero.new(42)
## ```
##
## The one way to construct a `NonZero(n)` is [NonZero.new], so holding a
## value proves the check happened. With a literal argument the compiler
## evaluates `new` while type-checking, so the bare destructure above
## compiles because it is proven to succeed, and `NonZero.new(0)` under
## such a destructure is a compile error rather than a runtime one. A value
## only known at runtime must have its potential error path handled.
##
## `NonZero` works with any number type, so e.g. `NonZero(F64)` is
## constructible, but `NaN` is considered non-zero.
NonZero(n) :: { value : n }.{

	## `Ok` wrapping the checked value, or `Err(Zero)`.
	new : n -> Try(NonZero(n), [Zero])
		where [
			n.is_eq : n, n -> Bool,
			n.from_numeral : Numeral -> Try(n, [InvalidNumeral(Str)]),
		]
	new = |value| if value == 0 {
		Err(Zero)
	} else {
		Ok(NonZero.{ value })
	}

	## The value that was checked.
	get : NonZero(n) -> n
	get = |nz| nz.value

	is_eq : NonZero(n), NonZero(n) -> Bool
		where [n.is_eq : n, n -> Bool]
	is_eq = |left, right| left.value == right.value
}

# Tests

u64_zero : U64
u64_zero = 0

u64_four : U64
u64_four = 4

expect NonZero.new(u64_zero) == Err(Zero)

expect
	match NonZero.new(u64_four) {
		Ok(four) => four.get() == 4
		Err(Zero) => Bool.False
	}

# The check adapts to the number type in play, here U8
u8_max : U8
u8_max = 255

expect
	match NonZero.new(u8_max) {
		Ok(max) => max.get() == 255
		Err(Zero) => Bool.False
	}

# A negative number is non-zero
i32_negative : I32
i32_negative = -3

expect
	match NonZero.new(i32_negative) {
		Ok(negative) => negative.get() == -3
		Err(Zero) => Bool.False
	}

# Checked values compare by their value
expect
	match (NonZero.new(u64_four), NonZero.new(u64_four)) {
		(Ok(a), Ok(b)) => a == b
		_ => Bool.False
	}

expect
	match (NonZero.new(u64_four), NonZero.new(u64_four + 1)) {
		(Ok(a), Ok(b)) => a != b
		_ => Bool.False
	}
