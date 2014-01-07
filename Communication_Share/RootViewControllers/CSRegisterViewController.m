//
//  CSRegisterViewController.m
//  Communication_Share
//
//  Created by Sonic Lin on 1/7/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSRegisterViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "CSConnectionManager.h"
#import "CSRootViewController.h"
#import "CSEncrypt.h"
#import "CSUtility.h"

@interface CSRegisterViewController ()<UITextFieldDelegate,MBProgressHUDDelegate,CSConnectionDelegate>{
    MBProgressHUD   *_hud;
    NSError         *_error;
}
@property (strong, nonatomic) CSConnectionManager    *connectionMgr;
@end

@implementation CSRegisterViewController

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
    _btnRegister.layer.cornerRadius=5.0f;
    _btnRegister.layer.masksToBounds=YES;
    _btnCancel.layer.cornerRadius=5.0f;
    _btnCancel.layer.masksToBounds=YES;
}
-(void)restUI{
    [self.view endEditing:YES];
    if (_hud) {
        [_hud hide:YES];
    }
    
    self.txtLoginName.text=@"";
    self.txtNickName.text=@"";
    self.txtPassword.text=@"";
    self.txtConfirmPassword.text=@"";
    self.txtEmailAddress.text=@"";
    self.error=nil;


}
-(IBAction)actRegister:(id)sender{
    [self.view endEditing:YES];
    NSMutableString *alertMessage=nil;
    alertMessage=[[NSMutableString alloc]initWithString:@"请检查"];
   NSError *__autoreleasing errorLoginName = nil;
    NSError *__autoreleasing errorNickName = nil;
    NSError *__autoreleasing errorPsaaword = nil;

    if (![self checkLoginName:&errorLoginName]) {
        [alertMessage appendString:@"登录名,"];
    }
    if (![self checkNickName:&errorNickName]) {
        [alertMessage appendString:@"昵称,"];
    }
    if (![self checkPassword:&errorPsaaword]) {
        [alertMessage appendString:@"密码,"];
    }
    if (![CSUtility validateEmailAddress:self.txtEmailAddress.text]) {
        [alertMessage appendString:@"邮箱,"];
    }
    if ([alertMessage length]>3) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:alertMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [self requestRegister];
    }
    
}

-(IBAction)actCancel:(id)sender{
    self.txtLoginName.text=@"";
    self.txtNickName.text=@"";
    self.txtPassword.text=@"";
    self.txtConfirmPassword.text=@"";
    self.txtEmailAddress.text=@"";
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)checkLoginName:(NSError **)errInfo{
    BOOL bReturnVal  =NO;
    NSError *err     =nil;
    do {
        if ([self.txtLoginName.text length]<=0) {
            err=[NSError errorWithDomain:NSCocoaErrorDomain
                                    code:0
                                userInfo:@{NSLocalizedDescriptionKey: @"Please check your loginName."}];
            break;
        }
    } while (0);
    if (!err) {
        bReturnVal=YES;
    }
    if (errInfo) {
        *errInfo=err;
    }
    return bReturnVal;
}
-(BOOL)checkNickName:(NSError **)errInfo{
    BOOL bReturnVal  =NO;
    NSError *err     =nil;
    do {
        if ([self.txtNickName.text length]<=0) {
            err=[NSError errorWithDomain:NSCocoaErrorDomain
                                    code:0
                                userInfo:@{NSLocalizedDescriptionKey: @"Please check your nickName."}];
            break;
        }
    } while (0);
    if (!err) {
        bReturnVal=YES;
    }
    if (errInfo) {
        *errInfo=err;
    }
    return bReturnVal;
}

-(BOOL)checkPassword:(NSError **)errInfo{
    BOOL bReturnVal  =NO;
    NSError *err     =nil;
    do {
        if ([self.txtPassword.text length]<=0||[self.txtConfirmPassword.text length]<=0||![self.txtConfirmPassword.text isEqualToString:self.txtPassword.text]) {
            err=[NSError errorWithDomain:NSCocoaErrorDomain
                                    code:0
                                userInfo:@{NSLocalizedDescriptionKey: @"Please check your password."}];
            break;
        }
    } while (0);
    if (!err) {
        bReturnVal=YES;
    }
    if (errInfo) {
        *errInfo=err;
    }
    return bReturnVal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark Utility
-(void)requestRegister{
    if (!_connectionMgr) {
        self.connectionMgr = [CSConnectionManager sharedManager];
    }
    
    [self.connectionMgr registerAccount:self.txtLoginName.text withNickName:self.txtNickName.text withPassword:[CSEncrypt encryptWithMD5:self.txtPassword.text] withEmail:self.txtEmailAddress.text callbackObj:self];
}
#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtLoginName) {
        [self.txtNickName becomeFirstResponder];
    }else if (textField==self.txtNickName){
        [self.txtPassword becomeFirstResponder];
    }else if (textField==self.txtPassword){
        [self.txtConfirmPassword becomeFirstResponder];
    }
    else if (textField == self.txtEmailAddress) {
        [self.txtEmailAddress resignFirstResponder];
        [self performSelector:@selector(actRegister:)
                   withObject:self.btnRegister
                   afterDelay:0.0f];
    }
    
    return YES;
}

#pragma mark -
#pragma mark Connection Delegate
- (void)PPRequest:(CSConnectionManager *)connection didLoadResponse:(id)dataResponse
{
    self.error = nil;
    
//    CSUserDM *userInfo = [[CSUserDM alloc] init];
    //    if (![ASUserDM parseIntoUserDM:userInfo fromXML:(NSString *)dataResponse]) {
    //        self.error = [NSError errorWithDomain:NSCocoaErrorDomain
    //                                         code:0
    //                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Parser Error", nil)}];
    //    }
    //    else {
//    userInfo.password = self.txtPassowrd.text;
//    
//    _userName = nil;
//    _userName = [[NSString alloc] initWithString:userInfo.userName];
//    
//    [NSKeyedArchiver archiveRootObject:userInfo
//                                toFile:[CSUtility userInfoPath]];
    //    }
    
    
    if (self.error) {
        _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkerror"]];
        _hud.labelText = @"注册失败";
    }
    else {
        _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
        _hud.labelText = @"注册成功";
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
	_hud.labelText = @"注册失败";
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
	_hud.labelText = @"注册超时";
    [_hud hide:YES afterDelay:1];
}

#pragma mark -
#pragma mark HUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    _hud = nil;
//    if (self.delegate) {
//        if (self.error) {
//            [self.delegate welcomeLoginFailed:self];
//        }
//        else {
//            [self.delegate welcomeLoginEnd:self];
//        }
//    }
}



@end
