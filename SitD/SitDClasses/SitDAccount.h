//
//  SitDAccount.h
//  SitD
//
//  Created by rainwolf on 13/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import YapDatabase;
@import YapDatabase.YapDatabaseView;
//#import <YapDatabase/YapDatabase.h>
#import "FGIntObjCSitD.h"
#import "SitDContact.h"
#import "SitDQueued.h"
@import TSMessages;
#import "SitDialer.h"
#import "SitDMessage.h"

//@class UIViewController;

@interface SitDAccount : NSObject {
    NSString *databaseName;
    NSData *databaseKey;
    YapDatabase *database;
    YapDatabaseConnection *databaseConnection, *roConnection;
    SitDialer *networkConnection;
    
    FGIntBase generation;
    BBSPrivateKey *privateBBSKey;
    Ed25519SHA512 *privateEd25519Key;
    NSData *identity, *publicIdentity;
    NSArray<NSString *> *contacts;
    NSMutableData *contactIDs;
    
    NSData *randomIds;
    
    NSString *serverAddress;
    NSString *serverId;
    BOOL accountExists, serverValid;
    
    __weak UIViewController *currentVC;
    NSMutableString *logString;
    
    NSMutableArray *queue;
    SitDQueued *currentTransacting;
    BOOL stopTransacting;
}

@property(retain, readwrite) NSString *databaseName;
@property(retain, readwrite) NSData *databaseKey;
@property(nonatomic, retain, readwrite) YapDatabase *database;
//@property(nonatomic, retain, readwrite, setter=setDatabase:) YapDatabase *database;
@property(nonatomic, readwrite, retain) YapDatabaseConnection *databaseConnection, *roConnection;
@property(nonatomic, readwrite, retain) SitDialer *networkConnection;

@property(atomic, assign, readwrite, setter=setGeneration:, getter=generation) FGIntBase generation;
@property(nonatomic, readwrite, retain, setter=setPrivateBBSKey:, getter=privateBBSKey) BBSPrivateKey *privateBBSKey;
@property(nonatomic, readwrite, retain, setter=setPrivateEd25519Key:, getter=privateEd25519Key) Ed25519SHA512 *privateEd25519Key;
@property(nonatomic, readwrite, retain, setter=setIdentity:, getter=identity) NSData *identity;
@property(nonatomic, readwrite, retain, setter=setPublicIdentity:, getter=publicIdentity) NSData *publicIdentity;

@property(nonatomic, retain, readwrite, setter=setContacts:, getter=contacts) NSArray<NSString *> *contacts;
@property(nonatomic, retain, readwrite, setter=setContactIDs:, getter=contactIDs) NSMutableData *contactIDs;

@property(nonatomic, retain, readwrite, setter=setRandomIds:, getter=randomIds) NSData *randomIds;
@property(nonatomic, retain, readwrite, setter=setServerAddress:, getter=serverAddress) NSString *serverAddress;
@property(nonatomic, retain, readwrite, setter=setServerId:, getter=serverId) NSString *serverId;
@property(atomic, assign, readwrite, setter=setAccountExists:, getter=accountExists) BOOL accountExists;
@property(atomic, assign, readwrite, setter=setServerValid:, getter=serverValid) BOOL serverValid;

@property(weak, nonatomic, readwrite) UIViewController *currentVC;
@property(nonatomic, retain, readwrite) NSMutableString *logString;
@property(nonatomic, retain, readwrite, setter=setQueue:, getter=queue) NSMutableArray *queue;
@property(nonatomic, retain, readwrite) SitDQueued *currentTransacting;
@property(atomic, readwrite, assign) BOOL stopTransacting;

-(void) appendLog: (NSString *) appendStr;
-(FGIntOverflow) newRandomId;
-(void) addContactID: (FGIntOverflow) newID;
-(void) newContactWithName: (NSString *) name;
-(NSString *) nameForContact: (NSString *) contactID;
-(void) removeContact: (NSString *) contactID;
-(void) restartKeyExchangeForContact: (NSString *) contactID;
-(void) completeKeyExchangeForContact: (NSString *) contactID withKeyExchange: (NSString *) keyXStr;
-(SitDContact *) loadContact: (NSString *) contactID;
-(void) popQueue;
-(void) pushToQueue: (SitDQueued *) queuedMsg;
-(void) handshakeComplete;
-(void) startTransacting;
-(void) transact;
-(void) dialerDisconnected;
-(void) createAccount;
-(void) processReply: (NSData *) replyData withTag: (long) tag;
-(void) processProto: (NSData *) protoData withTag: (tag) tag;
-(void) revokeContact: (NSString *) contactID;

-(NSData *) publicEd25519Key;

-(void) showNotificationWithTitle: (NSString *) title message: (NSString *) message andType: (TSMessageNotificationType) type;
-(void) storeMessage: (SitDMessageContent *) message;
-(void) registerMessagesListExtension;
-(void) markReadDelivered: (uint64_t) localID;
-(void) removeMessage: (uint64_t) msgId;



@end
