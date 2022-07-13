# Axivion Suite Bazel Integration Showcase

This repository showcases the simplest form of an integration of the Axivion
Suite into the `bazel` build system. This assumes that you are running on Linux
with `gcc` as your compiler and have installed the Axivion Suite as
`/opt/bauhaus-suite`.

## `C++` Source Code

[`//main:main`](main/BUILD.bazel) defines a simple binary that prints `Hello
Axivion!`. Verify this builds with the autodetected system toolchain with:

```
➜  bazel-axivion-showcase git:(main) bazelisk run //main
[..]
Hello Axivion!
```

## Axivion Suite Setup

To be able to compile this with the Axivion Suite, please make sure you have
installed/setup the Axivion Suite in `/opt/bauhaus-suite/`, generated a
`/opt/bauhaus-suite/compiler_config/` using `gccsetup` and placed your license
key either in `/opt/bauhaus-suite/config/` or `/opt/bauhaus-suite/compiler_config/`.

The best way to integrate the Axivion Suite is as a cross-compiler targeting an
artifical `axivion` cpu. To enable this, [`//support:axivion`](support/BUILD.bazel)
defines a constraint value on the cpu and [`//support:linux_axivion`](support/BUILD.bazel)
a platform that is constraint to this cpu. Finally
[`//support:linux_axivion_toolchain`](support/BUILD.bazel) defines a compiler
toolchain cabable of running on a `x86_64` Linux host, targeting the `axivion`
cpu. Build the binary using the Axivion Suite via a [`--platform`](.bazelrc)
setting using the following:

```
➜  bazel-axivion-showcase git:(main) bazelisk build --config=axivion //main
```

Alternatively a crosstool toolchain is defined in
[`//support/axivion:toolchain`](support/axivion/BUILD.bazel).  This also makes
use of a `axivion` cpu that has to be specified on the commandline as
`--cpu=axivion`. Build the binary using the Axivion via a
[`--crosstool_top`](.bazelrc) setting using the following:

```
➜  bazel-axivion-showcase git:(main) bazelisk build --config=axivion_crosstool //main
```

Please refer to the [`.bazelrc`](.bazelrc) file for details on the flag key/value pairs.

## Notes on the Integration

During a normal build `bazel` will autodetect a compiler toolchain. The
toolchain definition can be found after the initial `bazelisk run //main` (not
using the Axivion Suite) in
`bazel-bazel-axivion-showcase/external/local_config_cc/`. We can base our
toolchain on a copy of that definiton,
https://github.com/limdor/bazel-examples/tree/master/linux_toolchain is a great
write-up that describes the process in detail.

The generated `BUILD` file was copied to
[`support/axivion/BUILD.bazel`](support/axivion/BUILD.bazel) and slightly
adapted:

- the `k8` cpu was replaced with an `axivion` cpu
- all mentions of an `arm` toolchain were removed
- `compiler_deps` filegroup was stripped down
- `cxx_builtin_include_directories` was extended by the Axivion Suite profile directory
- the [`cc_wrapper.sh`](support/axivion/cc_wrapper.sh) script was used for the
  `gcc`/`cpp` tools in the `tool_paths` setting

The [`support/axivion/cc_wrapper.sh`](support/axivion/cc_wrapper.sh) script is
necessary to call the Axivion Suite compiler `cafeCC` as we need to inject a
`BAUHAUS_CONFIG` environment variable and pass some default flags.
