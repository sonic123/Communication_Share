//
//  CSConnectionManager.m
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSConnectionManager.h"
#import "CSHttpConnection.h"

static CSConnectionManager *_sharedConnectionMgr  =nil;

static NSString * const kCommunicationAndShareBaseURLString    = @"http://121.199.58.200";

@interface CSConnectionManager ()<CSHttpConnectionDelegate>
{
    CSHttpConnection   *_connection;
}


@end

@implementation CSConnectionManager
+(CSConnectionManager *)sharedManager{
    static dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        _sharedConnectionMgr=[[CSConnectionManager alloc]init];
    });
    return _sharedConnectionMgr;
}

-(void)login:(NSString *)username
    withPassword:(NSString *)password
 callbackObj:(id<CSConnectionDelegate>)callbackDelegate{

    NSMutableURLRequest *aRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/user.signIn",kCommunicationAndShareBaseURLString]]];
    [aRequest setHTTPMethod:@"POST"];
    [aRequest setValue:@"application/json;charset='utf-8'" forHTTPHeaderField:@"Content-type"];
    NSDictionary *paramDic=[NSDictionary dictionaryWithObjectsAndKeys:username,@"uName",password,@"pwd", nil];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:paramDic options:NSJSONWritingPrettyPrinted error:&error];
    [aRequest setHTTPBody:postData];
    if (!_connection) {
        _connection = [[CSHttpConnection alloc] init];
        _connection.delegate = self;
    }
    
    __block CSConnectionManager *weakSelf = self;
    [_connection setCompletionBlock:^(id connection) {
        NSError *connectionError = [((CSHttpConnection*)connection) connectionError];
        if (connectionError) {
            NSLog(@"%@", connectionError);
            if (callbackDelegate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [callbackDelegate PPRequest:weakSelf didFailLoadWithError:connectionError];
                });
            }
        }
        else {
            if (callbackDelegate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [callbackDelegate PPRequest:weakSelf didLoadResponse:[connection responseString]];
                });
            }
        }
        
    }];

    [_connection sendRequest:aRequest];
    
}
-(void)registerAccount:(NSString *)loginName
          withNickName:(NSString *)nickName
          withPassword:(NSString *)password
             withEmail:(NSString *)email
           callbackObj:(id<CSConnectionDelegate>)callbackDelegate{
    NSMutableURLRequest *aRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/user.register",kCommunicationAndShareBaseURLString]]];
    [aRequest setHTTPMethod:@"POST"];
    [aRequest setValue:@"application/json;charset='utf-8'" forHTTPHeaderField:@"Content-type"];
    NSDictionary *paramDic=[NSDictionary dictionaryWithObjectsAndKeys:loginName,@"loginname",nickName,@"nickname",password,@"pass",email,@"email", nil];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:paramDic options:NSJSONWritingPrettyPrinted error:&error];
    [aRequest setHTTPBody:postData];
    if (!_connection) {
        _connection = [[CSHttpConnection alloc] init];
        _connection.delegate = self;
    }
    
    __block CSConnectionManager *weakSelf = self;
    [_connection setCompletionBlock:^(id connection) {
        NSError *connectionError = [((CSHttpConnection*)connection) connectionError];
        if (connectionError) {
            NSLog(@"%@", connectionError);
            if (callbackDelegate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [callbackDelegate PPRequest:weakSelf didFailLoadWithError:connectionError];
                });
            }
        }
        else {
            if (callbackDelegate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [callbackDelegate PPRequest:weakSelf didLoadResponse:[connection responseString]];
                });
            }
        }
        
    }];
    
    [_connection sendRequest:aRequest];
}

@end
