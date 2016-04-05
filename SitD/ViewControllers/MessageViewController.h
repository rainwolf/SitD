//
//  MessageViewController.h
//  SitD
//
//  Created by rainwolf on 18/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SitDMessage.h"
@import PopoverView;

@class SitDAccount;

@interface MessageViewController : UIViewController <UIDocumentInteractionControllerDelegate> {
    SitDMessageContent *sitdMesssage;
    UITextView *messageView;
    NSString *message;
    NSArray *attachments;
    __weak SitDAccount *account;
    PopoverView *actionPopoverView;
}
@property(weak, nonatomic, readwrite) SitDAccount *account;
@property(nonatomic, retain, readwrite) SitDMessageContent *sitdMesssage;
@property(nonatomic, retain, readwrite) UITextView *messageView;
@property(nonatomic, retain, readwrite) NSString *message;
@property(nonatomic, retain, readwrite) NSArray *attachments;
@property(nonatomic, retain, readwrite) PopoverView *actionPopoverView;

@end
