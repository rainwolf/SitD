/*
License, info, etc
------------------
This implementation is made by me, Walied Othman, to contact me mail to rainwolf@submanifold.be, always mention wether it's about 
FGInt for Objective-C, preferably in the subject line. My source code is free, but only to other free software, 
it's a two-way street, if you use my code in an application from which you won't make any money of (e.g. software for the good of 
mankind) then go right ahead, I do demand acknowledgement for my work.  However, if you're using my code in a commercial application, 
an application from which you'll make money, then yes, I charge a license-fee, as described in the license agreement for commercial 
use, see the textfile in this zip-file.
If you're going to use these implementations, let me know, so I can put up a link on my page if desired, I 'm always curious as to 
see where my spawn ends up in.  If any algorithm is patented in your country, you should acquire a license before using it.  Modified 
versions of this software must contain an acknowledgement of the original author (=me).

This implementation is available at 
http://www.submanifold.be

copyright 2012, Walied Othman
This header may not be removed.
*/

#import <Foundation/Foundation.h>
#import <Security/SecRandom.h>

typedef uint32_t FGIntBase;
typedef uint64_t FGIntOverflow;
typedef int64_t FGIntIndex;
typedef unsigned char tag;

typedef enum {error, equal, smaller, larger} tCompare;
#define FGInt_version 20141115
#define karatsubaThreshold 300 // ToBeDetermined
#define barrettThreshold 512
#define quotientKey @"quotient"
#define remainderKey @"remainder"
#define A_KEY @"a"
#define B_KEY @"b"
#define p192Bytes {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xfe,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}
#define p224Bytes {0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}
#define p256Bytes {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0xff,0xff,0xff,0xff}
#define p384Bytes {0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xfe,0xff,0xff,0xff,0xff,0xff,0xff,0xff,\
				   0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}
#define p521Bytes {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,\
				   0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x01,0x00,0x00}
#define p192 0
#define p224 1
#define p256 2
#define p384 3
#define p521 4




@interface FGInt : NSObject <NSMutableCopying> {
    NSMutableData *number;
    BOOL sign;
}

@property (assign, readwrite) BOOL sign;
@property (assign, readwrite) NSMutableData *number;

-(FGInt *) initWithNZeroes: (FGIntOverflow) n;
-(FGInt *) initAsP25519;
-(FGInt *) initAsZero;
-(FGInt *) initAsOne;
-(id) initWithCapacity: (FGIntOverflow) capacity;
-(id) initWithNumber: (NSMutableData *) initNumber;
-(id) initWithoutNumber;
-(void) dealloc;
-(void) eraseAndRelease;
// -(id) shallowCopy;
-(void) verifyAdjust;
+(void) verifyAdjustNumber: (NSMutableData *) numberData;

-(NSMutableData *) number;
-(void) setNumber: (NSMutableData *) inputNumber;

-(FGInt *) initWithBase10String: (NSString *) base10String;
-(FGInt *) initWithFGIntBase: (FGIntBase) fGIntBase;
-(FGInt *) initWithNegativeFGIntBase: (FGIntBase) fGIntBase;
-(FGInt *) initWithNSString: (NSString *) string;
-(FGInt *) initWithNSData: (NSData *) nsData;
-(FGInt *) initWithMPINSData: (NSData *) mpiNSData;
-(FGInt *) initWithBigEndianNSData: (NSData *) bigEndianNSData;
-(id) initWithRandomNumberOfBitSize: (FGIntOverflow) bitSize;
-(id) initWithRandomNumberAtMost: (FGInt *) atMost;
-(FGInt *) initWithCurve25519SecretKey;
-(FGInt *) initWithNSDataToEd25519FGInt: (NSData *) nsData;
-(NSData *) toNSData;
-(NSData *) toMPINSData;
-(NSData *) toBigEndianNSData;
-(NSData *) toBigEndianNSDataOfLength: (FGIntOverflow) length;
-(NSString *) toNSString;

// +(FGIntBase) divideFGIntNumberByIntBis: (NSMutableArray *) FGIntNumber divideBy: (FGIntBase) divInt;
// //-(id) duplicate;
// -(NSMutableArray *) duplicateNumber;
-(NSString *) toBase10String;
+(tCompare) compareAbsoluteValueOf: (FGInt *) fGInt1 with: (FGInt *) fGInt2;
-(BOOL) isZero;
-(BOOL) isOne;
-(BOOL) isEven;
+(FGInt *) add: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
-(void) changeSign;
+(FGInt *) subtract: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) pencilPaperMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) karatsubaMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) multiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) pencilPaperSquare: (FGInt *) fGInt;
+(FGInt *) karatsubaSquare: (FGInt *) fGInt;
+(FGInt *) square: (FGInt *) fGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN;
-(void) shiftLeftBy32;
-(void) shiftRightBy32;
-(void) shiftLeftBy32Times: (FGIntOverflow) n;
-(void) shiftRightBy32Times: (FGIntOverflow) n;
-(void) shiftLeft;
-(void) shiftRight;
-(void) shiftRightBy: (FGIntOverflow) by;
-(void) shiftLeftBy: (FGIntOverflow) by;
-(void) increment;
-(void) decrement;
-(void) multiplyByInt: (FGIntBase) multInt;
-(void) subtractWith: (FGInt *) fGInt;
-(void) addWith: (FGInt *) fGInt;
-(void) subtractWith: (FGInt *) fGInt multipliedByInt: (FGIntBase) multInt;
+(FGInt *) reduce: (FGInt *) fGInt bySubtracting: (FGInt *) nFGInt atMost: (FGIntBase) nTimes;
-(FGInt *) reduceBySubtracting: (FGInt *) nFGInt atMost: (FGIntBase) nTimes;
+(NSDictionary *) longDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) newtonInversion: (FGInt *) fGInt withPrecision: (FGIntOverflow) precision;
+(NSDictionary *) barrettDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision;
+(FGInt *) barrett: (FGInt *) fGInt modulo: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision;
+(FGInt *) barrettModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision;
+(FGInt *) longDivisionMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) longDivisionModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN barrettMod: (FGInt *) modFGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN longDivisionMod: (FGInt *) modFGInt;
+(FGInt *) mod: (FGInt *) fGInt by: (FGInt *) modFGInt;
+(NSDictionary *) divide: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) gcd: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) binaryGCD: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) lcm: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) modularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt;
+(FGInt *) invert: (FGInt *) fGInt moduloPrime: (FGInt *) pFGInt;
+(FGInt *) shiftEuclideanInvert: (FGInt *) aFGInt mod: (FGInt *) nFGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN montgomeryMod: (FGInt *) modFGInt;
// +(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN montgomeryMod: (FGInt *) modFGInt withStop: (BOOL *) stop;
+(FGInt *) leftShiftModularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt;
-(FGIntBase) modFGIntByInt: (FGIntBase) divInt;
-(void) divideByInt: (FGIntBase) divInt;
-(BOOL) trialDivision;
+(NSDictionary *) bezoutBachet: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
-(BOOL) rabinMillerTest: (FGIntBase) numberOfTests;
-(BOOL) rabinMillerTest: (FGIntBase) numberOfTests withStop: (BOOL *) stop;
-(BOOL) primalityTest: (FGIntBase) numberOfTests;
-(BOOL) primalityTest: (FGIntBase) numberOfTests withStop: (BOOL *) stop;
+(FGInt *) divide: (FGInt *) fGInt byFGIntBase: (FGIntBase) divInt;
-(int) legendreSymbolMod: (FGInt *) pFGInt;
-(int) legendreSymbolMod: (FGInt *) pFGInt withStop: (BOOL *) stop;
+(FGInt *) squareRootOf: (FGInt *) fGInt mod: (FGInt *) pFGInt;
+(FGInt *) squareRootOf: (FGInt *) fGInt mod: (FGInt *) pFGInt withStop: (BOOL *) stop;
-(FGInt *) factorial;
//-(FGInt *) findNearestLargerPrime;
-(void) findNearestLargerPrime;
-(void) findLargerPrime;
-(void) findNearestLargerPrimeWithRabinMillerTests: (FGIntBase) numberOfTests;
-(void) findLargerPrimeWithRabinMillerTests: (FGIntBase) numberOfTests;
//-(FGInt *) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt;
-(void) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt;
-(void) findLargerDSAPrimeWith: (FGInt *) qFGInt;
-(FGInt *) isNearlyPrimeAndAtLeast: (FGIntOverflow) leastSize;


+(NSString *) convertNSDataToBase64: (NSData *) nsData;
+(NSString *) convertNSStringToBase64: (NSString *) nsString;
// +(int) getBase64Index: (char) base64Char;
+(NSData *) convertBase64ToNSData: (NSString *) base64String;
+(NSString *) convertBase64ToNSString: (NSString *) base64String;
-(FGIntOverflow) bitSize;
-(FGIntOverflow) byteSize;

-(FGInt *) modNISTP192;
-(FGInt *) modNISTP192: (FGInt *) p192FGInt;
-(FGInt *) modNISTP224;
-(FGInt *) modNISTP224: (FGInt *) p224FGInt;
-(FGInt *) modNISTP256;
-(FGInt *) modNISTP256: (FGInt *) p256FGInt;
-(FGInt *) modNISTP384;
-(FGInt *) modNISTP384: (FGInt *) p384FGInt;
-(FGInt *) modNISTP521;
-(FGInt *) modNISTP521: (FGInt *) p521FGInt;
-(FGInt *) modNISTprime: (FGInt *) nistFGInt andTag: (tag) nistTag;

+(FGInt *) addModulo25638: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) subtractModulo25638: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) multiplyModulo25638: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) squareModulo25638: (FGInt *) fGInt;
-(void) mod25519;
+(FGInt *) invertMod25519: (FGInt *) fGInt;

+(FGInt *) addBasePointOnCurve25519: (FGInt *) x0 kTimes: (FGInt *) kTimes;
+(FGInt *) raise: (FGInt *) fGInt  toThePowerMod25519: (FGInt *) fGIntN;

// -(void) shiftRightBy136;
-(void) mod1305;
+(FGInt *) multiplyModulo1305ish: (FGInt *) fGInt1 and: (FGInt *) fGInt2;

@end