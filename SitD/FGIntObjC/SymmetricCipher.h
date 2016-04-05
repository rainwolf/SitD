#import <Foundation/Foundation.h>

typedef unsigned int word;



@interface Salsa20 : NSObject {
	NSData *message, *nonce, *key;
}
@property (retain, readwrite) NSData *message;
@property (retain, readwrite) NSData *nonce;
@property (retain, readwrite) NSData *key;

-(NSData *) salsa20Encrypt;
-(NSData *) salsa20Decrypt;
-(NSData *) xsalsa20Encrypt;
-(NSData *) xsalsa20Decrypt;
+(NSData *) createKeyFromSharedSecret: (NSData *) sharedSecret;

@end




// @interface Rijndael256 : NSObject {
// 	NSData *message, *iv, *key;
// }
// @property (retain, readwrite) NSData *message;
// @property (retain, readwrite) NSData *iv;
// @property (retain, readwrite) NSData *key;


// @end



