//
//  CSRootViewController.m
//  Communication_Share
//
//  Created by Sonic on 1/6/14.
//  Copyright (c) 2014 Sonic. All rights reserved.
//

#import "CSRootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CSUtility.h"
#import "CSWelcomeViewController.h"
#import "CSContentViewController.h"

@interface CSRootViewController ()<CSWelecomeDelegate>

@end

@implementation CSRootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    BOOL     bIsDir = NO;
    NSString *strUserInfo=[CSUtility userInfoPath];
    
    //Normal Login Page
    if (! strUserInfo || ![[NSFileManager defaultManager] fileExistsAtPath:strUserInfo
                                                               isDirectory:&bIsDir] || bIsDir) {
        _welcomeVC=[[CSWelcomeViewController alloc]initWithNibName:@"CSWelcomeViewController" bundle:nil];
        _welcomeVC.delegate=self;
        [self.view addSubview:_welcomeVC.view];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)revealInView:(UIView*)newTopView
{
    int newTopViewIndex = [self.view.subviews indexOfObject:newTopView];
    if (newTopViewIndex == self.view.subviews.count - 1) {
        return;
    }
    
    CATransition *showContentAnim  = [CATransition animation];
    showContentAnim.duration       = 0.5f;
    showContentAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    showContentAnim.type       = kCATransitionReveal;
    showContentAnim.subtype    = kCATransitionFromLeft;
    showContentAnim.delegate   = self;
    
	[self.view.layer addAnimation:showContentAnim forKey:@"Reveal"];
    [self.view exchangeSubviewAtIndex:self.view.subviews.count - 1
                   withSubviewAtIndex:newTopViewIndex];
}

- (void)revealOutView:(UIView*)newTopView
{
    int newTopViewIndex = [self.view.subviews indexOfObject:newTopView];
    if (newTopViewIndex == self.view.subviews.count - 1) {
        return;
    }
    
    CATransition *showContentAnim  = [CATransition animation];
    showContentAnim.duration       = 0.5f;
    showContentAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    showContentAnim.type       = kCATransitionReveal;
    showContentAnim.subtype    = kCATransitionFromRight;
    showContentAnim.delegate   = self;
    
	[self.view.layer addAnimation:showContentAnim forKey:@"Reveal"];
    [self.view exchangeSubviewAtIndex:self.view.subviews.count - 1
                   withSubviewAtIndex:newTopViewIndex];
}

#pragma mark -
#pragma mark WelcomeDelegate
-(void)welcomeLoginEnd:(CSWelcomeViewController *)aWelcomeVC{
    if (!_contentVC) {
        _contentVC=[[CSContentViewController alloc]initWithNibName:@"CSContentViewController" bundle:nil];
    
        NSString *userName          = _welcomeVC.userName;
        NSArray  *arrNameComponent  = [userName componentsSeparatedByString:@" "];
        
        if (arrNameComponent && arrNameComponent.count >=1) {
            userName =[arrNameComponent objectAtIndex:0];
        }
        _contentVC.userName = userName;
        [self.view insertSubview:_contentVC.view belowSubview:_welcomeVC.view];
    }
    
    [self performSelector:@selector(revealOutView:) withObject:_contentVC.view afterDelay:0.0f];
}

-(void)welcomeLoginFailed:(CSWelcomeViewController *)aWelcomeVC{
    
}
#pragma mark -
#pragma mark RegisterDelegate
-(void)showRegitserView:(CSRegisterViewController *)aRegisterVC{
    [self.navigationController pushViewController:(UIViewController *)aRegisterVC animated:YES];
}


@end
