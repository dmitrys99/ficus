# Ficus

This is a new functional language with the first-class array support
that also supports imperative and object-oriented programming paradigms.
`ficus` compiler generates a portable C/C++ code out of .fx files.

## License

The code is distributed under Apache 2 license, see the [LICENSE](LICENSE)

## How to build

The compiler is written in Ficus itself and needs C/C++ compiler and make utility.

### **Unix (Linux, macOS, BSD, WSL, ...)**

```
cd <ficus_root>
make -j8
bin/ficus -run test/test_all.fx # run unit tests
bin/ficus -run -O3 examples/fst.fx # run some examples, e.g. fst.fx,
                                   # optionally specify optimization level
```

### **Windows (native)**

Install Visual Studio, for example Visual Studio 2019 Community Edition, open "Developer PowerShell for VS2019" from the Windows menu and type:

```
cd <ficus_root>
nmake -f Makefile.win32
bin/ficus -run -O3 examples/fst.fx # the usage is the same as on Unix
```

### **Set environment variables**

You can add `<ficus_root>/bin` to the `PATH`. You can also customize ficus compiler behaviour by setting the following environment variables:

* `FICUS_PATH` can point to the standard library (`<ficus_root>/lib`), though ficus attempts to find the standard library even without `FICUS_PATH`. It can also contain other directories separated by `:` on Unix and `;` on Windows. The directories with imported modules can also be provided via one or more command-line options `-I <import_path>`. Note that if a compiled module imports other modules from the directory where it resides then that directory does not need to be explicitly specified.

* `FICUS_CFLAGS` is used by C/C++ compiler to build the produced .c/.cpp files. Alternative way to pass extra flags to C/C++ compiler is via `-cflags "<cflags>"` command-line option, e.g. `-cflags "-ffast-math -mavx2"`.

* `FICUS_LINK_LIBRARIES` contains the linker flags and the extra linked libraries. Alternative way to pass the extra linker flags to C/C++ compiler is via `-clibs "<clibs>"` command-line option.

## How to use

(run `ficus --help` to get more detailed up-to-date information about command line parameters)

Here is a brief description with some most common options:
```
ficus [-app|-run|...] [-O0|-O1|-O3] [-verbose] [-I <extra_module_path>]* [-o <appname>] <scriptname.fx> [-- <script arg1> <script arg2> ...]
```

* `-app` (the flag is set by default) generates C code for the specified script as well as for the imported modules (one .c file per one .fx file), then runs the compiler for each of the generated .c files and then links the produced object files into the final app. The compiled app, as well as the intermediate `.c` and `.o` files, is stored in `__fxbuild__/<appname>/<appname>`. By default `<appname>==<scriptname>`. Override the app name (and the output path) with `-o` option.
* `-run` builds the app (see the flag `-app`) and then runs it. You can pass command-line parameters to the script after `--` separator.
* `-verbose` makes the compiler to report build progress and various information, which can be especially useful when building big apps

## Ficus 1.0

![TODO](/misc/ficus1.0.png)

(see https://github.com/vpisarev/ficus/issues/4 for the decryption and the status)

## Credits

* The compiler was inspired by min-caml
(http://esumii.github.io/min-caml/index-e.html) by Eijiro Sumii et al.

* The compiler, the standard library and documentation use pieces directly copied from or inspired by various open-source projects, including:
  * [rpmalloc](https://github.com/mjansson/rpmalloc)
  * ['Relaxed-Radix B-tree'-based immutable vectors](https://github.com/hypirion/c-rrb)
  * [xoshiro algorithm for random number generation](https://prng.di.unimi.it)
  * [Python-like hash table implementation](https://github.com/python/cpython/blob/master/Objects/dictobject.c)
  * [RE1](https://code.google.com/archive/p/re1/) and [RE2](https://github.com/google/re2) regular expression engines
  * [OpenCV library](https://github.com/opencv/opencv)
  * [Red-Black trees in OCaml](https://github.com/bmeurer/ocaml-rbtrees)
  * [Unicode lookup table generator](https://www.strchr.com/multi-stage_tables)
  * [Literata](https://fonts.google.com/specimen/Literata), [iA Writer](https://github.com/iaolo/iA-Fonts) and [Recursive](https://www.recursive.design) fonts.
  * etc.