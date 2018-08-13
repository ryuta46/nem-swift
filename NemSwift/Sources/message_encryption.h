//
//  message_encyption.h
//  NemSwift
//
//  Created by Taizo Kusuda on 2018/08/13.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

#ifndef message_encryption_h
#define message_encryption_h

int create_random_bytes(unsigned char* buff, size_t size);
void create_shared_key(unsigned char* shared_key, const unsigned char* public_key, const unsigned char* private_key, const unsigned char* salt);

#endif /* message_encryption_h */
