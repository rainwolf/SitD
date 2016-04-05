//
//  SitDMessage.h
//  SitD
//
//  Created by rainwolf on 18/03/16.
//  Copyright © 2016 rainwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SitDFile : NSObject <NSSecureCoding> {
    NSString *filename, *filenameOnDisk;
    NSData *nonce, *key;
}
@property(nonatomic, retain, readwrite) NSString *filename, *filenameOnDisk;
@property(nonatomic, retain, readwrite) NSData *nonce, *key;

-(id)initWithCoder:(NSCoder*)decoder;
-(void)encodeWithCoder:(NSCoder*)encoder;

@end



@interface SitDMessage : NSObject <NSSecureCoding> {
    uint64_t messageID, localID;
    BOOL acknowledged, outgoing, hasFiles, unread;
    NSString *contactID, *contactName;
    NSDate *timestamp;
}
@property(atomic, readwrite, assign) uint64_t messageID, localID;
@property(atomic, readwrite, assign) BOOL acknowledged, outgoing, hasFiles, unread;
@property(nonatomic, readwrite, retain) NSString *contactID, *contactName;
@property(nonatomic, readwrite, retain) NSDate *timestamp;

-(id)initWithCoder:(NSCoder*)decoder;
-(void)encodeWithCoder:(NSCoder*)encoder;

@end

@interface SitDMessageContent : NSObject <NSSecureCoding> {
    uint64_t messageID, localID;
    BOOL acknowledged, outgoing, hasFiles, unread;
    NSString *contactID, *contactName;
    NSDate *timestamp;
    NSData *encodedBody;
    NSArray<SitDFile *> *files;
}
@property(atomic, readwrite, assign) uint64_t messageID, localID;
@property(atomic, readwrite, assign) BOOL acknowledged, outgoing, hasFiles, unread;
@property(nonatomic, readwrite, retain) NSString *contactID, *contactName;
@property(nonatomic, readwrite, retain) NSDate *timestamp;
@property(nonatomic, retain, readwrite) NSData *encodedBody;
@property(nonatomic, retain, readwrite) NSArray<SitDFile *> *files;

-(id)initWithCoder:(NSCoder*)decoder;
-(void)encodeWithCoder:(NSCoder*)encoder;

-(SitDMessage *) summary;

@end
