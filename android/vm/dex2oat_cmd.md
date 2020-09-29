 dex2oat: [dex2oat]
 Output must be supplied with either --oat-file or --oat-fd
 Command: dex2oat
 Usage: dex2oat [options]...

   -j<number>: specifies the number of threads used for compilation.
        Default is the number of detected hardware threads available on the
        host system.
       Example: -j12

   --dex-file=<dex-file>: specifies a .dex, .jar, or .apk file to compile.
       Example: --dex-file=/system/framework/core.jar

   --dex-location=<dex-location>: specifies an alternative dex location to
       encode in the oat file for the corresponding --dex-file argument.
       Example: --dex-file=/home/build/out/system/framework/core.jar
                --dex-location=/system/framework/core.jar

   --zip-fd=<file-descriptor>: specifies a file descriptor of a zip file
       containing a classes.dex file to compile.
       Example: --zip-fd=5

   --zip-location=<zip-location>: specifies a symbolic name for the file
       corresponding to the file descriptor specified by --zip-fd.
       Example: --zip-location=/system/app/Calculator.apk

   --oat-file=<file.oat>: specifies an oat output destination via a filename.
       Example: --oat-file=/system/framework/boot.oat

   --oat-fd=<number>: specifies the oat output destination via a file descriptor.
       Example: --oat-fd=6

   --input-vdex-fd=<number>: specifies the vdex input source via a file descriptor.
       Example: --input-vdex-fd=6

   --output-vdex-fd=<number>: specifies the vdex output destination via a file
       descriptor.
       Example: --output-vdex-fd=6

   --oat-location=<oat-name>: specifies a symbolic name for the file corresponding
       to the file descriptor specified by --oat-fd.
       Example: --oat-location=/data/dalvik-cache/system@app@Calculator.apk.oat

   --oat-symbols=<file.oat>: specifies an oat output destination with full symbols.
       Example: --oat-symbols=/symbols/system/framework/boot.oat

   --image=<file.art>: specifies an output image filename.
       Example: --image=/system/framework/boot.art

   --image-format=(uncompressed|lz4|lz4hc):
       Which format to store the image.
       Example: --image-format=lz4
       Default: uncompressed

   --image-classes=<classname-file>: specifies classes to include in an image.
       Example: --image=frameworks/base/preloaded-classes

   --base=<hex-address>: specifies the base address when creating a boot image.
       Example: --base=0x50000000

   --boot-image=<file.art>: provide the image file for the boot class path.
       Do not include the arch as part of the name, it is added automatically.
       Example: --boot-image=/system/framework/boot.art
                (specifies /system/framework/<arch>/boot.art as the image file)
       Default: $ANDROID_ROOT/system/framework/boot.art

   --android-root=<path>: used to locate libraries for portable linking.
       Example: --android-root=out/host/linux-x86
       Default: $ANDROID_ROOT

   --instruction-set=(arm|arm64|mips|mips64|x86|x86_64): compile for a particular
       instruction set.
       Example: --instruction-set=x86
       Default: arm

   --instruction-set-features=...,: Specify instruction set features
       Example: --instruction-set-features=div
       Default: default

   --compile-pic: Force indirect use of code, methods, and classes
       Default: disabled

   --compiler-backend=(Quick|Optimizing): select compiler backend
       set.
       Example: --compiler-backend=Optimizing
       Default: Optimizing

   --compiler-filter=(assume-verified|extract|verify|quicken|space-profile|space|speed-profile|speed|everything-profile|everything):
       select compiler filter.
       Example: --compiler-filter=everything
       Default: speed

   --huge-method-max=<method-instruction-count>: threshold size for a huge
       method for compiler filter tuning.
       Example: --huge-method-max=10000
       Default: 10000

   --large-method-max=<method-instruction-count>: threshold size for a large
       method for compiler filter tuning.
       Example: --large-method-max=600
       Default: 600

   --small-method-max=<method-instruction-count>: threshold size for a small
       method for compiler filter tuning.
       Example: --small-method-max=60
       Default: 60

   --tiny-method-max=<method-instruction-count>: threshold size for a tiny
       method for compiler filter tuning.
       Example: --tiny-method-max=20
       Default: 20

   --num-dex-methods=<method-count>: threshold size for a small dex file for
       compiler filter tuning. If the input has fewer than this many methods
       and the filter is not interpret-only or verify-none or verify-at-runtime,
       overrides the filter to use speed
       Example: --num-dex-method=900
       Default: 900

   --inline-max-code-units=<code-units-count>: the maximum code units that a method
       can have to be considered for inlining. A zero value will disable inlining.
       Honored only by Optimizing. Has priority over the --compiler-filter option.
       Intended for development/experimental use.
       Example: --inline-max-code-units=32
       Default: 32

   --dump-timings: display a breakdown of where time was spent

   -g
   --generate-debug-info: Generate debug information for native debugging,
       such as stack unwinding information, ELF symbols and DWARF sections.
       If used without --debuggable, it will be best-effort only.
       This option does not affect the generated code. (disabled by default)

   --no-generate-debug-info: Do not generate debug information for native debugging.

   --generate-mini-debug-info: Generate minimal amount of LZMA-compressed
       debug information necessary to print backtraces. (disabled by default)

   --no-generate-mini-debug-info: Do not generate backtrace info.

   --generate-build-id: Generate GNU-compatible linker build ID ELF section with
       SHA-1 of the file content (and thus stable across identical builds)

   --no-generate-build-id: Do not generate the build ID ELF section.

   --debuggable: Produce code debuggable with Java debugger.

   --avoid-storing-invocation: Avoid storing the invocation args in the key value
       store. Used to test determinism with different args.

   --runtime-arg <argument>: used to specify various arguments for the runtime,
       such as initial heap size, maximum heap size, and verbose output.
       Use a separate --runtime-arg switch for each argument.
       Example: --runtime-arg -Xms256m

   --profile-file=<filename>: specify profiler output file to use for compilation.

   --profile-file-fd=<number>: same as --profile-file but accepts a file descriptor.
       Cannot be used together with --profile-file.

   --swap-file=<file-name>: specifies a file to use for swap.
       Example: --swap-file=/data/tmp/swap.001

   --swap-fd=<file-descriptor>: specifies a file to use for swap (by descriptor).
       Example: --swap-fd=10

   --swap-dex-size-threshold=<size>: specifies the minimum total dex file size in
       bytes to allow the use of swap.
       Example: --swap-dex-size-threshold=1000000
       Default: 20971520

   --swap-dex-count-threshold=<count>: specifies the minimum number of dex files to
       allow the use of swap.
       Example: --swap-dex-count-threshold=10
       Default: 2

   --very-large-app-threshold=<size>: specifies the minimum total dex file size in
       bytes to consider the input "very large" and reduce compilation done.
       Example: --very-large-app-threshold=100000000

   --app-image-fd=<file-descriptor>: specify output file descriptor for app image.
       The image is non-empty only if a profile is passed in.
       Example: --app-image-fd=10

   --app-image-file=<file-name>: specify a file name for app image.
       Example: --app-image-file=/data/dalvik-cache/system@app@Calculator.apk.art

   --multi-image: specify that separate oat and image files be generated for each input dex file.

   --force-determinism: force the compiler to emit a deterministic output.

   --dump-cfg=<cfg-file>: dump control-flow graphs (CFGs) to specified file.
       Example: --dump-cfg=output.cfg

   --dump-cfg-append: when dumping CFGs to an existing file, append new CFG data to
       existing data (instead of overwriting existing data with new data, which is
       the default behavior). This option is only meaningful when used with
       --dump-cfg.

   --classpath-dir=<directory-path>: directory used to resolve relative class paths.

   --class-loader-context=<string spec>: a string specifying the intended
       runtime loading context for the compiled dex files.

   --stored-class-loader-context=<string spec>: a string specifying the intended
       runtime loading context that is stored in the oat file. Overrides
       --class-loader-context. Note that this ignores the classpath_dir arg.

       It describes how the class loader chain should be built in order to ensure
       classes are resolved during dex2aot as they would be resolved at runtime.
       This spec will be encoded in the oat file. If at runtime the dex file is
       loaded in a different context, the oat file will be rejected.

       The chain is interpreted in the natural 'parent order', meaning that class
       loader 'i+1' will be the parent of class loader 'i'.
       The compilation sources will be appended to the classpath of the first class
       loader.

       E.g. if the context is 'PCL[lib1.dex];DLC[lib2.dex]' and
       --dex-file=src.dex then dex2oat will setup a PathClassLoader with classpath
       'lib1.dex:src.dex' and set its parent to a DelegateLastClassLoader with
       classpath 'lib2.dex'.

       Note that the compiler will be tolerant if the source dex files specified
       with --dex-file are found in the classpath. The source dex files will be
       removed from any class loader's classpath possibly resulting in empty
       class loaders.

       Example: --class-loader-context=PCL[lib1.dex:lib2.dex];DLC[lib3.dex]

   --dirty-image-objects=<directory-path>: list of known dirty objects in the image.
       The image writer will group them together.

   --compact-dex-level=none|fast: None avoids generating compact dex, fast
       generates compact dex with low compile time. If speed-profile is specified as
       the compiler filter and the profile is not empty, the default compact dex
       level is always used.

   --deduplicate-code=true|false: enable|disable code deduplication. Deduplicated
       code will have an arbitrary symbol tagged with [DEDUPED].

   --copy-dex-files=true|false: enable|disable copying the dex files into the
       output vdex.

   --compilation-reason=<string>: optional metadata specifying the reason for
       compiling the apk. If specified, the string will be embedded verbatim in
       the key value store of the oat file.

       Example: --compilation-reason=install
