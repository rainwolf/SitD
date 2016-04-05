#import <Foundation/Foundation.h>



@interface Poly1305 : NSObject {
	NSData *message, *r, *s, *hmac;
}
@property (retain, readwrite) NSData *message;
@property (retain, readwrite) NSData *r;
@property (retain, readwrite) NSData *s;
@property (nonatomic, retain, readwrite) NSData *hmac;
-(NSData *) computeHMAC;
-(BOOL) verifyHmac;


@end



@interface Poly1305XSalsa20 : Poly1305 {
	NSData *boxedMessage;
}
@property (retain, readwrite) NSData *boxedMessage;

@end





@interface Poly1305AES : Poly1305 {
	NSData *key, *nonce;
}
@property (retain, readwrite) NSData *key;
@property (retain, readwrite) NSData *nonce;

@end




