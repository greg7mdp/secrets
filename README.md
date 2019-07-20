secrets
=======

[![Build Status][badge-ci]][ci]
[![Test Coverage][badge-coverage]][coverage]
[![Cargo Crate][badge-package]][package]
[![License][badge-license]][license]

`secrets` is a library to help Rust programmers safely held cryptographic
secrets in memory.

It is mostly an ergonomic wrapper around the memory-protection utilities
provided by [libsodium].

Fixed-size buffers allocated on the stack gain the following protections:

* [`mlock(2)`][mlock] is called on the underlying memory
* the underlying memory is zeroed out when no longer in use
* they are borrowed for their entire lifespan, so cannot be moved
* they are compared in constant time
* they are prevented from being printed by `Debug`
* they are prevented from being `Clone`d

Fixed and variable-sized buffers can be allocated on the heap and gain
the following protections:

* the underlying memory is protected from being read from or written to
  with [`mprotect(2)`][mprotect] unless an active borrow is in scope
* [`mlock(2)`][mlock] is called on the allocated memory
* the underlying memory is zeroed out when no longer in use
* overflows and underflows are detected using inaccessible guard pages,
  causing an immediate segmentation fault and program termination
* short underflows that write to memory are detected when memory is
  freed using canaries, and will result in a segmentation fault and
  program termination

Examples
--------

Generating cryptographic keys:

```rust
Secret::<[u8; 16]>::random(|s| {
     // use `s` as if it were a `&mut [u8; 16]`
});
```

Holding a decrypted plaintext (pseudocode):

```rust
let key = SecretBox::<[u8; 16]>::new(|mut s| {
    /// initialized from some preexisting key
});

let mut ciphertext = SecretVec::<u8>::from(&mut b"..."); // some ciphertext
let     nonce      = b"..."; // some nonce
let     tag        = b"..."; // some authentication tag

let ciphertext_rw = ciphertext.borrow_mut();

crypto::secretbox::open_detached(
    &ciphertext_rw[..],
    tag, nonce, key
);
```

License
-------

Licensed under either of

 * [Apache License, Version 2.0](LICENSE-APACHE)
 * [MIT license](LICENSE-MIT)

at your option.

[ci]:       https://travis-ci.org/stouset/secrets
[coverage]: https://coveralls.io/github/stouset/secrets
[docs]:     https://stouset.github.io/secrets
[license]:  https://github.com/stouset/secrets/blob/master/LICENSE
[package]:  https://crates.io/crates/secrets

[badge-ci]:       https://img.shields.io/travis/stouset/secrets/master.svg
[badge-coverage]: https://coveralls.io/repos/github/stouset/secrets/badge.svg
[badge-license]:  https://img.shields.io/crates/l/secrets.svg
[badge-package]:  https://img.shields.io/crates/v/secrets.svg

[libsodium]: https://download.libsodium.org/doc/memory_management
[mlock]:     http://man7.org/linux/man-pages/man2/mlock.2.html
[mprotect]:  http://man7.org/linux/man-pages/man2/mprotect.2.html
