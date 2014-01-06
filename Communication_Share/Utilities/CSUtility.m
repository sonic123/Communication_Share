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
@end
