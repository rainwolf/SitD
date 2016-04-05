//
//  CompositionViewController.m
//  SitD
//
//  Created by rainwolf on 01/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "CompositionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Pond.pbobjc.h"
#import "SitDAccount.h"
#import "constants.h"
//@import TSMessages;




@implementation CompositionViewController
@synthesize account;
@synthesize contactID, replyText;
@synthesize textView;
@synthesize keyboardHeight;
@synthesize sendButton, attachButton;
@synthesize actionPopoverView;
@synthesize replyToId;


-(instancetype) init {
    if (self = [super init]) {
        replyToId = 0;
        replyText = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width - 100, 35);
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendButton setTitle: NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [sendButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    //    [sendButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [sendButton setFrame:frame];
    attachButton = [UIButton buttonWithType:UIButtonTypeCustom];
    attachButton.backgroundColor = [UIColor clearColor];
    attachButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    attachButton.alpha = 0.5f;
    attachButton.enabled = NO;
    [attachButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [attachButton setTitle: NSLocalizedString(@"Attach a file", nil) forState:UIControlStateNormal];
    [attachButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [attachButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    //    [sendButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [attachButton setFrame:frame];
    

    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Actions", nil) style:UIBarButtonItemStyleDone target:self action:@selector(showActions)];
    [self.navigationItem setRightBarButtonItems: [NSArray arrayWithObjects:actionItem, nil]];

    keyboardHeight = 0;
    
//    self.navigationController.navigationBar.translucent = NO;
    [self setEdgesForExtendedLayout: UIRectEdgeNone];
    textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor grayColor];
    [textView setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight];
    [textView setTextColor: [UIColor whiteColor]];
    
    [[UITextView appearance] setTintColor:[UIColor whiteColor]];
    [textView setTextContainerInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    textView.layer.cornerRadius=5.0f;
    textView.layer.masksToBounds=YES;
    textView.layer.borderColor=[[UIColor whiteColor] CGColor];
    textView.layer.borderWidth = 2.0f;
    
    textView.text = replyText;

    [self.view addSubview: textView];

}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setTitle: [account nameForContact: contactID]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowHide:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [actionPopoverView animateRotationToNewPoint:CGPointMake(self.view.bounds.size.width - 20, 0) inView:self.view withDuration:0.1f];
}

-(void) showActions {
    [textView resignFirstResponder];
    actionPopoverView = [PopoverView showPopoverAtPoint: CGPointMake(self.view.bounds.size.width - 20, 0) inView:self.view withViewArray:[NSArray arrayWithObjects:sendButton, attachButton, nil] delegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) send {
    [actionPopoverView dismiss];
    SitDContact *contact = [account loadContact: contactID];
    Message *pondMessage = [[Message alloc] init];
    [pondMessage setBody: [textView.text dataUsingEncoding: NSUTF8StringEncoding]];
    [pondMessage setBodyEncoding: Message_Encoding_Raw];
    [pondMessage setTime: [[NSDate date] timeIntervalSince1970]];
    [pondMessage setId_p: [account newRandomId]];
    if (self.replyToId) {
        [pondMessage setInReplyTo: self.replyToId];
    }
    NSData *messageData = [pondMessage data];
    FGIntBase len = [messageData length];
    if (MAXSERIALIZEDMESSAGE < len) {
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: [NSString stringWithFormat:NSLocalizedString(@"The message is too long, remove at least %i characters", nil), len - (MAXSERIALIZEDMESSAGE)] andType: TSMessageNotificationTypeError];
        return;
    }
    
    SitDMessageContent *storedMessage = [[SitDMessageContent alloc] init];
    [storedMessage setTimestamp: [NSDate date]];
    [storedMessage setEncodedBody: pondMessage.body];
    [storedMessage setMessageID: pondMessage.id_p];
    [storedMessage setContactID: contact.iD];
    [storedMessage setContactName: contact.name];
    [storedMessage setOutgoing: YES];
    [storedMessage setLocalID: pondMessage.id_p];
    
    NSLog(@"send storeMessage");
    [account storeMessage: storedMessage];
    
    NSMutableData *paddedMessage = [[NSMutableData alloc] initWithBytes: &len length:4];
    [paddedMessage appendData: messageData];
    NSLog(@"send storeMessage add random data");
    [paddedMessage appendData: [FGIntXtra randomDataOfLength: (MAXSERIALIZEDMESSAGE - len)]];
    
    NSLog(@"send is sealing");

    NSData *sealed = [[contact ratchet] encrypt: paddedMessage];

    NSLog(@"send is sealed");

    SitDQueued *queuedMsg = [[SitDQueued alloc] init];
    [queuedMsg setMessage: sealed];
    [queuedMsg setServerHost: contact.serverAddress];
    [queuedMsg setServerIdentity: contact.serverId];
    [queuedMsg setContactID: contactID];
    [queuedMsg setAnonymous: YES];
    [queuedMsg setTag: DELIVERPROTO];
    [queuedMsg setLocalMsgId: storedMessage.localID];
    
    NSLog(@"send is queueing");
    [account pushToQueue: queuedMsg];
    NSLog(@"send is queued");
    [account startTransacting];
    NSLog(@"send started transacting");
    
//    [actionPopoverView dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) attach {
    
}

-(void)keyboardWillShowHide: (NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    if ([[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y == self.view.frame.origin.y + self.view.bounds.size.height) {
        keyboardHeight = 0;
    } else {
        keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    }
    CGRect frameRect = textView.frame;
    float viewHeight = self.view.bounds.size.height - keyboardHeight;
    frameRect.size.height = viewHeight;
    textView.frame = frameRect;
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
