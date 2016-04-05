//
//  constants.h
//  SitD
//
//  Created by rainwolf on 09/01/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#ifndef constants_h
#define constants_h


#endif /* constants_h */

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define SitDAccountKey @"SitDAccount"
#define SitDInboxKey @"SitDInbox"
#define SitDInboxOverviewKey @"SitDInboxOverview"
#define SitDOutboxKey @"SitDOutbox"
#define SitDOutboxOverviewKey @"SitDOutboxOverview"
#define SitDContactIDs @"SitDContactIDs"
#define NACLOVERHEAD 16
#define TRANSPORTSIZE (16384 - 2 - NACLOVERHEAD)
#define TRANSPORTBLOCKSIZE (4096 - 2)
#define MESSAGEOVERHEAD 512
#define MAXSERIALIZEDMESSAGE (TRANSPORTSIZE - (NACLOVERHEAD + 4 + 4 + 32 + 24) - NACLOVERHEAD - MESSAGEOVERHEAD)

#define MAXMISSINGMESSAGES 8

// headerSize is the size, in bytes, of a header's plaintext contents.
#define HEADERSIZE 4 /* uint32 message count */ + 4 /* uint32 previous message count */ + 32 /* curve25519 ratchet public */ + 24 /* nonce for message */
// sealedHeader is the size, in bytes, of an encrypted header.
#define SEALEDHEADERSIZE 24 /* nonce */ + HEADERSIZE + NACLOVERHEAD
// nonceInHeaderOffset is the offset of the message nonce in the header's plaintext.
#define NONCEINHEADEROFFSET 4 + 4 + 32

#define PROTOMASK 131072
#define PROTOREPLYTAG (PROTOMASK | 1)
#define NEWACCOUNTPROTO (PROTOMASK | 2)
#define REVOCATIONPROTO (PROTOMASK | 4)
#define DELIVERPROTO (PROTOMASK | 8)
#define FETCHPROTO (PROTOMASK | 16)
