//
//  ConsoleViewController.h
//  SitD
//
//  Created by rainwolf on 26/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SitDAccount.h"
@class SitDAccount;


@interface ConsoleViewController : UIViewController {
    __weak SitDAccount *account;
    UITextView *consoleLog;
}
@property(weak, nonatomic, readwrite) SitDAccount *account;
@property(retain, readwrite, nonatomic) UITextView *consoleLog;

@end
