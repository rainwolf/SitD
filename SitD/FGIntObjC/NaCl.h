#import <Foundation/Foundation.h>
#import <Security/SecRandom.h>


@interface NaClPacket : NSObject {
	NSData *message, *key, *nonce, *recipientPK, *secretKey;
}
@property (retain, readwrite) NSData *message;
@property (retain, readwrite) NSData *key;
@property (retain, readwrite) NSData *nonce;
@property (retain, readwrite) NSData *recipientPK;
@property (retain, readwrite) NSData *secretKey;

-(NaClPacket *) initWithMessage: (NSData *) messageData key: (NSData *) keyData andNonce: (NSData *) nonceData;
-(NaClPacket *) initWithMessage: (NSData *) messageData recipientsPublicKey: (NSData *) recipientPKData secretKey: (NSData *) secretKeyData andNonce: (NSData *) nonceData;
-(NSData *) packXsalsa20Poly1305;
-(NSData *) unpackXsalsa20Poly1305;
-(NSData *) packCurve25519Xsalsa20Poly1305;
-(NSData *) unpackCurve25519Xsalsa20Poly1305;
+(NSData *) newCurve25519PrivateKey;
+(NSData *) curve25519PrivateKey: (NSData *) inData;
+(NSData *) curve25519BasePointTimes: (NSData *) scalar;
+(NSData *) curve25519Point: (NSData *) point times: (NSData *) scalar;

@end

