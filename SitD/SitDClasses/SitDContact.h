//
//  SitDContact.h
//  SitD
//
//  Created by rainwolf on 27/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGIntObjCSitD.h"
@import YapDatabase;
#import "SitDRatchet.h"

@class SitDAccount;

@interface SitDContact : NSObject {
    __weak YapDatabaseConnection *databaseConnection;
    __weak SitDAccount *account;
    
    NSString *iD;
    NSString *name;
    NSDate *timeAdded;
    BOOL pending, revoked, revokedMe;
    NSData *keyExchangeData;
    BBSGroup *myGroup;
    BBSMemberKey *myBBSMemberKey, *theirBBSMemberKey;
    FGIntBase generation;
    NSString *serverAddress, *serverId;
//    NSData *identityPublic, *ed25519Public;
    
    SitDRatchet *ratchet;
}
@property(weak, nonatomic, readwrite) YapDatabaseConnection *databaseConnection;
@property(weak, nonatomic, readwrite) SitDAccount *account;

@property(nonatomic, retain, readwrite) NSString *iD;
//@property(nonatomic, retain, readwrite, setter=setID:, getter=iD) NSString *iD;
@property(nonatomic, retain, readwrite, setter=setName:, getter=name) NSString *name;
@property(nonatomic, retain, readwrite, setter=setTimeAdded:, getter=timeAdded) NSDate *timeAdded;
@property(atomic, readwrite, assign, setter=setPending:, getter=pending) BOOL pending;
@property(atomic, readwrite, assign, setter=setRevoked:, getter=revoked) BOOL revoked;
@property(atomic, readwrite, assign, setter=setRevokedMe:, getter=revokedMe) BOOL revokedMe;
@property(nonatomic, retain, readwrite, setter=setKeyExchangeData:, getter=keyExchangeData) NSData *keyExchangeData;
@property(nonatomic, retain, readwrite) BBSGroup *myGroup;
@property(nonatomic, retain, readwrite, setter=setMyBBSMemberKey:, getter=myBBSMemberKey) BBSMemberKey *myBBSMemberKey;
@property(nonatomic, retain, readwrite, setter=setTheirBBSMemberKey:, getter=theirBBSMemberKey) BBSMemberKey *theirBBSMemberKey;
@property(atomic, readwrite, assign, setter=setGeneration:, getter=generation) FGIntBase generation;
@property(nonatomic, readwrite, retain, setter=setServerAddress:, getter=serverAddress) NSString *serverAddress;
@property(nonatomic, readwrite, retain, setter=setServerId:, getter=serverId) NSString *serverId;
//@property(nonatomic, retain, readwrite, setter=setIdentityPublic:, getter=identityPublic) NSData *identityPublic;
//@property(nonatomic, retain, readwrite, setter=setEd25519Public:, getter=ed25519Public) NSData *ed25519Public;

@property(nonatomic, retain, readwrite) SitDRatchet *ratchet;


-(instancetype) initWithID: (NSString *) idStr myIdentity: (NSData *) myId myEd25519Public: (NSData *) myEd myBBSGroup: (BBSGroup *) bbsGroup account: (SitDAccount *) acc andDatabaseConnection: (YapDatabaseConnection *) dbConn;


@end
