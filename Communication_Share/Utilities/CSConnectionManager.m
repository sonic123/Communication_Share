//
//  CSConnectionManager.m
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSConnectionManager.h"

static CSConnectionManager *_sharedConnectionMgr  =nil;
@implementation CSConnectionManager

+(CSConnectionManager *)sharedManager{
    static dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        _sharedConnectionMgr=[[CSConnectionManager alloc]init];
    });
    return _sharedConnectionMgr;
}

-(void)login:(NSString *)username
    password:(NSString *)password
 callbackObj:(id<CSConnectionDelegate>)callbackDelegate{
    
}

@end
