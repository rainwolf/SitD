//
//  SitDMessage.m
//  SitD
//
//  Created by rainwolf on 18/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import "SitDMessage.h"


@implementation SitDFile
@synthesize filename, filenameOnDisk;
@synthesize nonce, key;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: self.filename forKey:@"filename"];
    [encoder encodeObject: self.filenameOnDisk forKey:@"filenameOnDisk"];
    [encoder encodeObject: self.nonce forKey:@"nonce"];
    [encoder encodeObject: self.key forKey:@"key"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.filename = [decoder decodeObjectOfClass: [NSString class] forKey:@"filename"];
        self.filenameOnDisk = [decoder decodeObjectOfClass: [NSString class] forKey:@"filenameOnDisk"];
        self.key = [decoder decodeObjectOfClass: [NSData class] forKey:@"key"];
        self.nonce = [decoder decodeObjectOfClass: [NSData class] forKey:@"nonce"];
    }
    return self;
}

+(BOOL) supportsSecureCoding {
    return YES;
}



@end


@implementation SitDMessage
@synthesize acknowledged, outgoing, hasFiles, unread;
@synthesize messageID, localID;
@synthesize contactID, contactName;
@synthesize timestamp;

-(instancetype) init {
    if (self = [super init]) {
        messageID = 0;
        localID = 0;
        acknowledged = NO;
        hasFiles = NO;
        outgoing = NO;
        unread = YES;
        contactID = nil;
        contactName = nil;
        timestamp = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt64: self.messageID forKey: @"messageID"];
    [encoder encodeInt64: self.localID forKey: @"localID"];
    [encoder encodeBool: self.outgoing forKey:@"outgoing"];
    [encoder encodeBool: self.acknowledged forKey:@"acknowledged"];
    [encoder encodeBool: self.hasFiles forKey:@"hasFiles"];
    [encoder encodeBool: self.unread forKey:@"unread"];
    [encoder encodeObject: self.contactID forKey:@"contactID"];
    [encoder encodeObject: self.contactName forKey:@"contactName"];
    [encoder encodeObject: self.timestamp forKey:@"timestamp"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.messageID = [decoder decodeInt64ForKey: @"messageID"];
        self.localID = [decoder decodeInt64ForKey: @"localID"];
        self.outgoing = [decoder decodeBoolForKey: @"outgoing"];
        self.acknowledged = [decoder decodeBoolForKey: @"acknowledged"];
        self.hasFiles = [decoder decodeBoolForKey: @"hasFiles"];
        self.unread = [decoder decodeBoolForKey: @"unread"];
        self.contactID = [decoder decodeObjectOfClass:[NSString class] forKey: @"contactID"];
        self.contactName = [decoder decodeObjectOfClass:[NSString class] forKey: @"contactName"];
        self.timestamp = [decoder decodeObjectOfClass:[NSDate class] forKey: @"timestamp"];
    }
    return self;
}

+(BOOL) supportsSecureCoding {
    return YES;
}




@end




@implementation SitDMessageContent
@synthesize acknowledged, outgoing, hasFiles, unread;
@synthesize messageID, localID;
@synthesize contactID, contactName;
@synthesize timestamp;
@synthesize encodedBody;
@synthesize files;

-(instancetype) init {
    if (self = [super init]) {
        messageID = 0;
        localID = 0;
        acknowledged = NO;
        outgoing= NO;
        unread = YES;
        hasFiles = NO;
        contactID = nil;
        contactName = nil;
        timestamp = nil;
        encodedBody = nil;
        files = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt64: self.messageID forKey: @"messageID"];
    [encoder encodeInt64: self.localID forKey: @"localID"];
    [encoder encodeBool: self.outgoing forKey:@"outgoing"];
    [encoder encodeBool: self.acknowledged forKey:@"acknowledged"];
    [encoder encodeBool: self.hasFiles forKey:@"hasFiles"];
    [encoder encodeBool: self.unread forKey:@"unread"];
    [encoder encodeObject: self.contactID forKey:@"contactID"];
    [encoder encodeObject: self.contactName forKey:@"contactName"];
    [encoder encodeObject: self.timestamp forKey:@"timestamp"];
    [encoder encodeObject: self.encodedBody forKey:@"encodedBody"];
    [encoder encodeObject: self.files forKey:@"files"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.messageID = [decoder decodeInt64ForKey: @"messageID"];
        self.localID = [decoder decodeInt64ForKey: @"localID"];
        self.outgoing = [decoder decodeBoolForKey: @"outgoing"];
        self.acknowledged = [decoder decodeBoolForKey: @"acknowledged"];
        self.hasFiles = [decoder decodeBoolForKey: @"hasFiles"];
        self.unread = [decoder decodeBoolForKey: @"unread"];
        self.contactID = [decoder decodeObjectOfClass:[NSString class] forKey: @"contactID"];
        self.contactName = [decoder decodeObjectOfClass:[NSString class] forKey: @"contactName"];
        self.timestamp = [decoder decodeObjectOfClass:[NSDate class] forKey: @"timestamp"];
        self.encodedBody = [decoder decodeObjectOfClass: [NSData class] forKey:@"encodedBody"];
        self.files = [decoder decodeObjectOfClass: [NSArray class] forKey:@"files"];
    }
    return self;
}

+(BOOL) supportsSecureCoding {
    return YES;
}

-(SitDMessage *) summary {
    SitDMessage *result = [[SitDMessage alloc] init];
    [result setLocalID: self.localID];
    [result setMessageID: self.messageID];
    [result setTimestamp: self.timestamp];
    [result setContactID: self.contactID];
    [result setContactName: self.contactName];
    [result setOutgoing: self.outgoing];
    [result setAcknowledged: self.acknowledged];
    [result setHasFiles: self.hasFiles];
    
    return result;
}




@end
