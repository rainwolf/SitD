#import "OneWay.h"
#import "FGInt.h"
#import <CommonCrypto/CommonCryptor.h>




@implementation Poly1305
@synthesize message;
@synthesize r;
@synthesize s;
@synthesize hmac;




-(id) init {
    if (self = [super init]) {
    	message = nil;
    	r = nil;
    	s = nil;
    	hmac = nil;
    }
    return self;
}


-(void) dealloc {
    if (message != nil) {
        [message release];
    }
    if (r != nil) {
        [r release];
    }
    if (s != nil) {
        [s release];
    }
    [super dealloc];
}   


-(NSData *) hmac {
	if (hmac) {
		return hmac;
	} else {
		hmac = [self computeHMAC];
		return hmac;
	}
}


-(NSData *) clamp {
	if (!r || ([r length] != 16)) {
		return nil;
	}
	NSMutableData *result = [r mutableCopy];
	unsigned char* resultBytes = [result mutableBytes];
	resultBytes[3] = resultBytes[3] & 15;
	resultBytes[7] = resultBytes[7] & 15;
	resultBytes[11] = resultBytes[11] & 15;
	resultBytes[15] = resultBytes[15] & 15;
	resultBytes[4] = resultBytes[4] & 252;
	resultBytes[8] = resultBytes[8] & 252;
	resultBytes[12] = resultBytes[12] & 252;

	return result;
}

-(void) setRandS {
	NSLog(@" setRandS method of Poly1305 was not overridden!");
	NSAssert(NO, @" setRandS method of Poly1305 was not overridden!");
}


-(NSData *) computeHMAC {
	[self setRandS];
	FGInt *messageBlockFGInt = [[FGInt alloc] initWithNZeroes: 5];
	FGInt *rFGInt = [[FGInt alloc] initWithNSData: [self clamp]];
	unsigned char* messageBlockArray = [[messageBlockFGInt number] mutableBytes];
	const unsigned char* inputDataArray = [message bytes];
	messageBlockArray[16] = 1;
	FGIntOverflow length = [message length];

	FGInt *hmacFGInt = [[FGInt alloc] initAsZero], *tmpFGInt;
	for ( FGIntIndex i = 0; i < (length >> 4); i++ ) {
		memcpy(messageBlockArray, &inputDataArray[i << 4], 16);
		[hmacFGInt addWith: messageBlockFGInt];
		tmpFGInt = [FGInt multiplyModulo1305ish: hmacFGInt and: rFGInt];
		[hmacFGInt release];
		hmacFGInt = tmpFGInt;
	}
	if ((length & 15) != 0) {
		memset(messageBlockArray, 0, 17);
		memcpy(messageBlockArray, &inputDataArray[length - (length & 15)], (length & 15));
		messageBlockArray[(length & 15)] = 1;
		[hmacFGInt addWith: messageBlockFGInt];
		tmpFGInt = [FGInt multiplyModulo1305ish: hmacFGInt and: rFGInt];
		[hmacFGInt release];
		hmacFGInt = tmpFGInt;
	}
	[hmacFGInt mod1305];

	[rFGInt release];
	[messageBlockFGInt release];

	FGInt *xorPadFGInt = [[FGInt alloc] initWithNSData: s];
	[hmacFGInt addWith: xorPadFGInt];
	[xorPadFGInt release];

	NSMutableData *result = [[hmacFGInt number] retain];
	[result setLength: 16];
	[hmacFGInt release];

	return result;
}



-(BOOL) verifyHmac {
	BOOL result;

	NSData *computedHMAC = [self computeHMAC];
	result = [hmac isEqualToData: computedHMAC];
	[computedHMAC release];

	return result;
}



@end





@implementation Poly1305XSalsa20
@synthesize boxedMessage;

-(void) setRandS {
	r = [[NSData alloc] initWithBytesNoCopy: (unsigned char*) [boxedMessage bytes] length: 16 freeWhenDone: NO];
	s = [[NSData alloc] initWithBytesNoCopy: &(((unsigned char*) [boxedMessage bytes])[16]) length: 16 freeWhenDone: NO];
	message = [[NSData alloc] initWithBytesNoCopy: &(((unsigned char*) [boxedMessage bytes])[32]) length: ([boxedMessage length] - 32) freeWhenDone: NO];
}

@end





@implementation Poly1305AES
@synthesize key;
@synthesize nonce;

/* some test vectors that passed
http://www.inconteam.com/software-development/41-encryption/55-aes-test-vectors#aes-ecb-128
http://cr.yp.to/mac/poly1305aes.py
*/


-(void) dealloc {
    if (key != nil) {
        [key release];
    }
    if (nonce != nil) {
        [nonce release];
    }
    [super dealloc];
}   



-(void) setRandS {
    NSAssert([self key], @"No key available for Poly1305AES");
    NSAssert([self nonce], @"No nonce available for Poly1305AES");
    NSAssert([[self nonce] length] == 16, @"The nonce needs to be 8 bytes long, Poly1305AES received %lu bytes", [[self nonce] length]);
    NSAssert([[self key] length] == 32, @"The key needs to be 32 bytes long, Poly1305AES received %lu bytes", [[self key] length]);

    NSMutableData *cipherData = [[NSMutableData alloc] initWithLength: [nonce length]];
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0x00, //No padding
    [key bytes], kCCKeySizeAES128, nil, [nonce bytes], [nonce length], [cipherData mutableBytes], [nonce length], &numBytesCrypted);

    if(cryptStatus == kCCSuccess) {
    	NSMutableData *mutableR = [[NSMutableData alloc] initWithLength: 16];
    	[key getBytes: [mutableR mutableBytes] range: NSMakeRange(16, 16)];
    	r = mutableR;
        [self setS: cipherData];
    }
}


@end
















