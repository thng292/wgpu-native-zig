# A zig wrapper around wgpu-native

This repo contains Zig binding for webgpu.h, generated from [webgpu.json](https://github.com/webgpu-native/webgpu-headers/blob/main/webgpu.json) and build.zig to automatically download & link [wgpu-native](https://github.com/gfx-rs/wgpu-native).

Checkout examples at [examples/](examples/).

## Installation 

```bash
zig fetch --save "git+https://github.com/thng292/wgpu-native-zig.git"
```

## Building examples

To build all examples
```
zig build example
```

To build a selected few
```
zig build example -Dexamples=compute,compute2
```

## To update webgpu.json

1. Download the new [webgpu.json](https://github.com/webgpu-native/webgpu-headers/blob/main/webgpu.json) and put it in `src/`
1. Run `zig build gen -- src/webgpu.json`

## To update wgpu-native

1. Run `zig build update-wgpu -Dwgpu-version=<version-to-update>`. (e.g. v29.0.1.1)

## To use another webgpu implementation

1. Update the build.zig.zon to add your implementation