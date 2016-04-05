//
//  EmptyUIViewController.m
//  SitD
//
//  Created by rainwolf on 12/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "EmptyUIViewController.h"
//#import "SitDSplitViewController.h"

@implementation EmptyUIViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

//-(void) viewDidAppear:(BOOL)animated {
//}


@end
