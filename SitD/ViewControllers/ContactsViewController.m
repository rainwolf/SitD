//
//  ContactsViewController.m
//  SitD
//
//  Created by rainwolf on 02/02/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "ContactsViewController.h"
#import "SitDContact.h"
#import "CompositionViewController.h"
#import "DetailNavigationController.h"
#import "SitDAccount.h"

@implementation ContactsViewController
@synthesize account;
@synthesize contactButtons;
@synthesize keyXCopyButton, addKeyXButton, revokeButton, msgButton, restartKeyXButton;
@synthesize localPeerID;
@synthesize p2pBrowserViewController;
@synthesize p2pSession;
@synthesize p2pAdvertiser;
@synthesize ephemeralPrivateDH, theirEphemeralPublicDH;

long selectedContact = -1;


-(instancetype) init {
    if (self = [super init]) {
        contactButtons = [[NSMutableArray alloc] init];
        
        keyXCopyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        keyXCopyButton.backgroundColor = [UIColor clearColor];
        keyXCopyButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [keyXCopyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [keyXCopyButton setTitle: NSLocalizedString(@"Copy Key Exchange", nil) forState:UIControlStateNormal];
        [keyXCopyButton addTarget:self action:@selector(copyKeyXToClipboard:) forControlEvents:UIControlEventTouchUpInside];
        [keyXCopyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [keyXCopyButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        
        addKeyXButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addKeyXButton.backgroundColor = [UIColor clearColor];
        addKeyXButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [addKeyXButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addKeyXButton setTitle: NSLocalizedString(@"Complete Key Exchange", nil) forState:UIControlStateNormal];
        [addKeyXButton addTarget:self action:@selector(completeKeyX:) forControlEvents:UIControlEventTouchUpInside];
        [addKeyXButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [addKeyXButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        
        revokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        revokeButton.backgroundColor = [UIColor clearColor];
        revokeButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [revokeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [revokeButton setTitle: NSLocalizedString(@"Revoke contact", nil) forState:UIControlStateNormal];
        [revokeButton addTarget:self action:@selector(revokeContact:) forControlEvents:UIControlEventTouchUpInside];
        [revokeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [revokeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        
        msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        msgButton.backgroundColor = [UIColor clearColor];
        msgButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [msgButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [msgButton setTitle: NSLocalizedString(@"Create new message", nil) forState:UIControlStateNormal];
        [msgButton addTarget:self action:@selector(newMessage:) forControlEvents:UIControlEventTouchUpInside];
        [msgButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [msgButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        
        restartKeyXButton = [UIButton buttonWithType:UIButtonTypeCustom];
        restartKeyXButton.backgroundColor = [UIColor clearColor];
        restartKeyXButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [restartKeyXButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [restartKeyXButton setTitle: NSLocalizedString(@"Restart Key Exchange", nil) forState:UIControlStateNormal];
        [restartKeyXButton addTarget:self action:@selector(restartKeyX:) forControlEvents:UIControlEventTouchUpInside];
        [restartKeyXButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [restartKeyXButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        
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
    UIBarButtonItem *addContactItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleDone target:self action:@selector(addContact)];
    [addContactItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:30] forKey:NSFontAttributeName] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:addContactItem];
    
    selectedContact = -1;
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (selectedContact != -1) {
        [self.tableView beginUpdates];
        if (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            for ( int i = 0; i < [contactButtons count]; ++i ) {
                if (i%2 == 0) {
                    [contactButtons objectAtIndex: i].frame = CGRectMake(10, 45 + (i/2)*35, (self.view.bounds.size.width - 20)/2, 30);
                } else {
                    [contactButtons objectAtIndex: i].frame = CGRectMake(10 + (self.view.bounds.size.width - 20)/2, 45 + (i/2)*35, (self.view.bounds.size.width - 20)/2, 30);
                }
            }
        } else {
            for ( int i = 0; i < [contactButtons count]; ++i ) {
                [contactButtons objectAtIndex: i].frame = CGRectMake(10, 45 + i*35, self.view.bounds.size.width - 20, 30);
            }
        }
        [self.tableView endUpdates];
    }
    
    
    self.navigationController.navigationBar.translucent = YES;
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ (%lu)",NSLocalizedString(@"Contacts", nil), [[account contacts] count]]];
    return [[account contacts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contact"];
    SitDContact *contact = [account loadContact:[[account contacts] objectAtIndex:indexPath.row]];
    if ([contact revoked]) {
        cell.textLabel.text = [NSString stringWithFormat: @"%@ - %@", [contact name], NSLocalizedString(@"revoked", nil)];
    } else if ([contact revokedMe]) {
        cell.textLabel.text = [NSString stringWithFormat: @"%@ - %@", [contact name], NSLocalizedString(@"revoked me", nil)];
    } else {
        cell.textLabel.text = [contact name];
    }
    if ([contact timeAdded]) {
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate: [contact timeAdded] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    } else {
        cell.detailTextLabel.text = @"ancient";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell...
    
    return cell;
    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [TSMessage dismissActiveNotification];
    if (selectedContact == indexPath.row) {
        selectedContact = -1;
        [self removeButtonsFromCell];
        [tableView beginUpdates];
        [tableView endUpdates];
    } else {
        if (selectedContact != -1) {
            [self removeButtonsFromCell];
        }
        selectedContact = indexPath.row;
        [tableView beginUpdates];
        [self addButtonsToCell: (ContactCell *) [self.tableView cellForRowAtIndexPath:indexPath]];
        [tableView endUpdates];
    }
//    SitDContact *contact = [account loadContact: [[account contacts] objectAtIndex:indexPath.row]];
//    ContactDetailsController *vc = [[ContactDetailsController alloc] init];
//    vc.myKeyX.text = [NSString stringWithFormat:@"-----BEGIN POND KEY EXCHANGE-----\n%@\n-----END POND KEY EXCHANGE-----", [[[FGIntXtra dataToBase64String:contact.keyExchangeData] stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""]];
//    NSLog(@"%@", vc.myKeyX.text);
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (selectedContact != -1) {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            for ( int i = 0; i < [contactButtons count]; ++i ) {
                if (i%2 == 0) {
                    [contactButtons objectAtIndex: i].frame = CGRectMake(10, 45 + (i/2)*35, (self.view.bounds.size.width - 20)/2, 30);
                } else {
                    [contactButtons objectAtIndex: i].frame = CGRectMake(10 + (self.view.bounds.size.width - 20)/2, 45 + (i/2)*35, (self.view.bounds.size.width - 20)/2, 30);
                }
            }
        } else {
            for ( int i = 0; i < [contactButtons count]; ++i ) {
                [contactButtons objectAtIndex: i].frame = CGRectMake(10, 45 + i*35, self.view.bounds.size.width - 20, 30);
            }
        }
    }
}

-(void) addButtonsToCell: (ContactCell *) cell {
    SitDContact *contact = [account loadContact: [[account contacts] objectAtIndex:selectedContact]];
    
    if (![contact pending] && ![contact revokedMe]) {
        [contactButtons addObject: msgButton];
    }
    if ([contact keyExchangeData]) {
        [contactButtons addObject: keyXCopyButton];
    }
    if ([contact pending]) {
        [contactButtons addObject: addKeyXButton];
    } else {
        [contactButtons addObject: restartKeyXButton];
    }
    if (![contact revoked] && ![contact pending]) {
        [contactButtons addObject: revokeButton];
    }
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        for ( int i = 0; i < [contactButtons count]; ++i ) {
            [contactButtons objectAtIndex: i].frame = CGRectMake(10, 45 + i*35, self.view.bounds.size.width - 20, 30);
        }
    } else {
        for ( int i = 0; i < [contactButtons count]; ++i ) {
            if (i%2 == 0) {
                [contactButtons objectAtIndex: i].frame = CGRectMake(10, 45 + (i/2)*35, (self.view.bounds.size.width - 20)/2, 30);
            } else {
                [contactButtons objectAtIndex: i].frame = CGRectMake(10 + (self.view.bounds.size.width - 20)/2, 45 + (i/2)*35, (self.view.bounds.size.width - 20)/2, 30);
            }
        }
    }
    for ( int i = 0; i < [contactButtons count]; ++i ) {
        [cell performSelector:@selector(addSubview:) withObject: [contactButtons objectAtIndex:i] afterDelay:0.2 + i*0.1];
    }
}
-(void) removeButtonsFromCell {
    for ( int i = 0; i < [contactButtons count] ; ++i ) {
        [[contactButtons objectAtIndex:i] performSelector:@selector(removeFromSuperview) withObject: nil afterDelay:([contactButtons count] - i)*0.05f];
    }
    [contactButtons removeAllObjects];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [account removeContact:[[account contacts] objectAtIndex:indexPath.row]];
    });
//    [self.tableView beginUpdates];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
//    [self.tableView endUpdates];
    [self.tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == selectedContact) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            return 50 + 35*[contactButtons count];
        } else {
            return 50 + 35*(([contactButtons count] + 1)/2);
        }
    }
    return 44;
}



-(void) addContact {
    if (![account accountExists]) {
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"You don't have a home server yet", nil) andType:TSMessageNotificationTypeError];
        return;
    }
    UIAlertController *contactEntryController = [UIAlertController
                                                    alertControllerWithTitle:NSLocalizedString(@"Enter a contact name", nil)
                                                    message: nil
                                                    preferredStyle:UIAlertControllerStyleAlert];
    [contactEntryController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"name", nil);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"Cancel action");
        
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *contactNameField = contactEntryController.textFields.firstObject;
        if (contactNameField.text && ![[contactNameField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            [account newContactWithName: contactNameField.text];
            [self.tableView reloadData];
        }
        
    }];
    [contactEntryController addAction:cancelAction];
    [contactEntryController addAction:okAction];
    
    [self.view setNeedsLayout];
    [self presentViewController:contactEntryController animated:NO completion:nil];
}


-(void) copyKeyXToClipboard: (UIButton *) sender {
    SitDContact *contact = [account loadContact: [[account contacts] objectAtIndex:selectedContact]];
    [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"-----BEGIN POND KEY EXCHANGE-----\n%@\n-----END POND KEY EXCHANGE-----", [FGIntXtra dataToBase64String:contact.keyExchangeData]]];
    [keyXCopyButton.titleLabel performSelector:@selector(setText:) withObject: NSLocalizedString(@"done", nil) afterDelay:0.1f];
    [keyXCopyButton.titleLabel performSelector:@selector(setText:) withObject: NSLocalizedString(@"Copy Key Exchange", nil) afterDelay:0.8f];
 
    NSLog(@"%@", [NSString stringWithFormat:@"-----BEGIN POND KEY EXCHANGE-----\n%@\n-----END POND KEY EXCHANGE-----", [FGIntXtra dataToBase64String:contact.keyExchangeData]]);
    NSLog(@"%lu", [contact.keyExchangeData length]);
}


-(void) completeKeyX: (UIButton *) sender {
    NSString *peerName = [FGIntXtra dataToHexString: [FGIntXtra randomDataOfLength: 4]];
    UIAlertController *keyXController = [UIAlertController
                                                 alertControllerWithTitle:NSLocalizedString(@"Pick a way to enter the contact's key exchange", nil)
                                                 message: nil
                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"Cancel action");
        
        
    }];
    UIAlertAction *pasteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Copy from clipboard", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *copiedKeyX = [UIPasteboard generalPasteboard].string;
        NSLog(@" I copied: %@", copiedKeyX);
        [account completeKeyExchangeForContact: [[account contacts] objectAtIndex: selectedContact] withKeyExchange: copiedKeyX];
        [self.tableView beginUpdates];
        [self removeButtonsFromCell];
        selectedContact = -1;
        [self.tableView endUpdates];
    }];
    UIAlertAction *bluetoothAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Peer-to-peer", nil), peerName] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        theirEphemeralPublicDH = nil;
        ephemeralPrivateDH = [NaClPacket newCurve25519PrivateKey];
        
        localPeerID = [[MCPeerID alloc] initWithDisplayName: peerName];
        p2pSession = [[MCSession alloc] initWithPeer: localPeerID securityIdentity:nil encryptionPreference: MCEncryptionRequired];
        p2pSession.delegate = self;

        p2pBrowserViewController = [[MCBrowserViewController alloc] initWithServiceType:@"SitD-service" session: p2pSession];
        [self presentViewController: p2pBrowserViewController animated:YES completion:nil];
        p2pBrowserViewController.delegate = self;
        [p2pBrowserViewController setMaximumNumberOfPeers: 2];
        
        p2pAdvertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"SitD-service" discoveryInfo:nil session:p2pSession];
        p2pAdvertiser.delegate = self;
        [p2pAdvertiser start];

    }];
    [keyXController addAction:cancelAction];
    [keyXController addAction:pasteAction];
    [keyXController addAction:bluetoothAction];
    
    [self.view setNeedsLayout];
    [self presentViewController:keyXController animated:NO completion:nil];
}

-(void) revokeContact: (UIButton *) sender {
    UIAlertController *revocationController = [UIAlertController
                                         alertControllerWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                         message: NSLocalizedString(@"This contact will no longer be able to send you messages. To delete all messages, swipe to delete contact.", nil)
                                         preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"Cancel action");
        
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Revoke", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [account revokeContact: [[account contacts] objectAtIndex: selectedContact]];
        });
    
        [self removeButtonsFromCell];
        [self.tableView beginUpdates];
        selectedContact = -1;
        [self.tableView endUpdates];
    }];
    [revocationController addAction:cancelAction];
    [revocationController addAction:okAction];
    
    [self.view setNeedsLayout];
    [self presentViewController:revocationController animated:NO completion:nil];
    
}

-(void) newMessage: (UIButton *) sender {

    CompositionViewController *vc = [[CompositionViewController alloc] init];
    [vc setAccount: account];
    [vc setContactID: [account.contacts objectAtIndex:selectedContact]];
//    DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
    vc.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
    vc.navigationItem.leftItemsSupplementBackButton = YES;
//    [self showDetailViewController: detailNavigationController sender:self];

    [self.tableView beginUpdates];
    [self removeButtonsFromCell];
    selectedContact = -1;
    [self.tableView endUpdates];

    [self.navigationController pushViewController:vc animated:YES];
}


-(void) restartKeyX: (UIButton *) sender {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [account restartKeyExchangeForContact: [[account contacts] objectAtIndex: selectedContact]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self removeButtonsFromCell];
            selectedContact = -1;
            [self.tableView endUpdates];
        });
    });
}






-(void) browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [p2pSession disconnect];
    [p2pAdvertiser stop];
    theirEphemeralPublicDH = nil;
    ephemeralPrivateDH = nil;
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void) browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [p2pSession disconnect];
    [p2pAdvertiser stop];
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSError *error;
    if ([data isEqualToData: [FGIntXtra hexStringToNSData: [peerID displayName]]] && theirEphemeralPublicDH) {
        theirEphemeralPublicDH = nil;
        ephemeralPrivateDH = nil;
        [session disconnect];
        [p2pAdvertiser stop];
    } else if ([data length] == 32) {
        theirEphemeralPublicDH = data;
        SitDContact *contact = [account loadContact: [[account contacts] objectAtIndex:selectedContact]];
        NaClPacket *nacl = [[NaClPacket alloc] initWithMessage:[contact keyExchangeData] recipientsPublicKey:theirEphemeralPublicDH secretKey:ephemeralPrivateDH andNonce: [[NSMutableData alloc] initWithLength:24]];
        [session sendData: [nacl packCurve25519Xsalsa20Poly1305] toPeers:[NSArray arrayWithObject:peerID] withMode:MCSessionSendDataReliable error: &error];
    } else {
        NaClPacket *nacl = [[NaClPacket alloc] initWithMessage:data recipientsPublicKey:theirEphemeralPublicDH secretKey:ephemeralPrivateDH andNonce: [[NSMutableData alloc] initWithLength:24]];
        [account completeKeyExchangeForContact: [[account contacts] objectAtIndex: selectedContact] withKeyExchange: [NSString stringWithFormat:@"-----BEGIN POND KEY EXCHANGE-----\n%@\n-----END POND KEY EXCHANGE-----", [FGIntXtra dataToBase64String: [nacl unpackCurve25519Xsalsa20Poly1305]]]];
        [session sendData:[FGIntXtra hexStringToNSData:[localPeerID displayName]] toPeers:[NSArray arrayWithObject: peerID] withMode:MCSessionSendDataReliable error: &error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self removeButtonsFromCell];
            selectedContact = -1;
            [self.tableView endUpdates];
        });
    }
}

-(void) session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (state == MCSessionStateConnected) {
        [p2pBrowserViewController dismissViewControllerAnimated:YES completion:nil];
        NSError *error;
        [session sendData: [NaClPacket curve25519BasePointTimes:ephemeralPrivateDH] toPeers:[NSArray arrayWithObject:peerID] withMode:MCSessionSendDataReliable error: &error];
    }
}
-(void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}
-(void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}
-(void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}


//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    [self dismissViewControllerAnimated:picker completion:nil];
//    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage: @"eng" engineMode:G8OCREngineModeTesseractCubeCombined];
////     tesseract = [[G8Tesseract alloc] initWithLanguage:nil configDictionary:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"F",@"F", nil] forKeys: [NSArray arrayWithObjects:@"load_system_dawg", @"load_freq_dawg", nil]] configFileNames:nil cachesRelatedDataPath:nil engineMode:G8OCREngineModeTesseractCubeCombined];
//    tesseract.delegate = self;
//    tesseract.charWhitelist = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/= -";
//    tesseract.maximumRecognitionTime = 5;
//    tesseract.image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        [tesseract recognize];
//                          NSLog(@"kitty took a pic");
//    NSLog(@"%@", [tesseract recognizedText]);
//}

@end



















@implementation ContactCell

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat screenWidth = self.bounds.size.width;
    CGFloat accessoryWidth;
    if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        accessoryWidth = 20;
    } else {
        accessoryWidth = 0;
    }
    [self.textLabel setFrame:CGRectMake( 10, 2, screenWidth - accessoryWidth - 20, 22)];
    [self.detailTextLabel setFrame:CGRectMake( 10, 24, screenWidth - accessoryWidth - 20, 18)];
    self.textLabel.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.detailTextLabel.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
}


@end

