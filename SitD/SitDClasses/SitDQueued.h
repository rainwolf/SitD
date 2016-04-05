//
//  SitDQueued.h
//  SitD
//
//  Created by rainwolf on 25/02/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SitDQueued : NSObject <NSSecureCoding> {
    BOOL anonymous;
    NSData *message;
    NSString *serverHost, *serverIdentity, *contactID;
    long tag;
    uint64_t localMsgId;
}
@property(atomic, assign, readwrite) BOOL anonymous;
@property(nonatomic, retain, readwrite) NSData *message;
@property(nonatomic, retain, readwrite) NSString *serverHost, *serverIdentity, *contactID;
@property(atomic, assign, readwrite) long tag;
@property(atomic, assign, readwrite) uint64_t localMsgId;


-(id)initWithCoder:(NSCoder*)decoder;
-(void)encodeWithCoder:(NSCoder*)encoder;

@end
