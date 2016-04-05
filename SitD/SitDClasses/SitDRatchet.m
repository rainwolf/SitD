//
//  SitDRatchet.m
//  SitD
//
//  Created by rainwolf on 27/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "SitDRatchet.h"
#import "constants.h"
#import "SitDAccount.h"

//@class SitDAccount;

@implementation SitDRatchet
@synthesize databaseConnection;
@synthesize account;
@synthesize iD;
@synthesize myIdentity, myEd25519Public, theirEd25519Public, theirIdentityPublic;
@synthesize rootKey, txHdrKey, rxHdrKey, nextTxHdrKey, nextRxHdrKey, txRatchetPrivate, rxRatchetPublic, txChainKey, rxChainKey;
@synthesize ratchet, v2;
@synthesize kxPrivate0, kxPrivate1;
@synthesize txCount, rxCount, prevTxCount;
@synthesize savedKeys;

-(instancetype) initWithID: (NSString *) idStr myIdentity: (NSData *) myId myEd25519Public: (NSData *) myEd account: (SitDAccount *) acc andDatabaseConnection: (YapDatabaseConnection *) dbConn {
    if (self = [super init]) {
        databaseConnection = dbConn;
        account = acc;
        iD = idStr;
        myIdentity = myId;
        myEd25519Public = myEd;
        
        theirEd25519Public = nil;
        theirIdentityPublic = nil;
        rootKey = nil;
        txHdrKey = nil;
        rxHdrKey = nil;
        nextTxHdrKey = nil;
        nextRxHdrKey = nil;
        txRatchetPrivate = nil;
        rxRatchetPublic = nil;
        txChainKey = nil;
        rxChainKey = nil;
        kxPrivate0 = nil;
        kxPrivate1 = nil;

        ratchet = NO;
        v2 = NO;

        txCount = 0;
        rxCount = 0;
        prevTxCount = 0;
        
        savedKeys = nil;
    }
    return self;
}





-(NSData *) theirEd25519Public {
    if (theirEd25519Public == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            theirEd25519Public = [transaction objectForKey:@"theirEd25519Public" inCollection: iD];
        }];
    }
    return theirEd25519Public;
}
-(void) setTheirEd25519Public:(NSData *)theirEd25519PublicData {
    theirEd25519Public = theirEd25519PublicData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:theirEd25519Public forKey:@"theirEd25519Public" inCollection: iD];
    }];
}
-(NSData *) theirIdentityPublic {
    if (theirIdentityPublic == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            theirIdentityPublic = [transaction objectForKey:@"theirIdentityPublic" inCollection: iD];
        }];
    }
    return theirIdentityPublic;
}
-(void) setTheirIdentityPublic:(NSData *)theirIdentityPublicData {
    theirIdentityPublic = theirIdentityPublicData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:theirIdentityPublic forKey:@"theirIdentityPublic" inCollection: iD];
    }];
}

-(NSData *) rootKey {
    if (rootKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            rootKey = [transaction objectForKey:@"rootKey" inCollection: iD];
        }];
    }
    return rootKey;
}
-(void) setRootKey:(NSData *)rootKeyData {
    rootKey = rootKeyData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:rootKeyData forKey:@"rootKey" inCollection: iD];
    }];
}

-(NSData *) txHdrKey {
    if (txHdrKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            txHdrKey = [transaction objectForKey:@"txHdrKey" inCollection: iD];
        }];
    }
    return txHdrKey;
}
-(void) setTxHdrKey:(NSData *)txHdrKeyData {
    txHdrKey = txHdrKeyData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:txHdrKey forKey:@"txHdrKey" inCollection: iD];
    }];
}
-(NSData *) rxHdrKey {
    if (rxHdrKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            rxHdrKey = [transaction objectForKey:@"rxHdrKey" inCollection: iD];
        }];
    }
    return rxHdrKey;
}
-(void) setRxHdrKey:(NSData *)rxHdrKeyData {
    rxHdrKey = rxHdrKeyData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:rxHdrKey forKey:@"rxHdrKey" inCollection: iD];
    }];
}
-(NSData *) nextTxHdrKey {
    if (nextTxHdrKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            nextTxHdrKey = [transaction objectForKey:@"nextTxHdrKey" inCollection: iD];
        }];
    }
    return nextTxHdrKey;
}
-(void) setNextTxHdrKey:(NSData *)nextTxHdrKeyData {
    nextTxHdrKey = nextTxHdrKeyData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:nextTxHdrKey forKey:@"nextTxHdrKey" inCollection: iD];
    }];
}
-(NSData *) nextRxHdrKey {
    if (nextRxHdrKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            nextRxHdrKey = [transaction objectForKey:@"nextRxHdrKey" inCollection: iD];
        }];
    }
    return nextRxHdrKey;
}
-(void) setNextRxHdrKey:(NSData *)nextRxHdrKeyData {
    nextRxHdrKey = nextRxHdrKeyData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:nextRxHdrKey forKey:@"nextRxHdrKey" inCollection: iD];
    }];
}
-(NSData *) txRatchetPrivate {
    if (txRatchetPrivate == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            txRatchetPrivate = [transaction objectForKey:@"txRatchetPrivate" inCollection: iD];
        }];
    }
    return txRatchetPrivate;
}
-(void) setTxRatchetPrivate:(NSData *)txRatchetPrivateData {
    txRatchetPrivate = txRatchetPrivateData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:txRatchetPrivate forKey:@"txRatchetPrivate" inCollection: iD];
    }];
}
-(NSData *) rxRatchetPublic {
    if (rxRatchetPublic == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            rxRatchetPublic = [transaction objectForKey:@"rxRatchetPublic" inCollection: iD];
        }];
    }
    return rxRatchetPublic;
}
-(void) setRxRatchetPublic:(NSData *)rxRatchetPublicData {
    rxRatchetPublic = rxRatchetPublicData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:rxRatchetPublic forKey:@"rxRatchetPublic" inCollection: iD];
    }];
}

-(NSData *) txChainKey {
    if (txChainKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            txChainKey = [transaction objectForKey:@"txChainKey" inCollection: iD];
        }];
    }
    return txChainKey;
}
-(void) setTxChainKey:(NSData *)txChainKeyData {
    txChainKey = txChainKeyData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:txChainKey forKey:@"txChainKey" inCollection: iD];
    }];
}
-(NSData *) rxChainKey {
    if (rxChainKey == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            rxChainKey = [transaction objectForKey:@"rxChainKey" inCollection: iD];
        }];
    }
    return rxChainKey;
}
-(void) setRxChainKey:(NSData *)rxChainKeyData {
    rxChainKey = rxChainKeyData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:rxChainKey forKey:@"rxChainKey" inCollection: iD];
    }];
}



-(BOOL) ratchet {
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *result = [transaction objectForKey:@"ratchet" inCollection: iD];
        ratchet = NO;
        if (result) {
            ratchet = [result isEqualToString:@"yes"];
        }
    }];
    return ratchet;
}
-(void) setRatchet:(BOOL)ratchetBOOL {
    ratchet = ratchetBOOL;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSString *boolStr;
        if (ratchet) {
            boolStr = @"yes";
        } else {
            boolStr = @"no";
        }
        [transaction setObject:boolStr forKey:@"ratchet" inCollection: iD];
    }];
}
-(BOOL) v2 {
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *result = [transaction objectForKey:@"v2" inCollection: iD];
        v2 = NO;
        if (result) {
            v2 = [result isEqualToString:@"yes"];
        }
    }];
    return v2;
}
-(void) setV2:(BOOL)v2BOOL {
    v2 = v2BOOL;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSString *boolStr;
        if (v2) {
            boolStr = @"yes";
        } else {
            boolStr = @"no";
        }
        [transaction setObject:boolStr forKey:@"v2" inCollection: iD];
    }];
}



-(NSData *) kxPrivate0 {
    if (kxPrivate0 == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            kxPrivate0 = [transaction objectForKey:@"kxPrivate0" inCollection: iD];
        }];
    }
    return kxPrivate0;
}
-(void) setKxPrivate0:(NSData *)kxPrivate0Data {
    kxPrivate0 = kxPrivate0Data;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        if (kxPrivate0) {
            [transaction setObject:kxPrivate0 forKey:@"kxPrivate0" inCollection: iD];
        } else {
            [transaction removeObjectForKey: @"kxPrivate0" inCollection: iD];
        }
    }];
}
-(NSData *) kxPrivate1 {
    if (kxPrivate1 == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            kxPrivate1 = [transaction objectForKey:@"kxPrivate1" inCollection: iD];
        }];
    }
    return kxPrivate1;
}
-(void) setKxPrivate1:(NSData *)kxPrivate1Data {
    kxPrivate1 = kxPrivate1Data;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        if (kxPrivate1) {
            [transaction setObject:kxPrivate1 forKey:@"kxPrivate1" inCollection: iD];
        } else {
            [transaction removeObjectForKey: @"kxPrivate1" inCollection: iD];
        }
    }];
}


-(void) setTxCount:(FGIntBase)txCountInt {
    txCount = txCountInt;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: [NSNumber numberWithUnsignedInt:txCount] forKey:@"txCount" inCollection:iD];
    }];
}
-(FGIntBase) txCount {
    if (txCount == 0) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            txCount = [[transaction objectForKey:@"txCount" inCollection: iD] unsignedIntValue];
        }];
    }
    return txCount;
}
-(void) setRxCount:(FGIntBase)rxCountInt {
    rxCount = rxCountInt;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: [NSNumber numberWithUnsignedInt:rxCount] forKey:@"rxCount" inCollection:iD];
    }];
}
-(FGIntBase) rxCount {
    if (rxCount == 0) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            rxCount = [[transaction objectForKey:@"rxCount" inCollection: iD] unsignedIntValue];
        }];
    }
    return rxCount;
}
-(void) setPrevTxCount:(FGIntBase) prevTxCountInt {
    prevTxCount = prevTxCountInt;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: [NSNumber numberWithUnsignedInt:prevTxCount] forKey:@"prevTxCount" inCollection:iD];
    }];
}
-(FGIntBase) prevTxCount {
    if (prevTxCount == 0) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            prevTxCount = [[transaction objectForKey:@"prevTxCount" inCollection: iD] unsignedIntValue];
        }];
    }
    return prevTxCount;
}


-(NSDictionary<NSData *, NSDictionary *> *) savedKeys {
    if (savedKeys == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            savedKeys = [transaction objectForKey:@"savedKeys" inCollection: iD];
        }];
    }
    return savedKeys;
}
-(void) setSavedKeys:(NSDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *)savedKeysDict {
    savedKeys = savedKeysDict;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        if (savedKeys) {
            [transaction setObject:savedKeys forKey:@"savedKeys" inCollection: iD];
        } else {
            [transaction removeObjectForKey: @"savedKeys" inCollection: iD];
        }
    }];
}



-(NSData *) encrypt: (NSData *) plaintext {
//    char headerKeyLabelBytes[] = "header key";
//    NSData *headerKeyLabel = [NSData dataWithBytes:headerKeyLabelBytes length:strlen(headerKeyLabelBytes)];

    
    if (self.ratchet) {
        [self setTxRatchetPrivate: [NaClPacket newCurve25519PrivateKey]];
        [self setTxHdrKey: self.nextTxHdrKey];
        
        char rootKeyUpdateLabelBytes[] = "root key update";
        NSData *rootKeyUpdateLabel = [NSData dataWithBytes:rootKeyUpdateLabelBytes length: sizeof(rootKeyUpdateLabelBytes) - 1];
        NSData *sharedKey, *keyMaterial;
        sharedKey = [NaClPacket curve25519Point: self.rxRatchetPublic times: self.txRatchetPrivate];
        NSMutableData *hashData = [[NSMutableData alloc] initWithData: rootKeyUpdateLabel];
        [hashData appendData: self.rootKey];
        [hashData appendData: sharedKey];
        
        char sendHeaderKeyLabelBytes[] = "next send header key";
        char chainKeyLabelBytes[] = "chain key";
        NSData *sendHeaderKeyLabel = [NSData dataWithBytes:sendHeaderKeyLabelBytes length:sizeof(sendHeaderKeyLabelBytes) - 1];
        NSData *chainKeyLabel = [NSData dataWithBytes:chainKeyLabelBytes length: sizeof(chainKeyLabelBytes) - 1];
        if (self.v2) {
            keyMaterial = [FGIntXtra SHA256: hashData];
            char rootKeyLabelBytes[] = "root key";
            NSData *rootKeyLabel = [NSData dataWithBytes:rootKeyLabelBytes length:sizeof(rootKeyLabelBytes) - 1];
            [self setRootKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: rootKeyLabel]];
            [self setNextTxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: sendHeaderKeyLabel]];
            [self setTxChainKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData: chainKeyLabel]];
        } else {
            [self setRootKey: [FGIntXtra SHA256: hashData]];
            [self setNextTxHdrKey: [FGIntXtra SHA256HMACForKey: self.rootKey AndData: sendHeaderKeyLabel]];
            [self setTxChainKey: [FGIntXtra SHA256HMACForKey: self.rootKey AndData: chainKeyLabel]];
        }
        
        [self setRatchet: NO];
        
        [self setPrevTxCount: self.txCount];
        [self setTxCount: 0];
    }
    
    char messageKeyLabelBytes[] = "message key";
    NSData *messageKeyLabel = [NSData dataWithBytes:messageKeyLabelBytes length: sizeof(messageKeyLabelBytes) - 1];
    NSData *messageKey = [FGIntXtra SHA256HMACForKey: self.txChainKey AndData:messageKeyLabel];
    char chainKeyStepLabelBytes[] = "chain key step";
    NSData *chainKeyStepLabel = [NSData dataWithBytes:chainKeyStepLabelBytes length: sizeof(chainKeyStepLabelBytes) - 1];
    [self setTxChainKey: [FGIntXtra SHA256HMACForKey: self.txChainKey AndData: chainKeyStepLabel]];
    
    NSData *txRatchetPublic = [NaClPacket curve25519BasePointTimes: self.txRatchetPrivate];
    NSData *headerNonce = [FGIntXtra randomDataOfLength: 24] , *messageNonce = [FGIntXtra randomDataOfLength: 24];
    
    NSMutableData *header = [[NSMutableData alloc] init];
    FGIntBase tmpInt = self.txCount;
    [header appendBytes: &tmpInt length: 4];
    tmpInt = self.prevTxCount;
    [header appendBytes: &tmpInt length: 4];
    [header appendData: txRatchetPublic];
    [header appendData: messageNonce];
    
    NSMutableData *result = [[NSMutableData alloc] initWithData: headerNonce];
    NaClPacket *nacl = [[NaClPacket alloc] initWithMessage: header key: self.txHdrKey andNonce: headerNonce];
    [result appendData: [nacl packXsalsa20Poly1305]];
    tmpInt = self.txCount;
    tmpInt += 1;
    [self setTxCount: tmpInt];
    
    nacl = [[NaClPacket alloc] initWithMessage: plaintext key: messageKey andNonce: messageNonce];
    [result appendData: [nacl packXsalsa20Poly1305]];
    
    return result;
}


-(NSData *) trySavedKeys: (NSData *) ciphertext {
    if ([ciphertext length] < SEALEDHEADERSIZE) {
        NSLog(@" ciphertext is too short");
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Sealed message is too short", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    
    NSData *headerKey = nil, *messageNum = nil, *message = nil;
    NSDictionary<NSData *, NSData *> *messageKeys = nil;
    NSData *headerNonce = [ciphertext subdataWithRange: NSMakeRange(0, 24)];
    NSData *sealedHeader = [ciphertext subdataWithRange: NSMakeRange(24, SEALEDHEADERSIZE - 24)];
    NaClPacket *nacl = nil;

    for (headerKey in self.savedKeys) {
        nacl = [[NaClPacket alloc] initWithMessage:sealedHeader key: self.rxHdrKey andNonce: headerNonce];
        NSData *header = [nacl unpackXsalsa20Poly1305];
        if (header == nil || [header length] != HEADERSIZE) {
            continue;
        }
        messageNum = [header subdataWithRange: NSMakeRange(0, 4)];
        messageKeys = [self.savedKeys objectForKey: headerKey];
        NSData *messageKey = [messageKeys objectForKey: messageNum];
        if (messageKey == nil) {
            return nil;
        }
        
        NSData *sealedMessage = [ciphertext subdataWithRange: NSMakeRange(SEALEDHEADERSIZE, [ciphertext length] - (SEALEDHEADERSIZE))];
        NSData *nonce = [header subdataWithRange:NSMakeRange(NONCEINHEADEROFFSET, 24)];
        nacl = [[NaClPacket alloc] initWithMessage:sealedMessage key: messageKey andNonce: nonce];
        
        message = [nacl unpackXsalsa20Poly1305];
        if (message == nil) {
            [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Message is corrupted", nil) andType:TSMessageNotificationTypeError];
            return nil;
        } else {
            break;
        }
        
        message = nil;
        messageNum = nil;
    }
    
    if (message && messageNum) {
        NSMutableDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *mutableSavedKeys = [self.savedKeys mutableCopy];
        NSMutableDictionary<NSData *, NSData *> *mutableMessageKeys = [messageKeys mutableCopy];
        [mutableMessageKeys removeObjectForKey:messageNum];
        if ([mutableMessageKeys count] == 0) {
            [mutableSavedKeys removeObjectForKey:headerKey];
        } else {
            [mutableSavedKeys setObject: mutableMessageKeys forKey:headerKey];
        }
        [self setSavedKeys: mutableSavedKeys];
    }

    return message;
}


-(NSDictionary<NSString *, id> *) saveHeaderKeys: (NSData *) headerKey receiveChainKey: (NSData *) receiveChainKey withMessageNum: (FGIntBase) msgNum andRxCount: (FGIntBase) receivedCount {
    if (msgNum < receivedCount) {
        NSLog(@" duplicate message or delayed too long");
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Duplicate message or delay too long", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    
    FGIntBase missingMsgs = msgNum - receivedCount;
    if (missingMsgs > MAXMISSINGMESSAGES) {
        NSLog(@" Message exceeds limit");
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Message exceedsd reordering limit", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    
    NSMutableDictionary<NSData *, NSData *> *messageKeys = nil;
    if (missingMsgs > 0) {
        messageKeys = [[NSMutableDictionary alloc] init];
    }
    
    char messageKeyLabelBytes[] = "message key";
    NSData *messageKeyLabel = [NSData dataWithBytes:messageKeyLabelBytes length: sizeof(messageKeyLabelBytes) - 1];
    char chainKeyStepLabelBytes[] = "chain key step";
    NSData *chainKeyStepLabel = [NSData dataWithBytes:chainKeyStepLabelBytes length: sizeof(chainKeyStepLabelBytes) - 1];
    NSData *messageKey = nil;
    NSData *provisionalChainKey = [receiveChainKey copy];
    
    for (FGIntBase i = receivedCount; i <= msgNum; ++i) {
        NSData *hmacKey = provisionalChainKey;
        messageKey = [FGIntXtra SHA256HMACForKey: hmacKey AndData: messageKeyLabel];
        provisionalChainKey = [FGIntXtra SHA256HMACForKey: hmacKey AndData: chainKeyStepLabel];
        if (i < msgNum) {
            [messageKeys setObject: messageKey forKey: [NSData dataWithBytes:&i length:4]];
        }
    }
    NSMutableDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *savedKeysLocal = nil;
    if (messageKeys) {
        savedKeysLocal = [[NSMutableDictionary alloc] init];
        [savedKeysLocal setObject:messageKeys forKey: headerKey];
    }
    
    NSMutableDictionary<NSString *, id> *result = [[NSMutableDictionary alloc] init];
    [result setObject: provisionalChainKey forKey: @"provisionalChainKey"];
    if (messageKey) {
        [result setObject: messageKey forKey: @"messageKey"];
    }
    if (savedKeysLocal) {
        [result setObject: savedKeysLocal forKey: @"savedKeys"];
    }
    
    return result;
}

-(void) mergeSavedKeys: (NSDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *) mergeKeys {
    if (mergeKeys == nil) {
        return;
    }
    if (self.savedKeys) {
        NSMutableDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *mutableSavedKeys = [self.savedKeys mutableCopy];
        for (NSData *mergeHdrKey in mergeKeys) {
            if ([self.savedKeys objectForKey: mergeHdrKey]) {
                NSDictionary<NSData *, NSData *> *mergeMsgKeys = [mergeKeys objectForKey: mergeHdrKey];
                NSMutableDictionary<NSData *, NSData *> *mutableMsgKeys = [[self.savedKeys objectForKey: mergeHdrKey] mutableCopy];
                for (NSData *msgNum in mergeMsgKeys) {
                    [mutableMsgKeys setObject: [mergeMsgKeys objectForKey:msgNum] forKey: msgNum];
                }
                [mutableSavedKeys setObject: mutableMsgKeys forKey: mergeHdrKey];
            } else {
                [mutableSavedKeys setObject: [mergeKeys objectForKey:mergeHdrKey] forKey: mergeHdrKey];
            }
        }
        [self setSavedKeys: mutableSavedKeys];
    } else {
        [self setSavedKeys: mergeKeys];
    }
}

-(NSData *) decrypt: (NSData *) ciphertext {
    if ([ciphertext length] < SEALEDHEADERSIZE) {
        NSLog(@" ciphertext is too short");
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Sealed message is too short", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    NSData *message = [self trySavedKeys: ciphertext];
    if (message) {
        return message;
    }
    
    
    NSData *headerNonce = [ciphertext subdataWithRange: NSMakeRange(0, 24)];
    NSData *sealedHeader = [ciphertext subdataWithRange: NSMakeRange(24, SEALEDHEADERSIZE - 24)];
    NaClPacket *nacl = nil;
    NSData *header = nil;
    if (self.rxHdrKey != nil) {
        nacl = [[NaClPacket alloc] initWithMessage:sealedHeader key: self.rxHdrKey andNonce: headerNonce];
        header = [nacl unpackXsalsa20Poly1305];
    }
    
    if (header) {
        if ([header length] != HEADERSIZE) {
            NSLog(@" header length wrong");
            [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Wrong header length", nil) andType:TSMessageNotificationTypeError];
            return nil;
        }
        FGIntBase* array = (FGIntBase *) [header bytes];
        FGIntBase messageNum = array[0];
        NSDictionary<NSString *, id> *saveKeysResult = [self saveHeaderKeys: self.rxHdrKey receiveChainKey:self.rxChainKey withMessageNum: messageNum andRxCount:self.rxCount];
        if (saveKeysResult == nil) {
            return nil;
        }
        NSData *sealedMessage = [ciphertext subdataWithRange: NSMakeRange(SEALEDHEADERSIZE, [ciphertext length] - (SEALEDHEADERSIZE))];
        NSData *nonce = [header subdataWithRange:NSMakeRange(NONCEINHEADEROFFSET, 24)];
        nacl = [[NaClPacket alloc] initWithMessage:sealedMessage key: [saveKeysResult objectForKey:@"messageKey"] andNonce: nonce];
        
        message = [nacl unpackXsalsa20Poly1305];
        if (message == nil) {
            [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Message is corrupt", nil) andType:TSMessageNotificationTypeError];
            return nil;
        }
        
        [self setRxChainKey: [saveKeysResult objectForKey: @"provisionalChainKey"]];
        [self mergeSavedKeys: [saveKeysResult objectForKey: @"savedKeys"]];
        [self setRxCount: messageNum + 1];
        
        return message;
    }
    
    nacl = [[NaClPacket alloc] initWithMessage:sealedHeader key: self.nextRxHdrKey andNonce: headerNonce];
    header = [nacl unpackXsalsa20Poly1305];
    if (header == nil) {
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Message is corrupt", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    if ([header length] != HEADERSIZE) {
        NSLog(@" header length wrong");
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Wrong header length", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    if (self.ratchet) {
        NSLog(@" received message encrypted to next header key without ratchet flag set");
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Ratchet flag error", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    
    FGIntBase* array = (FGIntBase *) [header bytes];
    FGIntBase messageNum = array[0];
    FGIntBase previousMessageCount = array[1];
    
    NSDictionary<NSString *, id> *saveKeysResult = [self saveHeaderKeys: self.rxHdrKey receiveChainKey:self.rxChainKey withMessageNum: previousMessageCount andRxCount:self.rxCount];
    if (saveKeysResult == nil) {
        return nil;
    }
    
    NSData *dhPublic, *sharedKey, *localRootKey, *chainKey, *keyMaterial;
    dhPublic = [header subdataWithRange:NSMakeRange(8, 32)];
    sharedKey = [NaClPacket curve25519Point: dhPublic times: self.txRatchetPrivate];
    
    NSMutableData *hashData = [[NSMutableData alloc] init];
    char rootKeyUpdateLabelBytes[] = "root key update";
    NSData *rootKeyUpdateLabel = [NSData dataWithBytes:rootKeyUpdateLabelBytes length: sizeof(rootKeyUpdateLabelBytes) - 1];
    [hashData appendData: rootKeyUpdateLabel];
    [hashData appendData: self.rootKey];
    [hashData appendData: sharedKey];
    
    keyMaterial = [FGIntXtra SHA256: hashData];
    
    if (self.v2) {
        char rootKeyLabelBytes[] = "root key";
        NSData *rootKeyLabel = [NSData dataWithBytes:rootKeyLabelBytes length:sizeof(rootKeyLabelBytes) - 1];
        localRootKey = [FGIntXtra SHA256HMACForKey: keyMaterial AndData: rootKeyLabel];
    } else {
        localRootKey = keyMaterial;
    }
    char chainKeyLabelBytes[] = "chain key";
    NSData *chainKeyLabel = [NSData dataWithBytes:chainKeyLabelBytes length: sizeof(chainKeyLabelBytes) - 1];
    chainKey = [FGIntXtra SHA256HMACForKey: keyMaterial AndData: chainKeyLabel];
    
    NSDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *oldSavedKeys = [saveKeysResult objectForKey: @"savedKeys"];
    saveKeysResult = [self saveHeaderKeys: self.nextRxHdrKey receiveChainKey: chainKey withMessageNum: messageNum andRxCount: 0];
    if (saveKeysResult == nil) {
        return nil;
    }
    
    NSData *sealedMessage = [ciphertext subdataWithRange: NSMakeRange(SEALEDHEADERSIZE, [ciphertext length] - (SEALEDHEADERSIZE))];
    NSData *nonce = [header subdataWithRange:NSMakeRange(NONCEINHEADEROFFSET, 24)];
    nacl = [[NaClPacket alloc] initWithMessage:sealedMessage key: [saveKeysResult objectForKey:@"messageKey"] andNonce: nonce];
    
    message = [nacl unpackXsalsa20Poly1305];
    if (message == nil) {
        [account showNotificationWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"Message is corrupt", nil) andType:TSMessageNotificationTypeError];
        return nil;
    }
    
    [self setRootKey: localRootKey];
    [self setRxChainKey: [saveKeysResult objectForKey: @"provisionalChainKey"]];
    [self setRxHdrKey: self.nextRxHdrKey];
    char sendHeaderKeyLabelBytes[] = "next send header key";
    NSData *sendHeaderKeyLabel = [NSData dataWithBytes:sendHeaderKeyLabelBytes length:sizeof(sendHeaderKeyLabelBytes) - 1];
    [self setNextRxHdrKey: [FGIntXtra SHA256HMACForKey: keyMaterial AndData:sendHeaderKeyLabel]];
    [self setTxRatchetPrivate: nil];
    [self setRxRatchetPublic: dhPublic];
    [self setRxCount: messageNum + 1];
    
    [self mergeSavedKeys: oldSavedKeys];
    [self mergeSavedKeys: [saveKeysResult objectForKey: @"savedKeys"]];
    [self setRatchet: YES];
    
    return message;
}


@end




















