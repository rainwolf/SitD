#import "BN256.h"





// quadratic non-residue -1, GFp^2 = GF(p)[X] / (X^2 + 1)
// i^2 = -1
// a + bX 


@implementation GFP2
@synthesize a, b;


-(id) init {
    if (self = [super init]) {
    	a = nil;
    	b = nil;
    }
    return self;
}
-(id) initOne {
    if (self = [super init]) {
    	a = [[FGInt alloc] initWithFGIntBase: 1];
    	b = [[FGInt alloc] initAsZero];
    }
    return self;
}
-(id) initZero {
    if (self = [super init]) {
    	a = [[FGInt alloc] initAsZero];
    	b = [[FGInt alloc] initAsZero];
    }
    return self;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 2*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSData *tmpData = [[NSData alloc] initWithBytes: &bytes[cnstLength] length: cnstLength];
    	a = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
		tmpData = [[NSData alloc] initWithBytes: bytes length: cnstLength];
    	b = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
    }
    return self;
}
-(void) dealloc {
    [a release];
    [b release];
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
    GFP2 *newGFP2 = [[GFP2 allocWithZone: zone] init];

    [newGFP2 setA: [a mutableCopy]];
    [newGFP2 setB: [b mutableCopy]];

    return newGFP2;
}
-(void) changeSign {
	[a changeSign];
	[b changeSign];
}
-(BOOL) isZero {
	if ([a isZero] && [b isZero]) {
		return YES;
	}
	return NO;
}
-(void) conjugate {
	[b changeSign];
}

+(GFP2 *) add: (GFP2 *) p1 and: (GFP2 *) p2 with: (FGInt *) pFGInt {
	GFP2 *sum = [[GFP2 alloc] init];

	FGInt *tmpFGInt;
	tmpFGInt = [FGInt add: [p1 a] and: [p2 a]];
	[tmpFGInt reduceBySubtracting: pFGInt atMost: 1];
	[sum setA: tmpFGInt];
	tmpFGInt = [FGInt add: [p1 b] and: [p2 b]];
	[tmpFGInt reduceBySubtracting: pFGInt atMost: 1];
	[sum setB: tmpFGInt];

	return sum;
}


+(GFP2 *) subtract: (GFP2 *) p1 and: (GFP2 *) p2 with: (FGInt *) pFGInt {
	GFP2 *sum = [[GFP2 alloc] init];

	FGInt *tmpFGInt;
	tmpFGInt = [FGInt subtract: [p1 a] and: [p2 a]];
	[tmpFGInt reduceBySubtracting: pFGInt atMost: 1];
	[sum setA: tmpFGInt];
	tmpFGInt = [FGInt subtract: [p1 b] and: [p2 b]];
	[tmpFGInt reduceBySubtracting: pFGInt atMost: 1];
	[sum setB: tmpFGInt];

	return sum;
}

+(GFP2 *) multiply: (GFP2 *) p1 and: (GFP2 *) p2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *product = [[GFP2 alloc] init];

	FGInt *tmp = [FGInt pencilPaperMultiply: [p1 a] and: [p2 a]];
	FGInt *v0 = [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision];
	[tmp release];
	tmp = [FGInt pencilPaperMultiply: [p1 b] and: [p2 b]];
	FGInt *v1 = [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision],
		*tmp1 = [[FGInt add: [p1 a] and: [p1 b]] reduceBySubtracting: pFGInt atMost: 1], 
		*tmp2 = [[FGInt add: [p2 a] and: [p2 b]] reduceBySubtracting: pFGInt atMost: 1];
	[tmp release];

	tmp = [FGInt pencilPaperMultiply: tmp1 and: tmp2];
	[tmp2 release];
	[tmp1 release];
	FGInt *tmp0 = [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision];
	[tmp release];
	tmp1 = [[FGInt subtract: tmp0 and: v0] reduceBySubtracting: pFGInt atMost: 1];
	[tmp0 release];

	[product setB: [[FGInt subtract: tmp1 and: v1] reduceBySubtracting: pFGInt atMost: 1]];
	[tmp1 release];
	[product setA: [[FGInt subtract: v0 and: v1] reduceBySubtracting: pFGInt atMost: 1]];
	[v0 release];
	[v1 release];

	return product;
}

+(GFP2 *) square: (GFP2 *) p1 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *square = [[GFP2 alloc] init];

	FGInt *tmp = [FGInt pencilPaperMultiply: [p1 a] and: [p1 b]],
		*tmp1 = [[FGInt add: [p1 a] and: [p1 b]] reduceBySubtracting: pFGInt atMost: 1], *tmp2 = [[FGInt subtract: [p1 a] and: [p1 b]] reduceBySubtracting: pFGInt atMost: 1];
	FGInt *v0 = [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision];
	[tmp release];
	tmp = [FGInt pencilPaperMultiply: tmp1 and: tmp2];
	[tmp1 release];
	[tmp2 release];

	[square setA: [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision]];
	[tmp release];

	[v0 shiftLeft];
	[square setB: [v0 reduceBySubtracting: pFGInt atMost: 1]];

	return square;
}

+(GFP2 *) multiplyByResiduePlus3: (GFP2 *) p1 with: (FGInt *) pFGInt {
	GFP2 *product = [[GFP2 alloc] init];

	FGInt *tmp = [[p1 a] mutableCopy];
	[tmp multiplyByInt: 3];
	[product setA: [[FGInt subtract: tmp and: [p1 b]] reduceBySubtracting: pFGInt atMost: 4]];
	[tmp release];
	tmp = [[p1 b] mutableCopy];
	[tmp multiplyByInt: 3];
	[product setB: [[FGInt add: tmp and: [p1 a]] reduceBySubtracting: pFGInt atMost: 4]];
	[tmp release];

	return product;
}

-(void) shiftLeftWith: (FGInt *) pFGInt {
	[a shiftLeft];
	[a reduceBySubtracting: pFGInt atMost: 1];
	[b shiftLeft];
	[b reduceBySubtracting: pFGInt atMost: 1];
}

-(void) shiftRightWith: (FGInt *) pFGInt {
	if (![a isEven]) {
		[a addWith: pFGInt];
	}
	[a shiftRight];
	if (![b isEven]) {
		[b addWith: pFGInt];
	}
	[b shiftRight];
}

-(void) multiplyByInt: (unsigned char) c with: (FGInt  *) pFGInt {
	[a multiplyByInt: c];
	[a reduceBySubtracting: pFGInt atMost: c];
	[b multiplyByInt: c];
	[b reduceBySubtracting: pFGInt atMost: c];
}

-(void) multiplyByFGInt: (FGInt *) fGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *tmp = [FGInt pencilPaperMultiply: a and: fGInt];
	[a release];
	a = [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision];
	[tmp release];
	tmp = [FGInt pencilPaperMultiply: b and: fGInt];
	[b release];
	b = [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision];
	[tmp release];
}


-(GFP2 *) invertWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *tmp1 = [FGInt pencilPaperSquare: a];
	FGInt* tmp2 = [FGInt barrettMod: tmp1 by: pFGInt with: invertedP andPrecision: precision];
	[tmp1 release];

	tmp1 = [FGInt pencilPaperSquare: b];
	FGInt* tmp = [FGInt barrettMod: tmp1 by: pFGInt with: invertedP andPrecision: precision];
	[tmp1 release];

	[tmp addWith: tmp2];
	[tmp2 release];
	[tmp reduceBySubtracting: pFGInt atMost: 1];

	FGInt *denominator = [FGInt invert: tmp moduloPrime: pFGInt];
	[tmp release];

	tmp = [FGInt pencilPaperMultiply: a and: denominator];

	GFP2 *inverted = [[GFP2 alloc] init];
	[inverted setA: [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision]];
	[tmp release];

	tmp = [FGInt pencilPaperMultiply: b and: denominator];
	[tmp changeSign];
	[inverted setB: [FGInt barrettMod: tmp by: pFGInt with: invertedP andPrecision: precision]];
	[tmp release];

	return inverted;
}


+(GFP2 *) raise: (GFP2 *) gfp2 toThePower: (FGInt *) fGIntN with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    GFP2 *power = [[GFP2 alloc] initOne];
    FGIntOverflow nLength = [[fGIntN number] length]/4;
    FGIntBase tmpWord;
    GFP2 *tmp1, *tmp;
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];

    tmp1 = [gfp2 mutableCopy];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmpWord = nFGIntNumber[i];
        for( FGIntIndex j = 0; j < 32; ++j ) {
            if ((tmpWord % 2) == 1) {
                tmp = [GFP2 multiply: power and: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
                [power release];
                power = tmp;
            }
            tmp = [GFP2 square: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
            tmpWord >>= 1;
        }
    }
    tmpWord = nFGIntNumber[nLength - 1];
    while(tmpWord != 0) {
        if ((tmpWord % 2) == 1) {
            tmp = [GFP2 multiply: power and: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [power release];
            power = tmp;
        }
        tmpWord >>= 1;
        if (tmpWord != 0) {
            tmp = [GFP2 square: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
        }
    }
    
    [tmp1 release];
    
    return power;
}



-(NSString *) toBase10String {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	NSMutableString *base10String = [[NSMutableString alloc] init];
	FGInt *tmp = [FGInt longDivisionMod: a by: pFGInt];
	NSString *tmpStr = [tmp toBase10String];
	[a release];
	a = tmp;
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @" + "];
	tmp = [FGInt longDivisionMod: b by: pFGInt];
	tmpStr = [tmp toBase10String];
	[b release];
	b = tmp;
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @"i"];

	[pFGInt release];

	return base10String;	
}

-(NSData *) marshal {
	if ((a == nil) || (b == nil)) {
		return nil;
	}
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
	NSMutableData *result = [[NSMutableData alloc] init];
	FGInt *tmp = [FGInt longDivisionMod: b by: pFGInt];
	[b release];
	b = tmp;
	NSData *tmpData = [tmp toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];
	tmp = [FGInt longDivisionMod: a by: pFGInt];
	[a release];
	a = tmp;
	tmpData = [tmp toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];

	[pFGInt release];
	return result;
}


@end







// cubic non-residue b = i+3, GFp^6 = GFp^2[X] / (X^3 - b)
// a + bX + cX^2


@implementation GFP6
@synthesize a, b, c;


-(id) init {
    if (self = [super init]) {
    	a = nil;
    	b = nil;
    	c = nil;
    }
    return self;
}
-(id) initOne {
    if (self = [super init]) {
    	a = [[GFP2 alloc] initOne];
    	b = [[GFP2 alloc] initZero];
    	c = [[GFP2 alloc] initZero];
    }
    return self;
}
-(id) initZero {
    if (self = [super init]) {
    	a = [[GFP2 alloc] initZero];
    	b = [[GFP2 alloc] initZero];
    	c = [[GFP2 alloc] initZero];
    }
    return self;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 6*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: &bytes[4*cnstLength] length: 2*cnstLength];
    	a = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[2*cnstLength] length: 2*cnstLength];
    	b = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
		tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 2*cnstLength];
    	c = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
    }
    return self;
}
-(void) dealloc {
    [a release];
    [b release];
    [c release];
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
    GFP6 *newGFP6 = [[GFP6 allocWithZone: zone] init];

    [newGFP6 setA: [a mutableCopy]];
    [newGFP6 setB: [b mutableCopy]];
    [newGFP6 setC: [c mutableCopy]];

    return newGFP6;
}
-(void) changeSign {
	[a changeSign];
	[b changeSign];
	[c changeSign];
}
-(BOOL) isZero {
	if ([a isZero] && [b isZero] && [c isZero]) {
		return YES;
	}
	return NO;
}


+(GFP6 *) add: (GFP6 *) p1 and: (GFP6 *) p2 with: (FGInt *) pFGInt {
	GFP6 *sum = [[GFP6 alloc] init];

	GFP2 *tmp;
	tmp = [GFP2 add: [p1 a] and: [p2 a] with: pFGInt];
	[sum setA: tmp];
	tmp = [GFP2 add: [p1 b] and: [p2 b] with: pFGInt];
	[sum setB: tmp];
	tmp = [GFP2 add: [p1 c] and: [p2 c] with: pFGInt];
	[sum setC: tmp];

	return sum;
}

+(GFP6 *) subtract: (GFP6 *) p1 and: (GFP6 *) p2 with: (FGInt *) pFGInt {
	GFP6 *sum = [[GFP6 alloc] init];

	GFP2 *tmp;
	tmp = [GFP2 subtract: [p1 a] and: [p2 a] with: pFGInt];
	[sum setA: tmp];
	tmp = [GFP2 subtract: [p1 b] and: [p2 b] with: pFGInt];
	[sum setB: tmp];
	tmp = [GFP2 subtract: [p1 c] and: [p2 c] with: pFGInt];
	[sum setC: tmp];

	return sum;
}

+(GFP6 *) multiply: (GFP6 *) p1 and: (GFP6 *) p2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP6 *product = [[GFP6 alloc] init];

	GFP2 *v0 = [GFP2 multiply: [p1 a] and: [p2 a]  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *v1 = [GFP2 multiply: [p1 b] and: [p2 b]  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *v2 = [GFP2 multiply: [p1 c] and: [p2 c]  with: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp1 = [GFP2 add: [p1 b] and: [p1 c]  with: pFGInt];
	GFP2 *tmp2 = [GFP2 add: [p2 b] and: [p2 c]  with: pFGInt];
	GFP2 *tmp = [GFP2 multiply: tmp1 and: tmp2  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP2 subtract: tmp and: v1  with: pFGInt];
	[tmp release];
	tmp2 = [GFP2 subtract: tmp1 and: v2  with: pFGInt];
	[tmp1 release];
	tmp = [GFP2 multiplyByResiduePlus3: tmp2  with: pFGInt];
	[tmp2 release];
	[product setA: [GFP2 add: v0 and: tmp  with: pFGInt]];
	[tmp release];

	tmp1 = [GFP2 add: [p1 b] and: [p1 a]  with: pFGInt];
	tmp2 = [GFP2 add: [p2 b] and: [p2 a]  with: pFGInt];
	tmp = [GFP2 multiply: tmp1 and: tmp2  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP2 subtract: tmp and: v1  with: pFGInt];
	[tmp release];
	tmp2 = [GFP2 subtract: tmp1 and: v0  with: pFGInt];
	[tmp1 release];
	tmp = [GFP2 multiplyByResiduePlus3: v2  with: pFGInt];
	[product setB: [GFP2 add: tmp2 and: tmp  with: pFGInt]];
	[tmp2 release];
	[tmp release];

	tmp1 = [GFP2 add: [p1 c] and: [p1 a]  with: pFGInt];
	tmp2 = [GFP2 add: [p2 c] and: [p2 a]  with: pFGInt];
	tmp = [GFP2 multiply: tmp1 and: tmp2  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP2 subtract: tmp and: v2  with: pFGInt];
	[tmp release];
	tmp2 = [GFP2 subtract: tmp1 and: v0  with: pFGInt];
	[tmp1 release];
	[product setC: [GFP2 add: tmp2 and: v1  with: pFGInt]];
	[tmp2 release];

	[v0 release];
	[v1 release];
	[v2 release];

	return product;
}

+(GFP6 *) square: (GFP6 *) p1 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP6 *square = [[GFP6 alloc] init];

	GFP2 *p1a = [p1 a], *p1b = [p1 b], *p1c = [p1 c];

	GFP2 *s0 = [GFP2 square: p1a  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *s4 = [GFP2 square: p1c  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp1 = [GFP2 add: p1a and: p1c  with: pFGInt];
	GFP2 *tmp2 = [GFP2 add: tmp1 and: p1b  with: pFGInt];
	GFP2 *s1 = [GFP2 square: tmp2  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp2 release];
	tmp2 = [GFP2 subtract: tmp1 and: p1b  with: pFGInt];
	GFP2 *s2 = [GFP2 square: tmp2  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp2 release];
	[tmp1 release];
	GFP2 *s3 = [GFP2 multiply: p1b and: p1c  with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[s3 shiftLeftWith: pFGInt];
	GFP2 *t1 = [GFP2 add: s1 and: s2  with: pFGInt];
	[t1 shiftRightWith: pFGInt];

	tmp1 = [GFP2 multiplyByResiduePlus3: s3  with: pFGInt];
	[square setA: [GFP2 add: tmp1 and: s0  with: pFGInt]];
	[tmp1 release];

	tmp1 = [GFP2 multiplyByResiduePlus3: s4  with: pFGInt];
	tmp2 = [GFP2 add: tmp1 and: s1  with: pFGInt];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp2 and: s3  with: pFGInt];
	[tmp2 release];
	[square setB: [GFP2 subtract: tmp1 and: t1  with: pFGInt]];
	[tmp1 release];

	tmp1 = [GFP2 subtract: t1 and: s0  with: pFGInt];
	[square setC: [GFP2 subtract: tmp1 and: s4  with: pFGInt]];
	[tmp1 release];

	[s0 release];
	[s1 release];
	[s2 release];
	[s3 release];
	[s4 release];
	[t1 release];

	return square;
}


-(GFP6 *) multiplyByRootWith: (FGInt *) pFGInt {
	GFP2 *tmp = [GFP2 multiplyByResiduePlus3: c with: pFGInt];
	[c release];
	c = b;
	b = a;
	a = tmp;

	return self;
}

-(void) shiftLeftWith: (FGInt *) pFGInt {
	[a shiftLeftWith: pFGInt];
	[b shiftLeftWith: pFGInt];
	[c shiftLeftWith: pFGInt];
}

-(void) multiplyByFGInt: (FGInt *) fGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a multiplyByFGInt: fGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b multiplyByFGInt: fGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[c multiplyByFGInt: fGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
}

-(void) multiplyByGFP2: (GFP2 *) gfp2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *tmp = [GFP2 multiply: a and: gfp2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[a release];
	a = tmp;
	tmp = [GFP2 multiply: b and: gfp2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b release];
	b = tmp;
	tmp = [GFP2 multiply: c and: gfp2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[c release];
	c = tmp;
}

-(GFP6 *) invertWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP6 *iGFP6 = [[GFP6 alloc] init];

	GFP2 *tmp = [GFP2 square: a with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp1 = [GFP2 multiply: c and: b with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp2 = [GFP2 multiplyByResiduePlus3: tmp1 with: pFGInt];
	[tmp1 release];
	[iGFP6 setA: [GFP2 subtract: tmp and: tmp2 with: pFGInt]];
	[tmp release];
	[tmp2 release];

	tmp = [GFP2 square: c with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp2 = [GFP2 multiplyByResiduePlus3: tmp with: pFGInt];
	[tmp release];
	tmp1 = [GFP2 multiply: a and: b with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[iGFP6 setB: [GFP2 subtract: tmp2 and: tmp1 with: pFGInt]];
	[tmp1 release];
	[tmp2 release];

	tmp = [GFP2 square: b with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp1 = [GFP2 multiply: a and: c with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[iGFP6 setC: [GFP2 subtract: tmp and: tmp1 with: pFGInt]];
	[tmp release];
	[tmp1 release];

	tmp1 = [GFP2 multiply: a and: [iGFP6 a] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp2 = [GFP2 multiply: c and: [iGFP6 b] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp = [GFP2 multiplyByResiduePlus3: tmp2 with: pFGInt];
	[tmp2 release];
	tmp2 = [GFP2 add: tmp1 and: tmp with: pFGInt];
	[tmp release];
	[tmp1 release];
	tmp1 = [GFP2 multiply: b and: [iGFP6 c] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp = [GFP2 multiplyByResiduePlus3: tmp1 with: pFGInt];
	[tmp1 release];
	tmp1 = [GFP2 add: tmp2 and: tmp with: pFGInt];
	[tmp2 release];
	[tmp release];
	tmp = [tmp1 invertWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];

	tmp1 = [GFP2 multiply: [iGFP6 a] and: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[[iGFP6 a] release];
	[iGFP6 setA: tmp1];
	tmp1 = [GFP2 multiply: [iGFP6 b] and: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[[iGFP6 b] release];
	[iGFP6 setB: tmp1];
	tmp1 = [GFP2 multiply: [iGFP6 c] and: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[[iGFP6 c] release];
	[iGFP6 setC: tmp1];

	[tmp release];

	return iGFP6;
}

-(void) frobeniusWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a conjugate];
	[b conjugate];
	[c conjugate];

	GFP2 *tmp = [[GFP2 alloc] init];
	FGIntBase numberArray1[8] = iPlus3To2Pm2o3aNumber;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray2[8] = iPlus3To2Pm2o3bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	[tmp setB: tmpFGInt];

	GFP2 *tmp0 = [GFP2 multiply: c and: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	[c release];
	c = tmp0;

	tmp = [[GFP2 alloc] init];
	FGIntBase numberArray3[8] = iPlus3ToPm1o3aNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray3 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray4[8] = iPlus3ToPm1o3bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray4 length: cnstLength]];
	[tmp setB: tmpFGInt];

	tmp0 = [GFP2 multiply: b and: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	[b release];
	b = tmp0;
}

-(void) frobenius2With: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGIntBase numberArray1[8] = iPlus3To2Psm2o3Number;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength - 8]];
	[c multiplyByFGInt: tmpFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];

	FGIntBase numberArray2[8] = iPlus3ToPsm1o3Number;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	[b multiplyByFGInt: tmpFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];
}



-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	NSString *tmpStr = [a toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @"\n + ("];
	tmpStr = [b toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")b\n + ("];
	tmpStr = [c toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")b^2"];

	return base10String;	
}


-(NSData *) marshal {
	if ((a == nil) || (b == nil) || (c == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [c marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [b marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [a marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}




@end









// a + bX 


@implementation GFP12
@synthesize a, b;


-(id) init {
    if (self = [super init]) {
    	a = nil;
    	b = nil;
    }
    return self;
}
-(id) initOne {
    if (self = [super init]) {
    	a = [[GFP6 alloc] initOne];
    	b = [[GFP6 alloc] initZero];
    }
    return self;
}
-(id) initZero {
    if (self = [super init]) {
    	a = [[GFP6 alloc] initZero];
    	b = [[GFP6 alloc] initZero];
    }
    return self;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 12*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: &bytes[6*cnstLength] length: 6*cnstLength];
    	a = [[GFP6 alloc] unMarshal: tmpData];
		[tmpData release];
		tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 6*cnstLength];
    	b = [[GFP6 alloc] unMarshal: tmpData];
		[tmpData release];
    }
    return self;
}
-(void) dealloc {
    [a release];
    [b release];
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
    GFP12 *newGFP12 = [[GFP12 allocWithZone: zone] init];

    [newGFP12 setA: [a mutableCopy]];
    [newGFP12 setB: [b mutableCopy]];

    return newGFP12;
}
-(void) conjugate {
	[b changeSign];
}
-(void) changeSign {
	[a changeSign];
	[b changeSign];
}
-(BOOL) isZero {
	if ([a isZero] && [b isZero]) {
		return YES;
	}
	return NO;
}

+(GFP12 *) add: (GFP12 *) p1 and: (GFP12 *) p2 {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	GFP12 *sum = [GFP12 add: p1 and: p2 with: pFGInt];

	[pFGInt release];

	return sum;
}
+(GFP12 *) add: (GFP12 *) p1 and: (GFP12 *) p2 with: (FGInt *) pFGInt {
	GFP12 *sum = [[GFP12 alloc] init];

	[sum setA: [GFP6 add: [p1 a] and: [p2 a] with: pFGInt]];
	[sum setB: [GFP6 add: [p1 b] and: [p2 b] with: pFGInt]];

	return sum;
}

+(GFP12 *) subtract: (GFP12 *) p1 and: (GFP12 *) p2 {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	GFP12 *sum = [GFP12 subtract: p1 and: p2 with: pFGInt];

	[pFGInt release];

	return sum;
}
+(GFP12 *) subtract: (GFP12 *) p1 and: (GFP12 *) p2 with: (FGInt *) pFGInt {
	GFP12 *sum = [[GFP12 alloc] init];

	[sum setA: [GFP6 subtract: [p1 a] and: [p2 a] with: pFGInt]];
	[sum setB: [GFP6 subtract: [p1 b] and: [p2 b] with: pFGInt]];

	return sum;
}

+(GFP12 *) multiply: (GFP12 *) p1 and: (GFP12 *) p2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	GFP12 *sum = [GFP12 multiply: p1 and: p2 with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return sum;
}
+(GFP12 *) multiply: (GFP12 *) p1 and: (GFP12 *) p2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP12 *product = [[GFP12 alloc] init];

	GFP6 *v0 = [GFP6 multiply: [p1 a] and: [p2 a] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP6 *v1 = [GFP6 multiply: [p1 b] and: [p2 b] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP6 *tmp1 = [GFP6 add: [p1 a] and: [p1 b] with: pFGInt], *tmp2 = [GFP6 add: [p2 a] and: [p2 b] with: pFGInt];

	GFP6 *tmp = [GFP6 multiply: tmp1 and: tmp2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP6 subtract: tmp and: v0 with: pFGInt];
	[tmp release];
	[product setB: [GFP6 subtract: tmp1 and: v1 with: pFGInt]];
	[tmp1 release];

	[v1 multiplyByRootWith: pFGInt];
	[product setA: [GFP6 add: v0 and: v1 with: pFGInt]];
	[v0 release];
	[v1 release];

	return product;
}

-(void) multiplyByFGInt: (FGInt *) fGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	[self multiplyByFGInt: fGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];
}
-(void) multiplyByFGInt: (FGInt *) fGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a multiplyByFGInt: fGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b multiplyByFGInt: fGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
}


+(GFP12 *) square: (GFP12 *) p1 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	GFP12 *sum = [GFP12 square: p1 with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return sum;
}
+(GFP12 *) square: (GFP12 *) p1 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP12 *square = [[GFP12 alloc] init];

	GFP6 *p1a = [p1 a], *p1b = [p1 b];

	GFP6 *v0 = [GFP6 multiply: p1a and: p1b with: pFGInt withInvertedP: invertedP andPrecision: precision],
		*tmp1 = [GFP6 add: p1a and: p1b with: pFGInt], *tmp = [p1b mutableCopy];
	[tmp multiplyByRootWith: pFGInt];
	GFP6 *tmp2 = [GFP6 add: p1a and: tmp with: pFGInt];
	[tmp release];
	tmp = [GFP6 multiply: tmp1 and: tmp2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP6 subtract: tmp and: v0 with: pFGInt];
	[tmp release];
	tmp = [v0 mutableCopy];
	[tmp multiplyByRootWith: pFGInt];

	[square setA: [GFP6 subtract: tmp1 and: tmp with: pFGInt]];
	[tmp1 release];
	[tmp release];

	[v0 shiftLeftWith: pFGInt];
	[square setB: v0];

	return square;
}

-(void) frobeniusWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a frobeniusWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b frobeniusWith: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp = [[GFP2 alloc] init];
	FGIntBase numberArray1[8] = iPlus3ToPm1o6aNumber;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray2[8] = iPlus3ToPm1o6bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	[tmp setB: tmpFGInt];

	[b multiplyByGFP2: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp release];
}

-(void) frobenius2With: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a frobenius2With: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b frobenius2With: pFGInt withInvertedP: invertedP andPrecision: precision];

	FGIntBase numberArray[8] = iPlus3ToPsm1o6Number;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
	[b multiplyByFGInt: tmpFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];
}

-(GFP12 *) invertWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP12 *iGFP12 = [[GFP12 alloc] init];

	GFP6 *tmp1 = [GFP6 square: a with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP6 *tmp2 = [GFP6 square: b with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp2 multiplyByRootWith: pFGInt];

	GFP6 *tmp = [GFP6 subtract: tmp1 and: tmp2 with: pFGInt];
	[tmp1 release];
	[tmp2 release];
	GFP6 *denominator = [tmp invertWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp release];

	tmp = [GFP6 multiply: a and: denominator with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[iGFP12 setA: tmp];
	tmp = [GFP6 multiply: b and: denominator with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp changeSign];
	[iGFP12 setB: tmp];

	return iGFP12;
}
-(GFP12 *) invert {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	GFP12 *tmp = [self invertWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	[invertedP release];
	[pFGInt release];

	return tmp;
}

+(GFP12 *) raise: (GFP12 *) gfp12 toThePower: (FGInt *) fGIntN withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	GFP12 *result = [GFP12 raise: gfp12 toThePower: fGIntN with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return result;
}
+(GFP12 *) raise: (GFP12 *) gfp12 toThePower: (FGInt *) fGIntN with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    GFP12 *power = [[GFP12 alloc] initOne];
    FGIntOverflow nLength = [[fGIntN number] length]/4;
    FGIntBase tmpWord;
    GFP12 *tmp1, *tmp;
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];

    tmp1 = [gfp12 retain];
    // tmp1 = [gfp12 mutableCopy];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmpWord = nFGIntNumber[i];
        for( FGIntIndex j = 0; j < 32; ++j ) {
            if ((tmpWord % 2) == 1) {
                tmp = [GFP12 multiply: power and: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
                [power release];
                power = tmp;
            }
            tmp = [GFP12 square: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
            tmpWord >>= 1;
        }
    }
    tmpWord = nFGIntNumber[nLength - 1];
    while(tmpWord != 0) {
        if ((tmpWord % 2) == 1) {
            tmp = [GFP12 multiply: power and: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [power release];
            power = tmp;
        }
        tmpWord >>= 1;
        if (tmpWord != 0) {
            tmp = [GFP12 square: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
        }
    }
    
    [tmp1 release];
    
    return power;
}



-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	NSString *tmpStr = [a toBase10String];
	[base10String appendString: @"("];
	[base10String appendString: tmpStr];
	[base10String appendString: @")"];
	[tmpStr release];
	[base10String appendString: @"\n + ("];
	tmpStr = [b toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")w"];

	return base10String;	
}

-(NSData *) marshal {
	if ((a == nil) || (b == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [b marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [a marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}


@end











@implementation G2Point
@synthesize x, y, z, t;
@synthesize infinity;


-(id) init {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	t = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initInfinity {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	t = nil;
    	infinity = YES;
    }
    return self;
}
-(id) initGenerator {
    if (self = [super init]) {

		FGInt *tmpFGInt;
		x = [[GFP2 alloc] init];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray1[] = {395465548u, 730492372u, 1573759699u, 3111621141u, 2921370308u, 2170125669u, 1925793323u, 2401581167u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength]];
		[x setA: tmpFGInt];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray2[] = {3273939312u, 938160865u, 3406146634u, 3157767012u, 1551183656u, 63401627u, 4285480269u, 785163334u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
		[x setB: tmpFGInt];
		
		y = [[GFP2 alloc] init];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray3[] = {3190851493u, 1766072483u, 3258878351u, 789467123u, 2581297586u, 924241030u, 3905616588u, 659445575u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray3 length: cnstLength]];
		[y setA: tmpFGInt];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray4[] = {2402402066u, 3751226898u, 4082187586u, 3185580628u, 2763768501u, 2519441126u, 591073251u, 766578421u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray4 length: cnstLength]];
		[y setB: tmpFGInt];
		
    	z = nil;
    	t = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initRandomPoint {
	FGIntOverflow precision = precisionBits;
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	FGInt *tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: precision];
	if (tmpFGInt == nil) {
		[order release];
		return nil;
	}

	[tmpFGInt reduceBySubtracting: order atMost: 1];

	G2Point *result = [G2Point addGeneratorKTimes: tmpFGInt];

	[tmpFGInt release];
	[order release];

	return result;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 4*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: &bytes[2*cnstLength] length: 2*cnstLength];
    	y = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
		tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 2*cnstLength];
    	x = [[GFP2 alloc] unMarshal: tmpData];
		z = nil;
		[tmpData release];
		if ([x isZero] && [y isZero]) {
			infinity = YES;
		} else {
			infinity = NO;
		}
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
    if (z != nil) {
	    [z release];
    }
    if (t != nil) {
	    [t release];
    }
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	if (infinity) {
		return [[G2Point alloc] initInfinity];
	}

    G2Point *newG2Point = [[G2Point allocWithZone: zone] init];

    [newG2Point setX: [x mutableCopy]];
    [newG2Point setY: [y mutableCopy]];
    if (z != nil) {
    	[newG2Point setZ: [z mutableCopy]];
    }
    if (t != nil) {
    	[newG2Point setT: [t mutableCopy]];
    }

    return newG2Point;
}
-(void) changeSign {
	if (!infinity) {
		[y changeSign];
	}
}
-(void) makeProjective {
	if (!infinity) {
		z = [[GFP2 alloc] initOne];
	}
}
-(void) makeExtendedProjective {
	if (!infinity) {
		z = [[GFP2 alloc] initOne];
		t = [z mutableCopy];
	}
}


+(G2Point *) add: (G2Point *) p1 and: (G2Point *) p2 {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G2Point *tmp0G2 = [p1 mutableCopy], *tmp1G2 = [p2 mutableCopy];
	[tmp0G2 makeProjective];
	[tmp1G2 makeProjective];

	G2Point *result = [G2Point projectiveAdd: tmp0G2 and: tmp1G2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[result makeAffineWith: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];
    [invertedP release];
    [tmp0G2 release];
    [tmp1G2 release];

    return result;
}


+(G2Point *) projectiveAdd: (G2Point *) p1 and: (G2Point *) p2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G2Point *sum = [G2Point projectiveAdd: p1 and: p2 with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return sum;
}
+(G2Point *) projectiveAdd: (G2Point *) p1 and: (G2Point *) p2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [p2 mutableCopy];
	}
	if ([p2 infinity]) {
		return [p1 mutableCopy];
	}

	G2Point *sum = [[G2Point alloc] init];

	GFP2 *z1z1 = [GFP2 square: [p1 z] with: pFGInt withInvertedP: invertedP andPrecision: precision], 
		*z2z2 = [GFP2 square: [p2 z] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *u1 = [GFP2 multiply: z2z2 and: [p1 x] with: pFGInt withInvertedP: invertedP andPrecision: precision], 
		*u2 = [GFP2 multiply: z1z1 and: [p2 x] with: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp = [GFP2 multiply: [p1 y] and: [p2 z] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *s1 = [GFP2 multiply: tmp and: z2z2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	tmp = [GFP2 multiply: [p2 y] and: [p1 z] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *s2 = [GFP2 multiply: tmp and: z1z1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp release];

	GFP2 *h = [GFP2 subtract: u2 and: u1 with: pFGInt];
	tmp = [h mutableCopy];
	[tmp shiftLeftWith: pFGInt];
	GFP2 *i = [GFP2 square: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	GFP2 *j = [GFP2 multiply: i and: h with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *r = [GFP2 subtract: s2 and: s1 with: pFGInt];
	if ([h isZero] && [r isZero]) {
		[z1z1 release];
		[z2z2 release];
		[u1 release];
		[u2 release];
		[s1 release];
		[s2 release];
		[h release];
		[i release];
		[j release];
		[r release];

		return [G2Point projectiveDouble: p1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	}
	[r shiftLeftWith: pFGInt];
	GFP2 *v = [GFP2 multiply: u1 and: i with: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp1 = [GFP2 square: r with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp = [GFP2 subtract: tmp1 and: j with: pFGInt];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp and: v with: pFGInt];
	[tmp release];
	[sum setX: [GFP2 subtract: tmp1 and: v with: pFGInt]];
	[tmp1 release];

	tmp1 = [GFP2 subtract: v and: [sum x] with: pFGInt];
	tmp = [GFP2 multiply: r and: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	tmp1 = [GFP2 multiply: s1 and: j with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 shiftLeftWith: pFGInt];
	[sum setY: [GFP2 subtract: tmp and: tmp1 with: pFGInt]];
	[tmp release];
	[tmp1 release];

	tmp1 = [GFP2 add: [p1 z] and: [p2 z] with: pFGInt];
	tmp = [GFP2 square: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp and: z1z1 with: pFGInt];
	[tmp release];
	tmp = [GFP2 subtract: tmp1 and: z2z2 with: pFGInt];
	[tmp1 release];
	[sum setZ: [GFP2 multiply: tmp and: h with: pFGInt withInvertedP: invertedP andPrecision: precision]];
	[tmp release];

	[z1z1 release];
	[z2z2 release];
	[u1 release];
	[u2 release];
	[s1 release];
	[s2 release];
	[h release];
	[i release];
	[j release];
	[r release];
	[v release];

	if ([[sum z] isZero]) {
		[sum release];
		sum = [[G2Point alloc] initInfinity];
	}

	return sum;
}


+(G2Point *) projectiveDouble: (G2Point *) p1 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G2Point *sum = [G2Point projectiveDouble: p1 with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return sum;
}
+(G2Point *) projectiveDouble: (G2Point *) p1 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [[G2Point alloc] initInfinity];
	}

	G2Point *sum = [[G2Point alloc] init];

	GFP2 *a = [GFP2 square: [p1 x] with: pFGInt withInvertedP: invertedP andPrecision: precision], 
		*b = [GFP2 square: [p1 y] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *c = [GFP2 square: b with: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp1 = [GFP2 add: [p1 x] and: b with: pFGInt];
	GFP2 *tmp = [GFP2 square: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp and: a with: pFGInt];
	[tmp release];
	GFP2 *d = [GFP2 subtract: tmp1 and: c with: pFGInt];
	[tmp1 release];
	[d shiftLeftWith: pFGInt];
	[a multiplyByInt: 3 with: pFGInt];
	GFP2 *f = [GFP2 square: a with: pFGInt withInvertedP: invertedP andPrecision: precision];

	tmp = [GFP2 subtract: f and: d with: pFGInt];
	[sum setX: [GFP2 subtract: tmp and: d with: pFGInt]];
	[tmp release];

	[c multiplyByInt: 8 with: pFGInt];
	tmp1 = [GFP2 subtract: d and: [sum x] with: pFGInt];
	tmp = [GFP2 multiply: tmp1 and: a with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[sum setY: [GFP2 subtract: tmp and: c with: pFGInt]];
	[tmp release];

	tmp = [GFP2 multiply: [p1 y] and: [p1 z] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp shiftLeftWith: pFGInt];
	[sum setZ: tmp];

	[a release];
	[b release];
	[c release];
	[d release];
	[f release];

	return sum;
}

-(void) makeAffineWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	[self makeAffineWith: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];
}
-(void) makeAffineWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if (z == nil) {
		return;
	}
	GFP2 *tmp = [z invertWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp1 = [GFP2 square: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp2 = [GFP2 multiply: x and: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[x release];
	x = tmp2;
	tmp2 = [GFP2 multiply: tmp and: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp release];
	tmp = [GFP2 multiply: y and: tmp2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp2 release];
	[y release];
	y = tmp;
    if (z != nil) {
	    [z release];
    }
	z = nil;
    if (t != nil) {
	    [t release];
    }
	t = nil;
}
-(void) makeAffine {
	if (z == nil) {
		return;
	}
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	[self makeAffineWith: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];
	[invertedP release];
}


+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G2Point *result = [G2Point add: g2Point kTimes: kFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return result;
}
+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    G2Point *result = [[G2Point alloc] initInfinity], *tmpECPoint, *tmpECPoint1;

    FGIntOverflow kLength = [[kFGInt number] length]/4, i, j;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kFGInt number] mutableBytes];
    
    // tmpECPoint1 = [g2Point retain];
    tmpECPoint1 = [g2Point mutableCopy];
    [tmpECPoint1 makeProjective];
    [result makeProjective];

    for( i = 0; i < kLength - 1; i++ ) {
        tmp = kFGIntNumber[i];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpECPoint = [G2Point projectiveAdd: result and: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
                [result release];
                result = tmpECPoint;
            }
            tmpECPoint = [G2Point projectiveDouble: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
            tmp >>= 1;
        }
    }
    tmp = kFGIntNumber[kLength - 1];
    while (tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpECPoint = [G2Point projectiveAdd: result and: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [result release];
            result = tmpECPoint;
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpECPoint = [G2Point projectiveDouble: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
        }
    }

    [tmpECPoint1 release];
    [result makeAffineWithInvertedP: invertedP andPrecision: precision];

    return result;
}
+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G2Point *result = [G2Point add: g2Point kTimes: kFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];
	[invertedP release];

    return result;
}

+(G2Point *) addGeneratorKTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G2Point * g2gen = [[G2Point alloc] initGenerator];

    G2Point *result = [G2Point add: g2gen kTimes: kFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

    [pFGInt release];
    [g2gen release];

    return result;
}
+(G2Point *) addGeneratorKTimes: (FGInt *) kFGInt {
	G2Point * generator = [[G2Point alloc] initGenerator];
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

    G2Point *result = [G2Point add: generator kTimes: kFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

    [generator release];
    [invertedP release];
    [pFGInt release];

    return result;
}


-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	if (infinity) {
		[base10String appendString: @"infinity"];
		return base10String;
	}
	NSString *tmpStr = [x toBase10String];
	[base10String appendString: @"("];
	[base10String appendString: tmpStr];
	[base10String appendString: @", \n"];
	[tmpStr release];
	tmpStr = [y toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")"];

	return base10String;	
}

-(NSData *) marshal {
	if (infinity) {
		return [[NSMutableData alloc] initWithLength: 4*cnstLength];
	}
	if ((x == nil) || (y == nil)) {
		return nil;
	}

	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [x marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [y marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}



@end












@implementation G1Point
@synthesize x, y, z;
@synthesize infinity;


-(id) init {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	// p = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initInfinity {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	// p = [pFGInt retain];
    	// p = [pFGInt mutableCopy];
    	infinity = YES;
    }
    return self;
}
-(id) initGenerator {
    if (self = [super init]) {
		// p = [[FGInt alloc] initWithoutNumber];
		// FGIntBase numberArray[8] = pNumber;
		// [p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
		x = [[FGInt alloc] initWithFGIntBase: 1];
		y = [[FGInt alloc] initWithFGIntBase: 2];
		[y changeSign];
    	z = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initRandomPoint {
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	FGInt *tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: cnstLength*8];
	if (tmpFGInt != nil) {
		[tmpFGInt reduceBySubtracting: order atMost: 1];
	} else {
		[order release];
		return nil;
	}

	G1Point *result = [G1Point addGeneratorKTimes: tmpFGInt];

	[tmpFGInt release];
	[order release];

	return result;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 2*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
  //   	p = [[FGInt alloc] initWithoutNumber];
		// FGIntBase numberArray[] = pNumber;
		// [p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

    	const unsigned char* bytes = [marshalData bytes];
    	NSData *tmpData = [[NSData alloc] initWithBytes: &bytes[cnstLength] length: cnstLength];
    	y = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
		tmpData = [[NSData alloc] initWithBytes: bytes length: cnstLength];
    	x = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
		z = nil;
		if ([x isZero] && [y isZero]) {
			infinity = YES;
		} else {
			infinity = NO;
		}
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
	if (z != nil) {
	    [z release];
	}
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	if (infinity) {
		return [[G1Point alloc] initInfinity];
	}

    G1Point *newG1Point = [[G1Point allocWithZone: zone] init];

    [newG1Point setX: [x mutableCopy]];
    [newG1Point setY: [y mutableCopy]];
    [newG1Point setZ: [z mutableCopy]];
    // [newG1Point setP: [p retain]];
    // [newG1Point setP: [p mutableCopy]];

    return newG1Point;
}
-(void) changeSign {
	if (!infinity) {
		[y changeSign];
	}
}
-(void) makeProjective {
	if (!infinity) {
		z = [[FGInt alloc] initWithFGIntBase: 1];
	}
}

+(G1Point *) add: (G1Point *) p1 and: (G1Point *) p2 {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];


	G1Point *tmp0G2 = [p1 mutableCopy], *tmp1G2 = [p2 mutableCopy];
	[tmp0G2 makeProjective];
	[tmp1G2 makeProjective];

	G1Point *result = [G1Point projectiveAdd: tmp0G2 and: tmp1G2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[result makeAffineWith: pFGInt withInvertedP: invertedP andPrecision: precision];

    [invertedP release];
	[pFGInt release];
    [tmp0G2 release];
    [tmp1G2 release];

    return result;
}


+(G1Point *) projectiveAdd: (G1Point *) p1 and: (G1Point *) p2 with: (FGInt *) p withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [p2 mutableCopy];
	}
	if ([p2 infinity]) {
		return [p1 mutableCopy];
	}

	G1Point *sum = [[G1Point alloc] init];

	FGInt *tmpBarrett;


	tmpBarrett = [FGInt pencilPaperSquare: [p1 z]];
	FGInt *z1z1 =  [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperSquare: [p2 z]];
	FGInt *z2z2 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperMultiply: z2z2 and: [p1 x]];
	FGInt *u1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperMultiply: z1z1 and: [p2 x] ];
	FGInt *u2 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	tmpBarrett = [FGInt pencilPaperMultiply: [p1 y] and: [p2 z]];
	FGInt *tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperMultiply: tmp and: z2z2];	
	FGInt *s1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp release];
	tmpBarrett = [FGInt pencilPaperMultiply: [p2 y] and: [p1 z]];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperMultiply: tmp and: z1z1];
	FGInt *s2 =  [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp release];

	FGInt *h = [FGInt subtract: u2 and: u1];
	[h reduceBySubtracting: p atMost: 1];
	tmp = [h mutableCopy];
	[tmp shiftLeft];
	[tmp reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt pencilPaperSquare: tmp];
	FGInt *i = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp release];
	tmpBarrett = [FGInt pencilPaperMultiply: i and: h];
	FGInt *j = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	FGInt *r = [FGInt subtract: s2 and: s1];
	if ([h isZero] && [r isZero]) {
		[z1z1 release];
		[z2z2 release];
		[u1 release];
		[u2 release];
		[s1 release];
		[s2 release];
		[h release];
		[i release];
		[j release];
		[r release];

		return [G1Point projectiveDouble: p1 with: p withInvertedP: invertedP andPrecision: precision];
	}
	[r shiftLeft];
	[r reduceBySubtracting: p atMost: 4];
	tmpBarrett = [FGInt pencilPaperMultiply: u1 and: i];
	FGInt *v = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	tmpBarrett = [FGInt pencilPaperSquare: r];
	FGInt *tmp1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmp = [FGInt subtract: tmp1 and: j];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: v];
	[tmp release];
	tmp = [FGInt subtract: tmp1 and: v];
	[tmp reduceBySubtracting: p atMost: 3];
	[sum setX: tmp];
	[tmp1 release];

	tmp1 = [FGInt subtract: v and: [sum x]];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt pencilPaperMultiply: r and: tmp1];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmpBarrett = [FGInt pencilPaperMultiply: s1 and: j];
	tmp1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 shiftLeft];
	tmpBarrett = [FGInt subtract: tmp and: tmp1];
	[tmpBarrett reduceBySubtracting: p atMost: 3];
	[sum setY: tmpBarrett];
	[tmp release];
	[tmp1 release];

	tmp1 = [FGInt add: [p1 z] and: [p2 z]];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt pencilPaperSquare: tmp1];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: z1z1];
	[tmp1 reduceBySubtracting: p atMost: 1];
	[tmp release];
	tmp = [FGInt subtract: tmp1 and: z2z2];
	[tmp reduceBySubtracting: p atMost: 1];
	[tmp1 release];
	tmpBarrett = [FGInt pencilPaperMultiply: tmp and: h];
	[sum setZ: [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision]];
	[tmpBarrett release];
	[tmp release];

	[z1z1 release];
	[z2z2 release];
	[u1 release];
	[u2 release];
	[s1 release];
	[s2 release];
	[h release];
	[i release];
	[j release];
	[r release];
	[v release];

	if ([[sum z] isZero]) {
		[sum release];
		sum = [[G1Point alloc] initInfinity];
	}

	// [sum setP: [p retain]];
	// [sum setP: [p mutableCopy]];

	return sum;
}


+(G1Point *) projectiveDouble: (G1Point *) p1 with: (FGInt *) p withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [[G1Point alloc] initInfinity];
	}

	G1Point *sum = [[G1Point alloc] init];

	FGInt *tmpBarrett;
	// else {
	// 	NSLog(@"uh-oh");
	// 	p = [[FGInt alloc] initWithBase10String: @"65000549695646603732796438742359905742825358107623003571877145026864184071783"];
	// }

	tmpBarrett = [FGInt pencilPaperSquare: [p1 x]];
	FGInt *a = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperSquare: [p1 y]];
	FGInt *b = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperSquare: b];
	FGInt *c = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	FGInt *tmp1 = [FGInt add: [p1 x] and: b];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt pencilPaperSquare: tmp1];
	FGInt *tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: a];
	[tmp release];
	FGInt *d = [FGInt subtract: tmp1 and: c];
	[tmp1 release];
	[d shiftLeft];
	[d reduceBySubtracting: p atMost: 5];
	[a multiplyByInt: 3];
	[a reduceBySubtracting: p atMost: 3];
	tmpBarrett = [FGInt pencilPaperSquare: a]; 
	FGInt *f = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	tmp = [FGInt subtract: f and: d];
	tmpBarrett = [FGInt subtract: tmp and: d];
	[tmpBarrett reduceBySubtracting: p atMost: 2];
	[sum setX: tmpBarrett];
	[tmp release];

	[c multiplyByInt: 8];
	tmp1 = [FGInt subtract: d and: [sum x]];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt pencilPaperMultiply: tmp1 and: a];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: c];
	[tmp1 reduceBySubtracting: p atMost: 9];
	[sum setY: tmp1];
	[tmp release];

	tmpBarrett = [FGInt pencilPaperMultiply: [p1 y] and: [p1 z]];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp shiftLeft];
	[tmp reduceBySubtracting: p atMost: 1];
	[sum setZ: tmp];

	[a release];
	[b release];
	[c release];
	[d release];
	[f release];

	// [sum setP: [p retain]];
	// [sum setP: [p mutableCopy]];

	return sum;
}

-(void) makeAffineWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if (z == nil) {
		return;
	}
	FGInt *tmp = [FGInt invert: z moduloPrime: pFGInt];
	FGInt *tmpBarrett = [FGInt pencilPaperSquare: tmp];
	FGInt *tmp1 = [FGInt barrettMod: tmpBarrett by: pFGInt with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt pencilPaperMultiply: x and: tmp1];
	FGInt *tmp2 = [FGInt barrettMod: tmpBarrett by: pFGInt with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[x release];
	x = tmp2;
	tmpBarrett = [FGInt pencilPaperMultiply: tmp and: tmp1];
	tmp2 = [FGInt barrettMod: tmpBarrett by: pFGInt with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	[tmp release];
	tmpBarrett = [FGInt pencilPaperMultiply: y and: tmp2];
	tmp =  [FGInt barrettMod: tmpBarrett by: pFGInt with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp2 release];
	[y release];
	y = tmp;
	[z release];
	z = nil;
}


+(G1Point *) add: (G1Point *) g1Point kTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G1Point *result = [G1Point add: g1Point kTimes: kFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return result;
}

+(G1Point *) add: (G1Point *) g1Point kTimes: (FGInt *) kFGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    G1Point *result = [[G1Point alloc] initInfinity], *tmpECPoint, *tmpECPoint1;

    FGIntOverflow kLength = [[kFGInt number] length]/4, i, j;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kFGInt number] mutableBytes];
    
    // tmpECPoint1 = [g1Point retain];
    tmpECPoint1 = [g1Point mutableCopy];
    [tmpECPoint1 makeProjective];
    [result makeProjective];

    for( i = 0; i < kLength - 1; i++ ) {
        tmp = kFGIntNumber[i];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpECPoint = [G1Point projectiveAdd: result and: tmpECPoint1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
                [result release];
                result = tmpECPoint;
            }
            tmpECPoint = [G1Point projectiveDouble: tmpECPoint1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
            tmp >>= 1;
        }
    }
    tmp = kFGIntNumber[kLength - 1];
    while (tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpECPoint = [G1Point projectiveAdd: result and: tmpECPoint1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [result release];
            result = tmpECPoint;
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpECPoint = [G1Point projectiveDouble: tmpECPoint1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
        }
    }

    [tmpECPoint1 release];
    [result makeAffineWith: pFGInt withInvertedP: invertedP andPrecision: precision];

    return result;
}
+(G1Point *) add: (G1Point *) g1Point kTimes: (FGInt *) kFGInt {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	G1Point *result = [G1Point add: g1Point kTimes: kFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];
	[invertedP release];
    return result;
}

+(G1Point *) addGeneratorKTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	G1Point * g1gen = [[G1Point alloc] initGenerator];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

    G1Point *result = [G1Point add: g1gen kTimes: kFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];

    [g1gen release];
	[pFGInt release];

    return result;
}
+(G1Point *) addGeneratorKTimes: (FGInt *) kFGInt {
	G1Point *generator = [[G1Point alloc] initGenerator];
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];

    G1Point *result = [G1Point add: generator kTimes: kFGInt withInvertedP: invertedP andPrecision: precision];

    [generator release];
    [invertedP release];

    return result;
}



-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	if (infinity) {
		[base10String appendString: @"infinity"];
		return base10String;
	}
	NSString *tmpStr = [x toBase10String];
	[base10String appendString: @"("];
	[base10String appendString: tmpStr];
	[base10String appendString: @", "];
	[tmpStr release];
	tmpStr = [y toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")"];

	return base10String;	
}

-(NSData *) marshal {
	if (infinity) {
		return [[NSMutableData alloc] initWithLength: 2*cnstLength];
	}
	if ((x == nil) || (y == nil)) {
        NSLog(@"uh-oh");
		return nil;
	}

	// if (![x sign] || ![y sign]) {
	// 	NSLog(@"uh-oh");
	// }

	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	FGInt *tmp;
	if (![x sign]) {
		tmp = [FGInt longDivisionMod: x by: pFGInt];
		// tmp = [FGInt add: pFGInt and: x];
	} else {
		tmp = x;
	}

	NSMutableData *result = [[NSMutableData alloc] init];
	// NSData *tmpData = [x toBigEndianNSDataOfLength: cnstLength];
	// NSData *tmpData = [[FGInt longDivisionMod: x by: pFGInt] toBigEndianNSDataOfLength: cnstLength];
	NSData *tmpData = [tmp toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];

	// tmpData = [y toBigEndianNSDataOfLength: cnstLength];
	if (![y sign]) {
		tmp = [FGInt longDivisionMod: y by: pFGInt];
		// tmp = [FGInt add: pFGInt and: y];
	} else {
		tmp = y;
	}
	// tmpData = [[FGInt longDivisionMod: y by: pFGInt] toBigEndianNSDataOfLength: cnstLength];
	tmpData = [tmp toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];

	[pFGInt release];

	return result;
}



@end







@implementation BN256





// mixed addition
//		g2p in projective coordinates X1, Y1, T1, Z1
//		g2q in affine coordinates x2, y2 and constant throughout up to a sign
//		cachedR2 is y1^2 and constant
//		g1Point is constant, xq,yq and where the line is evaluated in

+(void) add: (G2Point **) g2p and: (G2Point *) g2q with: (GFP2 *) cachedR2 evaluateLineIn: (G1Point *) g1Point andMultiply: (GFP12 **) f with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *tmp0, *tmp1;

	GFP2 *b = [GFP2 multiply: [g2q x] and: [*g2p t] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp0 = [GFP2 add: [*g2p z] and: [g2q y] with: pFGInt];
	tmp1 = [GFP2 square: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: cachedR2 with: pFGInt];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp0 and: [*g2p t] with: pFGInt];
	[tmp0 release];
	GFP2 *d = [GFP2 multiply: tmp1 and: [*g2p t] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	GFP2 *h = [GFP2 subtract: b and: [*g2p x] with: pFGInt];
	GFP2 *i = [GFP2 square: h with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *e = [i mutableCopy];
	[e multiplyByInt: 4 with: pFGInt];
	GFP2 *j = [GFP2 multiply: h and: e with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp0 = [GFP2 subtract: d and: [*g2p y] with: pFGInt];
	GFP2 *l1 = [GFP2 subtract: tmp0 and: [*g2p y] with: pFGInt];
	[tmp0 release];
	if ([h isZero] && [l1 isZero]) {
		NSLog(@"kitteeeh");
		[b release];
		[d release];
		[h release];
		[i release];
		[e release];
		[j release];
		[l1 release];
		return [BN256 double: g2p evaluateLineIn: g1Point andMultiply: f with: pFGInt withInvertedP: invertedP andPrecision: precision];
	}

	GFP2 *v = [GFP2 multiply: [*g2p x] and: e with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp0 = [GFP2 square: l1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmp1 = [GFP2 subtract: tmp0 and: j with: pFGInt];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: v with: pFGInt];
	[tmp1 release];
	G2Point *sum = [[G2Point alloc] init];
	[sum setX: [GFP2 subtract: tmp0 and: v with: pFGInt]];
	[tmp0 release];

	tmp0 = [GFP2 subtract: v and: [sum x] with: pFGInt];
	tmp1 = [GFP2 multiply: tmp0 and: l1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 multiply: [*g2p y] and: j with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 shiftLeftWith: pFGInt];
	[sum setY: [GFP2 subtract: tmp1 and: tmp0 with: pFGInt]];
	[tmp1 release];
	[tmp0 release];

	tmp0 = [GFP2 add: h and: [*g2p z] with: pFGInt];
	tmp1 = [GFP2 square: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: [*g2p t] with: pFGInt];
	[tmp1 release];
	[sum setZ: [GFP2 subtract: tmp0 and: i with: pFGInt]];
	[tmp0 release];

	[sum setT: [GFP2 square: [sum z] with: pFGInt withInvertedP: invertedP andPrecision: precision]];

	GFP2 *c0 = [[sum z] mutableCopy];
	[c0 multiplyByFGInt: [g1Point y] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[c0 shiftLeftWith: pFGInt];

	GFP2 *b0 = [l1 mutableCopy];
	[b0 multiplyByFGInt: [g1Point x] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b0 shiftLeftWith: pFGInt];
	[b0 changeSign];

	tmp0 = [GFP2 add: [sum z] and: [g2q y] with: pFGInt];
	tmp1 = [GFP2 square: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: cachedR2 and: tmp1 with: pFGInt];
	[tmp1 release];
	tmp1 = [GFP2 add: tmp0 and: [sum t] with: pFGInt];
	[tmp0 release];
	tmp0 = [GFP2 multiply: l1 and: [g2q x] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 shiftLeftWith: pFGInt];
	GFP2 *a0 = [GFP2 add: tmp1 and: tmp0 with: pFGInt];
	[tmp0 release];
	[tmp1 release];


	GFP6 *a2 = [[GFP6 alloc] init];
	[a2 setC: [[GFP2 alloc] initZero]];
	// [a2 setB: [a0 mutableCopy]];
	// [a2 setA: [b0 mutableCopy]];
	[a2 setB: [a0 retain]];
	[a2 setA: [b0 retain]];
	GFP6 *tmp6 = [GFP6 multiply: a2 and: [*f b] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[a2 release];
	a2 = tmp6;
	tmp6 = [[*f a] mutableCopy];
	[tmp6 multiplyByGFP2: c0 with: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP6 *tmp7 = [[GFP6 alloc] init];
	[tmp7 setA: [GFP2 add: b0 and: c0 with: pFGInt]];
	[tmp7 setB: [a0 mutableCopy]];
	[tmp7 setC: [[GFP2 alloc] initZero]];

	GFP6 *tmp8 = [GFP6 add: [*f a] and: [*f b] with: pFGInt];
	[[*f b] release];
	[[*f a] release];
	[*f setB: tmp8];
	[*f setA: tmp6];

	tmp6 = [GFP6 multiply: [*f b] and: tmp7 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[[*f b] release];
	[tmp7 release];
	tmp7 = [GFP6 subtract: tmp6 and: a2 with: pFGInt];
	[tmp6 release];
	[*f setB: [GFP6 subtract: tmp7 and: [*f a] with: pFGInt]];
	[tmp7 release];
	[a2 multiplyByRootWith: pFGInt];
	tmp6 = [GFP6 add: [*f a] and: a2 with: pFGInt];
	[[*f a] release];
	[*f setA: tmp6];


	[a0 release];
	[a2 release];
	[b0 release];
	[c0 release];

	[b release];
	[d release];
	[h release];
	[i release];
	[e release];
	[j release];
	[l1 release];
	[v release];

	[*g2p release];
	*g2p = sum;
}



+(void) double: (G2Point **) g2p evaluateLineIn: (G1Point *) g1Point andMultiply: (GFP12 **) f with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *a = [GFP2 square: [*g2p x] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *b = [GFP2 square: [*g2p y] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *c = [GFP2 square: b with: pFGInt withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp0 = [GFP2 add: [*g2p x] and: b with: pFGInt];
	GFP2 *tmp1 = [GFP2 square: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: a with: pFGInt];
	[tmp1 release];
	GFP2 *d = [GFP2 subtract: tmp0 and: c with: pFGInt];
	[tmp0 release];
	[d shiftLeftWith: pFGInt];
	GFP2 *e = [a mutableCopy];
	[e multiplyByInt: 3 with: pFGInt];
	GFP2 *g = [GFP2 square: e with: pFGInt withInvertedP: invertedP andPrecision: precision];

	G2Point *sum = [[G2Point alloc] init];
	tmp0 = [GFP2 subtract: g and: d with: pFGInt];
	[sum setX: [GFP2 subtract: tmp0 and: d with: pFGInt]];
	[tmp0 release];

	tmp0 = [GFP2 subtract: d and: [sum x] with: pFGInt];
	tmp1 = [GFP2 multiply: tmp0 and: e with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	// tmp0 = [c mutableCopy];
	tmp0 = [c retain];
	[tmp0 multiplyByInt: 8 with: pFGInt];
	[sum setY: [GFP2 subtract: tmp1 and: tmp0 with: pFGInt]];
	[tmp0 release];
	[tmp1 release];

	tmp0 = [GFP2 add: [*g2p y] and: [*g2p z] with: pFGInt];
	tmp1 = [GFP2 square: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: b with: pFGInt];
	[tmp1 release];
	[sum setZ: [GFP2 subtract: tmp0 and: [*g2p t] with: pFGInt]];
	[tmp0 release];

	[sum setT: [GFP2 square: [sum z] with: pFGInt withInvertedP: invertedP andPrecision: precision]];

	GFP2 *c0 = [GFP2 multiply: [sum z] and: [*g2p t] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[c0 multiplyByFGInt: [g1Point y] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[c0 shiftLeftWith: pFGInt];

	GFP2 *b0 = [GFP2 multiply: [*g2p t] and: e with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b0 multiplyByFGInt: [g1Point x] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[b0 shiftLeftWith: pFGInt];
	[b0 changeSign];

	tmp0 = [GFP2 add: e and: [*g2p x] with: pFGInt];
	tmp1 = [GFP2 square: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: a with: pFGInt];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp0 and: g with: pFGInt];
	[tmp0 release];
	[b multiplyByInt: 4 with: pFGInt];
	GFP2 *a0 = [GFP2 subtract: tmp1 and: b with: pFGInt];
	[tmp1 release];


	GFP6 *a2 = [[GFP6 alloc] init];
	[a2 setC: [[GFP2 alloc] initZero]];
	// [a2 setB: [a0 mutableCopy]];
	// [a2 setA: [b0 mutableCopy]];
	[a2 setB: [a0 retain]];
	[a2 setA: [b0 retain]];
	GFP6 *tmp6 = [GFP6 multiply: a2 and: [*f b] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[a2 release];
	a2 = tmp6;
	tmp6 = [[*f a] mutableCopy];
	[tmp6 multiplyByGFP2: c0 with: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP6 *tmp7 = [[GFP6 alloc] init];
	[tmp7 setA: [GFP2 add: b0 and: c0 with: pFGInt]];
	// [tmp7 setB: [a0 mutableCopy]];
	[tmp7 setB: [a0 retain]];
	[tmp7 setC: [[GFP2 alloc] initZero]];

	GFP6 *tmp8 = [GFP6 add: [*f a] and: [*f b] with: pFGInt];
	[[*f b] release];
	[*f setB: tmp8];
	[[*f a] release];
	[*f setA: tmp6];

	tmp6 = [GFP6 multiply: [*f b] and: tmp7 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[[*f b] release];
	[tmp7 release];
	tmp7 = [GFP6 subtract: tmp6 and: a2 with: pFGInt];
	[tmp6 release];
	[*f setB: [GFP6 subtract: tmp7 and: [*f a] with: pFGInt]];
	[tmp7 release];
	[a2 multiplyByRootWith: pFGInt];
	tmp6 = [GFP6 add: [*f a] and: a2 with: pFGInt];
	[[*f a] release];
	[*f setA: tmp6];

	[a2 release];

	[a0 release];
	[b0 release];
	[c0 release];
	[a release];
	[b release];
	[c release];
	[d release];
	[e release];
	[g release];

	[*g2p release];
	*g2p = sum;
}



+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	GFP12 *result = [BN256 optimalAtePairing: q and: p with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[pFGInt release];

	return result;
}
+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([q infinity] || [p infinity]) {
		return [[GFP12 alloc] initOne];
	}

	int nafLength = 66;
	char naf6up2[] = {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, -1, 0, 1, 0, 0, 0, 1, 0, -1, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 1};

	GFP12 *f = [[GFP12 alloc] initOne];
	GFP12 *tmpF;
	G2Point *r = [q mutableCopy];
	G2Point *minusQ = [q mutableCopy];
	[minusQ changeSign];
	[r makeExtendedProjective];

	GFP2 *cachedR2 = [GFP2 square: [q y] with: pFGInt withInvertedP: invertedP andPrecision: precision];


	for ( int i = nafLength - 1; i > 0; --i ) {
		tmpF = [GFP12 square: f with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[f release];
		f = tmpF;
		[BN256 double: &r evaluateLineIn: p andMultiply: &f with: pFGInt withInvertedP: invertedP andPrecision: precision];

		if (naf6up2[i - 1] == 1) {
			[BN256 add: &r and: q with: cachedR2 evaluateLineIn: p andMultiply: &f with: pFGInt withInvertedP: invertedP andPrecision: precision];
		} else if (naf6up2[i - 1] == -1) {
			[BN256 add: &r and: minusQ with: cachedR2 evaluateLineIn: p andMultiply: &f with: pFGInt withInvertedP: invertedP andPrecision: precision];
		}
	}

	G2Point *q1 = [[G2Point alloc] init];
	GFP2 *tmp0 = [[q x] mutableCopy];
	[tmp0 conjugate];
	GFP2 *tmp = [[GFP2 alloc] init];
	FGIntBase numberArray3[8] = iPlus3ToPm1o3aNumber;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray3 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray4[8] = iPlus3ToPm1o3bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray4 length: cnstLength]];
	[tmp setB: tmpFGInt];
	// [tmp setP: [[tmp0 p] mutableCopy]];
	[q1 setX: [GFP2 multiply: tmp0 and: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision]];
	[tmp release];
	[tmp0 release];
	tmp0 = [[q y] mutableCopy];
	[tmp0 conjugate];
	tmp = [[GFP2 alloc] init];
	FGIntBase numberArray5[8] = iPlus3ToPm1o2aNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray5 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray6[8] = iPlus3ToPm1o2bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray6 length: cnstLength]];
	[tmp setB: tmpFGInt];
	// [tmp setP: [[tmp0 p] mutableCopy]];
	[q1 setY: [GFP2 multiply: tmp0 and: tmp with: pFGInt withInvertedP: invertedP andPrecision: precision]];
	[tmp release];
	[tmp0 release];

	G2Point *q2 = [[G2Point alloc] init];
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray2[8] = iPlus3ToPsm1o3Number;
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	tmp = [[q x] mutableCopy];
	[tmp multiplyByFGInt: tmpFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];
	[q2 setX: tmp];
	[q2 setY: [[q y] mutableCopy]];

	[cachedR2 release];
	cachedR2 = [GFP2 square: [q1 y] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[BN256 add: &r and: q1 with: cachedR2 evaluateLineIn: p andMultiply: &f with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[cachedR2 release];
	cachedR2 = [GFP2 square: [q2 y] with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[BN256 add: &r and: q2 with: cachedR2 evaluateLineIn: p andMultiply: &f with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[r release];
	[minusQ release];
	[cachedR2 release];
	[q1 release];
	[q2 release];


	// FGInt *prime = [[FGInt alloc] initWithoutNumber];
	// FGIntBase numberArrayP[8] = pNumber;
	// [prime setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];
	// FGInt *n = [[FGInt alloc] initWithoutNumber];
	// FGIntBase numberArrayN[8] = nNumber;
	// [n setNumber: [[NSMutableData alloc] initWithBytes: numberArrayN length: cnstLength]];
	// FGInt *p12 = [FGInt raise: prime toThePower: [[FGInt alloc] initWithFGIntBase: 12]];
	// [p12 decrement];
	// NSDictionary *divmod = [FGInt divide: p12 by: n];
	// tmpFGInt = [divmod objectForKey: quotientKey];

	// return [GFP12 raise: f toThePower: tmpFGInt withInvertedP: invertedP andPrecision: precision];


	// final exponentiation

	GFP12 *t1 = [f mutableCopy];
	[[t1 b] changeSign];
	GFP12 *fInv = [f invertWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t1 and: fInv with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	[fInv release];
	t1 = tmpF;

	GFP12 *t2 = [t1 mutableCopy];
	[t2 frobenius2With: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t1 and: t2 withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;

	GFP12 *fp = [t1 mutableCopy], *fp2 = [t1 mutableCopy], *fp3;
	[fp frobeniusWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	[fp2 frobenius2With: pFGInt withInvertedP: invertedP andPrecision: precision];
	fp3 = [fp2 mutableCopy];
	[fp3 frobeniusWith: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP12 *fu, *fu2, *fu3;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray1[] = {3965223681u, 1517727386u};
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: 8]];
	fu = [GFP12 raise: t1 toThePower: tmpFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	fu2 = [GFP12 raise: fu toThePower: tmpFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	fu3 = [GFP12 raise: fu2 toThePower: tmpFGInt with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];

	GFP12 *y3 = [fu mutableCopy], *fu2p = [fu2 mutableCopy], *fu3p = [fu3 mutableCopy], *y2;
	[y3 frobeniusWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	[fu2p frobeniusWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	[fu3p frobeniusWith: pFGInt withInvertedP: invertedP andPrecision: precision];
	y2 = [fu2 mutableCopy];
	[y2 frobenius2With: pFGInt withInvertedP: invertedP andPrecision: precision];

	GFP12 *y0 = [GFP12 multiply: fp and: fp2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: y0 and: fp3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[y0 release];
	y0 = tmpF;

	GFP12 *y1 = [t1 mutableCopy], *y4 = [GFP12 multiply: fu and: fu2p withInvertedP: invertedP andPrecision: precision], 
			*y5 = [fu2 mutableCopy];
	[y1 conjugate];
	[y5 conjugate];
	[y3 conjugate];
	[y4 conjugate];

	GFP12 *y6 = [GFP12 multiply: fu3 and: fu3p with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[y6 conjugate];

	GFP12 *t0 = [GFP12 square: y6 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t0 and: y4 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t0 release];
	t0 = [GFP12 multiply: tmpF and: y5 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = [GFP12 multiply: y3 and: y5 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t0 and: t1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;
	tmpF = [GFP12 multiply: t0 and: y2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t0 release];
	t0 = tmpF;
	tmpF = [GFP12 square: t1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = [GFP12 multiply: t0 and: tmpF with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpF release];
	tmpF = [GFP12 square: t1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;
	[t0 release];
	t0 = [GFP12 multiply: t1 and: y1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t1 and: y0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;
	tmpF = [GFP12 square: t0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	f = [GFP12 multiply: t1 and: tmpF with: pFGInt withInvertedP: invertedP andPrecision: precision];

	[t0 release];
	[t1 release];
	[y0 release];
	[y1 release];
	[y2 release];
	[y3 release];
	[y4 release];
	[y5 release];
	[y6 release];
	[fu release];
	[fu2 release];
	[fu3 release];
	[fp release];
	[fp2 release];
	[fp3 release];
	[fu2p release];
	[fu3p release];

	return f;
}


+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p {
	if ([q infinity] || [p infinity]) {
		return [[GFP12 alloc] initOne];
	}
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	GFP12 *result = [BN256 optimalAtePairing: q and: p with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[invertedP release];
	[pFGInt release];

	return result;
}


+(BOOL) testPairing {
	FGIntBase precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: invertedLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];

	FGInt *tmpFGInt1 = [[FGInt alloc] initWithRandomNumberOfBitSize: precision - 1], 
			*tmpFGInt2 = [[FGInt alloc] initWithRandomNumberOfBitSize: precision - 1], 
			*tmpFGInt3 = [[FGInt alloc] initWithRandomNumberOfBitSize: precision - 1];
	G1Point *g1gen = [[G1Point alloc] initGenerator];
	G1Point *g1_1 = [G1Point add: g1gen kTimes: tmpFGInt1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	G1Point *g1_2 = [G1Point add: g1gen kTimes: tmpFGInt2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	G1Point *g1_3 = [G1Point add: g1gen kTimes: tmpFGInt3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	G2Point *g2gen = [[G2Point alloc] initGenerator];
	G2Point *g2_1 = [G2Point add: g2gen kTimes: tmpFGInt1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	G2Point *g2_2 = [G2Point add: g2gen kTimes: tmpFGInt2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	G2Point *g2_3 = [G2Point add: g2gen kTimes: tmpFGInt3 with: pFGInt withInvertedP: invertedP andPrecision: precision];

	__block GFP12 *gfp12_1, *gfp12_2, *gfp12_3;
    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


//	NSDate *date1;
//	double timePassed_ms1;
	// g2_1 = [[G2Point alloc] unMarshal: [g2_1 marshal]];
	// g1_2 = [[G1Point alloc] unMarshal: [g1_2 marshal]];
	dispatch_group_async(d_group, bg_queue, ^{
		NSDate *date_1 = [NSDate date];
		GFP12 *tmpGFP12 = [BN256 optimalAtePairing: g2_1 and: g1_2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		double timePassed_ms_1 = [date_1 timeIntervalSinceNow] * -1000.0;
		NSLog(@"1st pairing and exponentiation took %fms", timePassed_ms_1);
		gfp12_1 = [GFP12 raise: tmpGFP12 toThePower: tmpFGInt3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmpGFP12 release];
    });


	// g2_2 = [[G2Point alloc] unMarshal: [g2_2 marshal]];
	// g1_3 = [[G1Point alloc] unMarshal: [g1_3 marshal]];
	dispatch_group_async(d_group, bg_queue, ^{
		NSDate *date_2 = [NSDate date];
		GFP12 *tmpGFP12 = [BN256 optimalAtePairing: g2_2 and: g1_3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		double timePassed_ms_2 = [date_2 timeIntervalSinceNow] * -1000.0;
		NSLog(@"2nd pairing and exponentiation took %fms", timePassed_ms_2);
		gfp12_2 = [GFP12 raise: tmpGFP12 toThePower: tmpFGInt1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmpGFP12 release];
    });


	// g2_3 = [[G2Point alloc] unMarshal: [g2_3 marshal]];
	// g1_1 = [[G1Point alloc] unMarshal: [g1_1 marshal]];
	dispatch_group_async(d_group, bg_queue, ^{
		NSDate *date_3 = [NSDate date];
		GFP12 *tmpGFP12 = [BN256 optimalAtePairing: g2_3 and: g1_1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		double timePassed_ms_3 = [date_3 timeIntervalSinceNow] * -1000.0;
		NSLog(@"3rd pairing and exponentiation took %fms", timePassed_ms_3);
		gfp12_3 = [GFP12 raise: tmpGFP12 toThePower: tmpFGInt2 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmpGFP12 release];
    });

	dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    dispatch_release(d_group);

	// gfp12_1 = [[GFP12 alloc] unMarshal: [gfp12_1 marshal]];
	// gfp12_2 = [[GFP12 alloc] unMarshal: [gfp12_2 marshal]];
	// gfp12_3 = [[GFP12 alloc] unMarshal: [gfp12_3 marshal]];

	GFP12 *gfp12 = [GFP12 subtract: gfp12_1 and: gfp12_2 with: pFGInt], 
			*gfp13 = [GFP12 subtract: gfp12_1 and: gfp12_3 with: pFGInt], 
			*gfp23 = [GFP12 subtract: gfp12_3 and: gfp12_2 with: pFGInt];

	// NSLog(@"%@", [gfp12 toBase10String]);
	// NSLog(@"%@", [gfp23 toBase10String]);
	// NSLog(@"%@", [gfp13 toBase10String]);

	[pFGInt release];
	[invertedP release];
	[g1gen release];
	[g2gen release];
	[g1_1 release];
	[g1_2 release];
	[g1_3 release];
	[g2_1 release];
	[g2_2 release];
	[g2_3 release];
	[tmpFGInt1 release];
	[tmpFGInt2 release];
	[tmpFGInt3 release];

	BOOL result = ([gfp13 isZero] && [gfp23 isZero] && [gfp12 isZero]);

	NSLog(@" Pairing test was %@successful \n\n", result?@"":@"not ");
	[gfp12 release];
	[gfp13 release];
	[gfp23 release];

	return result;
}


@end





























