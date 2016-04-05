//
//  EntryViewController.h
//  SitD
//
//  Created by rainwolf on 29/11/15.
//  Copyright © 2015 rainwolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGIntObjCSitD.h"
#import "constants.h"
@import YapDatabase;

@class SitDAccount;

@interface PWTextField : UITextField 

@end



@interface EntryViewController : UIViewController <UITextFieldDelegate> {
    float keyboardHeight;
    PWTextField *passwordTextField;
    UILabel *label;
    NSString *accountName;
    NSData *accountKey;
    YapDatabase *sitdAccount;
    
    SitDAccount *account;
}
@property(nonatomic, assign, readwrite) float keyboardHeight;
@property(retain, readwrite) NSString *accountName;
@property(retain, readwrite) UILabel *label;

@property(retain, readwrite) NSData *accountKey;
@property(nonatomic, retain, readwrite) YapDatabase *sitdAccount;
@property(readwrite, retain) PWTextField *passwordTextField;

@property(retain, readwrite) SitDAccount *account;

@end



