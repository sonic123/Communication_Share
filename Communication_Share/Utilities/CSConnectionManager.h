//
//  CSConnectionManager.h
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSConnectionDelegate;

@interface CSConnectionManager : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;

+(CSConnectionManager *)sharedManager;

-(void)login:(NSString *)username
    password:(NSString *)password
 callbackObj:(id<CSConnectionDelegate>)callbackDelegate;

@end

@protocol CSConnectionDelegate <NSObject>
@optional
- (void)PPRequest:(CSConnectionManager *)connection didLoadResponse:(id)dataResponse;
- (void)PPRequest:(CSConnectionManager *)connection didFailLoadWithError:(NSError*)error;
- (void)PPRequestDidCancelLoad:(CSConnectionManager *)connection;
- (void)PPRequestDidTimeout:(CSConnectionManager *)connection;

@end
