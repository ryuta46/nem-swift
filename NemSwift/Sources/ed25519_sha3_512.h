//
//  ed25519_sha3_512.h
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/15.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

#ifndef ed25519_sha3_512_h
#define ed25519_sha3_512_h

#include <stdio.h>

void ed25519_sha3_create_keypair(unsigned char *public_key, unsigned char *private_key, const unsigned char *seed);
void ed25519_sha3_sign(unsigned char *signature, const unsigned char *message, size_t message_len, const unsigned char *public_key, const unsigned char *private_key);
int ed25519_sha3_verify(const unsigned char *signature, const unsigned char *message, size_t message_len, const unsigned char *public_key);

#endif /* ed25519_sha3_512_h */
