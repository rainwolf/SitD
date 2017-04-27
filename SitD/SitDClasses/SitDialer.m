//
//  PondDialer.m
//  pondTester
//
//  Created by rainwolf on 20/09/15.
//  Copyright © 2015 rainwolf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SitDialer.h"
#import "FGIntObjCSitD.h"
#import "constants.h"
#import "SitDAccount.h"
@import CPAProxy;


#define HANDSHAKEMASK 65536


#define OTHERMASK 262144
#define CLOSE 524288
//#define Mask 1048576
//#define Mask 2097152
//#define Mask 4194304
//#define Mask 8388608
#define ephemeralLength 0
#define ephemeralPublic 1
#define serverProofLength 2
#define serverProof 3
#define clientProof 4
#define maxRetries 5

#define TIMEOUT 10

@implementation SitDialer
@synthesize pondSocket;
@synthesize torProxyManager;
@synthesize connected2Tor, connectedDialer, wants2Connect;
@synthesize writeNonce, readNonce;
@synthesize writeKey, readKey, identity, identityPublic, serverIdentityPublic, myEphemeralPublicKey, myEphemeralPrivateKey, serverEphemeral;
@synthesize serverName, serverIdentityString;
@synthesize anonymous;
@synthesize obfsproxy;


@synthesize account;

int retries = 2;

//long socksPort = 16333;

-(SitDialer *) init {
    self = [super init];
    if (self) {
        connectedDialer = NO;
        wants2Connect = NO;
        serverIdentityPublic = nil;
        serverIdentityString = nil;
        anonymous = NO;
        writeKey = nil;
        readKey = nil;
        writeNonce = nil;
        readNonce = nil;
        identity = nil;
        identityPublic = nil;
        serverIdentityPublic = nil;
        myEphemeralPrivateKey = nil;
        myEphemeralPublicKey = nil;
        serverEphemeral = nil;
        
        torProxyManager = nil;
        
    }
    
    return self;
}

-(void) startTor {
    NSBundle *cpaProxyBundle = [NSBundle bundleWithURL: [[NSBundle bundleForClass:[CPAProxyManager class]] URLForResource:@"CPAProxy" withExtension:@"bundle"]];
    NSString *torrcPath = [cpaProxyBundle pathForResource:@"torrc" ofType:nil];
    torrcPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"torrc"];
    NSString *geoipPath = [cpaProxyBundle pathForResource:@"geoip" ofType:nil];
    NSLog(@"%@",geoipPath);
    NSLog(@"%@", torrcPath);

//    obfsproxy = [[ObfsThread alloc] init];
//    [obfsproxy start];
    
    // Place to store Tor caches (non-temp storage improves performance since
    // directory data does not need to be re-loaded each launch)
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *torDataDir = [documentsDirectory stringByAppendingPathComponent:@"tor"];
    
    // Initialize a CPAProxyManager
    CPAConfiguration *configuration = [CPAConfiguration configurationWithTorrcPath:torrcPath geoipPath:geoipPath torDataDirectoryPath:torDataDir];
    torProxyManager = [CPAProxyManager proxyWithConfiguration:configuration];
    [torProxyManager setupWithCompletion:^(NSString *socksHost, NSUInteger socksPort, NSError *error) {
        if (error == nil) {
            // ... do something with Tor socks hostname & port ...
            NSLog(@"Connected: host=%@, port=%lu", socksHost, (long)socksPort);
            
            [account showNotificationWithTitle:NSLocalizedString(@"Connected to Tor", nil) message:nil andType:TSMessageNotificationTypeSuccess];
            
            //                [account transact];
        }
    } progress:^(NSInteger progress, NSString *summaryString) {
        // ... do something to notify user of tor's initialization progress ...
        
        [account appendLog:[NSString stringWithFormat:@"%li %@ \n", (long)progress, summaryString]];
        
    }];
}

-(void) restartTor {
    if (torProxyManager) {
        [torProxyManager cpa_sendSignal:@"NEWNYM" completionBlock:^(NSString *socksHost, NSError *error) {
            NSLog(@"setting tor NEWNYM");
            [account showNotificationWithTitle:NSLocalizedString(@"New Tor identity acquired", nil) message:nil andType:TSMessageNotificationTypeSuccess];
        } completionQueue:dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    } else {
        [self startTor];
    }
}



-(void) connectDialerWithError: (NSError *) error {
    NSLog(@"connect dialer %@ at %@", serverIdentityString, serverName);
    
    serverIdentityPublic = [FGIntXtra base32StringToNSData:serverIdentityString];
//    pondSocket = [[GCDAsyncProxySocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    dispatch_queue_t queue = dispatch_queue_create("be.submanifold.SitDialerQueue", DISPATCH_QUEUE_SERIAL);
    pondSocket = [[GCDAsyncProxySocket alloc] initWithDelegate:self delegateQueue: queue];
    [pondSocket setProxyHost: [torProxyManager SOCKSHost] port: [torProxyManager SOCKSPort] version:GCDAsyncSocketSOCKSVersion5];
    [pondSocket setAutoDisconnectOnClosedReadStream:YES];
    
    wants2Connect = YES;
    if (![pondSocket connectToHost:serverName onPort:16333 withTimeout:TIMEOUT error:&error]) {
        NSLog(@"I goofed: %@", error);
    } else {
        NSLog(@"Tor seems connected?");
    }
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    writeNonce = [[NSMutableData alloc] initWithLength:24];
    readNonce = [writeNonce mutableCopy];
    writeKey = nil;
    readKey = nil;

    
    NSLog(@"disconnected with error: %@", error);
    if (wants2Connect && [torProxyManager isConnected]) {
//        if (++retries < maxRetries) {
            [pondSocket setProxyUsername:[NSString stringWithFormat:@"%i", ++retries] password:@""];
            [pondSocket connectToHost:serverName onPort:16333 withTimeout:TIMEOUT error:&error];
//        } else {
//            [self connectDialerToHost:server withError: error];
//        }
    }
    
    if (!wants2Connect) {
        [account dialerDisconnected];
    }
    
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"pondSocket is connected to %@", host);
    connectedDialer = YES;
    [self handshake];
}

-(void) handshake {
    writeNonce = [[NSMutableData alloc] initWithLength:24];
    readNonce = [writeNonce mutableCopy];
    writeKey = nil;
    readKey = nil;
    myEphemeralPrivateKey = [NaClPacket newCurve25519PrivateKey];
    myEphemeralPublicKey = [NaClPacket curve25519BasePointTimes:myEphemeralPrivateKey];
    if (anonymous) {
        identity = [NaClPacket newCurve25519PrivateKey];
        identityPublic = [NaClPacket curve25519BasePointTimes:identity];
    }

    
    NSLog(@"shaking hands...");
    NSMutableData *length = [[NSMutableData alloc] initWithLength:2];
    unsigned char *bytes = [length mutableBytes];
    bytes[0] = [myEphemeralPublicKey length];
    bytes[1] = ([myEphemeralPublicKey length] >> 8);
    [pondSocket writeData:length withTimeout: TIMEOUT tag: HANDSHAKEMASK | ephemeralLength];
    [pondSocket writeData:myEphemeralPublicKey withTimeout:TIMEOUT tag: HANDSHAKEMASK | ephemeralPublic];
    [pondSocket readDataToLength:2 withTimeout:TIMEOUT tag: HANDSHAKEMASK | ephemeralLength];
}
-(void) handshakeWithData: (NSData *) data andTag: (long) tag {
    tag &= (HANDSHAKEMASK - 1);
    if (tag == ephemeralLength) {
        const unsigned char *bytes = [data bytes];
        unsigned int len = bytes[0] + (bytes[1] << 8);
        if (len != 32) {
            NSLog(@"length error");
        } else {
            [pondSocket readDataToLength:32 withTimeout:TIMEOUT tag:HANDSHAKEMASK | ephemeralPublic];
        }
    }
    if (tag == ephemeralPublic) {
        serverEphemeral = [data copy];
        NSData *sharedEphemeral = [NaClPacket curve25519Point:serverEphemeral times:myEphemeralPrivateKey];
        char clientBytes[] = "client keys";
        NSData *writeMagic = [NSData dataWithBytes:clientBytes length:sizeof(clientBytes)];
        char serverBytes[] = "server keys";
        NSData *readMagic = [NSData dataWithBytes:serverBytes length:sizeof(serverBytes)];
        NSMutableData *tmpData = [writeMagic mutableCopy];
        [tmpData appendData:sharedEphemeral];
        writeKey = [FGIntXtra SHA256:tmpData];
        tmpData = [readMagic mutableCopy];
        [tmpData appendData:sharedEphemeral];
        readKey = [FGIntXtra SHA256:tmpData];
        
        [pondSocket readDataToLength:2 withTimeout:TIMEOUT tag:HANDSHAKEMASK | serverProofLength];
    }
    if (tag == serverProofLength) {
        const unsigned char *bytes = [data bytes];
        unsigned int len = bytes[0] + (bytes[1] << 8);
        if (len != 32 + 16) {
            NSLog(@" digest length error");
        } else {
            [pondSocket readDataToLength:(32 + 16) withTimeout:TIMEOUT tag:HANDSHAKEMASK | serverProof];
        }
    }
    if (tag == serverProof) {
        NaClPacket *nacl = [[NaClPacket alloc] initWithMessage:data key:readKey andNonce:readNonce];
        NSData *unpacked = [nacl unpackXsalsa20Poly1305];
        [self incrementReadNonce];
        if (!unpacked) {
            return;
        }
        
        NSMutableData *tmpData = [myEphemeralPublicKey mutableCopy];
        [tmpData appendData:serverEphemeral];
        NSData *tmpHash = [FGIntXtra SHA256:tmpData];
        
        NSData *ephemeralIdentityShared = [NaClPacket curve25519Point:serverIdentityPublic times:myEphemeralPrivateKey];
        char serverProofBytes[] = "server proof";
        tmpData = [NSMutableData dataWithBytes:serverProofBytes length:sizeof(serverProofBytes)];
        [tmpData appendData:tmpHash];
        tmpHash = [FGIntXtra SHA256HMACForKey:ephemeralIdentityShared AndData:tmpData];
        
        if ([unpacked isEqualToData:tmpHash]) {
            NSLog(@"digests match, handshake complete");
            tmpData = [myEphemeralPublicKey mutableCopy];
            [tmpData appendData:serverEphemeral];
            [tmpData appendData:unpacked];
            tmpHash = [FGIntXtra SHA256:tmpData];
            
            NSData *identityShared = [NaClPacket curve25519Point:serverIdentityPublic times:identity];
            char clientProofBytes[] = "client proof";
            tmpData = [NSMutableData dataWithBytes:clientProofBytes length:sizeof(clientProofBytes)];
            [tmpData appendData:tmpHash];
            
            NSMutableData *finalMessage = [identityPublic mutableCopy];
            [finalMessage appendData:[FGIntXtra SHA256HMACForKey:identityShared AndData:tmpData]];
            
            NSMutableData *length = [[NSMutableData alloc] initWithLength:2];
            unsigned char *bytes = [length mutableBytes];
            bytes[0] = ([finalMessage length] + 16);
            bytes[1] = (([finalMessage length] + 16) >> 8);
            [pondSocket writeData:length withTimeout:-1 tag: 4];
            nacl = [[NaClPacket alloc] initWithMessage:finalMessage key:writeKey andNonce:writeNonce];
            [pondSocket writeData:[nacl packXsalsa20Poly1305] withTimeout:TIMEOUT tag: HANDSHAKEMASK | clientProof];
            [self incrementWriteNonce];
            
            [account handshakeComplete];
        } else {
            NSLog(@"digests don't match \n %@ \n %@", unpacked, tmpHash);
        }
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag & HANDSHAKEMASK) {
        NSLog(@"I wrote handshake data");
    }
    if (tag & PROTOMASK) {
        [self readProtoWithTag: tag | PROTOREPLYTAG];
        NSLog(@"I wrote proto data");
    }
    if (tag & CLOSE) {
        [self disconnect];
    }
    if (tag == ephemeralLength) {
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
//    NSLog(@"I read tag %lu: %@",tag, data);
    
    if (tag & HANDSHAKEMASK) {
        [self handshakeWithData:data andTag:tag];
    } else if (tag & PROTOMASK) {
        [self readProto: data withTag: tag];
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    [pondSocket disconnect];
    connectedDialer = NO;
    return -1;
}
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    [pondSocket disconnect];
    connectedDialer = NO;
    return -1;
}
-(void) close {
    NSMutableData *writeData = [[NSMutableData alloc] initWithLength:2];
    NaClPacket *nacl = [[NaClPacket alloc] initWithMessage:[[NSData alloc] init] key:writeKey andNonce:writeNonce];
    NSData *encrypted = [nacl packXsalsa20Poly1305];
    unsigned char* bytes = [writeData mutableBytes];
    long len = [encrypted length];
    bytes[0] = len;
    bytes[1] = (len >> 8);
    [writeData appendData: encrypted];
    
    [pondSocket writeData: writeData withTimeout:TIMEOUT tag: CLOSE];
    [self incrementWriteNonce];
}

-(void) disconnect {
    wants2Connect = NO;
    connectedDialer = NO;
    if (pondSocket) {
        [pondSocket disconnect];
    }
}

-(void) disconnectAfterReading {
    wants2Connect = NO;
    connectedDialer = NO;
    if (pondSocket) {
        [pondSocket disconnectAfterReading];
    }
}

-(void) disconnectAfterWriting {
    wants2Connect = NO;
    connectedDialer = NO;
    if (pondSocket) {
        [pondSocket disconnectAfterWriting];
    }
}

-(void) readProtoWithTag: (long) tag {
//    [self waitForConnection];
    if (tag & PROTOREPLYTAG) {
        [pondSocket readDataToLength: TRANSPORTSIZE + 2 + NACLOVERHEAD + 2 withTimeout:TIMEOUT tag: tag];
    }
}

-(void) readProto: (NSData *) protoData withTag: (long) tag {
    if (tag & PROTOREPLYTAG) {
        long len = 0;
        unsigned char *bytes = (unsigned char *) [protoData bytes];
        len = (bytes[0] | (long) (bytes[1] << 8));
        if (len != ([protoData length] - 2)) {
            NSLog(@" protoReply wrong length, expected %lu and got %lu", len, [protoData length] - 2);
            return;
        }
        NSData *encrypted = [NSData dataWithBytes:&bytes[2] length:len];
        NaClPacket *nacl = [[NaClPacket alloc] initWithMessage:encrypted key:readKey andNonce:readNonce];
        NSData *decrypted = [nacl unpackXsalsa20Poly1305];
        if (decrypted == nil) {
            NSLog(@" protoReply decryption failed");
            return;
        }
        bytes = (unsigned char *) [decrypted bytes];
        len = (bytes[0] | (long) (bytes[1] << 8));
        if (len > ([decrypted length] - 2)) {
            NSLog(@" protoReply decrypted wrong length, expected %lu and got %lu", len, [decrypted length] - 2);
            return;
        }
        NSData *trimmedData = [NSData dataWithBytes:&bytes[2] length:len];
        [self incrementReadNonce];
        if (trimmedData) {
            [account processProto:trimmedData withTag:tag];
        } else {
            NSLog(@" decryption of protoReply failed");
        }
    }
    
    
}

-(void) waitForConnection {
    int retries = 0;
    while (!connectedDialer && retries < 30) {
        ++retries;
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
//        [NSThread sleepForTimeInterval: 2];
    }
}

-(void) writeProto: (NSData *) protoData withTag: (long) tag {
//    [self waitForConnection];
    long len = [protoData length];
    if (len > TRANSPORTSIZE) {
        NSLog(@" proto length too large, expected less than %i, got %lu", TRANSPORTSIZE, len);
        return;
    }
    NSMutableData *netData = [[NSMutableData alloc] initWithLength:2];
    unsigned char* bytes = [netData mutableBytes];
    bytes[0] = len;
    bytes[1] = (len >> 8);
    [netData appendData: protoData];
    [netData setLength:TRANSPORTSIZE + 2];
    NSMutableData *writeData = [[NSMutableData alloc] initWithLength:2];
    NaClPacket *nacl = [[NaClPacket alloc] initWithMessage:netData key:writeKey andNonce:writeNonce];
    NSData *encrypted = [nacl packXsalsa20Poly1305];
    bytes = [writeData mutableBytes];
    len = [encrypted length];
    bytes[0] = len;
    bytes[1] = (len >> 8);
    [writeData appendData: encrypted];
    
    [pondSocket writeData: writeData withTimeout:TIMEOUT tag: tag];
    [self incrementWriteNonce];
}


-(void) incrementWriteNonce {
    [FGIntXtra incrementNSMutableData:writeNonce];
}
-(void) incrementReadNonce {
    [FGIntXtra incrementNSMutableData:readNonce];
}

@end





