#import "NaCl.h"
#import "FGInt.h"
#import "SymmetricCipher.h"
#import "OneWay.h"


@implementation NaClPacket
@synthesize message;
@synthesize key;
@synthesize nonce;
@synthesize recipientPK;
@synthesize secretKey;



-(NaClPacket *) init {
    if (self = [super init]) {
    	message = nil;
    	key = nil;
    	nonce = nil;
    	recipientPK = nil;
    	secretKey = nil;
    }
    return self;
}

-(NaClPacket *) initWithMessage: (NSData *) messageData key: (NSData *) keyData andNonce: (NSData *) nonceData {
    if (self = [super init]) {
    	message = [messageData retain];
    	key = [keyData retain];
    	nonce = [nonceData retain];
    	recipientPK = nil;
    	secretKey = nil;
    }
    return self;
}

-(NaClPacket *) initWithMessage: (NSData *) messageData recipientsPublicKey: (NSData *) recipientPKData secretKey: (NSData *) secretKeyData andNonce: (NSData *) nonceData {
    if (self = [super init]) {
    	message = [messageData retain];
    	key = nil;
    	nonce = [nonceData retain];
    	recipientPK = [recipientPKData retain];
    	secretKey = [secretKeyData retain];
    }
    return self;
}

-(void) dealloc {
	if (message) {
		[message release];
	}
	if (key) {
		[key release];
	}
	if (nonce) {
		[nonce release];
	}
	if (recipientPK) {
		[recipientPK release];
	}
	if (secretKey) {
		[secretKey release];
	}
	[super dealloc];
}


-(NSData *) packXsalsa20Poly1305 {
	NSAssert(message, @" no message ");
	NSAssert(key, @" no key ");
	NSAssert(nonce, @" no nonce ");
	NSAssert([key length] == 32, @" key length needs to be 32 bytes, NaClPacket received %lu ", [key length]);
	NSAssert([nonce length] == 24, @" nonce length needs to be 24 bytes, NaClPacket received %lu ", [nonce length]);
	
	NSMutableData *messageShiftedRight = [[NSMutableData alloc] initWithLength: 32];
	[messageShiftedRight appendData: message];
	Salsa20 *salsa20Secret = [[Salsa20 alloc] init];
	[salsa20Secret setKey: key];
	[salsa20Secret setNonce: nonce];
	[salsa20Secret setMessage: messageShiftedRight];
	NSMutableData *xsalsa20EncryptedData = (NSMutableData *) [salsa20Secret xsalsa20Encrypt];
	[salsa20Secret release];

	Poly1305XSalsa20 *authenticatedMessage = [[Poly1305XSalsa20 alloc] init];
	[authenticatedMessage setBoxedMessage: xsalsa20EncryptedData];
	NSMutableData *result = (NSMutableData *) [authenticatedMessage computeHMAC];
	[result appendBytes: &([xsalsa20EncryptedData mutableBytes][32]) length: ([xsalsa20EncryptedData length] - 32)];

	[xsalsa20EncryptedData release];
	[authenticatedMessage release];

	return result;
}

-(NSData *) unpackXsalsa20Poly1305 {
	NSAssert(message, @" no message ");
	NSAssert(key, @" no key ");
	NSAssert(nonce, @" no nonce ");
	NSAssert([key length] == 32, @" key length needs to be 32 bytes, NaClPacket received %lu ", [key length]);
	NSAssert([nonce length] == 24, @" nonce length needs to be 24 bytes, NaClPacket received %lu ", [nonce length]);
	
	NSMutableData *messageShiftedRight = [[NSMutableData alloc] initWithLength: 32];
	Salsa20 *salsa20Secret = [[Salsa20 alloc] init];
	[salsa20Secret setKey: key];
	[salsa20Secret setNonce: nonce];
	[salsa20Secret setMessage: messageShiftedRight];
	NSMutableData *xsalsa20EncryptedData = (NSMutableData *) [salsa20Secret xsalsa20Encrypt];
	[xsalsa20EncryptedData appendBytes: &([message bytes][16]) length: ([message length] - 16)];
	NSData *hMac = [[NSData alloc] initWithBytesNoCopy: (unsigned char*) [message bytes] length: 16 freeWhenDone: NO];


	Poly1305XSalsa20 *authenticatedMessage = [[Poly1305XSalsa20 alloc] init];
	[authenticatedMessage setBoxedMessage: xsalsa20EncryptedData];
	[authenticatedMessage setHmac: hMac];
	NSMutableData *result = nil;
	if ([authenticatedMessage verifyHmac]) {
		[salsa20Secret setMessage: xsalsa20EncryptedData];
		NSData* tmpResult = [salsa20Secret xsalsa20Decrypt];
		result = [[NSMutableData alloc] initWithBytes: &([tmpResult bytes][32]) length: [tmpResult length] - 32];
		[tmpResult release];
	} else {
		result = nil;
	}

	// [xsalsa20EncryptedData release];
	[salsa20Secret release];
	[authenticatedMessage release];

	return result;
}



-(NSData *) packCurve25519Xsalsa20Poly1305 {
	NSAssert(secretKey, @" no secretKey ");
	NSAssert(recipientPK, @" no recipientPK ");

    NSData *preSharedSecret = [NaClPacket curve25519Point:recipientPK times:secretKey];
	key = [Salsa20 createKeyFromSharedSecret: preSharedSecret];
	[preSharedSecret release];

	return [self packXsalsa20Poly1305];
}

-(NSData *) unpackCurve25519Xsalsa20Poly1305 {
	NSAssert(secretKey, @" no secretKey ");
	NSAssert(recipientPK, @" no recipientPK ");

    NSData *preSharedSecret = [NaClPacket curve25519Point:recipientPK times: secretKey];
	key = [Salsa20 createKeyFromSharedSecret: preSharedSecret];
	[preSharedSecret release];

	return [self unpackXsalsa20Poly1305];
}


+(NSData *) newCurve25519PrivateKey {
    NSMutableData *tmpData = [[NSMutableData alloc] initWithLength: 32];
    int result = SecRandomCopyBytes(kSecRandomDefault, 32, [tmpData mutableBytes]);
    if (result != 0) {
        [tmpData release];
        return nil;
    }
    unsigned char* numberArray = [tmpData mutableBytes];
    numberArray[31] = numberArray[31] | 64;
    numberArray[31] = numberArray[31] & 127;
    numberArray[0] = numberArray[0] & 248;
    
    return tmpData;
}

+(NSData *) curve25519PrivateKey: (NSData *) inData {
    NSMutableData *tmpData = [[NSMutableData alloc] initWithData:inData];
    [tmpData setLength:32];
    unsigned char* numberArray = [tmpData mutableBytes];
    numberArray[31] = numberArray[31] | 64;
    numberArray[31] = numberArray[31] & 127;
    numberArray[0] = numberArray[0] & 248;
    
    return tmpData;
}

+(NSData *) curve25519BasePointTimes: (NSData *) scalar {
    unsigned char basePt = 9;
    NSData *adjustedScalar = [NaClPacket curve25519PrivateKey:scalar];
    NSData *basePoint = [[NSData alloc] initWithBytes:&basePt length:sizeof(basePt)];
    NSData *result = [NaClPacket curve25519Point:basePoint times: adjustedScalar];
    [adjustedScalar release];
    [basePoint release];
    
    return result;
}

+(NSData *) curve25519Point: (NSData *) point times: (NSData *) scalar {
    NSData *adjustedScalar = [NaClPacket curve25519PrivateKey:scalar];
    FGInt *pointFGInt = [[FGInt alloc] initWithNSData: point],
            *scalarFGInt = [[FGInt alloc] initWithNSData: adjustedScalar];
    [adjustedScalar release];
    FGInt *resultFGInt = [FGInt addBasePointOnCurve25519: pointFGInt kTimes: scalarFGInt];
    [pointFGInt release];
    [scalarFGInt release];
    NSData *result = [resultFGInt toNSData];
    
    return result;
}


@end