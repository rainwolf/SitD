//
//  MessagesTableViewController.m
//  SitD
//
//  Created by rainwolf on 28/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "constants.h"
#import "SitDMessage.h"
#import "SitDAccount.h"

#import "DetailNavigationController.h"
#import "MessageViewController.h"




@implementation MessagesTableViewController
@synthesize isInbox;
@synthesize contactID;
@synthesize account;
@synthesize messagesMapping;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.view setBackgroundColor:[UIColor grayColor]];
    
    [self.account registerMessagesListExtension];
    
    self.messagesMapping = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^(NSString *group, YapDatabaseReadTransaction *transaction){
        return YES;
    } sortBlock:^(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction){
        if ([group1 isEqualToString: NSLocalizedString(@"unread", nil)] && [group2 isEqualToString: NSLocalizedString(@"undelivered", nil)]) {
            return NSOrderedAscending;
        }
        if ([group2 isEqualToString: NSLocalizedString(@"unread", nil)] && [group1 isEqualToString: NSLocalizedString(@"undelivered", nil)]) {
            return NSOrderedDescending;
        }

        if ([group1 isEqualToString: NSLocalizedString(@"unread", nil)] || [group1 isEqualToString: NSLocalizedString(@"undelivered", nil)]) {
            return NSOrderedAscending;
        }
        if ([group2 isEqualToString: NSLocalizedString(@"unread", nil)] || [group2 isEqualToString: NSLocalizedString(@"undelivered", nil)]) {
            return NSOrderedDescending;
        }
        return [group1 compare: group2];
        // I think this locks up the database, fuck.
//        return [[self.account nameForContact: group1] compare:[self.account nameForContact: group2]];
    } view:@"messagesList"];
    
    
    [self.messagesMapping setIsDynamicSectionForAllGroups: YES];
    [account.roConnection beginLongLivedReadTransaction];
    
    // Initialize our mappings.
    // Note that we do this after we've started our database longLived transaction.
    [account.roConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        
        // Calling this for the first time will initialize the mappings,
        // and will allow mappings to cache certain information
        // such as the counts for each section.
        [self.messagesMapping updateWithTransaction:transaction];
    }];
    
    
    
    UIBarButtonItem *transactItem = [[UIBarButtonItem alloc] initWithTitle:@"transact" style:UIBarButtonItemStylePlain target:self action:@selector(startTransactions)];
    [self.navigationItem setRightBarButtonItem: transactItem];
    
    self.tableView.scrollEnabled = NO;
}
-(void) startTransactions {
    if (account.currentTransacting) {
        [account.networkConnection disconnect];
        [account setCurrentTransacting: nil];
        [account setStopTransacting: YES];
        self.navigationItem.rightBarButtonItem.title = @"transact";
        return;
    }
    [account startTransacting];
    [self transactingAndAnimate];
}
-(void) transactingAndAnimate {
    //    return;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        do {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem.title = @"transacting";
            });
            [NSThread sleepForTimeInterval: 1];
        } while (account.currentTransacting);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem.title = @"transact";
        });
    });
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (account.currentTransacting) {
        [self transactingAndAnimate];
    }
    [account.roConnection beginLongLivedReadTransaction];
    [account.roConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        [self.messagesMapping updateWithTransaction:transaction];
    }];
    [self.tableView reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object: account.database];
//object: account.roConnection.database];
    
}
-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YapDatabaseModifiedNotification object:nil];

}

- (void)yapDatabaseModified:(NSNotification *)notification {
//    NSLog(@"YAPDATABASE modified");
//    [account.roConnection beginLongLivedReadTransaction];
    __block NSArray *sectionChanges = nil;
    __block NSArray *rowChanges = nil;
    __block NSArray *notifications = nil;
    notifications = [account.roConnection beginLongLivedReadTransaction];
//    [account.roConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
//        [messagesMapping updateWithTransaction:transaction];
//    }];
//    [self.tableView reloadData];
//    return;
    
    // doesn't work.
    
    if ( ! [[account.roConnection ext:@"messagesList"] hasChangesForNotifications:notifications])
    {
        // Sweet.
        // Just update my mappings so it's on the same snapshot as my connection, and I'm done.
        [account.roConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
            [self.messagesMapping updateWithTransaction:transaction];
        }];
//        NSLog(@"YAPDATABASE modified, no changes exiting");
        return;
    }

    // Process the notification(s),
    // and get the change-set(s) as applies to my view and mappings configuration.
//    NSLog(@"YAPDATABASE modified, get changes");
    [[account.roConnection ext:@"messagesList"] getSectionChanges:&sectionChanges
                                                       rowChanges:&rowChanges
                                                 forNotifications:notifications
                                                     withMappings: messagesMapping];


    
    // No need to update mappings.
    // The above method did it automatically.
    
    if ([sectionChanges count] == 0 & [rowChanges count] == 0)
    {
//        NSLog(@"YAPDATABASE modified, no changes to apply, exiting");
        // Nothing has changed that affects our tableView
        [self.tableView reloadData];

        return;
    }

    [self.tableView reloadSectionIndexTitles];

    // Familiar with NSFetchedResultsController?
    // Then this should look pretty familiar
    
    [self.tableView beginUpdates];
//    NSLog(@"YAPDATABASE modified, updates begun");
    
    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
//            case YapDatabaseViewChangeUpdate : {
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionChange.index] withRowAnimation:UITableViewRowAnimationAutomatic];
//                break;
//            }
        }
    }
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
//    NSLog(@"YAPDATABASE modified, updates ended");

//    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.messagesMapping numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesMapping numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"messageSummary"];
    
    [account.roConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        
        // In fact, there is a category with useful methods for us: YapDatabaseViewTransaction (Mappings)
        // So we often don't have to even think about these things...
        SitDMessage *message = [[transaction ext:@"messagesList"] objectAtIndexPath:indexPath withMappings: self.messagesMapping];
        if ([[self.messagesMapping groupForSection:indexPath.section] isEqualToString: NSLocalizedString(@"unread", nil)] || [[self.messagesMapping groupForSection:indexPath.section] isEqualToString: NSLocalizedString(@"undelivered", nil)]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", message.outgoing?@"<=":@"=>", [message contactName]];
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate: [message timestamp] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", message.outgoing?@"<=":@"=>", [NSDateFormatter localizedStringFromDate: [message timestamp] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
        }
        //        cell.detailTextLabel.text = message.time;
        
    }];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell...
    
    return cell;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ (%lu)",[self.messagesMapping groupForSection:section], [self.messagesMapping numberOfItemsInSection:section]];
    if ([[self.messagesMapping groupForSection:section] isEqualToString: NSLocalizedString(@"unread", nil)] || [[self.messagesMapping groupForSection:section] isEqualToString: NSLocalizedString(@"undelivered", nil)]) {
        return [NSString stringWithFormat:@"%@ (%lu)",[self.messagesMapping groupForSection:section], [self.messagesMapping numberOfItemsInSection:section]];
    }
//    if ([[self.messagesMapping groupForSection:section] isEqualToString:@"unread"]) {
//        return [NSString stringWithFormat:@"unread (%lu)", [self.messagesMapping numberOfItemsInSection:section]];
//    }
//    if ([[self.messagesMapping groupForSection:section] isEqualToString:@"undelivered"]) {
//        return [NSString stringWithFormat:@"undelivered (%lu)", [self.messagesMapping numberOfItemsInSection:section]];
//    }
//    return [NSString stringWithFormat:@"%@ (%lu)",[self.messagesMapping groupForSection:section], [self.messagesMapping numberOfItemsInSection:section]];
    return [NSString stringWithFormat:@"%@ (%lu)",[self.account nameForContact: [self.messagesMapping groupForSection:section]], [self.messagesMapping numberOfItemsInSection:section]];
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [TSMessage dismissActiveNotification];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [account.roConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        SitDMessage *message = [[transaction ext:@"messagesList"] objectAtIndexPath:indexPath withMappings: self.messagesMapping];
        uint64_t msgID = [message localID];
        NSString *msgIdStr = [FGIntXtra dataToHexString: [NSData dataWithBytes:&msgID length: 8]];
        SitDMessageContent *messageContent = [transaction objectForKey: msgIdStr inCollection:(message.outgoing?SitDOutboxKey:SitDInboxKey)];
        if (message.unread && !message.outgoing) {
            [account markReadDelivered: msgID];
        }
        
        MessageViewController *vc = [[MessageViewController alloc] init];
        [vc setSitdMesssage: messageContent];
        [vc setAccount:account];
//        DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
        vc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        vc.navigationItem.leftItemsSupplementBackButton = YES;
        [self.navigationController pushViewController:vc animated:YES];
//        [self showDetailViewController: detailNavigationController sender:self];
    }];
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [account.roConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        SitDMessage *message = [[transaction ext:@"messagesList"] objectAtIndexPath:indexPath withMappings: self.messagesMapping];
        [account removeMessage: message.localID];
    }];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
