//
//  SitDQueued.m
//  SitD
//
//  Created by rainwolf on 25/02/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "SitDQueued.h"

@implementation SitDQueued
@synthesize anonymous;
@synthesize serverHost, serverIdentity, contactID;
@synthesize message;
@synthesize tag;
@synthesize localMsgId;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: self.serverHost forKey:@"serverHost"];
    [encoder encodeObject: self.serverIdentity forKey:@"serverIdentity"];
    [encoder encodeObject: self.message forKey:@"message"];
    [encoder encodeObject: self.contactID forKey:@"contactID"];
    [encoder encodeBool: self.anonymous forKey:@"anonymous"];
    [encoder encodeInt32: self.tag forKey:@"tag"];
    [encoder encodeInt64:self.localMsgId forKey: @"localMsgId"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.serverHost = [decoder decodeObjectOfClass: [NSString class] forKey:@"serverHost"];
        self.serverIdentity = [decoder decodeObjectOfClass: [NSString class] forKey:@"serverIdentity"];
        self.message = [decoder decodeObjectOfClass: [NSData class] forKey:@"message"];
        self.contactID = [decoder decodeObjectOfClass: [NSString class] forKey:@"contactID"];
        self.anonymous = [decoder decodeBoolForKey: @"anonymous"];
        self.tag = [decoder decodeInt32ForKey: @"tag"];
        self.localMsgId = [decoder decodeInt64ForKey: @"localMsgId"];
    }
    return self;
}

+(BOOL) supportsSecureCoding {
    return YES;
}

@end
