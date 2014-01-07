//
//  CSRegisterViewController.h
//  Communication_Share
//
//  Created by Sonic Lin on 1/7/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSRegisterViewController : UIViewController

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) IBOutlet UITextField *txtLoginName;
@property (strong, nonatomic) IBOutlet UITextField *txtNickName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;

-(IBAction)actRegister:(id)sender;
-(IBAction)actCancel:(id)sender;

@end
