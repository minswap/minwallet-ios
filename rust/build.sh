#!/bin/bash

cargo check

cargo build --release

cargo run --bin uniffi-bindgen generate --library ./target/release/libmwrust.dylib --language swift --out-dir ./bindings

mv ./bindings/mwrustFFI.modulemap ./bindings/module.modulemap

rustup target add aarch64-apple-ios-sim aarch64-apple-ios

cargo build --target=aarch64-apple-ios-sim --release
cargo build --target=aarch64-apple-ios --release

rm -rf ios
xcodebuild -create-xcframework \
        -library ./target/aarch64-apple-ios-sim/release/libmwrust.a -headers ./bindings \
        -library ./target/aarch64-apple-ios/release/libmwrust.a -headers ./bindings \
        -output "ios/Mobile.xcframework"
