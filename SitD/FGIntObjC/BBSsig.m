#import "BBSsig.h"
#import "FGIntXtra.h"




@implementation BBSRevocation
@synthesize a;
@synthesize x;
@synthesize aStar;


-(id) init {
    if (self = [super init]) {
		a = nil;
		x = nil;
		aStar = nil;
    }
    return self;
}
-(void) dealloc {
	if (a != nil) {
	    [a release];
	}
	if (x != nil) {
	    [x release];
	}
	if (aStar != nil) {
	    [aStar release];
	}
    [super dealloc];
}


-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 7*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 2*cnstLength];
    	a = [[G1Point alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[2*cnstLength] length: cnstLength];
    	x = [[FGInt alloc] initWithBigEndianNSData: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[3*cnstLength] length: 4*cnstLength];
    	aStar = [[G2Point alloc] unMarshal: tmpData];
		[tmpData release];
    }
    return self;
}



-(NSData *) marshal {
	if ((x == nil) || (a == nil) || (aStar == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [a marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [x toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [aStar marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}


@end






@implementation BBSGroup
@synthesize g1, h, u, v;
@synthesize	g2, w;
@synthesize ehw, ehg2, minusEg1g2;


-(id) init {
    if (self = [super init]) {
		g1 = nil;
		h = nil;
		u = nil;
		v = nil;
		g2 = nil;
		w = nil;
		ehw = nil;
		ehg2 = nil;
		minusEg1g2 = nil;
    }
    return self;
}
-(void) dealloc {
	if (g1 != nil) {
	    [g1 release];
	}
	if (h != nil) {
	    [h release];
	}
	if (u != nil) {
	    [u release];
	}
	if (v != nil) {
	    [v release];
	}
	if (g2 != nil) {
	    [g2 release];
	}
	if (w != nil) {
	    [w release];
	}
	if (ehw != nil) {
	    [ehw release];
	}
	if (ehg2 != nil) {
	    [ehg2 release];
	}
	if (minusEg1g2 != nil) {
	    [minusEg1g2 release];
	}
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	BBSGroup *newGroup = [[BBSGroup alloc] init];
	[newGroup setG1: [g1 mutableCopy]];
	[newGroup setH: [h mutableCopy]];
	[newGroup setU: [u mutableCopy]];
	[newGroup setV: [v mutableCopy]];
	[newGroup setG2: [g2 mutableCopy]];
	[newGroup setW: [w mutableCopy]];
	[newGroup setEhw: [ehw mutableCopy]];
	[newGroup setEhg2: [ehg2 mutableCopy]];
	[newGroup setMinusEg1g2: [minusEg1g2 mutableCopy]];

	return newGroup;
}


-(void) updateWithRevocation: (BBSRevocation *) revocation {
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	FGInt *tmpFGInt = [FGInt subtract: order and: [revocation x]];
	G2Point *tmp0G2 = [G2Point add: [revocation aStar] kTimes: tmpFGInt];
	[tmpFGInt release];

	[w release];
	w = [G2Point add: g2 and: tmp0G2];
	[tmp0G2 release];

	[g1 release];
	g1 = [[revocation a] mutableCopy];
	[g2 release];
	g2 = [[revocation aStar] mutableCopy];

	[order release];

	__block GFP12 *tmpEHW, *tmpEHG2, *tmpMG1G2;
    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	dispatch_group_async(d_group, bg_queue, ^{
		GFP12 *tmp = [BN256 optimalAtePairing: g2 and: g1];
		tmpMG1G2 = [tmp invert];
		[tmp release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		tmpEHW = [BN256 optimalAtePairing: w and: h];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		tmpEHG2 = [BN256 optimalAtePairing: g2 and: h];
    });
	dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    dispatch_release(d_group);

	ehw = tmpEHW;
	ehg2 = tmpEHG2;
	minusEg1g2 = tmpMG1G2;
}


-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != (4*2 + 2*4)*cnstLength && [marshalData length] != (4*2 + 2*4 + 12*3)*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 2*cnstLength];
    	g1 = [[G1Point alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[2*cnstLength] length: 2*cnstLength];
    	h = [[G1Point alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[4*cnstLength] length: 2*cnstLength];
    	u = [[G1Point alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[6*cnstLength] length: 2*cnstLength];
    	v = [[G1Point alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[8*cnstLength] length: 4*cnstLength];
    	g2 = [[G2Point alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[12*cnstLength] length: 4*cnstLength];
    	w = [[G2Point alloc] unMarshal: tmpData];
		[tmpData release];

		__block GFP12 *tmpEHW, *tmpEHG2, *tmpMG1G2;

		if ([marshalData length] < (4*2 + 2*4 + 12*3)*cnstLength) {
		    dispatch_group_t d_group = dispatch_group_create();
		    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

			dispatch_group_async(d_group, bg_queue, ^{
				GFP12 *tmp = [BN256 optimalAtePairing: g2 and: g1];
				tmpMG1G2 = [tmp invert];
				[tmp release];
		    });
			dispatch_group_async(d_group, bg_queue, ^{
				tmpEHW = [BN256 optimalAtePairing: w and: h];
		    });
			dispatch_group_async(d_group, bg_queue, ^{
				tmpEHG2 = [BN256 optimalAtePairing: g2 and: h];
		    });
			dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
		    dispatch_release(d_group);
		} else {
	    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[16*cnstLength] length: 12*cnstLength];
	    	tmpEHW = [[GFP12 alloc] unMarshal: tmpData];
			[tmpData release];
	    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[28*cnstLength] length: 12*cnstLength];
	    	tmpEHG2 = [[GFP12 alloc] unMarshal: tmpData];
			[tmpData release];
	    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[40*cnstLength] length: 12*cnstLength];
	    	tmpMG1G2 = [[GFP12 alloc] unMarshal: tmpData];
			[tmpData release];
		}

		ehw = tmpEHW;
		ehg2 = tmpEHG2;
		minusEg1g2 = tmpMG1G2;
    }
    return self;
}



-(NSData *) marshal {
	if ((g1 == nil) || (h == nil) || (u == nil) || v == (nil) || (g2 == nil) || (w == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [g1 marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [h marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [u marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [v marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [g2 marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [w marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}

-(NSData *) extendedMarshal {
	if ((g1 == nil) || (h == nil) || (u == nil) || v == (nil) || (g2 == nil) || (w == nil) || (ehw == nil) || (ehg2 == nil) || (minusEg1g2 == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [g1 marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [h marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [u marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [v marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [g2 marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [w marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [ehw marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [ehg2 marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [minusEg1g2 marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}


@end




@implementation BBSMemberKey
@synthesize group;
@synthesize x;
@synthesize a;


-(id) init {
    if (self = [super init]) {
    	group = nil;
		x = nil;
		a = nil;
    }
    return self;
}
-(id) initNewMemberWithGroupPrivateKey: (BBSPrivateKey *) bbsGroupPrivate {
    if (self = [super init]) {
		group = [[bbsGroupPrivate group] mutableCopy];

		FGInt *order = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray[] = nNumber;
		[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

		x = [[FGInt alloc] initWithRandomNumberAtMost: order];
		if (x == nil) {
			[group release];
			[order release];
			return nil;
		}
		FGInt *tmp0 = [FGInt add: [bbsGroupPrivate gamma] and: x];
		// [tmp0 reduceBySubtracting: order atMost: 1];
		FGInt *tmp1 = [FGInt invert: tmp0 moduloPrime: order];
		[tmp0 release];

		a = [G1Point add: [group g1] kTimes: tmp1];
		[tmp1 release];

		[order release];
    }
    return self;
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	BBSMemberKey *newMember = [[BBSMemberKey alloc] init];

	[newMember setX: [x mutableCopy]];
	[newMember setA: [a mutableCopy]];
	[newMember setGroup: [group mutableCopy]];

	return newMember;
}
-(void) dealloc {
	if (x != nil) {
	    [x release];
	}
	if (a != nil) {
	    [a release];
	}
	if (group != nil) {
		[group release];
	}
    [super dealloc];
}

-(BOOL) updateWithRevocation: (BBSRevocation *) revocation {
	if ([FGInt compareAbsoluteValueOf: x with: [revocation x]] == equal) {
		return NO;
	}

	[group updateWithRevocation: revocation];

	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	FGInt *tmp0 = [FGInt subtract: x and: [revocation x]];
	FGInt *d = [FGInt invert: tmp0 moduloPrime: order];
	[tmp0 release];
	[order release];

	G1Point *tmp0G1 = [G1Point add: [revocation a] kTimes: d];
	G1Point *tmp1G1 = [G1Point add: a kTimes: d];
	[d release];
	[tmp1G1 changeSign];
	[a release];
	a = [G1Point add: tmp0G1 and: tmp1G1];
	[tmp0G1 release];
	[tmp1G1 release];

	return YES;
}


-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 3*cnstLength && [marshalData length] != (3*cnstLength + (4*2 + 2*4 + 12*3)*cnstLength)) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: bytes length: cnstLength];
    	x = [[FGInt alloc] initWithBigEndianNSData: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[cnstLength] length: 2*cnstLength];
    	a = [[G1Point alloc] unMarshal: tmpData];
		[tmpData release];
        if ([marshalData length] == (3*cnstLength + (4*2 + 2*4 + 12*3)*cnstLength)) {
            tmpData = [[NSMutableData alloc] initWithBytes: &bytes[3*cnstLength] length: (4*2 + 2*4 + 12*3)*cnstLength];
            group = [[BBSGroup alloc] unMarshal:tmpData];
            [tmpData release];
        }
        
    }
    return self;
}



-(NSData *) marshal {
    if ((x == nil) || (a == nil)) {
        return nil;
    }
    NSMutableData *result = [[NSMutableData alloc] init];
    NSData *tmpData = [x toBigEndianNSDataOfLength: cnstLength];
    [result appendData: tmpData];
    [tmpData release];
    tmpData = [a marshal];
    [result appendData: tmpData];
    [tmpData release];
    
    return result;
}

-(NSData *) extendedMarshal {
    if ((x == nil) || (a == nil)) {
        return nil;
    }
    NSMutableData *result = [[NSMutableData alloc] init];
    NSData *tmpData = [x toBigEndianNSDataOfLength: cnstLength];
    [result appendData: tmpData];
    [tmpData release];
    tmpData = [a marshal];
    [result appendData: tmpData];
    [tmpData release];
    tmpData = [group extendedMarshal];
    [result appendData: tmpData];
    [tmpData release];
    
    
    return result;
}


@end












@implementation BBSPrivateKey
@synthesize group;
@synthesize xi1, xi2, gamma;


-(id) init {
    if (self = [super init]) {
    	group = nil;
		xi1 = nil;
		xi2 = nil;
		gamma = nil;
    }
    return self;
}
-(id) generateGroup {
    if (self = [super init]) {
    	group = [[BBSGroup alloc] init];

		__block G1Point *tmp0G1, *tmp1G1;
		__block G2Point *tmpG2;
	    dispatch_group_t d_group = dispatch_group_create();
	    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

		dispatch_group_async(d_group, bg_queue, ^{
			tmp0G1 = [[G1Point alloc] initRandomPoint];
	    });
		dispatch_group_async(d_group, bg_queue, ^{
			tmp1G1 = [[G1Point alloc] initRandomPoint];
	    });
		dispatch_group_async(d_group, bg_queue, ^{
	    	tmpG2 = [[G2Point alloc] initRandomPoint];
	    });
		dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);


    	[group setG1: tmp0G1];
    	if (tmp0G1 == nil) {
    		[group release];
    		return nil;
    	}
    	[group setH: tmp1G1];
    	if (tmp1G1 == nil) {
    		[group release];
    		return nil;
    	}
    	[group setG2: tmpG2];
    	if (tmpG2 == nil) {
    		[group release];
    		return nil;
    	}

    	FGInt *order = [[FGInt alloc] initWithoutNumber];
    	FGIntBase numberArray[] = nNumber;
    	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
    	FGInt *tmpFGInt = [[FGInt alloc] initWithRandomNumberAtMost: order];
    	if (tmpFGInt == nil) {
    		[order release];
    		[group release];
    		return nil;
    	} else {
    		xi1 = tmpFGInt;
    	}
    	tmpFGInt = [[FGInt alloc] initWithRandomNumberAtMost: order];
    	if (tmpFGInt == nil) {
    		[order release];
    		[group release];
    		[xi1 release];
    		return nil;
    	} else {
    		xi2 = tmpFGInt;
    	}
    	tmpFGInt = [[FGInt alloc] initWithRandomNumberAtMost: order];
    	if (tmpFGInt == nil) {
    		[order release];
    		[group release];
    		[xi1 release];
    		[xi2 release];
    		return nil;
    	} else {
    		gamma = tmpFGInt;
    	}

    	[group setW: [G2Point add: [group g2] kTimes: gamma]];


		__block GFP12 *tmpEHW, *tmpEHG2, *tmpMG1G2;
		__block G1Point *tmpU, *tmpV;

		dispatch_group_async(d_group, bg_queue, ^{
			GFP12 *tmp = [BN256 optimalAtePairing: [group g2] and: [group g1]];
			tmpMG1G2 = [tmp invert];
			[tmp release];
	    });
		dispatch_group_async(d_group, bg_queue, ^{
			tmpEHW = [BN256 optimalAtePairing: [group w] and: [group h]];
	    });
		dispatch_group_async(d_group, bg_queue, ^{
			tmpEHG2 = [BN256 optimalAtePairing: [group g2] and: [group h]];
	    });
		dispatch_group_async(d_group, bg_queue, ^{
			FGInt *tmp = [FGInt invert: xi1 moduloPrime: order];
			tmpU = [G1Point add: [group h] kTimes: tmp];
			[tmp release];
	    });
		dispatch_group_async(d_group, bg_queue, ^{
			FGInt *tmp = [FGInt invert: xi2 moduloPrime: order];
			tmpV = [G1Point add: [group h] kTimes: tmp];
			[tmp release];
	    });
		dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
	    dispatch_release(d_group);

    	[group setEhw: tmpEHW];
    	[group setEhg2: tmpEHG2];
    	[group setMinusEg1g2: tmpMG1G2];
	    [group setU: tmpU];
	    [group setV: tmpV];

    	[order release];
    }
    return self;
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	BBSPrivateKey *newPrivate = [[BBSPrivateKey alloc] init];

	[newPrivate setXi1: [xi1 mutableCopy]];
	[newPrivate setXi2: [xi2 mutableCopy]];
	[newPrivate setGroup: [group mutableCopy]];

	return newPrivate;
}
-(void) dealloc {
	if (xi1 != nil) {
	    [xi1 release];
	}
	if (xi2 != nil) {
	    [xi2 release];
	}
	if (gamma != nil) {
	    [gamma release];
	}
	if (group != nil) {
		[group release];
	}
    [super dealloc];
}


-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 3*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: bytes length: cnstLength];
    	xi1 = [[FGInt alloc] initWithBigEndianNSData: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[cnstLength] length: cnstLength];
    	xi2 = [[FGInt alloc] initWithBigEndianNSData: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[2*cnstLength] length: cnstLength];
    	gamma = [[FGInt alloc] initWithBigEndianNSData: tmpData];
		[tmpData release];
    }
    return self;
}

-(NSData *) marshal {
	if ((xi1 == nil) || (xi2 == nil) || (gamma == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [xi1 toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [xi2 toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [gamma toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}

-(BBSRevocation *) generateRevocationForMember: (BBSMemberKey *) memberKey {
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	BBSRevocation *revocation = [[BBSRevocation alloc] init];
	FGInt *tmp0 = [FGInt add: gamma and: [memberKey x]], 
			*s = [FGInt invert: tmp0 moduloPrime: order];
	[order release];
	[tmp0 release];

	[revocation setAStar: [G2Point add: [group g2] kTimes: s]];
	[s release];
	[revocation setX: [[memberKey x] mutableCopy]];
	[revocation setA: [[memberKey a] mutableCopy]];

	return revocation;
}

@end











@implementation BBSsig


+(NSData *) hash: (NSData *) plaintext {
	return [FGIntXtra SHA256: plaintext];
}


+(NSData *) sign: (NSData *) digest withMemberKey: (BBSMemberKey *) memberKey {
	FGIntOverflow precision = precisionBits;
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];
	FGInt *tmp0;

	NSMutableArray *rndms = [[NSMutableArray alloc] init];
	for ( int i = 0; i < 7; ++i ) {
		tmp0 = [[FGInt alloc] initWithRandomNumberAtMost: order];
		if (tmp0 == nil) {
			[rndms release];
			[order release];
			return nil;
		}
		[rndms addObject: tmp0];
	}
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayInvP[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArrayInvP length: invertedLength]];

	FGInt *alpha = [rndms objectAtIndex: 0];
	FGInt *beta = [rndms objectAtIndex: 1];

	G1Point *t1 = [G1Point add: [[memberKey group] u] kTimes: alpha with: pFGInt withInvertedP: invertedP andPrecision: precision];
	G1Point *t2 = [G1Point add: [[memberKey group] v] kTimes: beta with: pFGInt withInvertedP: invertedP andPrecision: precision];

	tmp0 = [FGInt add: alpha and: beta];
	[tmp0 reduceBySubtracting: order atMost: 1];
	G1Point *tmp0G1 = [G1Point add: [[memberKey group] h] kTimes: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision], 
			// *t33 = [[memberKey a] mutableCopy],
			// *t3 = [G1Point add: tmp0G1 and: t33];
			*t3 = [G1Point add: tmp0G1 and: [memberKey a]];
	[tmp0 release];
	[tmp0G1 release];

	FGInt *invertedOrder = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayN[] = invertedNnumber;
	[invertedOrder setNumber: [[NSMutableData alloc] initWithBytes: numberArrayN length: invertedLength]];

	tmp0 = [FGInt multiply: alpha and: [memberKey x]];
	FGInt *delta1 = [FGInt barrettMod: tmp0 by: order with: invertedOrder andPrecision: precision];
	[tmp0 release];
	tmp0 = [FGInt multiply: beta and: [memberKey x]];
	FGInt *delta2 = [FGInt barrettMod: tmp0 by: order with: invertedOrder andPrecision: precision];
	[tmp0 release];

	FGInt *ralpha = [rndms objectAtIndex: 2];
	FGInt *rbeta = [rndms objectAtIndex: 3];
	FGInt *rx = [rndms objectAtIndex: 4];
	FGInt *rdelta1 = [rndms objectAtIndex: 5];
	FGInt *rdelta2 = [rndms objectAtIndex: 6];

	__block G1Point *r1, *r2, *r4, *r5;
	__block GFP12 *r3, *tmp0_r3, *tmp1_r3;
    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	dispatch_group_async(d_group, bg_queue, ^{
		r1 = [G1Point add: [[memberKey group] u] kTimes: ralpha with: pFGInt withInvertedP: invertedP andPrecision: precision];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		r2 = [G1Point add: [[memberKey group] v] kTimes: rbeta with: pFGInt withInvertedP: invertedP andPrecision: precision];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		GFP12 *tmpGFP12 = [BN256 optimalAtePairing: [[memberKey group] g2] and: t3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		r3 = [GFP12 raise: tmpGFP12 toThePower: rx with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmpGFP12 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		FGInt *tmp0 = [FGInt add: ralpha and: rbeta];
		[tmp0 reduceBySubtracting: order atMost: 1];
		FGInt *tmp1 = [FGInt subtract: order and: tmp0];
		[tmp0 release];
		tmp0_r3 = [GFP12 raise: [[memberKey group] ehw] toThePower: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmp1 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		FGInt *tmp0 = [FGInt add: rdelta1 and: rdelta2];
		[tmp0 reduceBySubtracting: order atMost: 1];
		FGInt *tmp1 = [FGInt subtract: order and: tmp0];
		[tmp0 release];
		tmp1_r3 = [GFP12 raise: [[memberKey group] ehg2] toThePower: tmp1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmp1 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		G1Point *tmp0G1 = [G1Point add: t1 kTimes: rx with: pFGInt withInvertedP: invertedP andPrecision: precision];
		FGInt *tmp0 = [FGInt subtract: order and: rdelta1];
		G1Point *tmp1G1 = [G1Point add: [[memberKey group] u] kTimes: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		r4 = [G1Point add: tmp0G1 and: tmp1G1];
		[tmp1G1 release];
		[tmp0G1 release];
		[tmp0 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		G1Point *tmp0G1 = [G1Point add: t2 kTimes: rx with: pFGInt withInvertedP: invertedP andPrecision: precision];
		FGInt *tmp0 = [FGInt subtract: order and: rdelta2];
		G1Point *tmp1G1 = [G1Point add: [[memberKey group] v] kTimes: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		r5 = [G1Point add: tmp0G1 and: tmp1G1];
		[tmp1G1 release];
		[tmp0G1 release];
		[tmp0 release];
    });
	dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    dispatch_release(d_group);

	GFP12 *tmp0GFP12 = [GFP12 multiply: r3 and: tmp0_r3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0_r3 release];
	[r3 release];
	r3 = tmp0GFP12;
	tmp0GFP12 = [GFP12 multiply: r3 and: tmp1_r3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp1_r3 release];
	[r3 release];
	r3 = tmp0GFP12;


	NSData *tmpData;
	NSMutableData *hashData = [[NSMutableData alloc] init];
	[hashData appendData: digest];
	tmpData = [t1 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [t2 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [t3 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r1 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r2 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r3 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r4 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r5 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [BBSsig hash: hashData];
	[hashData release];

	FGInt *c = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];
	[c reduceBySubtracting: order atMost: 1];

	tmp0 = [FGInt multiply: c and: alpha];
	[tmp0 addWith: ralpha];
	FGInt *salpha = [FGInt barrettMod: tmp0 by: order with: invertedOrder andPrecision: precision];
	[tmp0 release];

	tmp0 = [FGInt multiply: c and: beta];
	[tmp0 addWith: rbeta];
	FGInt *sbeta = [FGInt barrettMod: tmp0 by: order with: invertedOrder andPrecision: precision];
	[tmp0 release];

	tmp0 = [FGInt multiply: c and: [memberKey x]];
	[tmp0 addWith: rx];
	FGInt *sx = [FGInt barrettMod: tmp0 by: order with: invertedOrder andPrecision: precision];
	[tmp0 release];

	tmp0 = [FGInt multiply: c and: delta1];
	[tmp0 addWith: rdelta1];
	FGInt *sdelta1 = [FGInt barrettMod: tmp0 by: order with: invertedOrder andPrecision: precision];
	[tmp0 release];

	tmp0 = [FGInt multiply: c and: delta2];
	[tmp0 addWith: rdelta2];
	FGInt *sdelta2 = [FGInt barrettMod: tmp0 by: order with: invertedOrder andPrecision: precision];
	[tmp0 release];

	NSMutableData *signature = [[NSMutableData alloc] init];
	tmpData = [t1 marshal];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [t2 marshal];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [t3 marshal];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [c toBigEndianNSDataOfLength: cnstLength];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [salpha toBigEndianNSDataOfLength: cnstLength];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [sbeta toBigEndianNSDataOfLength: cnstLength];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [sx toBigEndianNSDataOfLength: cnstLength];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [sdelta1 toBigEndianNSDataOfLength: cnstLength];
	[signature appendData: tmpData];
	[tmpData release];
	tmpData = [sdelta2 toBigEndianNSDataOfLength: cnstLength];
	[signature appendData: tmpData];
	[tmpData release];


	[order release];
	[pFGInt release];
	[rndms release];
	[t1 release];
	[t2 release];
	[t3 release];
	[invertedOrder release];
	[delta1 release];
	[delta2 release];
	[r1 release];
	[r2 release];
	[r3 release];
	[r4 release];
	[r5 release];
	[invertedP release];
	[c release];
	[salpha release];
	[sbeta release];
	[sx release];
	[sdelta1 release];
	[sdelta2 release];

	return signature;
}


+(G1Point *) r1245: (G1Point *) g1 and: (G1Point *) g2 addKtimes: (FGInt *) k andLtimes: (FGInt *) l with: (FGInt *) pFGInt withOrder: (FGInt *) order andInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	G1Point *tmp0G1 = [G1Point add: g1 kTimes: k with: pFGInt withInvertedP: invertedP andPrecision: precision];
	FGInt *tmp0 = [FGInt subtract: order and: l];
	G1Point *tmp1G1 = [G1Point add: g2 kTimes: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	G1Point *result = [G1Point add: tmp0G1 and: tmp1G1];
	[tmp1G1 release];
	[tmp0G1 release];

	return result;
}

+(GFP12 *) sAdd: (FGInt *) s1 and: (FGInt *) s2 andRaise: (GFP12 *) gfp12 with: (FGInt *) pFGInt withOrder: (FGInt *) order andInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision { 
	FGInt *tmp1 = [FGInt add: s1 and: s2];
	[tmp1 reduceBySubtracting: order atMost: 1];
	FGInt *tmp0 = [FGInt subtract: order and: tmp1];
	[tmp1 release];
 	GFP12 *result = [GFP12 raise: gfp12 toThePower: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];

	return result;
}

+(GFP12 *) pair: (G2Point *) g2 and: (G1Point *) g1 multiply: (GFP12 *) gfp12 andRaiseTo: (FGInt *) exp with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP12 *tmp0GFP12 = [BN256 optimalAtePairing: g2 and: g1 with: pFGInt withInvertedP: invertedP andPrecision: precision];
	if (gfp12) {
		GFP12 *tmp1GFP12 = [GFP12 multiply: tmp0GFP12 and: gfp12 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmp0GFP12 release];
		tmp0GFP12 = tmp1GFP12;
	}
	GFP12 *result = [GFP12 raise: tmp0GFP12 toThePower: exp with: pFGInt withInvertedP: invertedP andPrecision: precision];
	[tmp0GFP12 release];

	return result;
}


+(BOOL) verifySignature: (NSData *) signature ofDigest: (NSData *) digest withGroupKey: (BBSGroup *) groupKey {
	if ([signature length] != 12*cnstLength) {
		return NO;
	}

	unsigned char *signatureBytes = (unsigned char *)[signature bytes];
	NSData *tmpData = [[NSData alloc] initWithBytes: signatureBytes length: 2*cnstLength];
	G1Point *t1 = [[G1Point alloc] unMarshal: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[2*cnstLength] length: 2*cnstLength];
	G1Point *t2 = [[G1Point alloc] unMarshal: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[4*cnstLength] length: 2*cnstLength];
	G1Point *t3 = [[G1Point alloc] unMarshal: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[6*cnstLength] length: cnstLength];
	FGInt *c = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[7*cnstLength] length: cnstLength];
	FGInt *salpha = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[8*cnstLength] length: cnstLength];
	FGInt *sbeta = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[9*cnstLength] length: cnstLength];
	FGInt *sx = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[10*cnstLength] length: cnstLength];
	FGInt *sdelta1 = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[11*cnstLength] length: cnstLength];
	FGInt *sdelta2 = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];


	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayInvP[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArrayInvP length: invertedLength]];
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
	FGInt *pFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = pNumber;
	[pFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];


	__block G1Point *r1, *r2, *r4, *r5;
	__block GFP12 *tmp0_r3, *tmp1_r3, *tmp2_r3, *tmp3_r3;
    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	dispatch_group_async(d_group, bg_queue, ^{
		GFP12 *tmp0GFP12 = [BN256 optimalAtePairing: [groupKey g2] and: t3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		tmp2_r3 = [GFP12 raise: tmp0GFP12 toThePower: sx with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmp0GFP12 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		GFP12 *tmp0GFP12 = [BN256 optimalAtePairing: [groupKey w] and: t3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		GFP12 *tmp1GFP12 = [GFP12 multiply: tmp0GFP12 and: [groupKey minusEg1g2] with: pFGInt withInvertedP: invertedP andPrecision: precision];
		tmp3_r3 = [GFP12 raise: tmp1GFP12 toThePower: c with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmp1GFP12 release];
		[tmp0GFP12 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		FGInt *tmp1 = [FGInt add: salpha and: sbeta];
		[tmp1 reduceBySubtracting: order atMost: 1];
		FGInt *tmp0 = [order mutableCopy];
		[tmp0 subtractWith: tmp1];
		[tmp1 release];
	 	tmp0_r3 = [GFP12 raise: [groupKey ehw] toThePower: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmp0 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		FGInt *tmp1 = [FGInt add: sdelta1 and: sdelta2];
		[tmp1 reduceBySubtracting: order atMost: 1];
		FGInt *tmp0 = [FGInt subtract: order and: tmp1];
		[tmp1 release];
	 	tmp1_r3 = [GFP12 raise: [groupKey ehg2] toThePower: tmp0 with: pFGInt withInvertedP: invertedP andPrecision: precision];
		[tmp0 release];
    });
	dispatch_group_async(d_group, bg_queue, ^{
	 	r1 = [BBSsig r1245: [groupKey u] and: t1 addKtimes: salpha andLtimes: c with: pFGInt withOrder: order andInvertedP: invertedP andPrecision: precision];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		r2 = [BBSsig r1245: [groupKey v] and: t2 addKtimes: sbeta andLtimes: c with: pFGInt withOrder: order andInvertedP: invertedP andPrecision: precision];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		r4 = [BBSsig r1245: t1 and: [groupKey u] addKtimes: sx andLtimes: sdelta1 with: pFGInt withOrder: order andInvertedP: invertedP andPrecision: precision];
    });
	dispatch_group_async(d_group, bg_queue, ^{
		r5 = [BBSsig r1245: t2 and: [groupKey v] addKtimes: sx andLtimes: sdelta2 with: pFGInt withOrder: order andInvertedP: invertedP andPrecision: precision];
    });

	dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    dispatch_release(d_group);

    GFP12 *r3 = [GFP12 multiply: tmp1_r3 and: tmp0_r3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
    [tmp1_r3 release];
    [tmp0_r3 release];
    tmp0_r3 = [GFP12 multiply: r3 and: tmp2_r3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
    [tmp2_r3 release];
    [r3 release];
    r3 = tmp0_r3;
    tmp1_r3 = [GFP12 multiply: r3 and: tmp3_r3 with: pFGInt withInvertedP: invertedP andPrecision: precision];
    [tmp3_r3 release];
    [r3 release];
    r3 = tmp1_r3;

	NSMutableData *hashData = [[NSMutableData alloc] initWithData: digest];
	tmpData = [t1 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [t2 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [t3 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r1 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r2 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r3 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r4 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [r5 marshal];
	[hashData appendData: tmpData];
	[tmpData release];
	tmpData = [BBSsig hash: hashData];
	[hashData release];

	FGInt *cPrime = [[FGInt alloc] initWithBigEndianNSData: tmpData];
	[tmpData release];
	[cPrime reduceBySubtracting: order atMost: 1];

	BOOL isValid = ([FGInt compareAbsoluteValueOf: c with: cPrime] == equal);

	[t1 release];
	[t2 release];
	[t3 release];
	[c release];
	[salpha release];
	[sbeta release];
	[sx release];
	[sdelta1 release];
	[sdelta2 release];
	[order release];
	[r1 release];
	[r2 release];
	[r4 release];
	[r5 release];
	[r3 release];
	[invertedP release];
	[cPrime release];
	[pFGInt release];

	return isValid;
}


+(NSData *) openSignature: (NSData *) signature withPrivateKey: (BBSPrivateKey *) privateKey {
	if ([signature length] != 12*cnstLength) {
		return nil;
	}

	unsigned char *signatureBytes = (unsigned char *) [signature bytes];
	NSData *tmpData = [[NSData alloc] initWithBytes: signatureBytes length: 2*cnstLength];
	G1Point *t1 = [[G1Point alloc] unMarshal: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[2*cnstLength] length: 2*cnstLength];
	G1Point *t2 = [[G1Point alloc] unMarshal: tmpData];
	[tmpData release];
	tmpData = [[NSData alloc] initWithBytes: &signatureBytes[4*cnstLength] length: 2*cnstLength];
	G1Point *t3 = [[G1Point alloc] unMarshal: tmpData];
	[tmpData release];

	G1Point *tmp0G1 = [G1Point add: t1 kTimes: [privateKey xi1]];
	G1Point *tmp1G1 = [G1Point add: t2 kTimes: [privateKey xi2]];
	G1Point *tmp2G1 = [G1Point add: tmp0G1 and: tmp1G1];
	[tmp0G1 release];
	[tmp1G1 release];
	[tmp2G1 changeSign];
	tmp0G1 = [G1Point add: t3 and: tmp2G1];
	[tmp2G1 release];

	tmpData = [tmp0G1 marshal];
	[tmp0G1 release];

	[t1 release];
	[t2 release];
	[t3 release];

	return tmpData;
}

+(void) testBBSsig {
	NSDate *date1;
	double timePassed_ms1;
	date1 = [NSDate date];
	BBSPrivateKey *privateKey = [[BBSPrivateKey alloc] generateGroup];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	if (privateKey == nil) {
	    NSLog(@"Group generation failed");
	} else {
	    NSLog(@"Group generation: success, and took %fms", timePassed_ms1);
	}

	date1 = [NSDate date];
	BBSMemberKey *memberKey = [[BBSMemberKey alloc] initNewMemberWithGroupPrivateKey: privateKey];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	if (memberKey == nil) {
	    NSLog(@"Member key generation                                                        failed");
	} else {
	    NSLog(@"Member key generation: success, and took %fms", timePassed_ms1);
	}

	BBSGroup *group = [[privateKey group] mutableCopy];
	group = [[BBSGroup alloc] unMarshal: [group marshal]];
	privateKey = [[BBSPrivateKey alloc] unMarshal: [privateKey marshal]];
	[privateKey setGroup: group];

	NSData *digest = [FGIntXtra SHA256: [[[NSString alloc] initWithString:@"hello world"] dataUsingEncoding: NSASCIIStringEncoding]];
	date1 = [NSDate date];
	NSData *signature = [BBSsig sign: digest withMemberKey: memberKey];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	if (signature == nil) {
	    NSLog(@"Signature generation                                                        failed");
	} else {
	    NSLog(@"Signature generation: success, and took %fms", timePassed_ms1);
	}
	date1 = [NSDate date];
	NSData *openSignature = [BBSsig openSignature: signature withPrivateKey: privateKey];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	if ([openSignature isEqualToData: [[memberKey a] marshal]]) {
	    NSLog(@"Signature open success, and took %fms", timePassed_ms1);
	} else {
	    NSLog(@"Signature open                                                        failed, and took %fms", timePassed_ms1);
	}

	date1 = [NSDate date];
	BOOL validation = [BBSsig verifySignature: signature ofDigest: digest withGroupKey: [memberKey group]];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"Signature verification: %@, and took %fms", validation?@"success":@"                                                       failed", timePassed_ms1);
	// date1 = [NSDate date];
	// validation = [BBSsig verifySignature: signature ofDigest: digest withGroupKey: [privateKey group]];
	// timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	// NSLog(@"Signature verification: %@, and took %fms", validation?@"success":@"                                                       failed", timePassed_ms1);
// 	NSLog(@"\n");
// return;
	digest = [FGIntXtra SHA256: [[[NSString alloc] initWithString:@"hello worldsies"] dataUsingEncoding: NSASCIIStringEncoding]];
	NSLog(@"Signature verification: %@ (should fail)", [BBSsig verifySignature: signature ofDigest: digest withGroupKey: [privateKey group]]?@"                                                       success":@"failed");


	digest = [FGIntXtra SHA256: [[[NSString alloc] initWithString:@"hello world"] dataUsingEncoding: NSASCIIStringEncoding]];
	date1 = [NSDate date];
	BBSMemberKey *memberKey2 = [[BBSMemberKey alloc] initNewMemberWithGroupPrivateKey: privateKey];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	if (memberKey2 == nil) {
	    NSLog(@"Member key 2 generation                                                        failed");
	} else {
	    NSLog(@"Member key 2 generation: success, and took %fms", timePassed_ms1);
	}
	memberKey2 = [[BBSMemberKey alloc] unMarshal: [memberKey2 marshal]];
	[memberKey2 setGroup: [group mutableCopy]];

	date1 = [NSDate date];
	BBSRevocation *revocation = [privateKey generateRevocationForMember: memberKey];
	[[privateKey group] updateWithRevocation: [[BBSRevocation alloc] unMarshal: [revocation marshal]]];
	// [[privateKey group] updateWithRevocation: revocation];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"Revocation generation and updating took %fms", timePassed_ms1);

	date1 = [NSDate date];
	validation = [BBSsig verifySignature: signature ofDigest: digest withGroupKey: [privateKey group]];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"Signature verification after revocation: %@, and took %fms (should fail)", validation?@"                                                       success":@"failed", timePassed_ms1);

	date1 = [NSDate date];
	signature = [BBSsig sign: digest withMemberKey: memberKey2];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	if (signature == nil) {
	    NSLog(@"Signature generation (before processing revocation)                                                        failed");
	} else {
	    NSLog(@"Signature generation (before processing revocation): success, and took %fms", timePassed_ms1);
	}
	date1 = [NSDate date];
	validation = [BBSsig verifySignature: signature ofDigest: digest withGroupKey: [privateKey group]];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"Signature verification (before processing revocation): %@, and took %fms (should fail)", validation?@"                                                       success":@"failed", timePassed_ms1);

	validation = [memberKey2 updateWithRevocation: revocation];
	NSLog(@"Updating revocation %@",validation?@"success":@"                                                              failed");

	date1 = [NSDate date];
	signature = [BBSsig sign: digest withMemberKey: memberKey2];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	if (signature == nil) {
	    NSLog(@"Signature generation (after processing revocation)                                                        failed");
	} else {
	    NSLog(@"Signature generation (after processing revocation): success, and took %fms", timePassed_ms1);
	}
	date1 = [NSDate date];
	validation = [BBSsig verifySignature: signature ofDigest: digest withGroupKey: [memberKey2 group]];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"Signature verification (after revocation): %@, and took %fms", validation?@"success":@"                                                       failed", timePassed_ms1);
	validation = [memberKey updateWithRevocation: revocation];

	NSLog(@"Updating revocation of the revoked key %@ (should fail) \n\n",validation?@"                                                       success":@"failed");


	[group release];
	[memberKey release];
	[privateKey release];
	[memberKey2 release];
	[digest release];
	[signature release];
}



@end




















