#!/bin/bash
#
# Universal Binary Script for ImageOptim-ESR components
# 1.9.0a1 by DingoBits, 2022-10-20
# 
# Both arm64 and x64 builds should be done now.
#

set -e

mkdir -p dependencies/binaries

lipo arm64_workspace/bin/advpng x64_workspace/bin/advpng -create -output dependencies/binaries/advpng
lipo arm64_workspace/bin/gifsicle x64_workspace/bin/gifsicle -create -output dependencies/binaries/gifsicle
lipo arm64_workspace/bin/guetzli x64_workspace/bin/guetzli -create -output dependencies/binaries/guetzli
lipo arm64_workspace/bin/jpegoptim x64_workspace/bin/jpegoptim -create -output dependencies/binaries/jpegoptim
lipo arm64_workspace/bin/jpegtran x64_workspace/bin/jpegtran -create -output dependencies/binaries/jpegtran
lipo arm64_workspace/bin/oxipng x64_workspace/bin/advpng -create -output dependencies/binaries/oxipng
lipo arm64_workspace/bin/pngcrush x64_workspace/bin/pngcrush -create -output dependencies/binaries/pngcrush
lipo arm64_workspace/bin/pngquant x64_workspace/bin/pngquant -create -output dependencies/binaries/pngquant
lipo arm64_workspace/bin/svgcleaner x64_workspace/bin/svgcleaner -create -output dependencies/binaries/svgcleaner
lipo arm64_workspace/bin/zopflipng x64_workspace/bin/zopflipng -create -output dependencies/binaries/zopflipng
