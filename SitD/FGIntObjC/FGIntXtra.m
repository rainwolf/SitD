#import "FGIntXtra.h"
#import "SymmetricCipher.h"

@implementation FGIntXtra




+(NSData *) SHA256HMACForKey: (NSData *) key AndData: (NSData *)data {
    unsigned char hmacBytes[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, [key bytes], [key length], [data bytes], [data length], hmacBytes);
    return [[NSData alloc] initWithBytes: hmacBytes length: CC_SHA256_DIGEST_LENGTH];
}

+(NSData *) SHA256: (NSData *) plainText {
    unsigned char hashBytes[CC_SHA256_DIGEST_LENGTH];
    if (CC_SHA256([plainText bytes], (unsigned int) [plainText length], hashBytes)) {
        return [[NSData alloc] initWithBytes: hashBytes length: CC_SHA256_DIGEST_LENGTH];
    } else {
        NSLog(@"Something went wrong calculating SHA256");
        return nil;
    }
}

+(NSData *) SHA512: (NSData *) plainText {
    unsigned char hashBytes[CC_SHA512_DIGEST_LENGTH];
    if (CC_SHA512([plainText bytes], (unsigned int) [plainText length], hashBytes)) {
        return [[NSData alloc] initWithBytes: hashBytes length: CC_SHA512_DIGEST_LENGTH];
    } else {
        NSLog(@"Something went wrong calculating SHA512");
        return nil;
    }
}

+(NSData *) randomDataOfLength: (long) length {
    NSMutableData *tmpData = [[NSMutableData alloc] initWithLength: length];
    int result = SecRandomCopyBytes(kSecRandomDefault, length, tmpData.mutableBytes);
    if (result != 0) {
        [tmpData release];
        return nil;
    } 
    return tmpData;
}



+(void) incrementNSMutableData: (NSMutableData *) data {
    unsigned char *bytes = [data mutableBytes];
    FGIntBase one = 1u;
    for ( FGIntOverflow i = 0; i < [data length]; ++i ) {
        if (one == 0) {
            break;
        }
        one = one + bytes[i];
        bytes[i] = one;
        one >>= 8;
    }
}

+(NSString *) dataToHexString: (NSData *) data {
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithFormat:@"%@", data];

    @autoreleasepool{
        NSRange range;
        NSCharacterSet *invertedHexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"] invertedSet];
        range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        while (range.location != NSNotFound) {
            [mutableStr deleteCharactersInRange: range];
            range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        }
    }

    return mutableStr;
}

+(NSData *) hexStringToNSData: (NSString *) str {
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString: str];
    @autoreleasepool{
        NSRange range;
        NSCharacterSet *invertedHexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"] invertedSet];
        range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        while (range.location != NSNotFound) {
            [mutableStr deleteCharactersInRange: range];
            range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        }
    }
    NSMutableData *result = [[NSMutableData alloc] initWithLength: [mutableStr length]/2];
    unsigned char* bytes = [result mutableBytes];
    NSData *strData = [mutableStr dataUsingEncoding: NSASCIIStringEncoding];
    const unsigned char* strBytes = [strData bytes];

    for (FGIntOverflow i = 0; i < [mutableStr length]/2; ++i ) {
        unsigned char tmpByte = strBytes[2*i];
        if (tmpByte > 64) {
            tmpByte += 9;
        }
        unsigned char byte = tmpByte << 4;
        tmpByte = strBytes[2*i + 1];
        if (tmpByte > 64) {
            tmpByte += 9;
        }
        bytes[i] = (byte | (tmpByte & 15));
    }
    return result;
}


+(NSString *) dataToBase32String: (NSData *) data {
    unsigned char base32Chars[32] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','2','3','4','5','6','7'};
    FGIntOverflow length = [data length];
    const unsigned char *bytes = [data bytes];
    FGIntOverflow i = 0;
    FGIntBase tmpBytes = 0;
    unsigned char bits = 0;
    NSMutableData *result = [[NSMutableData alloc] init];
    while (i < length) {
        tmpBytes = (tmpBytes << 8) | bytes[i];
        bits += 8;
        while (bits > 4) {
            bits -= 5;
            [result appendBytes: &base32Chars[(tmpBytes >> bits) & 31] length: 1];
        }
        ++i;
    }
    if (bits > 0) {
        [result appendBytes: &base32Chars[(tmpBytes & (31 >> (5 - bits))) << (5 - bits)] length: 1];
    }
    [result increaseLengthBy: 1];

    NSString *str = [[NSString alloc] initWithData: result encoding: NSASCIIStringEncoding];
    [result release];

    return str;
}

+(NSData *) base32StringToNSData: (NSString *) str {
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString: [str uppercaseString]];
    @autoreleasepool{
        NSRange range;
        NSCharacterSet *invertedBase32Set = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"] invertedSet];
        range = [mutableStr rangeOfCharacterFromSet: invertedBase32Set];
        while (range.location != NSNotFound) {
            [mutableStr deleteCharactersInRange: range];
            range = [mutableStr rangeOfCharacterFromSet: invertedBase32Set];
        }
    }
    NSData *strData = [mutableStr dataUsingEncoding: NSASCIIStringEncoding];
    const unsigned char* strBytes = [strData bytes];
    FGIntOverflow strLength = [mutableStr length];
    FGIntOverflow resultLength = strLength * 5 / 8 + ((((strLength*5)%8) == 0)?0:1);
    NSMutableData *result = [[NSMutableData alloc] initWithLength: resultLength];
    unsigned char* bytes = [result mutableBytes];
    FGIntOverflow i = 0, resultIdx = 0;
    FGIntOverflow tmpBytes = 0;
    unsigned char bits = 0;
    while ( i < strLength ) {
        unsigned char tmpByte = strBytes[i];
        if (tmpByte < 56) {
            tmpByte += 41;
        }
        tmpByte -= 1;
        tmpByte &= 31;
        tmpBytes = tmpByte | (tmpBytes << 5);
        ++i;
        bits += 5;
        if ((bits > 7) && (resultIdx < resultLength)) {
            bits -= 8;
            bytes[resultIdx] = tmpBytes >> bits;
            ++resultIdx;
        }
        if ((i == strLength) && (bits > 0) && (resultIdx < resultLength)) {
            tmpBytes = tmpBytes ^ ((tmpBytes >> bits) << bits);
            if (tmpBytes != 0) {
                bytes[resultIdx] = tmpBytes;
                ++resultIdx;
            }
        }
    }
    if (resultIdx < resultLength) {
        [result setLength: resultIdx];
    }

    return result;
}

+(NSString *) dataToBase64String: (NSData *) data {
    return [data base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength | NSDataBase64EncodingEndLineWithCarriageReturn | NSDataBase64EncodingEndLineWithLineFeed];
}
+(NSData *) base64StringToNSData: (NSString *) str {
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString: str];
    @autoreleasepool{
        NSRange range;
        NSCharacterSet *invertedBase32Set = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="] invertedSet];
        range = [mutableStr rangeOfCharacterFromSet: invertedBase32Set];
        while (range.location != NSNotFound) {
            [mutableStr deleteCharactersInRange: range];
            range = [mutableStr rangeOfCharacterFromSet: invertedBase32Set];
        }
    }
    return [[NSData alloc] initWithBase64EncodedString: mutableStr options: 0];
}


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
static void salsa208(word* const outputWords, word* const inputWords) {
    word tmpWordsIn[16];
    memcpy(tmpWordsIn, inputWords, 64);

    doubleRound(outputWords, tmpWordsIn);
    doubleRound(tmpWordsIn, outputWords);
    doubleRound(outputWords, tmpWordsIn);
    doubleRound(tmpWordsIn, outputWords);
    for ( int i = 0; i < 16; i++ ) {
        outputWords[i] = inputWords[i] + tmpWordsIn[i];
    }
}
static void scryptBlockMix(unsigned char* bIn, unsigned char* bOut, unsigned int blocksize) {
    unsigned char x[64];
    unsigned char t[64];
    memcpy(x, &bIn[(2*blocksize - 1)*64], 64);
    for ( unsigned int i = 0; i < (2*blocksize); i += 2 ) {
        for ( int j = 0; j < 64; ++j ) {
            t[j] = x[j] ^ bIn[i*64 + j];
        }
        salsa208((word*) x, (word*) t);
        memcpy(&bOut[(i/2)*64], x, 64);
        for ( int j = 0; j < 64; ++j ) {
            t[j] = x[j] ^ bIn[(i + 1)*64 + j];
        }
        salsa208((word*) x, (word*) t);
        memcpy(&bOut[(i/2)*64 + blocksize*64], x, 64);
    }
}
static void scryptROMix(unsigned char* b, unsigned int blocksize, unsigned long long cost) {
    unsigned char x[128*blocksize];
    unsigned char* v = malloc(128*cost*blocksize);
    unsigned char t[128*blocksize];

    memcpy(x, b, 128*blocksize);

    for ( unsigned int i = 0; i < cost; ++i ) {
        memcpy(&v[i*128*blocksize], x, 128*blocksize);
        scryptBlockMix(x, t, blocksize);
        memcpy(x, t, 128*blocksize);
    }



    for ( unsigned int i = 0; i < cost; ++i ) {
        unsigned long long j = ((unsigned long long*) x)[16*blocksize - 8] % cost;
        for ( unsigned int k = 0; k < 128*blocksize; ++k ) {
            t[k] = x[k] ^ v[j*128*blocksize + k];
        }
        scryptBlockMix(t, x, blocksize);
    }    

    memcpy(b, x, 128*blocksize);
    free(v);
}


+(NSData *) scryptPassphrase: (NSString *) passphrase withSalt: (NSData *) salt cost: (unsigned long long) cost parallelism: (unsigned int) parallelism blockSize: (unsigned int) blocksize keyLength: (unsigned int) keyLength {
    if (((cost & (cost - 1)) != 0) && (cost > 1)) {
        NSLog(@" The cost parameter should be a power of 2 and larger than 1");
        return nil;
    }
    if (((unsigned long long) 4*parallelism*blocksize) >> 30) {
        NSLog(@" The parallelism/blocksize parameter are too large");
        return nil;
    }
    NSData *passphraseData = [passphrase dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *prior = [[NSMutableData alloc] initWithLength: parallelism*128*blocksize];
    unsigned char *priorBytes = [prior mutableBytes];
    CCKeyDerivationPBKDF(kCCPBKDF2, [passphraseData bytes], [passphraseData length], [salt bytes], [salt length], kCCPRFHmacAlgSHA256, 1, priorBytes, parallelism*128*blocksize);
    for ( unsigned int i = 0; i < parallelism; ++i ) {
        scryptROMix(&priorBytes[128*blocksize*i], blocksize, cost);
    }

    NSMutableData *derivedKey = [[NSMutableData alloc] initWithLength: keyLength];
    unsigned char* derivedKeyBytes = [derivedKey mutableBytes];
    CCKeyDerivationPBKDF(kCCPBKDF2, [passphraseData bytes], [passphraseData length], priorBytes, parallelism*128*blocksize, kCCPRFHmacAlgSHA256, 1, derivedKeyBytes, keyLength);
    [prior release];

    return derivedKey;
}





@end































