//
//  CSUtility.h
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const UserInfoFileName = @"userInfo";

@interface CSUtility : NSObject

#pragma mark -
#pragma mark FileSystem
+(NSString *)getSystemPathByDir:(NSSearchPathDirectory)dir
                         domain:(NSSearchPathDomainMask)domainMask
               relativeFilePath:(NSString *)strRelativeFilePath;
+(NSString *)userInfoPath;
+ (BOOL)validateEmailAddress:(NSString*)address;
@end
