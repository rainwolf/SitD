//
//  PondDialer.h
//  pondTester
//
//  Created by rainwolf on 20/09/15.
//  Copyright © 2015 rainwolf. All rights reserved.
//

#ifndef PondDialer_h
#define PondDialer_h


#endif /* PondDialer_h */
//#include <CPAProxy/CPAProxy.h>
//#import "GCDAsyncProxySocket.h"
@import ProxyKit;


@class SitDAccount;
@class CPAProxyManager;

@interface SitDialer : NSObject <GCDAsyncSocketDelegate> {
    GCDAsyncProxySocket *pondSocket;
    CPAProxyManager *torProxyManager;
    BOOL connected2Tor, connectedDialer, wants2Connect;
    NSMutableData *writeNonce, *readNonce;
    NSData *identity, *identityPublic, *serverIdentityPublic, *writeKey, *readKey, *myEphemeralPublicKey, *myEphemeralPrivateKey, *serverEphemeral;
    NSString *serverName, *serverIdentityString;
    
    BOOL anonymous;
    
    __weak SitDAccount *account;
    
}

@property(nonatomic,retain) GCDAsyncProxySocket *pondSocket;
@property(nonatomic,retain) CPAProxyManager *torProxyManager;
@property(atomic) BOOL connected2Tor, connectedDialer, wants2Connect;
@property(nonatomic, retain) NSMutableData *writeNonce, *readNonce;
@property(nonatomic, retain) NSData *identity, *identityPublic, *serverIdentityPublic, *writeKey, *readKey, *myEphemeralPublicKey, *myEphemeralPrivateKey, *serverEphemeral;
@property(nonatomic, retain) NSString *serverName, *serverIdentityString;

@property(atomic, assign, readwrite) BOOL anonymous;

@property(weak, nonatomic, readwrite) SitDAccount *account;

-(void) startTor;
-(void) restartTor;
//-(SitDialer *) initWithTorProxyManager: (CPAProxyManager *) cpaProxyMngr;
-(void) connectDialerWithError: (NSError *) error;
-(void) disconnect;
-(void) disconnectAfterReading;
-(void) disconnectAfterWriting;
-(void) close;

-(void) writeProto: (NSData *) protoData withTag: (long) tag;
-(void) readProto: (NSData *) protoData withTag: (long) tag;
-(void) readProtoWithTag: (long) tag;

@end

