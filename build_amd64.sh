#!/bin/bash
#
# amd64 Build Script for ImageOptim-ESR components
# 1.9.0a2 by DingoBits, 2023-08-03
# 
# You need build tools
# autoconf automake cmake rust
#
# Also
# rustup target add x86_64-apple-darwin aarch64-apple-darwin
#
# pngquant has optional dependencies
# little-cms2
#
# Also
# rustup target add x86_64-apple-darwin aarch64-apple-darwin
#

set -e

cp -r dependencies amd64_pkgs

WORKSPACE="$(pwd)/amd64_workspace"
NPROC=$(sysctl -n machdep.cpu.thread_count)
mkdir -p "$WORKSPACE"
RUST_TARGET_TRIPLE="x86_64-apple-darwin"

export ARCH="x86_64"
export ARCHS="x86_64"
export TARGET="x86_64-apple-macos12"
export HOST="x86_64-apple-macos12"
export MACOSX_DEPLOYMENT_TARGET=12.4
export CPPFLAGS="-O3 -flto -funroll-loops -I$WORKSPACE/include"
export LDFLAGS="-L$WORKSPACE/lib"
export PATH="$WORKSPACE/bin:$PATH"
export PREFIX="$WORKSPACE"
export CPATH="$WORKSPACE/include"
export LIBRARY_PATH="$WORKSPACE/lib"
export PKG_CONFIG_PATH="$WORKSPACE/lib/pkgconfig"

cd amd64_pkgs || exit

run() {
	OUTPUT=$("$@" 2>&1)
	if [ $? -ne 0 ]; then
		echo "$ $*"
		echo "$OUTPUT"
		exit 1
	fi
}

if [ -f "$WORKSPACE/lib/libz.a" ]; then
    echo "Skipping zlib since it's already built."
else
	echo "Building zlib"
	cd zlib || exit
	run cmake . -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="$WORKSPACE"
	run make -j "$NPROC"
	run make install/strip
	cd .. || exit
fi

if [ -f "$WORKSPACE/lib/libpng.a" ]; then
    echo "Skipping libpng since it's already built."
else
	echo "Building libpng"
	cd libpng || exit
	run cmake . -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="$WORKSPACE" -DPNG_ARM_NEON=off -DPNG_INTEL_SSE=on -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF -DZLIB_INCLUDE_DIR="${WORKSPACE}/include" -DZLIB_LIBRARY_RELEASE="${WORKSPACE}/lib/libz.a" 
	run make -j "$NPROC"
	run make install/strip
	cd .. || exit
fi

if [ -f "$WORKSPACE/lib/libjpeg.a" ]; then
    echo "Skipping libjpeg-turbo since it's already built."
else
	echo "Building libjpeg-turbo"
	cd libjpeg-turbo || exit
	run cmake . -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="$WORKSPACE" -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DPNG_SUPPORTED=OFF -DWITH_12BIT=ON -DWITH_ARITH_DEC=ON -DWITH_ARITH_ENC=ON -DWITH_MEM_SRCDST=ON -DWITH_SIMD=ON
	run make -j "$NPROC"
	run make install/strip
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/gifsicle" ]; then
    echo "Skipping gifsicle since it's already built."
else
	echo "Building gifsicle"
	cd gifsicle || exit
	run arch -x86_64 ./bootstrap.sh
	run arch -x86_64 ./configure --prefix="$WORKSPACE" --disable-gifview --disable-gifdiff
	run arch -x86_64 make -j "$NPROC"
	run make install-strip
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/guetzli" ]; then
    echo "Skipping guetzli since it's already built."
else
	echo "Building guetzli"
	cd guetzli || exit
	export LDFLAGS="-L$WORKSPACE/lib -lz"
	run arch -x86_64 make config=release guetzli -j "$NPROC"
	run arch -x86_64 strip bin/Release/guetzli
	cp bin/Release/guetzli "$WORKSPACE/bin"
	export LDFLAGS="-L$WORKSPACE/lib"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/jpegoptim" ]; then
    echo "Skipping jpegoptim since it's already built."
else
	echo "Building jpegoptim"
	cd jpegoptim || exit
	run arch -x86_64 ./configure --prefix="$WORKSPACE" --with-arith --with-libjpeg="$WORKSPACE/lib"
	run arch -x86_64 make -j "$NPROC"
	run arch -x86_64 make strip
	run make install
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/oxipng" ]; then
    echo "Skipping oxipng since it's already built."
else
	echo "Building oxipng"
	cd oxipng || exit
	run cargo rustc --bin oxipng --release --target $RUST_TARGET_TRIPLE -- -C lto=fat -C opt-level=3 -C strip=symbols 
	cp "target/$RUST_TARGET_TRIPLE/release/oxipng" "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/pngcrush" ]; then
    echo "Skipping pngcrush since it's already built."
else
	echo "Building pngcrush"
	cd pngcrush || exit
	# Link with optimized zlib
	if [ ! -f Makefile.backup ]; then
	    sed -i.backup -e 's/\-O3/\-O3\ \-flto/' -e '/^LIBS/s/$/\ \-lz/' -e '48,52d' Makefile
	fi
	run arch -x86_64 make -j "$NPROC"
	run arch -x86_64 strip pngcrush
	cp pngcrush "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/pngquant" ]; then
    echo "Skipping pngquant since it's already built."
else
	echo "Building pngquant"
	cd pngquant || exit
	run cargo rustc --bin pngquant --features static --release --target $RUST_TARGET_TRIPLE -- -C lto=fat -C opt-level=3 -C strip=symbols
	cp "target/$RUST_TARGET_TRIPLE/release/pngquant" "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/svgcleaner" ]; then
    echo "Skipping svgcleaner since it's already built."
else
	echo "Building svgcleaner"
	cd svgcleaner || exit
	run cargo rustc --bin svgcleaner --release --target $RUST_TARGET_TRIPLE -- -C lto=fat -C opt-level=3 -C strip=symbols
	cp "target/$RUST_TARGET_TRIPLE/release/svgcleaner" "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/zopflipng" ]; then
    echo "Skipping zopfli since it's already built."
else
	echo "Building zopfli"
cd zopfli || exit
	# Remove extraneous closing bracket
	if [ ! -f src/zopfli/katajainen.c.backup ]; then
	    sed -i.backup '186d' src/zopfli/katajainen.c
	fi
	if [ ! -f Makefile.backup ]; then
	    sed -i.backup 's/\-O2/\-O3/' Makefile
	fi
	run arch -x86_64 make zopflipng -j "$NPROC"
	run arch -x86_64 strip zopflipng
	cp zopflipng "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/lib/libdeflate.a" ]; then
    echo "Skipping libdeflate since it's already built."
else
	echo "Building libdeflate"
	cd libdeflate || exit
	run cmake . -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_BUILD_TYPE=RELEASE -DLIBDEFLATE_BUILD_SHARED_LIB=OFF -DLIBDEFLATE_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$WORKSPACE"
	run arch -x86_64 make -j "$NPROC"
	run arch -x86_64 make install/strip
	rm -f "${WORKSPACE}/lib/libdeflate.0.dylib"
	rm -f "${WORKSPACE}/lib/libdeflate.dylib"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/advpng" ]; then
    echo "Skipping advpng since it's already built."
else
	echo "Building advpng"
	# AdvPNG has trouble linking with optimized zlib
	rm -f "${WORKSPACE}/include/zlib.h"
	rm -f "${WORKSPACE}/include/zconf.h"
	rm -f "${WORKSPACE}/lib/libz.a"
	rm -f "${WORKSPACE}/pkgconfig/zlib.pc"
	cd advpng || exit
	# Update Zopfli
	rm -rf zopfli
	cp -r ../zopfli/src/zopfli ./
	run arch -x86_64 autoreconf -fiv 
	run arch -x86_64 ./configure --prefix="$WORKSPACE" --disable-debug
	if [ ! -f Makefile.backup ]; then
	    sed -i.backup -e 's/\$\(am\_\_objects\_2\)//' -e '/^LIBS/s/$/\ \-ldeflate/' Makefile
	fi
	run arch -x86_64 make -j "$NPROC"
	run arch -x86_64 make install-strip
	cd .. || exit
fi

exit 0
