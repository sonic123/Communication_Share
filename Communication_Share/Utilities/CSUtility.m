//
//  CSUtility.m
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSUtility.h"

@implementation CSUtility
+(NSString *)getSystemPathByDir:(NSSearchPathDirectory)dir
                         domain:(NSSearchPathDomainMask)domainMask
               relativeFilePath:(NSString *)strRelativeFilePath{
    NSString		*strDir			= nil;
	NSArray			*arrDirPaths	= NSSearchPathForDirectoriesInDomains(dir,
                                                                          domainMask,
                                                                          YES);
	if (arrDirPaths == nil || arrDirPaths.count == 0) {
		return nil;
	}
	
	strDir = [arrDirPaths objectAtIndex:0];
	if (strRelativeFilePath != nil) {
		return [strDir stringByAppendingPathComponent:strRelativeFilePath];
	}
	
	return strDir;
}
+(NSString *)userInfoPath{
    return [CSUtility getSystemPathByDir:NSDocumentDirectory
                                  domain:NSUserDomainMask
                        relativeFilePath:UserInfoFileName];
}
#pragma mark -
#pragma mark EMail format check
+ (BOOL)validateEmailAddress:(NSString*)address
{
    if (!address) {
        return NO;
    }
    
    NSError             *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:address
                                                    options:0
                                                      range:NSMakeRange(0, address.length)];
    return (match != nil);
}
@end
