//
//  CSEncrypt.m
//  Communication_Share
//
//  Created by Sonic on 1/7/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSEncrypt.h"
#import "CommonCrypto/CommonDigest.h"

@implementation CSEncrypt

+(NSString *)encryptWithMD5:(NSString *)aEncryptStr{
    const char *cStr = [aEncryptStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}
@end
