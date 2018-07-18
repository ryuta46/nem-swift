//
//  ed25519_sha3_512.c
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/15.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

#include "ed25519_sha3_512.h"

#include "RHash/librhash/sha3.h"
#include "ed25519/src/ge.h"
#include "ed25519/src/sc.h"

void ed25519_sha3_create_keypair(unsigned char *public_key, unsigned char *private_key, const unsigned char *seed) {
    ge_p3 A;
    
    sha3_ctx ctx;
    rhash_keccak_512_init(&ctx);
    rhash_keccak_update(&ctx, seed, 32);
    rhash_keccak_final(&ctx, private_key);
    
    private_key[0] &= 248;
    private_key[31] &= 63;
    private_key[31] |= 64;
    
    ge_scalarmult_base(&A, private_key);
    ge_p3_tobytes(public_key, &A);
}

void ed25519_sha3_sign(unsigned char *signature, const unsigned char *message, size_t message_len, const unsigned char *public_key, const unsigned char *private_key) {
    sha3_ctx hash;
    unsigned char hram[64];
    unsigned char r[64];
    ge_p3 R;
    
    rhash_keccak_512_init(&hash);
    rhash_keccak_update(&hash, private_key + 32, 32);
    rhash_keccak_update(&hash, message, message_len);
    rhash_keccak_final(&hash, r);
    
    sc_reduce(r);
    ge_scalarmult_base(&R, r);
    ge_p3_tobytes(signature, &R);
    
    rhash_keccak_512_init(&hash);
    rhash_keccak_update(&hash, signature, 32);
    rhash_keccak_update(&hash, public_key, 32);
    rhash_keccak_update(&hash, message, message_len);
    rhash_keccak_final(&hash, hram);
    
    sc_reduce(hram);
    sc_muladd(signature + 32, hram, private_key, r);
}

static int consttime_equal(const unsigned char *x, const unsigned char *y) {
    unsigned char r = 0;
    
    r = x[0] ^ y[0];
#define F(i) r |= x[i] ^ y[i]
    F(1);
    F(2);
    F(3);
    F(4);
    F(5);
    F(6);
    F(7);
    F(8);
    F(9);
    F(10);
    F(11);
    F(12);
    F(13);
    F(14);
    F(15);
    F(16);
    F(17);
    F(18);
    F(19);
    F(20);
    F(21);
    F(22);
    F(23);
    F(24);
    F(25);
    F(26);
    F(27);
    F(28);
    F(29);
    F(30);
    F(31);
#undef F
    
    return !r;
}

int ed25519_sha3_verify(const unsigned char *signature, const unsigned char *message, size_t message_len, const unsigned char *public_key) {
    unsigned char h[64];
    unsigned char checker[32];
    sha3_ctx hash;
    ge_p3 A;
    ge_p2 R;
    
    if (signature[63] & 224) {
        return 0;
    }
    
    if (ge_frombytes_negate_vartime(&A, public_key) != 0) {
        return 0;
    }
    
    rhash_keccak_512_init(&hash);
    rhash_keccak_update(&hash, signature, 32);
    rhash_keccak_update(&hash, public_key, 32);
    rhash_keccak_update(&hash, message, message_len);
    rhash_keccak_final(&hash, h);
    
    sc_reduce(h);
    ge_double_scalarmult_vartime(&R, h, &A, signature + 32);
    ge_tobytes(checker, &R);
    
    if (!consttime_equal(checker, signature)) {
        return 0;
    }
    
    return 1;
}


