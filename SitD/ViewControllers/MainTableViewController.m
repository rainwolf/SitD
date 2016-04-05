//
//  MainTableViewController.m
//  SitD
//
//  Created by rainwolf on 08/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "MainTableViewController.h"
#import "EntryViewController.h"
#import "MasterNavigationController.h"
#import "DetailNavigationController.h"
#import "EmptyUIViewController.h"
#import "ContactsViewController.h"
#import "ConsoleViewController.h"
#import "MessagesTableViewController.h"

//#import "FGIntObjCSitD.h"
//#import <YapDatabase/YapDatabase.h>
//#import "constants.h"
#import "SitDAccount.h"


@implementation MainTableViewController
@synthesize account;

BOOL collapseDetailViewController = YES;

-(id) init {
    if (self = [super init]) {
        collapseDetailViewController = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    [self.navigationItem setLeftBarButtonItem:menuItem];

    UIBarButtonItem *transactItem = [[UIBarButtonItem alloc] initWithTitle:@"transact" style:UIBarButtonItemStylePlain target:self action:@selector(startTransactions)];
    [self.navigationItem setRightBarButtonItem: transactItem];

    self.tableView.scrollEnabled = NO;
}
-(void) startTransactions {
    [account startTransacting];
    [self transactingAndAnimate];
}
-(void) transactingAndAnimate {
//    return;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        do {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.navigationItem.rightBarButtonItem.title isEqualToString: @"transact"]) {
                    self.navigationItem.rightBarButtonItem.title = @"transacting";
                } else if ([self.navigationItem.rightBarButtonItem.title isEqualToString: @"transacting"]) {
                    self.navigationItem.rightBarButtonItem.title = @"transacting.";
                } else if ([self.navigationItem.rightBarButtonItem.title isEqualToString: @"transacting."]) {
                    self.navigationItem.rightBarButtonItem.title = @"transacting..";
                } else if ([self.navigationItem.rightBarButtonItem.title isEqualToString: @"transacting.."]) {
                    self.navigationItem.rightBarButtonItem.title = @"transacting...";
                } else {
                    self.navigationItem.rightBarButtonItem.title = @"transacting";
                }
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
    [self queryForServer];
    if (account.currentTransacting) {
        [self transactingAndAnimate];
    }
}

-(void) logout {
//    MasterNavigationController *navController = (MasterNavigationController *) self.navigationController;
    
    SitDAccount *newAccount = [[SitDAccount alloc] init];
    [newAccount setCurrentVC: self];
    [newAccount.networkConnection setTorProxyManager: self.account.networkConnection.torProxyManager];
    [newAccount.networkConnection setAccount:newAccount];
    EntryViewController *entryVC = [[EntryViewController alloc] init];
    [entryVC setAccount: newAccount];

    self.account.database = nil;
    self.account.databaseConnection = nil;
    self.account.roConnection = nil;
    self.account.databaseName = nil;
    self.account.databaseKey = nil;

    //    if (self.account.networkConnection.torProxyManager == nil) {
//        NSLog(@" tor is nil before logout");
//    }
//    NSLog(@"setting tor in entry");
//    [entryVC setTorProxyManager: self.account.networkConnection.torProxyManager];
//    [account setCurrentVC: entryVC];
//    [account.networkConnection disconnect];
    
    [[UIApplication sharedApplication].keyWindow setRootViewController: entryVC];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSString stringWithFormat:@"%lu", section];
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 3 || indexPath.section > 0) {
        return nil;
    }
    
    if (indexPath.section == 0) {
        int row = 0;
        if (indexPath.row == row) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"inbox"];
            //    [tableView dequeueReusableCellWithIdentifier:@"inbox" forIndexPath:indexPath];
            
            cell.textLabel.text = @"Messages";
            cell.detailTextLabel.text = @"Where conversations happen";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            // Configure the cell...
            
            return cell;
        }
//        ++row;
//        if (indexPath.row == row) {
//            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"outbox"];
//            //    [tableView dequeueReusableCellWithIdentifier:@"inbox" forIndexPath:indexPath];
//            
//            cell.textLabel.text = @"Outbox";
//            cell.detailTextLabel.text = @"Where messages depart";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            // Configure the cell...
//            
//            return cell;
//        }
        ++row;
        if (indexPath.row == row) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contacts"];
            
            cell.textLabel.text = @"Contacts";
            cell.detailTextLabel.text = @"Where friends are";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            // Configure the cell...
            
            return cell;
        }
        ++row;
        if (indexPath.row == row) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"console"];
            
            cell.textLabel.text = @"console";
            cell.detailTextLabel.text = @"Where /dev/null is";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            // Configure the cell...
            
            return cell;
        }
    }
    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [TSMessage dismissActiveNotification];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    collapseDetailViewController = NO;
    if (indexPath.section == 0) {
        int row = 0;
        if (indexPath.row == row) {
            MessagesTableViewController *vc = [[MessagesTableViewController alloc] init];
            [vc setAccount: self.account];
            DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
            vc.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
            vc.navigationItem.leftItemsSupplementBackButton = YES;
            [self showDetailViewController: detailNavigationController sender:self];
        }
//        ++row;
//        if (indexPath.row == row) {
//            EmptyUIViewController *vc = [[EmptyUIViewController alloc] init];
//            DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
//            vc.view.backgroundColor = [UIColor redColor];
//            vc.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
//            vc.navigationItem.leftItemsSupplementBackButton = YES;
//            [self showDetailViewController: detailNavigationController sender:self];
//        }
        ++row;
        if (indexPath.row == row) {
            ContactsViewController *vc = [[ContactsViewController alloc] init];
            [vc setAccount: self.account];
            DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
            //            vc.view.backgroundColor = [UIColor redColor];
            vc.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
            vc.navigationItem.leftItemsSupplementBackButton = YES;
            [self showDetailViewController: detailNavigationController sender:self];
        }
        ++row;
        if (indexPath.row == row) {
            ConsoleViewController *vc = [[ConsoleViewController alloc] init];
            [vc setAccount: self.account];
            DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
            //            vc.view.backgroundColor = [UIColor redColor];
            vc.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
            vc.navigationItem.leftItemsSupplementBackButton = YES;
            [self showDetailViewController: detailNavigationController sender:self];
        }
        
    }
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


//-(bool) splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(id)sender {
//    vc.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
//    vc.navigationItem.leftItemsSupplementBackButton = YES;
//}


- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    return collapseDetailViewController;
}
















-(void) queryForServer {
//    MasterNavigationController *navController = (MasterNavigationController *) self.navigationController;
    if (![self.account accountExists]) {
        NSLog(@"kitty");
        UIAlertController *serverEntryController = [UIAlertController
                                                    alertControllerWithTitle:NSLocalizedString(@"Enter Pond server", nil)
                                                    message:nil
                                                    preferredStyle:UIAlertControllerStyleAlert];
        [serverEntryController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            //            [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            textField.placeholder = NSLocalizedString(@"pondserver://serverID@hostname.onion", nil);
            //            textField.secureTextEntry = YES;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"Cancel action");
            
            
            
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *serverTextField = serverEntryController.textFields.firstObject;
            NSString *tmpStr = [serverTextField.text stringByReplacingOccurrencesOfString:@"pondserver://" withString:@""];
            NSRange chr = [tmpStr rangeOfString:@"@"];
            if (chr.location == NSNotFound) {
                return;
            }
            NSString *serverId = [tmpStr substringToIndex:chr.location];
            NSString *host = [tmpStr substringFromIndex:chr.location + 1];
            if ([[FGIntXtra base32StringToNSData:serverId] length] == 32 && [host length] == (16 + 6)) {
                NSLog(@"valid server");
                //                    store server and create account
                [self.account setServerAddress:host];
                [self.account setServerId:serverId];
                
                [self.account createAccount];
                
            } else {
                UIAlertController *invalidServerAlert = [UIAlertController
                                                         alertControllerWithTitle:NSLocalizedString(@"Invalid server entry", nil)
                                                         message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okayAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    NSLog(@"Cancel action");
                }];
                [invalidServerAlert addAction:okayAction];
                [invalidServerAlert.view setNeedsLayout];
                [self presentViewController:invalidServerAlert animated:NO completion:nil];
                NSLog(@"server entry errpr");
            }
        }];
        //        okAction.enabled = NO;
        [serverEntryController addAction:cancelAction];
        [serverEntryController addAction:okAction];
        
        [self.view setNeedsLayout];
        [self presentViewController:serverEntryController animated:NO completion:nil];
    }
}

@end
