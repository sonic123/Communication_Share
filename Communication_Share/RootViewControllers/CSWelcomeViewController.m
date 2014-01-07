//
//  CSWelcomeViewController.m
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSWelcomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "CSUserDM.h"
#import "CSConnectionManager.h"
#import "CSUtility.h"
#import "CSRegisterViewController.h"

@interface CSWelcomeViewController ()<UITextFieldDelegate,MBProgressHUDDelegate,CSConnectionDelegate>{
    MBProgressHUD   *_hud;
    NSError         *_error;
}

@property (strong, nonatomic) CSConnectionManager    *connectionMgr;
@end

@implementation CSWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
}
-(void)initUI{
    _btnLogin.layer.cornerRadius=5.0f;
    _btnLogin.layer.masksToBounds=YES;
    UITapGestureRecognizer *tapGesture=nil;
    tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapFindPWD:)];
    [_lblFindPwd addGestureRecognizer:tapGesture];
    tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAccountRegister:)];
    [_lblAccountRegister addGestureRecognizer:tapGesture];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.navi.isNavigationBarHidden) {
        [self.navi setNavigationBarHidden:YES];
    }
}
-(void)resetUI{
    [self.view endEditing:YES];
    if (_hud) {
        [_hud hide:YES];
    }
    
    self.txtPassowrd.text=@"";
    
    self.error=nil;
    _userName=nil;
}
-(IBAction)tapFindPWD:(id)sender{
    NSLog(@"Find Password !");
}
-(IBAction)tapAccountRegister:(id)sender{
    NSLog(@"Register Account !");
    if (!_navi) {
        _navi=[[UINavigationController alloc]initWithRootViewController:self];
    }
    if (!_registerVC) {
        _registerVC=[[CSRegisterViewController alloc]initWithNibName:@"CSRegisterViewController" bundle:nil];
    }
    [self.navi pushViewController:_registerVC animated:YES];
    
    
}
-(IBAction)actLogin:(id)sender{
    [self.view endEditing:YES];
    
    NSError *__autoreleasing error = nil;
    if(![self checkInvalid:&error]){
        return;
    }
    
    if (!_hud) {
        _hud=[[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_hud];
        _hud.delegate=self;
        _hud.minSize=CGSizeMake(100, 100);
    }else{
        _hud.alpha = 1.0f;
    }
    
    _hud.labelText = @"登录中...";
    [_hud show:YES];
    [self performSelector:@selector(requestLogin) withObject:nil afterDelay:0.0f];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark Utility
- (void)requestLogin
{
    if (!_connectionMgr) {
        self.connectionMgr = [CSConnectionManager sharedManager];
    }
    
    [self.connectionMgr login:self.txtUserName.text
                     password:self.txtPassowrd.text
                  callbackObj:self];
}
-(BOOL)checkInvalid:(NSError **)errInfo{
    BOOL     bReturnVal  = NO;
    NSError  *err        =nil;
    do {
        if (!self.txtUserName.text || self.txtPassowrd.text.length <=0) {
            err=[NSError errorWithDomain:NSCocoaErrorDomain
                                    code:0
                                userInfo:@{NSLocalizedDescriptionKey: @"Please enter your password."}];
            break;
        }
    } while (0);
    if (!err) {
        bReturnVal = TRUE;
    }
    
    if (errInfo) {
        *errInfo = err;
    }
    
    return bReturnVal;
}
#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtUserName) {
        [self.txtPassowrd becomeFirstResponder];
    }
    else if (textField == self.txtPassowrd) {
        [self.txtPassowrd resignFirstResponder];
        [self performSelector:@selector(actLogin:)
                   withObject:self.btnLogin
                   afterDelay:0.0f];
    }
    
    return YES;
}

#pragma mark -
#pragma mark Connection Delegate
- (void)PPRequest:(CSConnectionManager *)connection didLoadResponse:(id)dataResponse
{
    self.error = nil;
    
    CSUserDM *userInfo = [[CSUserDM alloc] init];
//    if (![ASUserDM parseIntoUserDM:userInfo fromXML:(NSString *)dataResponse]) {
//        self.error = [NSError errorWithDomain:NSCocoaErrorDomain
//                                         code:0
//                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Parser Error", nil)}];
//    }
//    else {
        userInfo.password = self.txtPassowrd.text;
        
        _userName = nil;
        _userName = [[NSString alloc] initWithString:userInfo.userName];
        
        [NSKeyedArchiver archiveRootObject:userInfo
                                    toFile:[CSUtility userInfoPath]];
//    }
    
    
    if (self.error) {
        _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkerror"]];
        _hud.labelText = @"登录失败";
    }
    else {
        _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
        _hud.labelText = @"登陆成功";
    }
    
    _hud.mode = MBProgressHUDModeCustomView;
    [_hud hide:YES afterDelay:1];
}

- (void)PPRequest:(CSConnectionManager *)connection didFailLoadWithError:(NSError*)error
{
    if (error) {
        self.error = error;
        NSLog(@"Login Failed:[%@]", error.localizedDescription);
    }
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkerror"]];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"登录失败";
    [_hud hide:YES afterDelay:1];
}

- (void)PPRequestDidTimeout:(CSConnectionManager *)connection
{
    self.error = [NSError errorWithDomain:NSCocoaErrorDomain
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Timeout", nil)}];
    NSLog(@"Login Failed:[Timeout]");
    
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkerror"]];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"登录超时";
    [_hud hide:YES afterDelay:1];
}

#pragma mark -
#pragma mark HUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    _hud = nil;
    if (self.delegate) {
        if (self.error) {
            [self.delegate welcomeLoginFailed:self];
        }
        else {
            [self.delegate welcomeLoginEnd:self];
        }
    }
}



@end
