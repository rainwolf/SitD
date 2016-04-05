#import "Ed25519SHA512.h"
#import "FGIntXtra.h"
#import <Security/SecRandom.h>





@implementation Ed25519Point
@synthesize x;
@synthesize y;
@synthesize projectiveZ;
@synthesize extendedT;


-(id) init {
    if ((self = [super init])) {
        x = nil;
        y = nil;
        projectiveZ = nil;
        extendedT = nil;
    }
    return self;
}

-(id) initAsInfinity {
    if ((self = [super init])) {
        x = [[FGInt alloc] initAsZero];
        y = [[FGInt alloc] initWithFGIntBase: 1];
        projectiveZ = nil;
        extendedT = nil;
    }
    return self;
}


-(id) initEd25519BasePointWithoutCurve {
    if ((self = [super init])) {
        x = [[FGInt alloc] initWithNZeroes: 8];
        FGIntBase* numberArray = [[x number] mutableBytes];
        numberArray[0] = 2401621274u; numberArray[1] = 3377868128u; numberArray[2] = 2502272946u; numberArray[3] = 1764542304u; 
        numberArray[4] = 4258716764u; numberArray[5] = 3232031281u; numberArray[6] = 3446559742u; numberArray[7] = 560543443u; 
        y = [[FGInt alloc] initWithNZeroes: 8];
        numberArray = [[y number] mutableBytes];
        numberArray[0] = 1717986904u; numberArray[1] = 1717986918u; numberArray[2] = 1717986918u; numberArray[3] = 1717986918u; 
        numberArray[4] = 1717986918u; numberArray[5] = 1717986918u; numberArray[6] = 1717986918u; numberArray[7] = 1717986918u; 
        projectiveZ = nil;
        extendedT = nil;
    }
    return self;
}

-(id) initFromCompressed25519NSDataWithoutCurve: (NSData *) compressedPoint {
	if ([compressedPoint length] != 32) {
		return nil;
	}
    if ((self = [super init])) {
    	y = [[FGInt alloc] initWithNSData: compressedPoint];
    	FGIntBase* numberArray = [[y number] mutableBytes];
    	FGIntBase signBit = 0;
    	if ([[y number] length]/4 == 8) {
    		signBit = numberArray[7] >> 31;
    		numberArray[7] = numberArray[7] - (signBit << 31);
    	}
        FGInt *d = [[FGInt alloc] initWithNZeroes: 8];
        numberArray = [[d number] mutableBytes];
        numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
        numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 
        FGInt *ySquare = [FGInt squareModulo25638: y];
        FGInt *u = [ySquare mutableCopy];
        [u decrement];
        FGInt *v = [FGInt multiplyModulo25638: ySquare and: d];
        [v increment];
        [d release];
        [ySquare release];

        FGInt *q58 = [[FGInt alloc] initAsP25519];
        FGInt *tmpFGInt = [[FGInt alloc] initWithFGIntBase: 5];
        [q58 subtractWith: tmpFGInt];
        [tmpFGInt release];
        [q58 shiftRightBy: 3];

        tmpFGInt = [FGInt squareModulo25638: v];
        FGInt *vCubed = [FGInt multiplyModulo25638: v and: tmpFGInt];
        FGInt *v7 = [FGInt squareModulo25638: tmpFGInt];
        [tmpFGInt release];
        tmpFGInt = v7;
        v7 = [FGInt multiplyModulo25638: tmpFGInt and: vCubed];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiplyModulo25638: v7 and: u];
        [v7 release];
        v7 = [FGInt raise: tmpFGInt toThePowerMod25519: q58];
        [q58 release];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiplyModulo25638: vCubed and: v7];
        [v7 release];
        [vCubed release];
        FGInt *beta = [FGInt multiplyModulo25638: tmpFGInt and: u];
        [tmpFGInt release];
        tmpFGInt = [FGInt squareModulo25638: beta];
        FGInt *t1 = [FGInt multiplyModulo25638: tmpFGInt and: v];
        [v release];
        [tmpFGInt release];
        [u setSign: NO];
        [u mod25519];
        [t1 mod25519];
        if ([FGInt compareAbsoluteValueOf: t1 with: u] == equal) {
	        FGInt *sqrtMinusOne = [[FGInt alloc] initWithNZeroes: 8];
	        numberArray = [[sqrtMinusOne number] mutableBytes];
	        numberArray[0] = 1242472624u; numberArray[1] = 3303938855u; numberArray[2] = 2905597048u; numberArray[3] = 792926214u; 
	        numberArray[4] = 1039914919u; numberArray[5] = 726466713u; numberArray[6] = 1338105611u; numberArray[7] = 730014848u; 
        	tmpFGInt = [FGInt multiplyModulo25638: beta and: sqrtMinusOne];
        	[beta release];
        	beta = tmpFGInt;
            [sqrtMinusOne release];
        }
        [t1 release];
        [u release];

		
    	[beta mod25519];
    	numberArray = [[beta number] mutableBytes];
    	if ((numberArray[0] % 2) != signBit) {
    		[beta setSign: NO];
    		[beta mod25519];
    	}
    	x = beta;

        projectiveZ = nil;
        extendedT = nil;
    }
    return self;
}

-(void) dealloc {
    if (x != nil) {
        [x release];
    }
    if (y != nil) {
        [y release];
    }
    if (projectiveZ != nil) {
        [projectiveZ release];
    } 
    if (extendedT != nil) {
        [extendedT release];
    } 
    [super dealloc];
}



-(id) mutableCopyWithZone: (NSZone *) zone {
    Ed25519Point *newEd25519Point = [[Ed25519Point allocWithZone: zone] init];
    [newEd25519Point setX: [x mutableCopy]];
    [newEd25519Point setY: [y mutableCopy]];
    if (projectiveZ != nil) {
        [newEd25519Point setProjectiveZ: [projectiveZ mutableCopy]];
    } else {
        [newEd25519Point setProjectiveZ: nil];
    }
    if (extendedT != nil) {
        [newEd25519Point setExtendedT: [extendedT mutableCopy]];
    } else {
        [newEd25519Point setExtendedT: nil];
    }
    return newEd25519Point;
}


-(NSData *) to25519NSData {
	FGIntBase* numberArray = [[x number] mutableBytes];
	FGIntBase signBit = numberArray[0] % 2;
	NSMutableData *result = [[y number] mutableCopy];
	[result setLength: 32];
	numberArray = [result mutableBytes];
	numberArray[7] = numberArray[7] | (signBit << 31);
	return result;
}


-(void) makeProjective25519 {
    projectiveZ = [[FGInt alloc] initWithFGIntBase: 1];
    extendedT = [FGInt multiplyModulo25638: x and: y];
}
-(void) makeAffine25519 {
	FGInt *p25519 = [[FGInt alloc] initAsP25519];
    FGInt  *tmpFGInt, *zInv = [FGInt invert: projectiveZ moduloPrime: p25519];
    tmpFGInt = [FGInt multiply: y and: zInv];
    [y release];
    [tmpFGInt mod25519];
    y = tmpFGInt;

    tmpFGInt = [FGInt multiply: x and: zInv];
    [x release];
    [tmpFGInt mod25519];
    x = tmpFGInt;
    [projectiveZ release];
    projectiveZ = nil;
    [extendedT release];
    extendedT = nil;
    [p25519 release];
}





+(Ed25519Point *) projectiveDoubleEd25519: (Ed25519Point *) tecPoint {
	FGInt *aFGInt = [FGInt squareModulo25638: [tecPoint x]];
	FGInt *bFGInt = [FGInt squareModulo25638: [tecPoint y]];
	FGInt *cFGInt = [FGInt squareModulo25638: [tecPoint projectiveZ]];

	FGInt *tmpFGInt = [FGInt addModulo25638: [tecPoint x] and: [tecPoint y]];
	FGInt *eFGInt = [FGInt squareModulo25638: tmpFGInt];
	[tmpFGInt release];
	tmpFGInt = [FGInt subtractModulo25638: eFGInt and: aFGInt];
	[eFGInt release];
	eFGInt = [FGInt subtractModulo25638: tmpFGInt and: bFGInt];
	[tmpFGInt release];	

	FGInt *gFGInt = [FGInt subtractModulo25638: bFGInt and: aFGInt];
	tmpFGInt = [FGInt subtractModulo25638: gFGInt and: cFGInt];
	FGInt *fFGInt = [FGInt subtractModulo25638: tmpFGInt and: cFGInt];
	[tmpFGInt release];
	[cFGInt release];
	FGInt *zero = [[FGInt alloc] initAsZero];
	tmpFGInt = [FGInt subtractModulo25638: zero and: aFGInt];
	[zero release];
	[aFGInt release];
	FGInt *hFGInt = [FGInt subtractModulo25638: tmpFGInt and: bFGInt];
	[tmpFGInt release];
	// [dFGInt release];
	[bFGInt release];

	Ed25519Point *result = [[Ed25519Point alloc] init];
	[result setX: [FGInt multiplyModulo25638: eFGInt and: fFGInt]];
	[result setY: [FGInt multiplyModulo25638: gFGInt and: hFGInt]];
	[result setExtendedT: [FGInt multiplyModulo25638: eFGInt and: hFGInt]];
	[result setProjectiveZ: [FGInt multiplyModulo25638: gFGInt and: fFGInt]];
	[eFGInt release];
	[fFGInt release];
	[gFGInt release];
	[hFGInt release];

	return result;
}


+(Ed25519Point *) projectiveAddEd25519: (Ed25519Point *) tecPoint1 and: (Ed25519Point *) tecPoint2 withD: (FGInt *) d {
	FGInt *aFGInt = [FGInt multiplyModulo25638: [tecPoint1 x] and: [tecPoint2 x]];
	FGInt *bFGInt = [FGInt multiplyModulo25638: [tecPoint1 y] and: [tecPoint2 y]];
	FGInt *tmpFGInt = [FGInt multiplyModulo25638: [tecPoint1 extendedT] and: [tecPoint2 extendedT]];
	FGInt *cFGInt = [FGInt multiplyModulo25638: tmpFGInt and: d];
	[tmpFGInt release];
	FGInt *dFGInt = [FGInt multiplyModulo25638: [tecPoint1 projectiveZ] and: [tecPoint2 projectiveZ]];
	FGInt *eFGInt = [FGInt addModulo25638: [tecPoint1 x] and: [tecPoint1 y]];
	FGInt *fFGInt = [FGInt addModulo25638: [tecPoint2 x] and: [tecPoint2 y]];
	tmpFGInt = [FGInt multiplyModulo25638: eFGInt and: fFGInt];
	[eFGInt release];
	[fFGInt release];
	fFGInt = [FGInt subtractModulo25638: tmpFGInt and: aFGInt];
	[tmpFGInt release];
	eFGInt = [FGInt subtractModulo25638: fFGInt and: bFGInt];
	[fFGInt release];
	FGInt *hFGInt = [FGInt addModulo25638: aFGInt and: bFGInt];
	fFGInt = [FGInt subtractModulo25638: dFGInt and: cFGInt];
	FGInt *gFGInt = [FGInt addModulo25638: dFGInt and: cFGInt];
	[aFGInt release];
	[bFGInt release];
	[cFGInt release];
	[dFGInt release];

	Ed25519Point *result = [[Ed25519Point alloc] init];
	[result setX: [FGInt multiplyModulo25638: eFGInt and: fFGInt]];
	[result setY: [FGInt multiplyModulo25638: gFGInt and: hFGInt]];
	[result setExtendedT: [FGInt multiplyModulo25638: eFGInt and: hFGInt]];
	[result setProjectiveZ: [FGInt multiplyModulo25638: gFGInt and: fFGInt]];
	[eFGInt release];
	[fFGInt release];
	[gFGInt release];
	[hFGInt release];

	return result;
}





+(Ed25519Point *) addEd25519: (Ed25519Point *) tecPoint kTimes: (FGInt *) kTimes {
    Ed25519Point *dbl, *add;
   	Ed25519Point *tecPoint1 = [[Ed25519Point alloc] initAsInfinity], *tecPoint2 = [tecPoint mutableCopy];
   	// [tecPoint1 setTec: [tecPoint2 tec]];

   	[tecPoint1 makeProjective25519]; 
   	[tecPoint2 makeProjective25519];

    FGInt *d = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* numberArray = [[d number] mutableBytes];
    numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
    numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 

    FGIntOverflow kLength = [[kTimes number] length]/4;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kTimes number] mutableBytes];
    tmp = kFGIntNumber[kLength - 1];
    int j = 31;
    while ((tmp & (1 << j)) == 0) {
        --j;
    }
    while (j >= 0) {
        if ((tmp & (1 << j)) == 0) {
        	dbl = [Ed25519Point projectiveDoubleEd25519: tecPoint1];
        	add = [Ed25519Point projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
        	[tecPoint1 release];
        	tecPoint1 = dbl;
        	[tecPoint2 release];
        	tecPoint2 = add;
        } else {
        	dbl = [Ed25519Point projectiveDoubleEd25519: tecPoint2];
        	add = [Ed25519Point projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
        	[tecPoint1 release];
        	tecPoint1 = add;
        	[tecPoint2 release];
        	tecPoint2 = dbl;
        }
        --j;
    }
   for( FGIntIndex i = kLength - 2; i >= 0; i-- ) {
        tmp = kFGIntNumber[i];
        for( j = 31; j >= 0; --j ) {
	        if ((tmp & (1 << j)) == 0) {
	        	dbl = [Ed25519Point projectiveDoubleEd25519: tecPoint1];
	        	add = [Ed25519Point projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
	        	[tecPoint1 release];
	        	tecPoint1 = dbl;
	        	[tecPoint2 release];
	        	tecPoint2 = add;
	        } else {
	        	dbl = [Ed25519Point projectiveDoubleEd25519: tecPoint2];
	        	add = [Ed25519Point projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
	        	[tecPoint1 release];
	        	tecPoint1 = add;
	        	[tecPoint2 release];
	        	tecPoint2 = dbl;
	        }
        }
    }
    [tecPoint2 release];
    [d release];

    [tecPoint1 makeAffine25519];

    return tecPoint1;
}

+(Ed25519Point *) addEd25519BasePointkTimes: (FGInt *) kTimes {
    Ed25519Point *tecPoint = [[Ed25519Point alloc] initEd25519BasePointWithoutCurve];
    Ed25519Point *dbl, *add;
    Ed25519Point *result = [[Ed25519Point alloc] initAsInfinity], *tecPoint2 = [tecPoint mutableCopy];
    // [result setTec: [tecPoint2 tec]];

    [result makeProjective25519]; 
    [tecPoint2 makeProjective25519];

    FGInt *d = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* numberArray = [[d number] mutableBytes];
    numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
    numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 

    FGIntOverflow kLength = [[kTimes number] length]/4;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kTimes number] mutableBytes];
    tmp = kFGIntNumber[kLength - 1];
    int j = 31;
    while ((tmp & (1 << j)) == 0) {
        --j;
    }
    while (j >= 0) {
        if ((tmp & (1 << j)) == 0) {
            dbl = [Ed25519Point projectiveDoubleEd25519: result];
            add = [Ed25519Point projectiveAddEd25519: result and: tecPoint2 withD: d];
            [result release];
            result = dbl;
            [tecPoint2 release];
            tecPoint2 = add;
        } else {
            dbl = [Ed25519Point projectiveDoubleEd25519: tecPoint2];
            add = [Ed25519Point projectiveAddEd25519: result and: tecPoint2 withD: d];
            [result release];
            result = add;
            [tecPoint2 release];
            tecPoint2 = dbl;
        }
        --j;
    }
   for( FGIntIndex i = kLength - 2; i >= 0; i-- ) {
        tmp = kFGIntNumber[i];
        for( j = 31; j >= 0; --j ) {
            if ((tmp & (1 << j)) == 0) {
                dbl = [Ed25519Point projectiveDoubleEd25519: result];
                add = [Ed25519Point projectiveAddEd25519: result and: tecPoint2 withD: d];
                [result release];
                result = dbl;
                [tecPoint2 release];
                tecPoint2 = add;
            } else {
                dbl = [Ed25519Point projectiveDoubleEd25519: tecPoint2];
                add = [Ed25519Point projectiveAddEd25519: result and: tecPoint2 withD: d];
                [result release];
                result = add;
                [tecPoint2 release];
                tecPoint2 = dbl;
            }
        }
    }
    [tecPoint2 release];
    [d release];
    [tecPoint release];

    [result makeAffine25519];

    return result;
}


+(Ed25519Point *) addEd25519: (Ed25519Point *) tecPoint1 k1Times: (FGInt *) k1FGInt and: (Ed25519Point *) tecPoint2 k2Times: (FGInt *) k2FGInt {
    if ([[k2FGInt number] length] > [[k1FGInt number] length]) {
        return [Ed25519Point addEd25519: tecPoint2 k1Times: k2FGInt and: tecPoint1 k2Times: k1FGInt];
    }
        
    FGInt *d = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* numberArray = [[d number] mutableBytes];
    numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
    numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 

    Ed25519Point *result = [[Ed25519Point alloc] initAsInfinity], *tmpECPoint;
    FGIntOverflow k1Length = [[k1FGInt number] length]/4, k2Length = [[k2FGInt number] length]/4, i;
    FGIntBase* k1FGIntNumber = [[k1FGInt number] mutableBytes];
    FGIntBase* k2FGIntNumber = [[k2FGInt number] mutableBytes];
    FGIntBase k1Base, k2Base;

    [result makeProjective25519];
    [tecPoint1 makeProjective25519];
    [tecPoint2 makeProjective25519];
    Ed25519Point *sum = [Ed25519Point projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];

    for( i = 0; i < k1Length; ++i ) {
        k1Base = k1FGIntNumber[k1Length - i - 1];
        if (k2Length > k1Length - i - 1) {
            k2Base = k2FGIntNumber[k1Length - i - 1];
        } else {
            k2Base = 0;
        }
        for( int j = 31; j >= 0; --j ) {
            tmpECPoint = [Ed25519Point projectiveDoubleEd25519: result];
            [result release];
            result = tmpECPoint;
            if ((((k1Base >> j) % 2) == 1) && (((k2Base >> j) % 2) == 1)) {
                tmpECPoint = [Ed25519Point projectiveAddEd25519: result and: sum withD: d];
                [result release];
                result = tmpECPoint;
            } else if (((k1Base >> j) % 2) == 1) {
                tmpECPoint = [Ed25519Point projectiveAddEd25519: result and: tecPoint1 withD: d];
                [result release];
                result = tmpECPoint;
            } else if (((k2Base >> j) % 2) == 1) {
                tmpECPoint = [Ed25519Point projectiveAddEd25519: result and: tecPoint2 withD: d];
                [result release];
                result = tmpECPoint;
            }
        }
    }
    [sum release];
    [d release];

    [[tecPoint1 projectiveZ] release];
    [[tecPoint1 extendedT] release];
    [[tecPoint2 projectiveZ] release];
    [[tecPoint2 extendedT] release];
    [tecPoint1 setProjectiveZ: nil];
    [tecPoint2 setProjectiveZ: nil];
    [tecPoint1 setExtendedT: nil];
    [tecPoint2 setExtendedT: nil];
    [result makeAffine25519];

    return result;
}

-(NSData *) toMontgomery25519X {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1];
    FGInt *oneMinusY = [FGInt subtractModulo25638:one and:y];
    FGInt *oneMinusYInverted = [FGInt invertMod25519: oneMinusY];
    FGInt *onePlusY = [FGInt addModulo25638:one and:y];
    FGInt *result = [FGInt multiplyModulo25638:oneMinusYInverted and:onePlusY];
    
    [result mod25519];
    [one release];
    [oneMinusY release];
    [oneMinusYInverted release];
    [onePlusY release];
    
    NSData *resultData = [[result number] retain];
    
    [result release];
    
    return  resultData;
}




@end
































@implementation Ed25519SHA512
@synthesize secretKey;
@synthesize publicKey;


-(Ed25519SHA512 *) init {
    if (self = [super init]) {
        secretKey = nil;
        publicKey = nil;
    }
    return self;
}


-(id) copyWithZone: (NSZone *) zone {
    Ed25519SHA512 *newKeys = [[Ed25519SHA512 allocWithZone: zone] init];

    [newKeys setSecretKey: [secretKey copy]];
    [newKeys setPublicKey: [publicKey mutableCopy]];

    return newKeys;
}


+(FGInt *) ed25519PrivateFGInt: (NSData *) inData {
    if ([inData length] < 32) {
        return nil;
    }
    NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: [inData bytes] length: 32];
    NSData *hashData = [FGIntXtra SHA512: tmpData];
    [tmpData release];

    FGInt *secretKeyFGInt = [[FGInt alloc] initWithNSDataToEd25519FGInt: hashData];
    [hashData release];
    
    return secretKeyFGInt;
}



-(void) generateNewSecretAndPublicKey {
    if (secretKey) {
        [secretKey release];
    }
    
    NSMutableData *tmpData = [[NSMutableData alloc] initWithLength: 32];
    if (SecRandomCopyBytes(kSecRandomDefault, 32, tmpData.mutableBytes)) {
        [tmpData release];
        return;
    }
    
    secretKey = (NSData *) tmpData;
    
    NSMutableData *hashData = (NSMutableData *) [FGIntXtra SHA512: secretKey];
    tmpData = [[NSMutableData alloc] initWithBytes: [hashData bytes] length: 32];
    FGInt *secretKeyFGInt = [[FGInt alloc] initWithNSDataToEd25519FGInt: tmpData];
    // [tmpData release];
    
    publicKey = [Ed25519Point addEd25519BasePointkTimes: secretKeyFGInt];
    [secretKeyFGInt eraseAndRelease];
    
    SecRandomCopyBytes(kSecRandomDefault, [tmpData length], [tmpData mutableBytes]);
    [tmpData release];
}

-(NSData *) secretKeyToCurve25519Key {
    if (secretKey == nil) {
        return  nil;
    }
    
    NSData *hashData = [FGIntXtra SHA512: secretKey];
    NSMutableData *result = [[NSMutableData alloc] initWithBytes: [hashData bytes] length: 32];
    [hashData release];
    unsigned char* numberArray = [result mutableBytes];
    numberArray[31] = numberArray[31] | 64;
    numberArray[31] = numberArray[31] & 127;
    numberArray[0] = numberArray[0] & 248;

    return result;
}


-(NSData *) secretKeyToNSData {
    NSMutableData *result = [secretKey mutableCopy];
    // NSLog(@"kitty %lu", [result length]);
    NSData *tmpData = [publicKey to25519NSData];
    [result appendData: tmpData];
    // NSLog(@"kitty %lu", [result length]);
    [tmpData release];

    return result;
}
-(NSData *) publicKeyToNSData {
    return [publicKey to25519NSData];
}
-(NSString *) secretKeyToBase64NSString {
    return [FGInt convertNSDataToBase64: [self secretKeyToNSData]];
}
-(NSString *) publicKeyToBase64NSString {
    return [FGInt convertNSDataToBase64: [self publicKeyToNSData]];
}
-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData {
    if ([secretKeyNSData length] != 64) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d. Expected 64 bytes but received %lu", __PRETTY_FUNCTION__, __LINE__, [secretKeyNSData length]);
    }
    secretKey = [[NSData alloc] initWithBytes: [secretKeyNSData bytes] length: 32];
    publicKey = [[Ed25519Point alloc] initFromCompressed25519NSDataWithoutCurve: [secretKeyNSData subdataWithRange: NSMakeRange(32,32)]];
}
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString {
    [self setSecretKeyWithNSData: [FGInt convertBase64ToNSData: secretKeyBase64NSString]];
}
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    if ([publicKeyNSData length] != 32) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d. Expected 32 bytes but received %lu", __PRETTY_FUNCTION__, __LINE__, [publicKeyNSData length]);
    }
    publicKey = [[Ed25519Point alloc] initFromCompressed25519NSDataWithoutCurve: publicKeyNSData];
}
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString {
    [self setPublicKeyWithNSData: [FGInt convertBase64ToNSData: publicKeyBase64NSString]];
}


-(NSData *) signNSData: (NSData *) plainText {
    // FGInt *secretKeyFGInt = [Ed25519SHA512 ed25519PrivateFGInt: secretKey];
    NSData *hashData = [FGIntXtra SHA512: secretKey];
    NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: [hashData bytes] length: 32];
    FGInt *secretKeyFGInt = [[FGInt alloc] initWithNSDataToEd25519FGInt: tmpData];
    int result = SecRandomCopyBytes(kSecRandomDefault, [tmpData length], [tmpData mutableBytes]);
    [tmpData release];

    NSMutableData *r = [[NSMutableData alloc] initWithData:[hashData subdataWithRange: NSMakeRange(32, 32)]];
    result = SecRandomCopyBytes(kSecRandomDefault, [hashData length], (unsigned char *) [hashData bytes]);
    [hashData release];
    [r appendData: plainText];
    tmpData = (NSMutableData *) [FGIntXtra SHA512: r];
    result = SecRandomCopyBytes(kSecRandomDefault, [r length], [r mutableBytes]);
    [r release];
    FGInt *rFGInt = [[FGInt alloc] initWithNSData: tmpData];
    [tmpData release];
    Ed25519Point *rPoint = [Ed25519Point addEd25519BasePointkTimes: rFGInt];

    NSMutableData *signatureData = (NSMutableData *) [rPoint to25519NSData];
    [rPoint release];

    tmpData = [signatureData mutableCopy];
    [tmpData appendData: [publicKey to25519NSData]];
    [tmpData appendData: plainText];
    hashData = [FGIntXtra SHA512: tmpData];
    FGInt *hashFGInt = [[FGInt alloc] initWithNSData: hashData];
    [tmpData release];

    FGInt *tmpFGInt = [FGInt multiply: hashFGInt and: secretKeyFGInt];
    [hashFGInt release];
    [secretKeyFGInt eraseAndRelease];
    [tmpFGInt addWith: rFGInt];
    [rFGInt eraseAndRelease];
    FGInt *lFGInt = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* numberArray = [[lFGInt number] mutableBytes];
    numberArray[0] = 1559614445u; numberArray[1] = 1477600026u; numberArray[2] = 2734136534u; numberArray[3] = 350157278u; 
    numberArray[4] = 0u; numberArray[5] = 0u; numberArray[6] = 0u; numberArray[7] = 268435456u; 
    FGInt *sFGInt = [FGInt longDivisionMod: tmpFGInt by: lFGInt];
    [lFGInt release];
    [tmpFGInt eraseAndRelease];

    [[sFGInt number] setLength: 32];
    [signatureData appendData: [sFGInt number]];
    [sFGInt release];

    return signatureData;
}


-(BOOL) verifySignature: (NSData *) signatureData ofPlainTextNSData: (NSData *) plainText {
    if ([signatureData length] != 64) {
        return NO;
    }
    NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: [signatureData bytes] length: 32];
    [tmpData appendData: [publicKey to25519NSData]];
    [tmpData appendData: plainText];
    NSMutableData *hashData = (NSMutableData *) [FGIntXtra SHA512: tmpData];
    FGInt *tmpFGInt = [[FGInt alloc] initWithNSData: hashData];
    [tmpData release];
    [tmpFGInt setSign: NO];
    FGInt *lFGInt = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* numberArray = [[lFGInt number] mutableBytes];
    numberArray[0] = 1559614445u; numberArray[1] = 1477600026u; numberArray[2] = 2734136534u; numberArray[3] = 350157278u; 
    numberArray[4] = 0u; numberArray[5] = 0u; numberArray[6] = 0u; numberArray[7] = 268435456u; 
    FGInt *hashFGInt = [FGInt longDivisionMod: tmpFGInt by: lFGInt];
    [lFGInt release];

    FGInt *sFGInt = [[FGInt alloc] initWithNSData: [signatureData subdataWithRange: NSMakeRange(32, 32)]];

    Ed25519Point *basePt = [[Ed25519Point alloc] initEd25519BasePointWithoutCurve];
    Ed25519Point *verificationPoint = [Ed25519Point addEd25519: basePt k1Times: sFGInt and: publicKey k2Times: hashFGInt];
    [basePt release];
    [sFGInt release];
    [hashFGInt release];
    NSData *verificationData = [verificationPoint to25519NSData];
    [verificationPoint release];
    BOOL result = [verificationData isEqualToData: [signatureData subdataWithRange: NSMakeRange(0, 32)]];
    [verificationData release];

    return result;
}


-(NSData *) signNSString: (NSString *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData];
        return signedData;
    }
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    @autoreleasepool{
        return [self verifySignature: signature ofPlainTextNSData: [plainText dataUsingEncoding:NSUTF8StringEncoding]];;
    }
}




@end


