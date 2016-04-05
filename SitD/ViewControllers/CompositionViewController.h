//
//  CompositionViewController.h
//  SitD
//
//  Created by rainwolf on 01/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <UIKit/UIKit.h>
@import PopoverView;

@class SitDAccount;

@interface CompositionViewController : UIViewController <UITextViewDelegate, PopoverViewDelegate> {
    __weak SitDAccount *account;
    NSString *contactID, *replyText;
    UITextView *textView;
    float keyboardHeight;
    UIButton *attachButton, *sendButton;
    PopoverView *actionPopoverView;
    uint64_t replyToId;
}
@property(nonatomic, retain, readwrite) UIButton *attachButton, *sendButton;
@property(weak, nonatomic, readwrite) SitDAccount *account;
@property(nonatomic, retain, readwrite) NSString *contactID, *replyText;
@property(nonatomic, retain, readwrite) UITextView *textView;
@property(atomic, assign, readwrite) float keyboardHeight;
@property(nonatomic, retain, readwrite) PopoverView *actionPopoverView;
@property(atomic, assign, readwrite) uint64_t replyToId;

@end
