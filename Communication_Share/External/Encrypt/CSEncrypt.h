//
//  CSEncrypt.h
//  Communication_Share
//
//  Created by Sonic on 1/7/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSEncrypt : NSObject
+(NSString *)encryptWithMD5:(NSString *)aEncryptStr;
@end
