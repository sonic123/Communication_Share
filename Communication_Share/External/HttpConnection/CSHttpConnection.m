//
//  CSHttpConnection.m
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSHttpConnection.h"
#import "Reachability.h"

@interface CSHttpConnection()
@property (nonatomic, retain) NSString *errorDescription;

- (void)timeOutHandler:(NSTimer*)theTimer;
- (void)endConnection;
+ (NSString*)errorDesription:(KeyChainConnectionErrorEnum)errType;
@end

@implementation CSHttpConnection
@synthesize delegate = _delegate;
@synthesize timeoutInterval = _dTimeoutInterval;
@synthesize errorDescription = _errorDescription;


#pragma mark -
#pragma mark override
- (id)init
{
    self = [super init];
    if (self) {
        _errorType          = kCSConnectionSuccess;
        _dTimeoutInterval   = 240.0f;
    }
    
    return self;
}

- (void)dealloc
{
    [_currentConnection release];
    [_dataReceived release];
    [_strUserName release];
    [_strPassword release];
    [_errorDescription release];
    [_timerForTimeout release];
    [completionBlock release];
    
    [super dealloc];

}

- (void)reset {
 [_dataReceived release];

    _dataReceived = [[NSMutableData alloc] initWithCapacity:0];
}

#pragma mark -
#pragma mark Blocks
//Set the completion block, the block would be invoked when the connection ends.
- (void)setCompletionBlock:(CSHttpCompletionBlock)aCompletionBlock
{
    [completionBlock release];
     completionBlock = [aCompletionBlock copy];
}


#pragma mark -
#pragma mark Interface
//Generates a SOAP URL request and starts the connection by "POST" method.
- (void)sendSOAPRequestWithURL:(NSString*)urlString
                   messageBody:(NSString*)message
                        action:(NSString*)action
{
    @synchronized(self) {
        
        [self reset];
        
        NSMutableURLRequest     *urlRequest = nil;
        
        //Input Check
        if (urlString == nil) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"invalid parameter";
            
            [self endConnection];
            return;
        }
        
        //Network Check
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        if ([reachability currentReachabilityStatus] == NotReachable) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"connection Failure";
            
            [self endConnection];
            return;
        }
        
        //Generate URLRequest
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:_dTimeoutInterval];
        if (urlRequest == nil) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"invalid URL";
            
            [self endConnection];
            return;
        }
        
        [urlRequest addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPMethod:@"POST"];
        if (message != nil) {
            [urlRequest addValue:[NSString stringWithFormat:@"%d", message.length] forHTTPHeaderField:@"Content-Length"];
            [urlRequest setHTTPBody:[message dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
        if (action != nil) {
            [urlRequest addValue:action forHTTPHeaderField:@"SOAPAction"];
        }
        
        //Make Connection
        if (_currentConnection != nil) {
            [_currentConnection cancel];
            [_currentConnection release];

        }
        _currentConnection = [[NSURLConnection connectionWithRequest:urlRequest
                                                            delegate:self] retain];
        
        //Timeout
        if (_timerForTimeout != nil) {
            [_timerForTimeout invalidate];
            [_timerForTimeout release];
        }
        if (message != nil) {
            //after ios3.0, as what apple said, if URLRequest has set HTTPBody,
            //the timeoutInterval would be automatically set to 240 seconds.
            //so we need set effective timeout by ourselves.
            _timerForTimeout = [[NSTimer scheduledTimerWithTimeInterval:_dTimeoutInterval
                                                                 target:self
                                                               selector:@selector(timeOutHandler:)
                                                               userInfo:nil
                                                                repeats:NO] retain];
        }
        
        [_currentConnection start];
    }
}


//Generates a RESTFUL URL request and starts the connection by "GET" method.
- (void)sendRestfulRequestWithURL:(NSString*)urlString
{
    @synchronized(self) {
        [self reset];
        
        NSMutableURLRequest     *urlRequest = nil;
        
        //input check
        if (urlString == nil) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"invalid parameter";
            [self endConnection];
            return;
        }
        
        //network check
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        if ([reachability currentReachabilityStatus] == NotReachable) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"connection Failure";
            [self endConnection];
            return;
        }
        
        //generate URLRequest
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:_dTimeoutInterval];
        if (urlRequest == nil) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"invalid URL";
            [self endConnection];
            return;
        }
        [urlRequest setHTTPMethod:@"GET"];
        
        //make connection
        if (_currentConnection != nil) {
            [_currentConnection cancel];
            [_currentConnection release];
        }
        _currentConnection = [[NSURLConnection connectionWithRequest:urlRequest
                                                            delegate:self] retain];
        
        [_currentConnection start];
    }
}

//Starts the connection by a customize URL request.
- (void)sendRequest:(NSURLRequest*)aURLRequest
{
    @synchronized(self) {
        
        [self reset];
        
        //input check
        if (aURLRequest == nil) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"invalid parameter";
            [self endConnection];
            return;
        }
        
        //network check
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        if ([reachability currentReachabilityStatus] == NotReachable) {
            _errorType              = kCSConnectionFailureErrorType;
            self.errorDescription   = @"connection Failure";
            [self endConnection];
            return;
        }
        
        //make connection
        if (_currentConnection != nil) {
            [_currentConnection cancel];
            [_currentConnection release];
        }
        _currentConnection = [[NSURLConnection connectionWithRequest:aURLRequest
                                                            delegate:self] retain];
        [_currentConnection start];

    }
}

//Returns the available response contents from current requesting connection.
//If there aren't any contents available, return nil;
- (NSString*)responseString
{
    return [[[NSString alloc] initWithData:_dataReceived
                                  encoding:NSUTF8StringEncoding] autorelease];
}

//Returns the error occurred which contains details of why the connection failed to load the request
//successfully. If the connection ends successfully with no error info, return nil;
//The error info as below:
// 1. kPwCConnectionFailureErrorType -- Connectivity failed with no network connection
// 2. kPwCConnectionTimedOutErrorType -- Connectivity with time out
// 3. kPwCConnectionCredentialsAuthErrorType -- Invalid user certificate
// 4. kPwCConnectionUserInfoAuthErrorType -- Invalid password
// 5. Etc.
- (NSError*)connectionError
{
    if (_errorType == kCSConnectionSuccess) {
        return nil;
    }
    
    return [NSError errorWithDomain:@"PwCHTTPConnectionError"
                               code:_errorType
                           userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString((_errorDescription==nil)?@"":_errorDescription, @"")
                                                                forKey:NSLocalizedDescriptionKey]];
}

#pragma mark -
#pragma mark Utility
+ (NSString*)errorDesription:(KeyChainConnectionErrorEnum)errType
{
	NSString *strErrDesc = nil;
	
	switch (errType) {
		case kCSConnectionSuccess:
			return @"connection success";
		case kCSConnectionTimedOutErrorType:
			strErrDesc = @"connection timeout";
			break;
		case kCSConnectionCredentialsAuthErrorType:
			strErrDesc = @"credential authentication failed";
			break;
		case kCSConnectionUserInfoAuthErrorType:
			strErrDesc = @"user name and password authentication failed";
			break;
		default:
			strErrDesc = @"connection Failure";
			break;
	}
	
	return strErrDesc;
}


- (void)endConnection
{
    //time out
    if (_timerForTimeout != nil) {
        [_timerForTimeout invalidate];
        [_timerForTimeout release];

    }
    
    //connection
    if (_currentConnection != nil) {
        [_currentConnection cancel];
        [_currentConnection release];

    }
    
    //success
    if (_errorType == kCSConnectionSuccess) {
        if(completionBlock) {
            completionBlock(self);
        }
        return;
    }
    
    //error occurred
    if (_errorDescription == nil) {
        self.errorDescription = [CSHttpConnection errorDesription:_errorType];
    }
    
    if(completionBlock) {
        completionBlock(self);
    }
}

#pragma mark -
#pragma mark timeOut
- (void)timeOutHandler:(NSTimer*)theTimer
{
    if (_timerForTimeout == theTimer)
    {
        _errorType = kCSConnectionTimedOutErrorType;
        [self endConnection];
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)resp
{
    NSHTTPURLResponse * response = (NSHTTPURLResponse *) resp;
    if ((response.statusCode / 100) != 2)
    {
        if (response.statusCode == 400) {
            _errorType = kCSConnectionCredentialsAuthErrorType;
        }
        else if (response.statusCode == 500) {
            _errorType = kCSConnectionCredentialsAuthErrorType;
        }
        else {
            _errorType = kCSConnectionUserInfoAuthErrorType;
        }
        
        [self endConnection];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data != nil) {
        [_dataReceived appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_dataReceived setLength:0];
    _errorType              = kCSConnectionFailureErrorType;
    self.errorDescription   = [error localizedDescription];
    [self endConnection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _errorType        = kCSConnectionSuccess;
    [self endConnection];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge == nil) {
        return;
    }
    
    if (_delegate != nil &&
        [(NSObject*)_delegate respondsToSelector:@selector(CSConnection: handleAuthenticationChanllenge:)]) {
        [_delegate CSConnection:self handleAuthenticationChanllenge:challenge];
        return;
    }
    
    [[challenge sender] performDefaultHandlingForAuthenticationChallenge:challenge];
}

//implement this delegate for iOS 4.x compatibility
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSString *requestedAuthenticationMethod = [protectionSpace authenticationMethod];
    if(requestedAuthenticationMethod == NSURLAuthenticationMethodHTTPBasic || 
       requestedAuthenticationMethod == NSURLAuthenticationMethodDefault || 
       requestedAuthenticationMethod == NSURLAuthenticationMethodClientCertificate || 
       requestedAuthenticationMethod == NSURLAuthenticationMethodNTLM) {
        return YES;
    }
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self connection:connection willSendRequestForAuthenticationChallenge:challenge];
}

@end

