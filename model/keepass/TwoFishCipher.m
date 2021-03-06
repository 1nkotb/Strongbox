//
//  TwoFishCipher.m
//  Strongbox
//
//  Created by Mark on 07/11/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import "TwoFishCipher.h"
#import "tomcrypt.h"

static const uint32_t kKeySize = 32;
static const uint32_t kBlockSize = 16;
static const uint32_t kIvSize = kBlockSize;

@implementation TwoFishCipher

- (NSData *)decrypt:(nonnull NSData *)data iv:(nonnull NSData *)iv key:(nonnull NSData *)key {
     int err;
    symmetric_key skey;
    
    if ((err = twofish_setup(key.bytes, kKeySize, 0, &skey)) != CRYPT_OK) {
        NSLog(@"Invalid Key");
        return nil;
    }
    
    NSMutableData *decData = [[NSMutableData alloc] init];
    
    uint8_t blockIv[kBlockSize];
    memcpy(blockIv, iv.bytes, kBlockSize);
    uint64_t numBlocks = data.length / kBlockSize;
    uint8_t *ct = (uint8_t*)data.bytes;

    uint8_t pt[kBlockSize];
    
    for(int block=0;block < numBlocks - 1;block++) {
        twofish_ecb_decrypt(ct, pt, &skey);

        for (int i = 0; i < kBlockSize; i++) {
            pt[i] ^= blockIv[i];
        }
        
        [decData appendBytes:pt length:kBlockSize];
        memcpy(blockIv, ct, kBlockSize);
        ct += kBlockSize;
    }
    
    // PKCS#7 Padding

    twofish_ecb_decrypt(ct, pt, &skey);
    
    for (int i = 0; i < kBlockSize; i++) {
        pt[i] ^= blockIv[i];
    }
    
    int paddingLength = pt[kBlockSize-1];
    if(paddingLength <= 0 || paddingLength > kBlockSize)  {
        NSLog(@"TWOFISH: Padding Byte Out of Range!");
        return nil;
    }
    for(int i = kBlockSize - paddingLength; i < kBlockSize; i++) {
        if(pt[i] != paddingLength) {
            NSLog(@"TWOFISH: Padding byte not equal expected!");
            return nil;
        }
    }

    [decData appendBytes:pt length:kBlockSize - paddingLength];

    return decData;
}

- (NSData *)encrypt:(nonnull NSData *)data iv:(nonnull NSData *)iv key:(nonnull NSData *)key {
    int err;
    symmetric_key skey;
    
    if ((err = twofish_setup(key.bytes, kKeySize, 0, &skey)) != CRYPT_OK) {
        NSLog(@"Invalid Key");
        return nil;
    }
    
    int numBlocks = (int)data.length / kBlockSize;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    
    uint8_t *pt = (uint8_t*)data.bytes;
    uint8_t ptBar[kBlockSize];
    unsigned char ct[kBlockSize];
    memcpy(ct, iv.bytes, kBlockSize); // Initialize CT with IV
    
    for (int i = 0; i < numBlocks; i++) {
        for (int j = 0; j < kBlockSize; j++) {
            ptBar[j] = pt[j] ^ ct[j];
        }

        twofish_ecb_encrypt(ptBar, ct, &skey);

        [ret appendBytes:ct length:kBlockSize];
        pt += kBlockSize;
    }
    
    // PKCS#7 Padding
    
    uint8_t padLen = kBlockSize - (data.length - (kBlockSize * numBlocks));
 
    for (size_t j = 0; j < kBlockSize - padLen; j++) {
        ptBar[j] = ct[j] ^ pt[j];
    }
    for (size_t i = kBlockSize - padLen; i < kBlockSize; i++) {
        ptBar[i] = ct[i] ^ padLen;
    }

    twofish_ecb_encrypt(ptBar, ct, &skey);

    [ret appendBytes:ct length:kBlockSize];
    
    return ret;
}

- (NSData *)generateIv {
    NSMutableData *newKey = [NSMutableData dataWithLength:kIvSize];
    
    if(SecRandomCopyBytes(kSecRandomDefault, kIvSize, newKey.mutableBytes))
    {
        NSLog(@"Could not securely copy new bytes");
        return nil;
    }
    
    return newKey;
}

@end
