//
//  SitDContact.m
//  SitD
//
//  Created by rainwolf on 27/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "SitDContact.h"

@implementation SitDContact
@synthesize databaseConnection;
@synthesize account;
@synthesize iD;
@synthesize name;
@synthesize timeAdded;
@synthesize pending, revoked, revokedMe;
@synthesize keyExchangeData;
@synthesize myGroup;
@synthesize myBBSMemberKey, theirBBSMemberKey;
@synthesize generation;
@synthesize serverAddress, serverId;
//@synthesize identityPublic, ed25519Public;

@synthesize ratchet;



-(instancetype) initWithID: (NSString *) idStr myIdentity: (NSData *) myId myEd25519Public: (NSData *) myEd myBBSGroup: (BBSGroup *) bbsGroup account: (SitDAccount *) acc andDatabaseConnection: (YapDatabaseConnection *) dbConn {
    if (self = [super init]) {
        databaseConnection = dbConn;
        account = acc;
        iD = idStr;
        name = nil;
        timeAdded= nil;
        pending = YES;
        revoked = NO;
        revokedMe = NO;
        keyExchangeData = nil;
        myGroup = bbsGroup;
        myBBSMemberKey = nil;
        theirBBSMemberKey = nil;
        serverAddress = nil;
        serverId = nil;
//        identityPublic = nil;
//        ed25519Public = nil;
        
        ratchet = [[SitDRatchet alloc] initWithID:iD myIdentity: myId myEd25519Public: myEd account: account andDatabaseConnection:databaseConnection];
    }
    return self;
}


-(NSString *) name {
    if (name == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            name = [transaction objectForKey:@"name" inCollection: iD];
        }];
    }
    return name;
}
-(void) setName:(NSString *)nameStr {
    name = nameStr;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:name forKey:@"name" inCollection: iD];
    }];
}
-(NSDate *) timeAdded {
    if (timeAdded == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            timeAdded = [transaction objectForKey:@"timeAdded" inCollection: iD];
        }];
    }
    return timeAdded;
}
-(void) setTimeAdded:(NSDate *)dateAdded {
    timeAdded = dateAdded;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:timeAdded forKey:@"timeAdded" inCollection: iD];
    }];
}

-(BOOL) pending {
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *result = [transaction objectForKey:@"pending" inCollection: iD];
        pending = YES;
        if (result) {
            pending = [result isEqualToString:@"yes"];
        }
    }];
    return pending;
}
-(void) setPending:(BOOL)pendingBOOL {
    pending = pendingBOOL;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSString *boolStr;
        if (pendingBOOL) {
            boolStr = @"yes";
        } else {
            boolStr = @"no";
        }
        [transaction setObject:boolStr forKey:@"pending" inCollection: iD];
    }];
}

-(BOOL) revoked {
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *result = [transaction objectForKey:@"revoked" inCollection: iD];
        revoked = NO;
        if (result) {
            revoked = [result isEqualToString:@"yes"];
        }
    }];
    return revoked;
}
-(void) setRevoked:(BOOL) revokedBOOL {
    revoked = revokedBOOL;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSString *boolStr;
        if (revoked) {
            boolStr = @"yes";
        } else {
            boolStr = @"no";
        }
        [transaction setObject:boolStr forKey:@"revoked" inCollection: iD];
    }];
}

-(BOOL) revokedMe {
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *result = [transaction objectForKey:@"revokedMe" inCollection: iD];
        revokedMe = NO;
        if (result) {
            revokedMe = [result isEqualToString:@"yes"];
        }
    }];
    return revokedMe;
}
-(void) setRevokedMe:(BOOL) revokedMeBOOL {
    revokedMe = revokedMeBOOL;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSString *boolStr;
        if (revokedMe) {
            boolStr = @"yes";
        } else {
            boolStr = @"no";
        }
        [transaction setObject:boolStr forKey:@"revokedMe" inCollection: iD];
    }];
}

-(NSData *) keyExchangeData {
    if (keyExchangeData) {
        return keyExchangeData;
    }
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        keyExchangeData = [transaction objectForKey:@"keyExchangeData" inCollection: iD];
    }];
    return keyExchangeData;
}
-(void) setKeyExchangeData:(NSData *)keyExchangeNSData {
    keyExchangeData = keyExchangeNSData;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        if (keyExchangeData) {
            [transaction setObject:keyExchangeData forKey:@"keyExchangeData" inCollection: iD];
        } else {
            [transaction removeObjectForKey: @"keyExchangeData" inCollection: iD];
        }
    }];
}


-(BBSMemberKey *) myBBSMemberKey {
    if (myBBSMemberKey) {
        return myBBSMemberKey;
    }
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSData *data = [transaction objectForKey:@"myBBSMemberKey" inCollection: iD];
        myBBSMemberKey = [[BBSMemberKey alloc] unMarshal:data];
    }];
    return myBBSMemberKey;
}
-(void) setMyBBSMemberKey:(BBSMemberKey *) memberKey {
    myBBSMemberKey = memberKey;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: [myBBSMemberKey extendedMarshal] forKey:@"myBBSMemberKey" inCollection: iD];
    }];
}

-(BBSMemberKey *) theirBBSMemberKey {
    if (theirBBSMemberKey) {
        return theirBBSMemberKey;
    }
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSData *data = [transaction objectForKey:@"theirBBSMemberKey" inCollection: iD];
        theirBBSMemberKey = [[BBSMemberKey alloc] unMarshal:data];
        if (theirBBSMemberKey) {
            if (myGroup) {
                [theirBBSMemberKey setGroup:myGroup];
            }
        }
    }];
    return theirBBSMemberKey;
}
-(void) setTheirBBSMemberKey:(BBSMemberKey *) memberKey {
    theirBBSMemberKey = memberKey;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: [theirBBSMemberKey marshal] forKey:@"theirBBSMemberKey" inCollection: iD];
    }];
}

-(void) setGeneration:(FGIntBase)gen {
    generation = gen;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject: [NSNumber numberWithUnsignedInt:generation] forKey:@"generation" inCollection:iD];
    }];
    
}
-(FGIntBase) generation {
    if (generation == 0) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            generation = [[transaction objectForKey:@"generation" inCollection:iD] unsignedIntValue];
        }];
    }
    return generation;
}

-(void) setServerAddress:(NSString *)serverAddressString {
    serverAddress = serverAddressString;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:serverAddress forKey:@"serverAddress" inCollection: iD];
    }];
}
-(NSString *) serverAddress {
    if (serverAddress == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            serverAddress = [transaction objectForKey:@"serverAddress" inCollection:iD];
        }];
    }
    return serverAddress;
}

-(void) setServerId:(NSString *)serverIdString {
    serverId = serverIdString;
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:serverId forKey:@"serverId" inCollection:iD];
    }];
}
-(NSString *) serverId {
    if (serverId == nil) {
        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            serverId = [transaction objectForKey:@"serverId" inCollection:iD];
        }];
    }
    return serverId;
}

//-(void) setIdentityPublic:(NSData *)identityPublicData {
//    identityPublic = identityPublicData;
//    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        [transaction setObject:identityPublic forKey:@"identityPublic" inCollection: iD];
//    }];
//}
//-(NSData *) identityPublic {
//    if (identityPublic == nil) {
//        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
//            identityPublic = [transaction objectForKey:@"identityPublic" inCollection: iD];
//        }];
//    }
//    return identityPublic;
//}
//
//-(void) setEd25519Public:(NSData *)ed25519PublicData {
//    ed25519Public = ed25519PublicData;
//    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        [transaction setObject:ed25519Public forKey:@"ed25519Public" inCollection:iD];
//    }];
//}
//-(NSData *) ed25519Public {
//    if (ed25519Public == nil) {
//        [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
//            ed25519Public = [transaction objectForKey:@"ed25519Public" inCollection:iD];
//        }];
//    }
//    return ed25519Public;
//}
//





-(NSData *) sign: (NSData *) message {
    
    
    
    return nil;
}







@end
