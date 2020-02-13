## Nim-Libp2p
## Copyright (c) 2020 Status Research & Development GmbH
## Licensed under either of
##  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
##  * MIT license ([LICENSE-MIT](LICENSE-MIT))
## at your option.
## This file may not be copied, modified, or distributed except according to
## those terms.

## This module integrates BearSSL ChaCha20+Poly1305
##
## This module uses unmodified parts of code from
## BearSSL library <https://bearssl.org/>
## Copyright(C) 2018 Thomas Pornin <pornin@bolet.org>.

# RFC @ https://tools.ietf.org/html/rfc7539

import bearssl

const
  ChaChaPolyKeySize = 32
  ChaChaPolyNonceSize = 12
  ChaChaPolyTagSize = 16
  
type
  ChaChaPoly = object
  ChaChaPolyKey* = array[ChaChaPolyKeySize, byte]
  ChaChaPolyNonce* = array[ChaChaPolyNonceSize, byte]
  ChaChaPolyTag* = array[ChaChaPolyTagSize, byte]

# bearssl allows us to use optimized versions
# this is reconciled at runtime
# we do this in the global scope / module init

# try for the best first
var
  chachapoly_native_impl: Poly1305Run = poly1305CtmulqGet()
  chacha_native_impl: Chacha20Run = chacha20Sse2Get()

# fall back if not available
if chachapoly_native_impl == nil:
  echo "ChaChaPoly could not use the fastest implementation, falling back"
  chachapoly_native_impl = poly1305CtmulRun

if chacha_native_impl == nil:
  echo "ChaCha could not use the fastest implementation, falling back"
  chacha_native_impl = chacha20CtRun

echo "ChaCha20Poly1305 global init done."

proc encrypt*(_: type[ChaChaPoly],
                 key: var ChaChaPolyKey,
                 nonce: var ChaChaPolyNonce,
                 tag: var ChaChaPolyTag,
                 data: var openarray[byte],
                 aad: var openarray[byte]) =
  chachapoly_native_impl(
    addr key[0],
    addr nonce[0],
    addr data[0],
    data.len,
    addr aad[0],
    aad.len,
    addr tag[0],
    chacha_native_impl,
    #[encrypt]# 1.cint)

proc decrypt*(_: type[ChaChaPoly],
                 key: var ChaChaPolyKey,
                 nonce: var ChaChaPolyNonce,
                 tag: var ChaChaPolyTag,
                 data: var openarray[byte],
                 aad: var openarray[byte]) =
  chachapoly_native_impl(
    addr key[0],
    addr nonce[0],
    addr data[0],
    data.len,
    addr aad[0],
    aad.len,
    addr tag[0],
    chacha_native_impl,
    #[decrypt]# 0.cint)

when isMainModule:
  var
    key: ChaChaPolyKey
    iv: ChaChaPolyNonce
    tag: ChaChaPolyTag
    data = [0.byte, 1, 2, 3, 4]
    aad = [0.byte, 1, 2, 3, 4]

  ChaChaPoly.encrypt(key, iv, tag, data, aad)
  assert data != [0.byte, 1, 2, 3, 4]
  ChaChaPoly.decrypt(key, iv, tag, data, aad)
  assert data == [0.byte, 1, 2, 3, 4]
