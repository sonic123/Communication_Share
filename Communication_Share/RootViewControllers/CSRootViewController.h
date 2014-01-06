//
//  CSRootViewController.h
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSWelcomeViewController;
@class CSContentViewController;

@interface CSRootViewController : UIViewController

@property (strong, nonatomic) CSWelcomeViewController *welcomeVC;
@property (strong, nonatomic) CSContentViewController *contentVC;

@end
