//
//  MessageViewController.m
//  SitD
//
//  Created by rainwolf on 18/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "MessageViewController.h"
#import "SitDAccount.h"
#import "DetailNavigationController.h"
#import "CompositionViewController.h"

@interface MessageViewController ()

@end

@implementation MessageViewController
@synthesize account;
@synthesize messageView;
@synthesize sitdMesssage;
@synthesize message;
@synthesize attachments;
@synthesize actionPopoverView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setEdgesForExtendedLayout: UIRectEdgeNone];
    messageView = [[UITextView alloc] initWithFrame:self.view.bounds];
    messageView.backgroundColor = [UIColor grayColor];
    [messageView setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight];
    [messageView setTextColor: [UIColor whiteColor]];
    
    [[UITextView appearance] setTintColor:[UIColor whiteColor]];
    [messageView setTextContainerInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    messageView.layer.cornerRadius=5.0f;
    messageView.layer.masksToBounds=YES;
    messageView.layer.borderColor=[[UIColor whiteColor] CGColor];
    messageView.layer.borderWidth = 2.0f;
    [messageView setEditable:NO];
    
    [self.view addSubview: messageView];
    
    [messageView setText: [[NSString alloc] initWithData: sitdMesssage.encodedBody encoding: NSUTF8StringEncoding]];

    UIBarButtonItem *transactItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"reply", nil) style:UIBarButtonItemStylePlain target:self action:@selector(reply)];
    [self.navigationItem setRightBarButtonItem: transactItem];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setTitle: sitdMesssage.contactName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) reply {
    CompositionViewController *vc = [[CompositionViewController alloc] init];
//    DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
    vc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    vc.navigationItem.leftItemsSupplementBackButton = YES;
    [vc setAccount: account];
    [vc setReplyToId:sitdMesssage.messageID];
    [vc setContactID: sitdMesssage.contactID];
    
//    [detailNavigationController setTitle:sitdMesssage.contactName];
    [vc setReplyText: [@"\n\n\n>" stringByAppendingString: [messageView.text stringByReplacingOccurrencesOfString:@"\n" withString: @"\n>"]]];
    [self.navigationController pushViewController:vc animated:YES];
//    [self showDetailViewController: detailNavigationController sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
