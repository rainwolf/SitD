//
//  MainTableViewController.h
//  SitD
//
//  Created by rainwolf on 08/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SitDAccount;

@interface MainTableViewController : UITableViewController <UISplitViewControllerDelegate> {
    __weak SitDAccount *account;
}
@property(weak, nonatomic, readwrite) SitDAccount *account;


@end
