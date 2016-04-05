//
//  ContactsViewController.h
//  SitD
//
//  Created by rainwolf on 02/02/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@class SitDAccount;

@interface ContactCell : UITableViewCell {}

@end



@interface ContactsViewController : UITableViewController <UINavigationControllerDelegate,MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate, MCSessionDelegate> {
    __weak SitDAccount *account;
    NSMutableArray<UIButton *> *contactButtons;
    UIButton *keyXCopyButton, *addKeyXButton, *revokeButton, *msgButton, *restartKeyXButton;
    MCPeerID *localPeerID;
    MCAdvertiserAssistant *p2pAdvertiser;
    MCSession *p2pSession;
    MCBrowserViewController *p2pBrowserViewController;
    NSData *ephemeralPrivateDH, *theirEphemeralPublicDH;
}
@property(weak, nonatomic, readwrite) SitDAccount *account;
@property(nonatomic, retain, readwrite) NSMutableArray<UIButton *> *contactButtons;
@property(nonatomic, retain, readwrite) UIButton *keyXCopyButton, *addKeyXButton, *revokeButton, *msgButton, *restartKeyXButton;
@property(nonatomic, retain, readwrite) MCPeerID *localPeerID;
@property(nonatomic, retain, readwrite) MCAdvertiserAssistant *p2pAdvertiser;
@property(nonatomic, retain, readwrite) MCSession *p2pSession;
@property(nonatomic, retain, readwrite) MCBrowserViewController *p2pBrowserViewController;
@property(nonatomic, retain, readwrite) NSData *ephemeralPrivateDH, *theirEphemeralPublicDH;


@end
