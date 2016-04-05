//
//  MessagesTableViewController.h
//  SitD
//
//  Created by rainwolf on 28/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

@import YapDatabase.YapDatabaseView;

@class SitDAccount;

@interface MessagesTableViewController : UITableViewController {
    BOOL isInbox;
    NSString *contactID;
    __weak SitDAccount *account;
    YapDatabaseViewMappings *messagesMapping;
}
@property(atomic, assign, readwrite) BOOL isInbox;
@property(nonatomic, retain, readwrite) NSString *contactID;
@property(nonatomic, weak, readwrite) SitDAccount *account;
@property(nonatomic, retain, readwrite) YapDatabaseViewMappings *messagesMapping;


@end
