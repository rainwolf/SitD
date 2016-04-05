#import "SymmetricCipher.h"



@implementation Salsa20
@synthesize message;
@synthesize nonce;
@synthesize key;


-(void) dealloc {
    if (message != nil) {
        [message release];
    }
    if (nonce != nil) {
        [nonce release];
    }
    if (key != nil) {
        [key release];
    }
    [super dealloc];
}   

/* some test vectors here https://github.com/alexwebr/salsa20/blob/master/test_vectors.128 */

static word rotateBy(word inputWord, int offSet) {
	return (inputWord << offSet) | (inputWord >> (32 - offSet));
}

static void quarterRound(word* const outputWord0, word* const outputWord1, word* const outputWord2, word* const outputWord3, 
	word* const inputWord0, word* const inputWord1, word* const inputWord2, word* const inputWord3) {
	
	*outputWord1 = *inputWord1 ^ (rotateBy(*inputWord0 + *inputWord3, 7));
	*outputWord2 = *inputWord2 ^ (rotateBy(*outputWord1 + *inputWord0, 9));
	*outputWord3 = *inputWord3 ^ (rotateBy(*outputWord2 + *outputWord1, 13));
	*outputWord0 = *inputWord0 ^ (rotateBy(*outputWord3 + *outputWord2, 18));
}

static void rowRound(word* const outputWords, word* const inputWords) {
	quarterRound(&outputWords[0], &outputWords[1], &outputWords[2], &outputWords[3], &inputWords[0], &inputWords[1], &inputWords[2], &inputWords[3]);
	quarterRound(&outputWords[5], &outputWords[6], &outputWords[7], &outputWords[4], &inputWords[5], &inputWords[6], &inputWords[7], &inputWords[4]);
	quarterRound(&outputWords[10], &outputWords[11], &outputWords[8], &outputWords[9], &inputWords[10], &inputWords[11], &inputWords[8], &inputWords[9]);
	quarterRound(&outputWords[15], &outputWords[12], &outputWords[13], &outputWords[14], &inputWords[15], &inputWords[12], &inputWords[13], &inputWords[14]);
}

static void columnRound(word* const outputWords, word* const inputWords) {
	quarterRound(&outputWords[0], &outputWords[4], &outputWords[8], &outputWords[12], &inputWords[0], &inputWords[4], &inputWords[8], &inputWords[12]);
	quarterRound(&outputWords[5], &outputWords[9], &outputWords[13], &outputWords[1], &inputWords[5], &inputWords[9], &inputWords[13], &inputWords[1]);
	quarterRound(&outputWords[10], &outputWords[14], &outputWords[2], &outputWords[6], &inputWords[10], &inputWords[14], &inputWords[2], &inputWords[6]);
	quarterRound(&outputWords[15], &outputWords[3], &outputWords[7], &outputWords[11], &inputWords[15], &inputWords[3], &inputWords[7], &inputWords[11]);
}

static void doubleRound(word* outputWords, word* inputWords) {
	static word tmpWords[16];
	columnRound(tmpWords, inputWords);
	rowRound(outputWords, tmpWords);
}

static void salsa20Hash(word* const outputWords, word* const inputWords) {
	word tmpWordsIn[16];
	memcpy(tmpWordsIn, inputWords, 64);

	for ( int i = 0; i < 5; i++ ) {
		doubleRound(outputWords, tmpWordsIn);
		doubleRound(tmpWordsIn, outputWords);
	}
	for ( int i = 0; i < 16; i++ ) {
		outputWords[i] = inputWords[i] + tmpWordsIn[i];
	}
}

static void salsa20Expand256bit(unsigned char* const outputBytes, unsigned char* const keyBytes, unsigned char* const nonceBytes) {
	unsigned char tmpBytes[64] = {101,120,112,97, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 110,100,32,51,
        0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 50,45,98,121, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 116,101,32,107};
	memcpy(&tmpBytes[4], keyBytes, 16);
	memcpy(&tmpBytes[24], nonceBytes, 16);
	memcpy(&tmpBytes[44], &keyBytes[16], 16);
	salsa20Hash((word*) outputBytes, (word*) tmpBytes);
}

static void salsa20Expand128bit(unsigned char* const outputBytes, unsigned char* const keyBytes, unsigned char* const nonceBytes) {
	unsigned char tmpBytes[64] = {101,120,112,97, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 110,100,32,49,
        0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 54,45,98,121, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 116,101,32,107};
	memcpy(&tmpBytes[4], keyBytes, 16);
	memcpy(&tmpBytes[24], nonceBytes, 16);
	memcpy(&tmpBytes[44], keyBytes, 16);
	salsa20Hash((word*) outputBytes, (word*) tmpBytes);
}

static void salsa20EncryptDecryptOrWhatever(unsigned char* const outputBytes, unsigned char* const inputBytes, unsigned long long const length, 
	unsigned char* const keyBytes, unsigned long const keyLength, unsigned char* const nonceBytes) {
	
	unsigned char nonceBytesCounter[16];
	memcpy(nonceBytesCounter, nonceBytes, 8);
	unsigned long long nonceCounter = 0;

	unsigned char salsa20kv[64];

	for ( word i = 0; i < (length >> 6); i++ ) {
		memcpy(&nonceBytesCounter[8], &nonceCounter, 8);
		if (keyLength == 32) {
			salsa20Expand256bit(salsa20kv, keyBytes, nonceBytesCounter);
		} else {
			salsa20Expand128bit(salsa20kv, keyBytes, nonceBytesCounter);
		}
		for ( int j = 0; j < 64; j++ ) {
			outputBytes[i*64 + j] = inputBytes[i*64 + j] ^ salsa20kv[j];
		}
		nonceCounter += 1;
	}
	word leftOver = (length & 63);
	if (leftOver != 0) {
		memcpy(&nonceBytesCounter[8], &nonceCounter, 8);
		if (keyLength == 32) {
			salsa20Expand256bit(salsa20kv, keyBytes, nonceBytesCounter);
		} else {
			salsa20Expand128bit(salsa20kv, keyBytes, nonceBytesCounter);
		}
		for ( int j = 0; j < leftOver; j++ ) {
			outputBytes[(length >> 6)*64 + j] = inputBytes[(length >> 6)*64 + j] ^ salsa20kv[j];
		}
	}
}


static void hsalsa20(unsigned char* const outputBytes, unsigned char* const keyBytes, unsigned char* const nonceBytes) {
	unsigned char tmpBytes[64] = {101,120,112,97, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 110,100,32,51, 
		0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 50,45,98,121, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 116,101,32,107};
	memcpy(&tmpBytes[4], keyBytes, 16);
	memcpy(&tmpBytes[24], nonceBytes, 16);
	memcpy(&tmpBytes[44], &keyBytes[16], 16);

	word outputWords[16];
	word* const inputWords = (word*) tmpBytes;

	for ( int i = 0; i < 5; i++ ) {
		doubleRound(outputWords, inputWords);
		doubleRound(inputWords, outputWords);
	}
	memcpy(outputBytes, inputWords, 4);
	memcpy(&outputBytes[4], &inputWords[5], 4);
	memcpy(&outputBytes[8], &inputWords[10], 4);
	memcpy(&outputBytes[12], &inputWords[15], 4);
	memcpy(&outputBytes[16], &inputWords[6], 16);
}






-(id) init {
    if (self = [super init]) {
    	message = nil;
    	nonce = nil;
    	key = nil;
    }
    return self;
}



-(NSData *) salsa20Encrypt {
	NSAssert([self message], @"No input data available for Salsa20");
	NSAssert([self key], @"No key available for Salsa20");
	NSAssert([self nonce], @"No nonce available for Salsa20");
    NSAssert([[self nonce] length] == 8, @"The nonce needs to be 8 bytes long, Salsa20 received %lu bytes", [[self nonce] length]);
    NSAssert((([[self key] length] == 16) || ([[self key] length] == 32)), @"The key needs to be 16 or 32 bytes long, Salsa20 received %lu bytes", [[self key] length]);


	NSMutableData *cipherText = [[NSMutableData alloc] initWithLength: [[self message] length]];
	unsigned char* plainTextBytes = (unsigned char*) [[self message] bytes];
	unsigned char* cipherTextBytes = [cipherText mutableBytes];
	unsigned char* keyBytes = (unsigned char*) [[self key] bytes];
	unsigned char* nonceBytes = (unsigned char*) [[self nonce] bytes];

	salsa20EncryptDecryptOrWhatever(cipherTextBytes, plainTextBytes, [message length], keyBytes, [[self key] length], nonceBytes);

	return cipherText;
}

-(NSData *) salsa20Decrypt {
	return [self salsa20Encrypt];
}



-(NSData *) xsalsa20Encrypt {
	NSAssert([self message], @"No input data available for XSalsa20");
	NSAssert([self key], @"No key available for XSalsa20");
	NSAssert([self nonce], @"No nonce available for XSalsa20");
    NSAssert([[self nonce] length] == 24, @"The nonce needs to be 24 bytes long, XSalsa20 received %lu bytes", [[self nonce] length]);
    NSAssert([[self key] length] == 32, @"The key needs to be 32 bytes long, XSalsa20 received %lu bytes", [[self key] length]);

	unsigned char* keyBytes = (unsigned char*) [[self key] bytes];
	unsigned char* nonceBytes = (unsigned char*) [[self nonce] bytes];
    NSMutableData *key1 = [[NSMutableData alloc] initWithLength: 32];
    hsalsa20([key1 mutableBytes], keyBytes, nonceBytes);

	NSMutableData *cipherText = [[NSMutableData alloc] initWithLength: [[self message] length]];
	unsigned char* plainTextBytes = (unsigned char*) [[self message] bytes];
	unsigned char* cipherTextBytes = [cipherText mutableBytes];
	keyBytes = (unsigned char*) [key1 bytes];
	nonceBytes = (unsigned char*) (&[[self nonce] bytes][16]);

	salsa20EncryptDecryptOrWhatever(cipherTextBytes, plainTextBytes, [message length], keyBytes, [key1 length], nonceBytes);

	return cipherText;
}

-(NSData *) xsalsa20Decrypt {
	return [self xsalsa20Encrypt];
}


+(NSData *) createKeyFromSharedSecret: (NSData *) sharedSecret {
	NSMutableData *nonce = [[NSMutableData alloc] initWithLength: 16];
	NSMutableData *key = [[NSMutableData alloc] initWithLength: 32];
	hsalsa20([key mutableBytes], (unsigned char*) [sharedSecret bytes], [nonce mutableBytes]);
	[nonce release];
	return key;
}
	
@end











//@implementation Rijndael256
//@synthesize message;
//@synthesize iv;
//@synthesize key;
//
//
//
//
//
//@end
//
//
















