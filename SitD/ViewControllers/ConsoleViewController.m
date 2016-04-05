//
//  ConsoleViewController.m
//  SitD
//
//  Created by rainwolf on 26/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "ConsoleViewController.h"
#import "SitDAccount.h"

@implementation ConsoleViewController
@synthesize consoleLog;
@synthesize account;

-(void) viewDidLoad {
    [super viewDidLoad];
    consoleLog = [[UITextView alloc] init];
    [consoleLog setFrame:self.view.frame];
    [self.view addSubview: consoleLog];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    consoleLog.text = account.logString;
}


@end
