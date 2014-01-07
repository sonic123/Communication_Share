//
//  CSWelcomeViewController.h
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSRegisterViewController;
@protocol CSWelecomeDelegate;

@interface CSWelcomeViewController : UIViewController

@property (assign, nonatomic) id<CSWelecomeDelegate> delegate;
@property (strong, nonatomic) NSError *error;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassowrd;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UILabel *lblFindPwd;
@property (weak, nonatomic) IBOutlet UILabel *lblAccountRegister;
@property (strong, nonatomic, readonly) NSString *userName;

@property (strong, nonatomic) UINavigationController *navi;
@property (strong, nonatomic) CSRegisterViewController *registerVC;


-(void)resetUI;
-(IBAction)actLogin:(id)sender;

@end

@protocol CSWelecomeDelegate <NSObject>

-(void)welcomeLoginEnd:(CSWelcomeViewController *)aWelcomeVC;
-(void)welcomeLoginFailed:(CSWelcomeViewController *)aWelcomeVC;

@end
