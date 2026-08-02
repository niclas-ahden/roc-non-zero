app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
	nz: "../package/main.roc",
}

import pf.Stdout
import nz.NonZero

main! = |args| {
	# Look at this spectacular line!
	Ok(non_zero) = NonZero.new(42)

	# Wait, `NonZero.new` returns an error if you give it a zero... How could
	# we just destructure that as `Ok(non_zero)` without dealing with that potential
	# `Err`?
	#
	# Well, Roc has a great feature! It'll figure out which values can be known at
	# compile-time and it'll evaluate those values during compilation. That means it'll
	# look at the number 42 above and say "this can't possibly change at runtime, so I'll
	# evaluate `NonZero.new(42)` right now during compilation". Since 42 is non-zero, the
	# _only_possible_result_ is `Ok`. It _cannot_ error, so Roc lets us destructure
	# it right away without error handling... Mind. Blown. 🤯.
	#
	# But what if it was zero?
	#
	#     Ok(non_zero) = NonZero.new(0)
	#
	# That'd give you an error at compile-time. How great is that?
	#
	# That makes `NonZero` really useful for eliminating error branches which you know
	# can never happen. We can for example write a function for safe division:

	safe_div : U64, NonZero(U64) -> U64
	safe_div = |a, b| a / b.get() # We use `.get()` to extract the non-zero number

	# And use it like so:
	compile_time_division = safe_div(42 * 42, non_zero)
	Stdout.line!("Compile-time: ${compile_time_division.to_str()}")?

	# Of course you can also use it for values which are only known at runtime.
	# In that case you just `match` or `?` as usual:
	match NonZero.new(args.len()) {
		Ok(runtime_value) => {
			runtime_division = safe_div(42, runtime_value)
			Stdout.line!("Runtime: ${runtime_division.to_str()}")?
		}
		Err(Zero) => Stdout.line!("No args given")?
	}

	# Psst: Roc already protects us from divide-by-zero for compile-time-evaluated values
	# (try it yourself `1 / 0` will give you a compilation error in Roc), so that example is
	# a bit silly, but there are plenty of other situations where you want a `NonZero` for your
	# business logic (e.g. for calculating how many hours you should devote to Diablo II).

	Ok({})
}
