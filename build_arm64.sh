#!/bin/bash
#
# arm64 Build Script for ImageOptim-ESR components
# 1.9.0a1 by DingoBits, 2022-10-20
# 
# You need following build tools
# autoconf automake cmake rust
#
# pngquant has optional dependencies
# little-cms2 openmp
#
# Also
# rustup target add x86_64-apple-darwin aarch64-apple-darwin
#

set -e

cp -r dependencies arm64_pkgs

WORKSPACE="$(pwd)/arm64_workspace"
NPROC=$(sysctl -n machdep.cpu.thread_count)
mkdir -p "$WORKSPACE"
RUST_TARGET_TRIPLE=aarch64-apple-darwin

export ARCH=arm64
export ARCHS=arm64
export TARGET="arm64-apple-macos12"
export HOST="arm64-apple-macos12"
export MACOSX_DEPLOYMENT_TARGET=12.0
export CPPFLAGS="-mcpu=apple-m1 -Ofast -flto -I$WORKSPACE/include"
export LDFLAGS="-L$WORKSPACE/lib"
export PATH="$WORKSPACE/bin:$PATH"
export PREFIX="$WORKSPACE"
export CPATH="$WORKSPACE/include"
export LIBRARY_PATH="$WORKSPACE/lib"
export PKG_CONFIG_PATH="$WORKSPACE/lib/pkgconfig"

cd arm64_pkgs || exit

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
	run ./configure --prefix="$WORKSPACE" --static
	run make -j "$NPROC"
	run make install
	cd .. || exit
fi

if [ -f "$WORKSPACE/lib/libpng.a" ]; then
    echo "Skipping libpng since it's already built."
else
	echo "Building libpng"
	cd libpng || exit
	run cmake . -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_BUILD_TYPE=RELEASE -DPNG_ARM_NEON=on -DPNG_INTEL_SSE=off -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF -DZLIB_INCLUDE_DIR="${WORKSPACE}/include" -DZLIB_LIBRARY_RELEASE="${WORKSPACE}/lib/libz.a"
	run make -j "$NPROC"
	run make install
	cd .. || exit
fi

if [ -f "$WORKSPACE/lib/libjpeg.a" ]; then
    echo "Skipping mozjpeg since it's already built."
else
	echo "Building mozjpeg"
	cd mozjpeg || exit
	run cmake . -DCMAKE_OSX_ARCHITECTURES="$ARCH" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-mcpu=apple-m1" -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DPNG_SUPPORTED=OFF -DWITH_12BIT=ON -DWITH_ARITH_DEC=ON -DWITH_ARITH_ENC=ON -DWITH_MEM_SRCDST=ON -DWITH_SIMD=ON -DCMAKE_INSTALL_PREFIX="$WORKSPACE"
	run make -j "$NPROC"
	run make install/strip
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/gifsicle" ]; then
    echo "Skipping gifsicle since it's already built."
else
	echo "Building gifsicle"
	cd gifsicle || exit
	run ./bootstrap.sh
	run ./configure --prefix="$WORKSPACE" --disable-gifview --disable-gifdiff
	run make -j "$NPROC"
	run make install
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/guetzli" ]; then
    echo "Skipping guetzli since it's already built."
else
	echo "Building guetzli"
	cd guetzli || exit
	export LDFLAGS="-L$WORKSPACE/lib -lz"
	run make config=release guetzli -j "$NPROC"
	cp bin/Release/guetzli "$WORKSPACE/bin"
	export LDFLAGS="-L$WORKSPACE/lib"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/jpegoptim" ]; then
    echo "Skipping jpegoptim since it's already built."
else
	echo "Building jpegoptim"
	cd jpegoptim || exit
	run ./configure --prefix="$WORKSPACE" --with-arith --with-libjpeg="$WORKSPACE/lib"
	run make -j "$NPROC"
	run make install
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/oxipng" ]; then
    echo "Skipping oxipng since it's already built."
else
	echo "Building oxipng"
	cd oxipng || exit
	run cargo rustc --bin oxipng --release --target $RUST_TARGET_TRIPLE -- -C target-cpu=apple-m1 -C lto=fat -C opt-level=3 -C strip=symbols 
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
	    sed -i.backup -e 's/\-O3/\-mcpu\=apple\-m1\ \-O3\ \-flto/' -e '/^LIBS/s/$/\ \-lz/' -e '48,52d' Makefile
	fi
	run make -j "$NPROC"
	cp pngcrush "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/pngquant" ]; then
    echo "Skipping pngquant since it's already built."
else
	echo "Building pngquant"
	if [ -d "/opt/homebrew/opt/libomp" ] ; then
		# OpenMP not linked by default. Copy from homebrew.
		cp -r "/opt/homebrew/opt/libomp/include/." "$WORKSPACE/include"
		cp "/opt/homebrew/opt/libomp/lib/libomp.a" "$WORKSPACE/lib/libomp.a"
	fi
	cd pngquant || exit
	run cargo rustc --bin pngquant --features static --release --target $RUST_TARGET_TRIPLE -- -C target-cpu=apple-m1 -C lto=fat -C opt-level=3 -C strip=symbols
	cp "target/$RUST_TARGET_TRIPLE/release/pngquant" "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/svgcleaner" ]; then
    echo "Skipping svgcleaner since it's already built."
else
	echo "Building svgcleaner"
	cd svgcleaner || exit
	run cargo rustc --bin svgcleaner --release --target $RUST_TARGET_TRIPLE -- -C target-cpu=apple-m1 -C lto=fat -C opt-level=3 -C strip=symbols
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
	    sed -i.backup 's/\-O2/\-mcpu=apple\-m1\ \-O3/' Makefile
	fi
	run make zopflipng -j "$NPROC"
	cp zopflipng "$WORKSPACE/bin"
	cd .. || exit
fi

if [ -f "$WORKSPACE/lib/libdeflate.a" ]; then
    echo "Skipping libdeflate since it's already built."
else
	echo "Building libdeflate"
	cd libdeflate || exit
	run make install -j "$NPROC" PREFIX="$WORKSPACE"
	rm "${WORKSPACE}/lib/libdeflate.0.dylib"
	rm "${WORKSPACE}/lib/libdeflate.dylib"
	cd .. || exit
fi

if [ -f "$WORKSPACE/bin/advpng" ]; then
    echo "Skipping advpng since it's already built."
else
	echo "Building advpng"

	# AdvPNG has trouble linking with optimized zlib
	rm "${WORKSPACE}/include/zlib.h"
	rm "${WORKSPACE}/include/zconf.h"
	rm "${WORKSPACE}/lib/libz.a"
	rm "${WORKSPACE}/pkgconfig/zlib.pc"
	cd advpng || exit
	# Update Zopfli
	rm -rf zopfli
	cp -r ../zopfli/src/zopfli ./
	run autoreconf -fiv 
	run ./configure --prefix="$WORKSPACE" --disable-debug
	if [ ! -f Makefile.backup ]; then
	    sed -i.backup -e 's/\$\(am\_\_objects\_2\)//g' -e '/^LIBS/s/$/\ \-ldeflate/' Makefile
	fi
	run make -j "$NPROC"
	run make install
	cd .. || exit
fi

exit 0
