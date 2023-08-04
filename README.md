# ImageOptim-ESR

[ImageOptim-ESR](https://github.com/DingoBits/ImageOptim-ESR) is a (stop-gap) continuation of [ImageOptim](https://github.com/ImageOptim/ImageOptim) 1.x, a GUI for lossless image optimization tools: [advpng](https://www.advancemame.it/doc-advpng), [gifsicle](https://github.com/kohler/gifsicle), [Guetzli](https://github.com/google/guetzli), [jpegoptim](https://github.com/tjko/jpegoptim), [MozJPEG](https://github.com/mozilla/mozjpeg), [oxipng](https://crates.rs/crates/oxipng),  [pngcrush](http://pmt.sourceforge.net/pngcrush), [pngquant](https://github.com/kornelski/pngquant), [pngout](http://www.advsys.net/ken/utils.htm), [svgcleaner](https://github.com/RazrFalcon/svgcleaner), [SVGO](https://github.com/svg/svgo) and  [zopfli](https://github.com/google/zopfli).

ImageOptim 1.x [has been announced EOL with 2.x in development](https://github.com/ImageOptim/ImageOptim/issues/354). The last version was 1.8.9a1 with limited arm64 support. ESR stands for Extended Support Release. This project updates its internal components with specific optimization for Apple Silicon, and makes minor bug fixes. There are no plans to make any major changes to the codebase.

|               | Original      | ESR           | Native arm64 |
| ------------- | ------------- | ------------- | ------------ |
| advpng        | 1.15          | 2.5           | ✓            |
| gifsicle      | 1.89          | 1.94          | ✓            |
| guetzli       | 1.0.1-de70ac2 | 1.0.1-214f2bb | ✓            |
| jpegoptim     | 1.4.4         | 1.5.4         | ✓            |
| libjpeg-turbo | 1.5.3         | 3.0.0         | ✓            |
| oxipng        | 4.0.3         | 8.0.0         | ✓            |
| pngcrush      | 1.8.10        | 1.8.13        | ✓            |
| pngquant      | 2.11.0        | 3.0.1         | ✓            |
| pngout        | 2015-09-20    | 2023-03-22    | ✓            |
| svgcleaner    | 0.9.6         | 0.9.6         | ✓            |
| SVGO          | 1.0.5         | 2.8.0         | ✓            |
| zopfli        | 1.0.2         | 1.0.3         | ✓            |

## Building

Instead of painstakingly making Xcode work with autotools, I took the patented quick-and-dirty approach and separated the build into three parts.

1. Build backend tools in terminal with `build_arm64.sh` and `build_amd64.sh`. You can choose just build for one platform.
2. Make universal binaries with `lipo.sh`.
3. Build ImageOptim-ESR with `imageoptim/ImageOptim.xcodeproj`.
