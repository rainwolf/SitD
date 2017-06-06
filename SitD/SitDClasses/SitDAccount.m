//
//  SitDAccount.m
//  SitD
//
//  Created by rainwolf on 13/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//


#import "SitDAccount.h"
#import "Pond.pbobjc.h"
#import "constants.h"
//#import "TSMessage.h"
//#import "SitDContact.h"
#import "DetailNavigationController.h"
#import "MessageViewController.h"


@implementation SitDAccount
@synthesize database;
@synthesize databaseKey;
@synthesize databaseName;
@synthesize networkConnection;

@synthesize generation;
@synthesize privateBBSKey;
@synthesize privateEd25519Key;
@synthesize databaseConnection, roConnection;
@synthesize identity;
@synthesize publicIdentity;

@synthesize contacts;
@synthesize contactIDs;

@synthesize randomIds;
@synthesize serverAddress;
@synthesize serverId;
@synthesize accountExists;
@synthesize serverValid;

@synthesize currentVC;
@synthesize logString;

@synthesize queue;
@synthesize currentTransacting;
@synthesize stopTransacting;


-(SitDAccount *) init {
    if (self = [super init]) {
        database = nil;
        databaseKey = nil;
        databaseName = nil;
        networkConnection = [[SitDialer alloc] init];
        [networkConnection setAccount:self];
        
        generation = 0;
        privateEd25519Key = nil;
        privateBBSKey = nil;
        databaseConnection = nil;
        identity = nil;
        publicIdentity = nil;
        
        contacts = nil;
        contactIDs = nil;
        
        randomIds = nil;
        serverAddress = nil;
        serverId = nil;
        accountExists = NO;
        serverValid = NO;
        
        currentVC = nil;
        logString = [[NSMutableString alloc] init];
        queue = nil;
        currentTransacting = nil;
    }
    return self;
}


-(void) setPrivateBBSKey:(BBSPrivateKey *)privateKey {
    privateBBSKey = privateKey;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:[privateKey marshal] forKey:@"privateBBSKey" inCollection:SitDAccountKey];
        [transaction setObject:[[privateKey group] extendedMarshal] forKey:@"bbsKeyGroup" inCollection:SitDAccountKey];
    }];
}

-(BBSPrivateKey *) privateBBSKey {
    if (privateBBSKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            privateBBSKey = [[BBSPrivateKey alloc] unMarshal:[transaction objectForKey:@"privateBBSKey" inCollection:SitDAccountKey]];
            [privateBBSKey setGroup:[[BBSGroup alloc] unMarshal:[transaction objectForKey:@"bbsKeyGroup" inCollection:SitDAccountKey]]];
        }];
    }
    return privateBBSKey;
}

-(void) setPrivateEd25519Key:(Ed25519SHA512 *)privateKey {
    privateEd25519Key = privateKey;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:[privateKey secretKeyToNSData] forKey:@"privateEd25516Key" inCollection:SitDAccountKey];
    }];
}
-(Ed25519SHA512 *) privateEd25519Key {
    if (privateEd25519Key == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            NSData *data = [transaction objectForKey:@"privateEd25516Key" inCollection:SitDAccountKey];
            privateEd25519Key = [[Ed25519SHA512 alloc] init];
            [privateEd25519Key setSecretKeyWithNSData: data];
        }];
    }
    return privateEd25519Key;
}
-(NSData *) publicEd25519Key {
    return [self.privateEd25519Key publicKeyToNSData];
}

-(void) setIdentity:(NSData *)identityData {
    identity = identityData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:identity forKey:@"identity" inCollection:SitDAccountKey];
    }];
}
-(NSData *) identity {
    if (identity == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            identity = [transaction objectForKey:@"identity" inCollection:SitDAccountKey];
        }];
    }
    return identity;
}


-(void) setPublicIdentity:(NSData *)publicIdentityData {
    publicIdentity = publicIdentityData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:publicIdentity forKey:@"publicIdentity" inCollection:SitDAccountKey];
    }];
}
-(NSData *) publicIdentity {
    if (publicIdentity == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            publicIdentity = [transaction objectForKey:@"publicIdentity" inCollection:SitDAccountKey];
        }];
    }
    return publicIdentity;
}



-(void) setRandomIds:(NSData *)randomIdsData {
    randomIds = randomIdsData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:randomIds forKey:@"randomIds" inCollection:SitDAccountKey];
    }];
}
-(NSData *) randomIds {
    if (randomIds == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            randomIds = [transaction objectForKey:@"randomIds" inCollection:SitDAccountKey];
        }];
    }
    return randomIds;
}
-(FGIntOverflow) newRandomId {
    NSMutableData *randomIdsData = [[self randomIds] mutableCopy];
    FGIntOverflow* idArray = [randomIdsData mutableBytes];
    FGIntOverflow idArrayLength = [randomIdsData length]/8;
    FGIntOverflow newId = 0;
    // infinite loop when random doesn't work
    BOOL isNew;
    {
        isNew = YES;
        if (! SecRandomCopyBytes(kSecRandomDefault, 8, (unsigned char *) &newId)) {
            for (FGIntOverflow i = 0; i < idArrayLength; ++i) {
                if (newId == idArray[i]) {
                    isNew = NO;
                    break;
                }
            }
        }

    } while (!isNew);
    [randomIdsData appendBytes:&newId length:8];
    [self setRandomIds:randomIdsData];
    
    return newId;
}
-(void) removeRandomID: (FGIntOverflow) idToRemove {
    NSData *idData = [NSData dataWithBytes: &idToRemove length:8];
    [self removeRandomIData: idData];
}
-(void) removeRandomIData: (NSData *) idData {
    unsigned long rangeStart = NSNotFound;
    NSRange foundRange = [self.randomIds rangeOfData: idData options: 0 range:NSMakeRange(rangeStart + 1, [self.randomIds length] - rangeStart - 1)];
    
    while (foundRange.location != NSNotFound && (foundRange.location % 8) != 0) {
        rangeStart = foundRange.location + 1;
        foundRange = [self.randomIds rangeOfData: idData options: 0 range:NSMakeRange(rangeStart + 1, [self.randomIds length] - rangeStart - 1)];
    }
    if (foundRange.location != NSNotFound) {
        NSMutableData *mutableIDs = [self.randomIds mutableCopy];
        [mutableIDs replaceBytesInRange:foundRange withBytes: nil length: 0];
        [self setRandomIds: mutableIDs];
    }
    
}

-(void) setServerAddress:(NSString *)serverAddressString {
    serverAddress = serverAddressString;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:serverAddress forKey:@"serverAddress" inCollection:SitDAccountKey];
    }];
}
-(NSString *) serverAddress {
    if (serverAddress == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            serverAddress = [transaction objectForKey:@"serverAddress" inCollection:SitDAccountKey];
        }];
    }
    return serverAddress;
}

-(void) setServerId:(NSString *)serverIdString {
    serverId = serverIdString;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:serverId forKey:@"serverId" inCollection:SitDAccountKey];
    }];
}
-(NSString *) serverId {
    if (serverId == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            serverId = [transaction objectForKey:@"serverId" inCollection:SitDAccountKey];
        }];
    }
    return serverId;
}

-(void) setAccountExists:(BOOL)accountExistsBool {
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSString *boolStr;
        if (accountExistsBool) {
            boolStr = @"yes";
        } else {
            boolStr = @"no";
        }
        [transaction setObject:boolStr forKey:@"accountExists" inCollection:SitDAccountKey];
    }];
}
-(BOOL) accountExists {
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *result = [transaction objectForKey:@"accountExists" inCollection:SitDAccountKey];
        accountExists = NO;
        if (result) {
            accountExists = [result isEqualToString:@"yes"];
        }
    }];
    return accountExists;
}
-(void) setServerValid:(BOOL)serverValidBool {
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSString *boolStr;
        if (serverValidBool) {
            boolStr = @"yes";
        } else {
            boolStr = @"no";
        }
        [transaction setObject:boolStr forKey:@"serverValid" inCollection:SitDAccountKey];
    }];
}
-(BOOL) serverValid {
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *result = [transaction objectForKey:@"serverValid" inCollection:SitDAccountKey];
        serverValid = NO;
        if (result) {
            serverValid = [result isEqualToString:@"yes"];
        }
    }];
    return accountExists;
}

-(void) setGeneration:(FGIntBase)gen {
    generation = gen;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: [NSNumber numberWithUnsignedInt:generation] forKey:@"generation" inCollection:SitDAccountKey];
    }];
    
}
-(FGIntBase) generation {
    if (generation == 0) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            generation = [[transaction objectForKey:@"generation" inCollection:SitDAccountKey] unsignedIntValue];
        }];
    }
    return generation;
}

-(void) setQueue:(NSMutableArray *)queueArray {
    queue = queueArray;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: queue forKey:@"queue" inCollection:SitDAccountKey];
    }];
    
}
-(NSMutableArray *) queue {
    if (queue == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            queue = [transaction objectForKey:@"queue" inCollection:SitDAccountKey];
        }];
    }
    return queue;
}
-(void) popQueue {
    NSMutableArray *selfQueue = self.queue;
    if (selfQueue && ([selfQueue count] > 0)) {
        [selfQueue removeObjectAtIndex: 0];
        [self setQueue: selfQueue];
    }
}
-(void) pushToQueue: (SitDQueued *) queuedMsg {
    NSMutableArray *selfQueue = self.queue;
    if (selfQueue == nil) {
        selfQueue = [[NSMutableArray alloc] init];
    }
    [selfQueue addObject: queuedMsg];
    [self setQueue: selfQueue];
}

-(void) appendLog: (NSString *) appendStr {
    NSDateFormatter *formatter;
    NSString        *dateString;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm "];
    dateString = [formatter stringFromDate:[NSDate date]];
    
    [logString appendString: dateString];
    [logString appendString: appendStr];
    [logString appendString: @"\n"];
}

-(void) startTransacting {
    BOOL hasFetch = NO;
    if (self.queue && ([self.queue count] > 0)) {
        for (SitDQueued *queued in self.queue) {
            hasFetch = ([queued tag] == FETCHPROTO);
            if (hasFetch) {
                break;
            }
        }
    }
    if (!hasFetch) {
        Fetch *fetch = [[Fetch alloc] init];
        Request *req = [[Request alloc] init];
        [req setFetch:fetch];
        SitDQueued *newFetch = [[SitDQueued alloc] init];
        [newFetch setMessage:[req data]];
        [newFetch setAnonymous: NO];
        [newFetch setServerHost: self.serverAddress];
        [newFetch setServerIdentity: self.serverId];
        [newFetch setContactID: @"Fetch"];
        [newFetch setTag: FETCHPROTO];
        [self pushToQueue: newFetch];
    }
    self.stopTransacting = NO;
    [self transact];
}

-(void) transact {
    if (self.stopTransacting) {
        return;
    }
    if (currentTransacting && [networkConnection wants2Connect]) {
        return;
    }
    if (self.queue == nil || [self.queue count] == 0) {
        return;
    }
    
    currentTransacting = [self.queue objectAtIndex:0];
    if (![currentTransacting anonymous]) {
        [networkConnection setIdentity: self.identity];
        [networkConnection setIdentityPublic: self.publicIdentity];
        [networkConnection setAnonymous:NO];
    } else {
        [networkConnection setIdentity: nil];
        [networkConnection setIdentityPublic: nil];
        [networkConnection setAnonymous:YES];
    }
    [networkConnection setServerName: currentTransacting.serverHost];
    [networkConnection setServerIdentityString: currentTransacting.serverIdentity];
    NSError *error;
    [networkConnection connectDialerWithError: error];
}
-(void) handshakeComplete {
    if (currentTransacting == nil) {
        return;
    }
    if (currentTransacting.tag == DELIVERPROTO) {
        SitDContact *contact = [self loadContact: currentTransacting.contactID];
        if (contact.revokedMe) {
            [self popQueue];
            currentTransacting = nil;
            return;
        }
        NSData *sealed = currentTransacting.message;
        NSData *groupSignature = [BBSsig sign: [FGIntXtra SHA256:sealed] withMemberKey: contact.myBBSMemberKey];
        Delivery *pondDelivery = [[Delivery alloc] init];
        [pondDelivery setTo: [contact.ratchet theirIdentityPublic]];
        [pondDelivery setGroupSignature: groupSignature];
        [pondDelivery setGeneration: contact.generation];
        [pondDelivery setMessage: sealed];
    
        Request *pondRequest = [[Request alloc] init];
        [pondRequest setDeliver: pondDelivery];
        [networkConnection writeProto: [pondRequest data] withTag: DELIVERPROTO];
    } else {
        [networkConnection writeProto: [currentTransacting message] withTag: [currentTransacting tag]];
    }
}
-(void) dialerDisconnected {
    [self transact];
}


-(void) createAccount {
    [self setGeneration:(FGIntBase) [self newRandomId]];
    NewAccount *newAcc = [[NewAccount alloc] init];
    [newAcc setGeneration:self.generation];
    [newAcc setGroup:[[self.privateBBSKey group] marshal]];
    Request *req = [[Request alloc] init];
    [req setNewAccount:newAcc];
    
    SitDQueued *msg = [[SitDQueued alloc] init];
    [msg setAnonymous: NO];
    [msg setTag:NEWACCOUNTPROTO];
    [msg setServerHost:self.serverAddress];
    [msg setServerIdentity: self.serverId];
    [msg setMessage: [req data]];

    [self pushToQueue: msg];
    
    [self transact];
}
-(void) processReply: (NSData *) replyData withTag: (long) tag {
//    NSLog(@"%lu tag processing", tag);
    __block SitDQueued *currentProcessing = currentTransacting;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error;
        Reply *reply = [[Reply alloc] initWithData:replyData error: &error];
        if (tag & NEWACCOUNTPROTO) {
            if (reply.status == Reply_Status_Ok) {
                NSLog(@"account created");
                [self popQueue];
                [self showNotificationWithTitle:NSLocalizedString(@"Account created", nil) message:NSLocalizedString(@"with the home server", nil) andType:TSMessageNotificationTypeSuccess];
                [self setAccountExists:YES];
            } else if (reply.status == Reply_Status_IdentityAlreadyKnown) {
                [self popQueue];
                NSLog(@"account exists already");
                [self showNotificationWithTitle:NSLocalizedString(@"Account already exists", nil) message:NSLocalizedString(@"with the home server", nil) andType:TSMessageNotificationTypeWarning];
                if (!self.accountExists) {
                    [self setAccountExists:YES];
                }
            } else if (reply.status == Reply_Status_RegistrationDisabled) {
                NSLog(@"server not accepting new registrations");
                [self showNotificationWithTitle:NSLocalizedString(@"New registrations are disabled", nil) message:NSLocalizedString(@"with the home server", nil) andType:TSMessageNotificationTypeWarning];
            } else {
                [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"account creation failed", nil) andType:TSMessageNotificationTypeError];
                NSLog(@"account creation failed %i", reply.status);
            }
        } else if (tag & REVOCATIONPROTO) {
    //        NSLog(@"%lu replystatus", reply.status);
            if (reply.status == Reply_Status_Ok) {
                NSLog(@"revocation success");
                SitDContact *contact = [self loadContact:[currentProcessing contactID]];
                if ([contact name]) {
                    [contact setRevoked: YES];
                }
                [self showNotificationWithTitle: [contact name] message: NSLocalizedString(@"successfully revoked", nil) andType:TSMessageNotificationTypeSuccess];
                [self popQueue];
            } else if (reply.status == Reply_Status_NoAccount) {
                NSLog(@"revocation failed");
                [self showNotificationWithTitle: NSLocalizedString(@"Revocation failed", nil) message: NSLocalizedString(@"No account exists", nil) andType:TSMessageNotificationTypeError];
            } else if (reply.status == Reply_Status_CannotParseRevocation) {
                NSLog(@"revocation failed");
                [self showNotificationWithTitle: NSLocalizedString(@"Revocation failed", nil) message: NSLocalizedString(@"Revocation parsing failed", nil) andType:TSMessageNotificationTypeError];
                [self popQueue];
            } else if (reply.status == Reply_Status_InternalError) {
                NSLog(@"revocation failed");
                [self showNotificationWithTitle: NSLocalizedString(@"Revocation failed", nil) message: NSLocalizedString(@"Server internal error", nil) andType:TSMessageNotificationTypeWarning];
            }
        } else if (tag & DELIVERPROTO) {
            if (reply.status == Reply_Status_GenerationRevoked) {
                if ([reply hasRevocation]) {
                    SitDContact *contact = [self loadContact: currentProcessing.contactID];
                    Ed25519SHA512 *theirEdKeys = [[Ed25519SHA512 alloc] init];
                    [theirEdKeys setPublicKeyWithNSData: [contact.ratchet theirEd25519Public]];
                    char revocationSignaturePrefixBytes[] = "revocation";
                    NSLog(@"kitteh, %lu", reply.extraRevocationsArray_Count);
                    unsigned long intCount = reply.extraRevocationsArray_Count;
                    for (int i = -1; i < intCount; ++i) {
                        SignedRevocation *signedRev;
                        if (i < 0) {
                            signedRev = [reply revocation];
                        } else {
                            signedRev = [[reply extraRevocationsArray] objectAtIndex: i];
                        }
                        if ([[signedRev revocation] generation] != [contact generation]) {
                            NSLog(@"Invalid Revocation generation, we received %ul but the current generation is %ul", [[signedRev revocation] generation], [contact generation]);
                            [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: @"Invalid revocation generation"  andType:TSMessageNotificationTypeError];
                            return;
                        }
                        NSMutableData *toVerifyRevocation = [NSMutableData dataWithBytes:revocationSignaturePrefixBytes length: sizeof(revocationSignaturePrefixBytes)];
                        [toVerifyRevocation appendData: [[signedRev revocation] data]];
                        if (![theirEdKeys verifySignature:[signedRev signature] ofPlainTextNSData:toVerifyRevocation]) {
                            NSLog(@"Invalid Revocation signature");
                            [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: @"Invalid revocation signature"  andType:TSMessageNotificationTypeError];
                            return;
                        }
                        SignedRevocation_Revocation *rev = [signedRev revocation];
                        BBSRevocation *revocation = [[BBSRevocation alloc] unMarshal: [rev revocation]];
                        BBSMemberKey *myKeyFromContact = [contact myBBSMemberKey];
                        BOOL revokedUs = [myKeyFromContact updateWithRevocation: revocation];
                        [contact setMyBBSMemberKey: myKeyFromContact];
                        if (!revokedUs) {
                            [contact setRevokedMe: YES];
                            NSLog(@"We are revoked");
                            [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: [NSString stringWithFormat: NSLocalizedString(@"%@ revoked me", nil), [contact name]]  andType:TSMessageNotificationTypeError];
                            currentTransacting = nil;
                            [self popQueue];
                            return;
                        } else {
                            [contact setGeneration: contact.generation + 1];
                        }
                    }
                }
            } else if (reply.status == Reply_Status_Ok) {
                [self popQueue];
                NSLog(@"message sent success");
                SitDContact *contact = [self loadContact:[currentProcessing contactID]];
                [self showNotificationWithTitle: [contact name] message: NSLocalizedString(@"message sent!", nil) andType:TSMessageNotificationTypeSuccess];
                [self markReadDelivered: currentProcessing.localMsgId];
            } else if (reply.status == Reply_Status_NoAccount) {
                NSLog(@"no account");
                [self showNotificationWithTitle: NSLocalizedString(@"Message delivery failed", nil) message: NSLocalizedString(@"No account exists", nil) andType:TSMessageNotificationTypeError];
            } else if (reply.status == Reply_Status_InternalError) {
                NSLog(@"internal error");
                [self showNotificationWithTitle: NSLocalizedString(@"Message delivery failed", nil) message: NSLocalizedString(@"Server internal error", nil) andType:TSMessageNotificationTypeWarning];
            } else {
                [self popQueue];
                [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Message Delivery failed", nil) andType:TSMessageNotificationTypeError];
                NSLog(@"message delivery failed %i", reply.status);
            }
            
        } else if (tag & FETCHPROTO) {
            [self popQueue];
    //        NSLog(@"kitten fetchproto %lu", [self.queue count]);
            if ([reply hasFetched]) {
                NSLog(@"kitten has fetched");
                [self processFetched: reply.fetched];
            } else {
                [self showNotificationWithTitle: nil message:NSLocalizedString(@"No new messages", nil) andType:TSMessageNotificationTypeWarning];
            }
            if ([reply hasAnnounce]) {
                NSLog(@"kitten has hasAnnounce");

            }
        }
//        if (reply.hasFetched) {
//            [self startTransacting];
//        }
    });
    [networkConnection close];
    currentTransacting = nil;
}

-(void) processProto: (NSData *) protoData withTag: (tag) tag {
    if (tag & PROTOREPLYTAG) {
        [self processReply:protoData withTag:tag];
    }
    
}





-(void) showNotificationWithTitle: (NSString *) title message: (NSString *) message andType: (TSMessageNotificationType) type{
    dispatch_async(dispatch_get_main_queue(), ^{
        [TSMessage showNotificationInViewController:self.currentVC
                                          title: title
                                       subtitle: message
                                          image:nil
                                               type: type
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                        buttonTitle: nil
                                 buttonCallback:^{
                                     [TSMessage dismissActiveNotification];
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];

    });
}


-(void) setContactIDs:(NSMutableData *)contactIDsData {
    contactIDs = contactIDsData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:contactIDs forKey: SitDContactIDs inCollection:SitDAccountKey];
    }];
}
-(NSData *) contactIDs {
    if (contactIDs == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            contactIDs = [transaction objectForKey: SitDContactIDs inCollection:SitDAccountKey];
        }];
    }
    return contactIDs;
}
-(void) addContactID: (FGIntOverflow) newID {
    // should check if it doesn't exist but that shouldn't happen because newrandid
    NSArray<NSString *> *oldContacts = [self contacts];

    NSData *newIdData = [NSData dataWithBytes:&newID length:8];
    NSData *oldIDs = [self contactIDs];
    NSMutableData *iDs;
    if (oldIDs == nil) {
        iDs = [[NSMutableData alloc] initWithData:newIdData];
    } else {
        iDs = [oldIDs mutableCopy];
        [iDs appendData:newIdData];
    }
    [self setContactIDs: iDs];
    
    NSMutableArray<NSString *> *newContacts;
    if (oldContacts == nil) {
        newContacts = [[NSMutableArray alloc] init];
    } else {
        newContacts = [oldContacts mutableCopy];
    }
    [newContacts addObject: [FGIntXtra dataToHexString: newIdData]];
    contacts = newContacts;
}

-(NSArray<NSString *> *) contacts {
    if (contacts) {
        return contacts;
    }
    NSMutableArray* mutableContacts = [[NSMutableArray alloc] init];
    NSData *contactData = [self contactIDs];
    unsigned char* contactIDsArray = (unsigned char *) [contactData bytes];
    for ( FGIntIndex i = 0; i < [contactData length]/8; ++i ) {
        [mutableContacts addObject: [FGIntXtra dataToHexString: [NSData dataWithBytes:&contactIDsArray[i*8] length:8]]];
    }
    return [mutableContacts sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [[self nameForContact: a] compare: [self nameForContact: b]];
    }];
}
-(void) setContacts:(NSArray<NSString *> *)contactsArray {
    contacts = contactsArray;
}

-(NSString *) nameForContact: (NSString *) contactID {
    __block NSString *name;
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        name = [transaction objectForKey: @"name" inCollection: contactID];
    }];
    return name;
}
-(void) removeContact: (NSString *) contactID {
    SitDContact *contact = [self loadContact: contactID];
    NSData *idToRemove = [FGIntXtra hexStringToNSData:contactID];
    NSMutableData *oldIDs = [self contactIDs];
    NSRange idRange = [oldIDs rangeOfData:idToRemove options:0 range:NSMakeRange(0, [oldIDs length])];
    [oldIDs replaceBytesInRange:idRange withBytes:nil length:0];
    [self setContactIDs: oldIDs];
    [self setContacts: nil];
    if (![contact revoked]) {
        [self revokeContact: contactID];
    }
    
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInCollection: contactID];
    }];
    
    [self removeRandomIData: idToRemove];
    [self removeMessagesForContact: contactID];
}
-(SitDContact *) loadContact: (NSString *) contactID {
    SitDContact *contact = [[SitDContact alloc] initWithID: contactID myIdentity: [self identity] myEd25519Public:[self publicEd25519Key] myBBSGroup: [self.privateBBSKey group] account:self andDatabaseConnection:databaseConnection];
    return contact;
}

-(void) newContactWithName: (NSString *) name {
    FGIntOverflow randID = [self newRandomId];
    NSData *contactIdData = [NSData dataWithBytes:&randID length:8];
    NSString *contactID = [FGIntXtra dataToHexString: contactIdData];

    [self addContactID: randID];
    
    SitDContact *newContact = [[SitDContact alloc] initWithID: contactID myIdentity: [self identity] myEd25519Public:[self publicEd25519Key] myBBSGroup: [self.privateBBSKey group] account:self andDatabaseConnection:databaseConnection];
    
    [newContact setName: name];
    [newContact setTimeAdded: [NSDate date]];
    
    [[newContact ratchet] setKxPrivate0: [FGIntXtra randomDataOfLength:32]];
    [[newContact ratchet] setKxPrivate1: [FGIntXtra randomDataOfLength:32]];
    
    BBSMemberKey *contactBBSMemberKey = [[BBSMemberKey alloc] initNewMemberWithGroupPrivateKey: self.privateBBSKey];
    
    [newContact setTheirBBSMemberKey:contactBBSMemberKey];
    
    KeyExchange *newKeyX = [[KeyExchange alloc] init];
    [newKeyX setPublicKey: [self publicEd25519Key]];
    [newKeyX setIdentityPublic: [self publicIdentity]];
    [newKeyX setServer: [NSString stringWithFormat:@"pondserver://%@@%@",self.serverId, self.serverAddress]];
    [newKeyX setGroup:[self.privateBBSKey.group marshal]];
    [newKeyX setGroupKey:[contactBBSMemberKey marshal]];
    [newKeyX setGeneration:self.generation];
    [newKeyX setDh:[NaClPacket curve25519BasePointTimes: newContact.ratchet.kxPrivate0]];
    [newKeyX setDh1:[NaClPacket curve25519BasePointTimes: newContact.ratchet.kxPrivate1]];
    
    NSData *keyXData = [newKeyX data];
    
    SignedKeyExchange *signedKeyX = [[SignedKeyExchange alloc] init];
    [signedKeyX setSigned_p:keyXData];
    [signedKeyX setSignature:[self.privateEd25519Key signNSData:keyXData]];
    
    newContact.keyExchangeData = [signedKeyX data];
    
    [newContact setPending:YES];
    
    [self showNotificationWithTitle:[NSString stringWithFormat:@"Contact %@ added", name] message:nil andType:TSMessageNotificationTypeSuccess];
    
//    NSLog(@"-----BEGIN POND KEY EXCHANGE-----\n%@\n-----END POND KEY EXCHANGE-----", [FGIntXtra dataToBase64String:newContact.keyExchangeData]);
}

-(void) restartKeyExchangeForContact: (NSString *) contactID {
    SitDContact *newContact = [self loadContact: contactID];
    [newContact setTimeAdded: [NSDate date]];
    [newContact setPending: YES];
    
    [[newContact ratchet] setKxPrivate0: [FGIntXtra randomDataOfLength:32]];
    [[newContact ratchet] setKxPrivate1: [FGIntXtra randomDataOfLength:32]];
    
    [[newContact ratchet] setTxCount: 0];
    [[newContact ratchet] setRxCount: 0];
    [[newContact ratchet] setPrevTxCount: 0];
    [[newContact ratchet] setSavedKeys: nil];

    
//    BBSMemberKey *contactBBSMemberKey = [[BBSMemberKey alloc] initNewMemberWithGroupPrivateKey: self.privateBBSKey];
    
    [newContact setTheirBBSMemberKey: [newContact theirBBSMemberKey]];
    
    KeyExchange *newKeyX = [[KeyExchange alloc] init];
    [newKeyX setPublicKey: [self publicEd25519Key]];
    [newKeyX setIdentityPublic: [self publicIdentity]];
    [newKeyX setServer: [NSString stringWithFormat:@"pondserver://%@@%@",self.serverId, self.serverAddress]];
    [newKeyX setGroup:[self.privateBBSKey.group marshal]];
    [newKeyX setGroupKey:[[newContact theirBBSMemberKey] marshal]];
    [newKeyX setGeneration:self.generation];
    [newKeyX setDh:[NaClPacket curve25519BasePointTimes: newContact.ratchet.kxPrivate0]];
    [newKeyX setDh1:[NaClPacket curve25519BasePointTimes: newContact.ratchet.kxPrivate1]];
    
    NSData *keyXData = [newKeyX data];
    
    SignedKeyExchange *signedKeyX = [[SignedKeyExchange alloc] init];
    [signedKeyX setSigned_p:keyXData];
    [signedKeyX setSignature:[self.privateEd25519Key signNSData:keyXData]];
    
    newContact.keyExchangeData = [signedKeyX data];
    
    [newContact setPending:YES];
    
    [self showNotificationWithTitle:[newContact name]  message: NSLocalizedString(@"New KeyX initiated", nil) andType:TSMessageNotificationTypeSuccess];
}

-(void) completeKeyExchangeForContact: (NSString *) contactID withKeyExchange: (NSString *) keyXStr {
    SitDContact *contact = [self loadContact:contactID];
    if ([[contact ratchet] kxPrivate0] == nil) {
        NSLog(@"Key Exchange for %@ already complete", [contact name]);
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: [NSString stringWithFormat:@"Key Exchange for %@ already complete", [contact name]]  andType:TSMessageNotificationTypeError];
        return;
    }

    NSString *base64Str = [[keyXStr stringByReplacingOccurrencesOfString:@"-----BEGIN POND KEY EXCHANGE-----" withString:@""] stringByReplacingOccurrencesOfString:@"-----END POND KEY EXCHANGE-----" withString:@""];
    NSData *signedKeyXData = [FGIntXtra base64StringToNSData: base64Str];
    NSError *error;
    SignedKeyExchange *signedKeyX = [[SignedKeyExchange alloc] initWithData:signedKeyXData error: &error];
    if (error) {
        NSLog(@"Error reading signedKeyX into proto %@", error);
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: [NSString stringWithFormat:@"Error reading signedKeyX into proto %@", error]  andType:TSMessageNotificationTypeError];
        return;
    }
    NSData *keyXData = [signedKeyX signed_p];
    KeyExchange *keyX = [[KeyExchange alloc] initWithData:keyXData error: &error];
    if (error) {
        NSLog(@"Error reading KeyX into proto %@", error);
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: [NSString stringWithFormat:@"Error reading KeyX into proto %@", error]  andType:TSMessageNotificationTypeError];
        return;
    }
    if ([[keyX publicKey] length] != 32) {
        NSLog(@"Wrong Ed25519 key length");
        [self showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: @"Wrong Ed25519 key length"  andType:TSMessageNotificationTypeError];
        return;
    }
    [contact.ratchet setTheirEd25519Public:[keyX publicKey]];
    Ed25519SHA512 *theirEdKeys = [[Ed25519SHA512 alloc] init];
    [theirEdKeys setPublicKeyWithNSData:[keyX publicKey]];
    if (![theirEdKeys verifySignature:[signedKeyX signature] ofPlainTextNSData:keyXData]) {
        NSLog(@"Invalid KeyX signature");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: @"Invalid KeyX signature"  andType:TSMessageNotificationTypeError];
        return;
    }
    if ([[keyX identityPublic] length] != 32) {
        NSLog(@"Wrong public identity length");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: @"Wrong public identity length"  andType:TSMessageNotificationTypeError];
        return;
    }
    [contact.ratchet setTheirIdentityPublic:[keyX identityPublic]];
    
    // do more checks for bbs keys
    BBSGroup *theirGroup = [[BBSGroup alloc] unMarshal:[keyX group]];
    BBSMemberKey *myMemberKey = [[BBSMemberKey alloc] unMarshal:[keyX groupKey]];
    [myMemberKey setGroup:theirGroup];
    [contact setMyBBSMemberKey: myMemberKey];
    
    [contact setGeneration:[keyX generation]];
    
    NSString *serverStr = [[keyX server] stringByReplacingOccurrencesOfString:@"pondserver://" withString:@""];
    NSRange chr = [serverStr rangeOfString:@"@"];
    if (chr.location == NSNotFound) {
        NSLog(@"Server format not quite right");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: @"Server format not quite right"  andType:TSMessageNotificationTypeError];
        return;
    }
    [contact setServerId: [serverStr substringToIndex:chr.location]];
    [contact setServerAddress: [serverStr substringFromIndex:chr.location + 1]];
    
    NSData *signingMontgomery = [[[Ed25519Point alloc] initFromCompressed25519NSDataWithoutCurve: [keyX publicKey]] toMontgomery25519X];
    BOOL isV2 = [signingMontgomery isEqualToData: [keyX identityPublic]];
    [contact.ratchet setV2: isV2];

//    signingMontgomery = [[[Ed25519Point alloc] initFromCompressed25519NSDataWithoutCurve: self.publicEd25519Key] toMontgomery25519X];
//    NSLog(@"kitty V2 %@", [signingMontgomery isEqualToData: self.publicIdentity]?@"it works":@"crap");

    NSData *public0 = [NaClPacket curve25519BasePointTimes:[[contact ratchet] kxPrivate0]];
    unsigned char* public0Bytes = (unsigned char *) [public0 bytes];
    unsigned char* dhBytes = (unsigned char *) [[keyX dh] bytes];
    int amAlice = 0;
    for ( int i = 0; i < 32; ++i ) {
        if (public0Bytes[i] < dhBytes[i]) {
            amAlice = -1;
            break;
        } else if (public0Bytes[i] > dhBytes[i]) {
            amAlice = 1;
            break;
        }
    }
    if (amAlice == 0) {
        NSLog(@"User echoed DH values");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: @"User echoed DH values"  andType:TSMessageNotificationTypeError];
        return;
    }
    
    NSMutableData *keyMaterial = [[NSMutableData alloc] init];
    NSData *sharedKey, *theirDh = [keyX dh];
    
    sharedKey = [NaClPacket curve25519Point:theirDh times: [[contact ratchet] kxPrivate0]];
    [keyMaterial appendData: sharedKey];
    if (amAlice == -1) {
        sharedKey = [NaClPacket curve25519Point:theirDh times: self.identity];
        [keyMaterial appendData: sharedKey];
        sharedKey = [NaClPacket curve25519Point: [[contact ratchet] theirIdentityPublic] times: [[contact ratchet] kxPrivate0]];
        [keyMaterial appendData: sharedKey];
        if (!isV2) {
            [keyMaterial appendData: self.publicEd25519Key];
            [keyMaterial appendData:[[contact ratchet] theirEd25519Public]];
        }
    } else {
        sharedKey = [NaClPacket curve25519Point: [[contact ratchet] theirIdentityPublic] times: [[contact ratchet] kxPrivate0]];
        [keyMaterial appendData: sharedKey];
        sharedKey = [NaClPacket curve25519Point:theirDh times: self.identity];
        [keyMaterial appendData: sharedKey];

        if (!isV2) {
            [keyMaterial appendData:[[contact ratchet] theirEd25519Public]];
            [keyMaterial appendData: self.publicEd25519Key];
        }
    }
    
//    sharedKey = keyMaterial;
//    keyMaterial = [[FGIntXtra SHA256: sharedKey] mutableCopy];
    
//    char rootKeyUpdateLabelBytes[] = "root key update";
//    char messageKeyLabelBytes[] = "message key";
//    char chainKeyStepLabelBytes[] = "chain key step";
//    NSData *rootKeyUpdateLabel = [NSData dataWithBytes:rootKeyUpdateLabelBytes length: strlen(rootKeyUpdateLabelBytes)];
//    NSData *messageKeyLabel = [NSData dataWithBytes:messageKeyLabelBytes length: strlen(messageKeyLabelBytes)];
//    NSData *chainKeyStepLabel = [NSData dataWithBytes:chainKeyStepLabelBytes length: strlen(chainKeyStepLabelBytes)];
    char chainKeyLabelBytes[] = "chain key";
    NSData *chainKeyLabel = [NSData dataWithBytes:chainKeyLabelBytes length: sizeof(chainKeyLabelBytes) - 1];
    char headerKeyLabelBytes[] = "header key";
    NSData *headerKeyLabel = [NSData dataWithBytes:headerKeyLabelBytes length:sizeof(headerKeyLabelBytes) - 1];
    char nextRecvHeaderKeyLabelBytes[] = "next receive header key";
    NSData *nextRecvHeaderKeyLabel = [NSData dataWithBytes:nextRecvHeaderKeyLabelBytes length:sizeof(nextRecvHeaderKeyLabelBytes) - 1];
    char rootKeyLabelBytes[] = "root key";
    NSData *rootKeyLabel = [NSData dataWithBytes:rootKeyLabelBytes length:sizeof(rootKeyLabelBytes) - 1];
    char sendHeaderKeyLabelBytes[] = "next send header key";
    NSData *sendHeaderKeyLabel = [NSData dataWithBytes:sendHeaderKeyLabelBytes length:sizeof(sendHeaderKeyLabelBytes) - 1];
    
    [[contact ratchet] setRootKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: rootKeyLabel]];
    if (amAlice == -1) {
        [[contact ratchet] setRxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: headerKeyLabel]];
        [[contact ratchet] setNextTxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: sendHeaderKeyLabel]];
        [[contact ratchet] setNextRxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: nextRecvHeaderKeyLabel]];
        [[contact ratchet] setRxChainKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: chainKeyLabel]];
        [[contact ratchet] setRxRatchetPublic: [keyX dh1]];
    } else {
        [[contact ratchet] setTxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: headerKeyLabel]];
        [[contact ratchet] setNextRxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: sendHeaderKeyLabel]];
        [[contact ratchet] setNextTxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: nextRecvHeaderKeyLabel]];
        [[contact ratchet] setTxChainKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: chainKeyLabel]];
        [[contact ratchet] setTxRatchetPrivate: [[contact ratchet] kxPrivate1]];
    }
    
    [[contact ratchet] setRatchet: (amAlice == -1)];
    [[contact ratchet] setKxPrivate0: nil];
    [[contact ratchet] setKxPrivate1: nil];

    [self showNotificationWithTitle: [contact name] message: NSLocalizedString(@"Key Exchange successful", nil)  andType:TSMessageNotificationTypeSuccess];

    [contact setPending:NO];
}


-(void) revokeContact: (NSString *) contactID {
        SitDContact *contact = [self loadContact:contactID];
        if ([contact revoked]) {
            [self showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: [NSString stringWithFormat:@"%@ %@", [contact name], NSLocalizedString(@"is already revoked", nil) ] andType:TSMessageNotificationTypeWarning];
            return;
        }
        BBSRevocation *revocation = [self.privateBBSKey generateRevocationForMember: contact.theirBBSMemberKey];
        [contact setRevoked:YES];
        
        BBSPrivateKey *myBBSKey = self.privateBBSKey;
        [[myBBSKey group] updateWithRevocation: revocation];
        [self setPrivateBBSKey: myBBSKey];
        
        for (NSString *contactIDToUpdate in contacts) {
            if (![contactID isEqualToString:contactIDToUpdate]) {
                SitDContact *contactToUpdate = [self loadContact:contactIDToUpdate];
                BBSMemberKey *theirKey = contactToUpdate.theirBBSMemberKey;
                [theirKey updateWithRevocation:revocation];
                [contactToUpdate setTheirBBSMemberKey:theirKey];
            }
        }
        
        SignedRevocation_Revocation *rev = [[SignedRevocation_Revocation alloc] init];
        [rev setGeneration: self.generation];
        [rev setRevocation: [revocation marshal]];
        
        FGIntBase newGeneration = self.generation + 1;
        [self setGeneration: newGeneration];
        
        char revocationSignaturePrefixBytes[] = "revocation";
        NSMutableData *toSignRevocation = [NSMutableData dataWithBytes:revocationSignaturePrefixBytes length: sizeof(revocationSignaturePrefixBytes)];
        [toSignRevocation appendData: [rev data]];
        NSData *signature = [self.privateEd25519Key signNSData: toSignRevocation];
        
        SignedRevocation *signedRevocation = [[SignedRevocation alloc] init];
        [signedRevocation setSignature:signature];
        [signedRevocation setRevocation: rev];

        Request *req = [[Request alloc] init];
        [req setRevocation: signedRevocation];

        SitDQueued *msg = [[SitDQueued alloc] init];
        [msg setMessage:[req data]];
        [msg setAnonymous: NO];
        [msg setServerHost: self.serverAddress];
        [msg setServerIdentity: self.serverId];
        [msg setContactID: contactID];
        [msg setTag: REVOCATIONPROTO];
        
        [self pushToQueue: msg];
        
        [self transact];
}

-(void) processFetched: (Fetched *) fetched {
//    NSLog(@"kitty %@", [FGIntXtra SHA256:fetched.message]);
//    NSLog(@"kitty %@", [[self.privateBBSKey group] marshal]);
    
    if (![BBSsig verifySignature:fetched.groupSignature ofDigest: [FGIntXtra SHA256:fetched.message] withGroupKey: self.privateBBSKey.group]) {
        NSLog(@"Group signature invalid");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Group signature invalid", nil) andType:TSMessageNotificationTypeError];
        return;
    }
    
    NSData *openedSignature = [BBSsig openSignature: fetched.groupSignature withPrivateKey: self.privateBBSKey];
    SitDContact *contact;
    for (NSString *contactID in self.contacts) {
        contact = [self loadContact: contactID];
        if ([openedSignature isEqualToData: [[contact.theirBBSMemberKey a] marshal]]) {
            break;
        }
        contact = nil;
    }
    if (contact == nil) {
        NSLog(@"unknown contact");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Unknown contact", nil) andType:TSMessageNotificationTypeError];
        return;
    }
    NSData *tmpPlaintext = [contact.ratchet decrypt: fetched.message];
    if (tmpPlaintext == nil) {
        NSLog(@"decryption failed");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Message decryption failed", nil) andType:TSMessageNotificationTypeError];
        return;
    }
    FGIntBase* array = (FGIntBase *) [tmpPlaintext bytes];
    FGIntBase len = array[0];
    if (len > [tmpPlaintext length] - 4) {
        NSLog(@"wrong plaintext length");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Wrong plaintext length", nil) andType:TSMessageNotificationTypeError];
        return;
    }
    NSData *plaintext = [tmpPlaintext subdataWithRange:NSMakeRange(4, len)];
    NSError *error;
    Message *message = [[Message alloc] initWithData: plaintext error: &error];
    if (error) {
        NSLog(@"Message parsing failed: %@", error);
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: [NSString stringWithFormat:NSLocalizedString(@"Message parsing failed %@", nil), error] andType:TSMessageNotificationTypeError];
        return;
    }

    if (message.bodyEncoding == Message_Encoding_Gzip) {
        NSLog(@"Message decoding failed");
        [self showNotificationWithTitle:NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"GZIPed Message parsing not implemented yet", nil) andType:TSMessageNotificationTypeError];
        return;
    }

//    NSLog(@"processFeteched: storemessage");
    
    [contact setKeyExchangeData: nil];
    
    SitDMessageContent *storedMessage = [[SitDMessageContent alloc] init];
    [storedMessage setTimestamp: [NSDate dateWithTimeIntervalSince1970: message.time]];
    [storedMessage setEncodedBody: message.body];
    [storedMessage setMessageID: message.id_p];
    [storedMessage setContactID: contact.iD];
    [storedMessage setContactName: contact.name];
    [storedMessage setOutgoing: NO];
    [storedMessage setLocalID: [self newRandomId]];
    
    [self storeMessage: storedMessage];
    
    [self showNotificationWithTitle:NSLocalizedString(@"New Message", nil) message: [NSString stringWithFormat:NSLocalizedString(@"from %@", nil), [contact name]] andMessage: storedMessage ];
    
}

-(void) storeMessage: (SitDMessageContent *) message {
//    NSLog(@"storing message");
    FGIntOverflow msgID = [message localID];
    SitDMessage *messageSummary = [message summary];
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        NSLog(@"storing message overview");
        [transaction setObject: messageSummary forKey: [FGIntXtra dataToHexString: [NSData dataWithBytes:&msgID length: 8]] inCollection: (message.outgoing?SitDOutboxOverviewKey:SitDInboxOverviewKey)];
    }];
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        NSLog(@"storing messagecontent");
        [transaction setObject: message forKey: [FGIntXtra dataToHexString: [NSData dataWithBytes:&msgID length: 8]] inCollection: (message.outgoing?SitDOutboxKey:SitDInboxKey)];
    }];
//    NSLog(@"storing message finished");
}



-(void) showNotificationWithTitle: (NSString *) title message: (NSString *) message andMessage: (SitDMessageContent *) sitdMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [TSMessage showNotificationInViewController:self.currentVC
                                              title: title
                                           subtitle: message
                                              image:nil
                                            type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:^{
                                                [TSMessage dismissActiveNotification];
                                               MessageViewController *vc = [[MessageViewController alloc] init];
                                               [vc setAccount: self];
                                               [vc setSitdMesssage: sitdMessage];
                                               
                                               [self markReadDelivered: sitdMessage.localID];
       
                                                DetailNavigationController *detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:vc];
                                                vc.navigationItem.leftBarButtonItem = self.currentVC.splitViewController.displayModeButtonItem;
                                                vc.navigationItem.leftItemsSupplementBackButton = YES;
                                               [self.currentVC showDetailViewController: detailNavigationController sender:self];
                                           }

                                     buttonTitle:NSLocalizedString(@"dismiss", nil)
                                     buttonCallback:^{
                                         [TSMessage dismissActiveNotification];
                                     }
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
        
    });
}


-(void) registerMessagesListExtension {
    if ([[self.database registeredExtensions] objectForKey: @"messagesList"]) {
//        NSLog(@"already registered");
        return;
    }
    
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(YapDatabaseReadTransaction *transaction, NSString *collection, NSString *key, id object) {
        if ([collection isEqualToString: SitDInboxOverviewKey] || [collection isEqualToString:SitDOutboxOverviewKey]) {
            if ([collection isEqualToString: SitDInboxOverviewKey]) {
                if ([object isKindOfClass:[SitDMessage class]]) {
                    if ([object unread]) {
                        return NSLocalizedString(@"unread", nil);
                    }
                    return [object contactName];
                }
            }
            if ([collection isEqualToString: SitDOutboxOverviewKey]) {
                if ([object isKindOfClass:[SitDMessage class]]) {
                    if ([object unread]) {
                        return NSLocalizedString(@"undelivered", nil);
                    }
                    return [object contactName];
                }
            }
        }
        return nil; // exclude from view
    }];
    YapDatabaseViewSorting *sorting =  [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        return [[((SitDMessage *) object2) timestamp] compare: [((SitDMessage *) object1) timestamp]];
//        if ([group isEqualToString:@"unread"]) {
//            return NSOrderedDescending;
//        }
//        if ([object1 isKindOfClass:[SitDMessage class]] && [object2 isKindOfClass:[SitDMessage class]]) {
//            return [[((SitDMessage *) object1) time] compare: [((SitDMessage *) object2) time]];
//        }
        return NSOrderedAscending;
    }];
    YapDatabaseAutoView *messagesListView = [[YapDatabaseAutoView alloc] initWithGrouping:grouping sorting:sorting];
    [database registerExtension:messagesListView withName:@"messagesList"];
}

-(void) markReadDelivered: (uint64_t) localID {
    NSString *msgIdStr = [FGIntXtra dataToHexString: [NSData dataWithBytes:&localID length: 8]];
    NSString *collection = SitDInboxOverviewKey;
    __block SitDMessage *message = nil;
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        message = [transaction objectForKey: msgIdStr inCollection: SitDInboxOverviewKey];
    }];
    if (message == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            message = [transaction objectForKey: msgIdStr inCollection: SitDOutboxOverviewKey];
        }];
        collection = SitDOutboxOverviewKey;
    }
    if (message) {
        [message setUnread:NO];
        [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction setObject: message forKey: msgIdStr inCollection: collection];
        }];
    }
}
-(void) removeMessage: (uint64_t) msgId {
    NSString *msgIdStr = [FGIntXtra dataToHexString: [NSData dataWithBytes:&msgId length: 8]];
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeObjectForKey: msgIdStr inCollection: SitDOutboxOverviewKey];
        [transaction removeObjectForKey: msgIdStr inCollection: SitDOutboxKey];
        [transaction removeObjectForKey: msgIdStr inCollection: SitDInboxOverviewKey];
        [transaction removeObjectForKey: msgIdStr inCollection: SitDInboxKey];
    }];
    [self removeRandomID: msgId];
}
-(void) removeMessagesForContact: (NSString *) contactID {
    __block NSMutableArray<NSString *> *inboxKeys = [[NSMutableArray alloc] init];
    __block NSMutableArray<NSString *> *outboxKeys = [[NSMutableArray alloc] init];
    
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [transaction enumerateKeysInCollection: SitDInboxOverviewKey usingBlock:^(NSString *key, BOOL *stop) {
            SitDMessage *message = [transaction objectForKey:key inCollection:SitDInboxOverviewKey];
            if ([message.contactID isEqualToString:contactID]) {
                [inboxKeys addObject: key];
            }
        }];
        [transaction enumerateKeysInCollection: SitDOutboxOverviewKey usingBlock:^(NSString *key, BOOL *stop) {
            SitDMessage *message = [transaction objectForKey:key inCollection:SitDOutboxOverviewKey];
            if ([message.contactID isEqualToString:contactID]) {
                [outboxKeys addObject: key];
            }
        }];
    }];
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeObjectsForKeys: inboxKeys inCollection:SitDInboxOverviewKey];
        [transaction removeObjectsForKeys: outboxKeys inCollection:SitDOutboxOverviewKey];
        [transaction removeObjectsForKeys: inboxKeys inCollection:SitDInboxKey];
        [transaction removeObjectsForKeys: outboxKeys inCollection:SitDOutboxKey];
    }];

    for (NSString *key in inboxKeys) {
        [self removeRandomIData: [FGIntXtra hexStringToNSData:key]];
    }
    for (NSString *key in outboxKeys) {
        [self removeRandomIData: [FGIntXtra hexStringToNSData:key]];
    }
}



@end





























