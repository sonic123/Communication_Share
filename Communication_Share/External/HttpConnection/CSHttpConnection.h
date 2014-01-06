//
//  CSHttpConnection.h
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kCSConnectionSuccess                           = 0,
	kCSConnectionFailureErrorType                  = 0x1,
	kCSConnectionTimedOutErrorType,
	kCSConnectionCredentialsAuthErrorType,
    kCSConnectionUserInfoAuthErrorType,
}KeyChainConnectionErrorEnum;

typedef void (^CSHttpCompletionBlock) (id connection);

@protocol CSHttpConnectionDelegate;

@interface CSHttpConnection : NSObject{
    CSHttpCompletionBlock         completionBlock;
    id<CSHttpConnectionDelegate>  _delegate;
    KeyChainConnectionErrorEnum   _errorType;
    NSString                     *_errorDescription;
    NSMutableData                *_dataReceived;
    NSURLConnection              *_currentConnection;
    double                        _dTimeoutInterval;
    NSTimer                      *_timerForTimeout;
    NSString                     *_strUserName;
    NSString                     *_strPassword;
}

@property (nonatomic, assign) id<CSHttpConnectionDelegate> delegate;
@property (nonatomic, assign) double                       timeoutInterval;

//
//Func:
//- (void)setCompletionBlock:(CSHTTPCompletionBlock)aCompletionBlock;
//
//Set the completion block, the block would be invoked when the connection ends.
- (void)setCompletionBlock:(CSHttpCompletionBlock)aCompletionBlock;

//
//Func:
//- (void)sendSOAPRequestWithURL:(NSString*)urlString
//                   messageBody:(NSString*)message
//                        action:(NSString*)action;
//
//Generates a SOAP URL request and starts the connection by "POST" method.
- (void)sendSOAPRequestWithURL:(NSString*)urlString
                   messageBody:(NSString*)message
                        action:(NSString*)action;

//
//Func:
//- (void)sendRestfulRequestWithURL:(NSString*)urlString;
//
//Generates a RESTFUL URL request and starts the connection by "GET" method.
- (void)sendRestfulRequestWithURL:(NSString*)urlString;

//
//Func:
//- (void)sendRequest:(NSURLRequest*)aURLRequest;
//
//Starts the connection by a customize URL request.
- (void)sendRequest:(NSURLRequest*)aURLRequest;

//
//Func:
//- (NSString*)responseString;
//
//Returns the available response contents from current requesting connection.
//If there aren't any contents available, return nil;
- (NSString*)responseString;

//
//Func:
//- (NSError*)connectionError;
//
//Returns the error occurred which contains details of why the connection failed to load the request
//successfully. If the connection ends successfully with no error info, return nil;
//The error info as below:
// 1. kPwCConnectionFailureErrorType -- Connectivity failed with no network connection
// 2. kPwCConnectionTimedOutErrorType -- Connectivity with time out
// 3. kPwCConnectionCredentialsAuthErrorType -- Invalid user certificate
// 4. kPwCConnectionUserInfoAuthErrorType -- Invalid password
// 5. Etc.
- (NSError*)connectionError;


@end

@protocol CSHttpConnectionDelegate

@optional
//- (void)PwCConnectionFinished:(PwCHttpConnection*)connection;
//- (void)PwCConnectionFailed:(PwCHttpConnection*)connection;
- (void)CSConnection:(CSHttpConnection*)connection
handleAuthenticationChanllenge:(NSURLAuthenticationChallenge*)challenge;

@end
