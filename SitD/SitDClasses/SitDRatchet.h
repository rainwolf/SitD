//
//  SitDRatchet.h
//  SitD
//
//  Created by rainwolf on 27/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YapDatabase/YapDatabase.h>
#import "FGIntObjCSitD.h"

@class SitDAccount;

@interface SitDRatchet : NSObject {
    __weak YapDatabaseConnection *databaseConnection;
    __weak SitDAccount *account;
    
    NSString *iD;

    NSData *myIdentity, *myEd25519Public, *theirEd25519Public, *theirIdentityPublic;
    NSData *rootKey, *txHdrKey, *rxHdrKey, *nextTxHdrKey, *nextRxHdrKey, *txRatchetPrivate, *rxRatchetPublic, *txChainKey, *rxChainKey;
    BOOL ratchet, v2;
    NSData *kxPrivate0, *kxPrivate1;
    
    FGIntBase txCount, rxCount, prevTxCount;
    
    NSDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *savedKeys;
}
@property(weak, nonatomic, readwrite) YapDatabaseConnection *databaseConnection;
@property(weak, nonatomic, readwrite) SitDAccount *account;

@property(nonatomic, retain, readwrite, setter=setID:, getter=iD) NSString *iD;

@property(nonatomic, retain, readwrite, setter=setMyIdentity:, getter=myIdentity) NSData *myIdentity;
@property(nonatomic, retain, readwrite, setter=setMyEd25519Public:, getter=myEd25519Public) NSData *myEd25519Public;
@property(nonatomic, retain, readwrite, setter=setTheirEd25519Public:, getter=theirEd25519Public) NSData *theirEd25519Public;
@property(nonatomic, retain, readwrite, setter=setTheirIdentityPublic:, getter=theirIdentityPublic) NSData *theirIdentityPublic;
@property(nonatomic, retain, readwrite, setter=setRootKey:, getter=rootKey) NSData *rootKey;
@property(nonatomic, retain, readwrite, setter=setTxHdrKey:, getter=txHdrKey) NSData *txHdrKey;
@property(nonatomic, retain, readwrite, setter=setRxHdrKey:, getter=rxHdrKey) NSData *rxHdrKey;
@property(nonatomic, retain, readwrite, setter=setNextTxHdrKey:, getter=nextTxHdrKey) NSData *nextTxHdrKey;
@property(nonatomic, retain, readwrite, setter=setNextRxHdrKey:, getter=nextRxHdrKey) NSData *nextRxHdrKey;
@property(nonatomic, retain, readwrite, setter=setTxRatchetPrivate:, getter=txRatchetPrivate) NSData *txRatchetPrivate;
@property(nonatomic, retain, readwrite, setter=setRxRatchetPublic:, getter=rxRatchetPublic) NSData *rxRatchetPublic;
@property(nonatomic, retain, readwrite, setter=setTxChainKey:, getter=txChainKey) NSData *txChainKey;
@property(nonatomic, retain, readwrite, setter=setRxChainKey:, getter=rxChainKey) NSData *rxChainKey;
@property(atomic, assign, readwrite, setter=setRatchet:, getter=ratchet) BOOL ratchet;
@property(atomic, assign, readwrite, setter=setV2:, getter=v2) BOOL v2;
@property(nonatomic, retain, readwrite, setter=setKxPrivate0:, getter=kxPrivate0) NSData *kxPrivate0;
@property(nonatomic, retain, readwrite, setter=setKxPrivate1:, getter=kxPrivate1) NSData *kxPrivate1;
@property(atomic, assign, readwrite, setter=setTxCount:, getter=txCount) FGIntBase txCount;
@property(atomic, assign, readwrite, setter=setRxCount:, getter=rxCount) FGIntBase rxCount;
@property(atomic, assign, readwrite, setter=setPrevTxCount:, getter=prevTxCount) FGIntBase prevTxCount;
@property(nonatomic, retain, readwrite, setter=setSavedKeys:, getter=savedKeys) NSDictionary<NSData *, NSDictionary<NSData *, NSData *> *> *savedKeys;

-(instancetype) initWithID: (NSString *) idStr myIdentity: (NSData *) myId myEd25519Public: (NSData *) myEd account: (SitDAccount *) acc andDatabaseConnection: (YapDatabaseConnection *) dbConn;

-(NSData *) encrypt: (NSData *) plaintext;
-(NSData *) decrypt: (NSData *) ciphertext;


@end
