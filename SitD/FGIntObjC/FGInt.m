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

#import "FGInt.h"
/* ToDo
   - divide and conquer division too?
*/


static const FGIntBase primes[1228] =
    {3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127,
    131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251,
    257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389,
    397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541,
    547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677,
    683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839,
    853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997, 1009,
    1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123,
    1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279,
    1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429,
    1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553,
    1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607, 1609, 1613, 1619, 1621, 1627, 1637, 1657, 1663, 1667, 1669, 1693,
    1697, 1699, 1709, 1721, 1723, 1733, 1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811, 1823, 1831, 1847,
    1861, 1867, 1871, 1873, 1877, 1879, 1889, 1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987, 1993, 1997,
    1999, 2003, 2011, 2017, 2027, 2029, 2039, 2053, 2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2129, 2131,
    2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213, 2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287,
    2293, 2297, 2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357, 2371, 2377, 2381, 2383, 2389, 2393, 2399, 2411, 2417,
    2423, 2437, 2441, 2447, 2459, 2467, 2473, 2477, 2503, 2521, 2531, 2539, 2543, 2549, 2551, 2557, 2579, 2591, 2593,
    2609, 2617, 2621, 2633, 2647, 2657, 2659, 2663, 2671, 2677, 2683, 2687, 2689, 2693, 2699, 2707, 2711, 2713, 2719,
    2729, 2731, 2741, 2749, 2753, 2767, 2777, 2789, 2791, 2797, 2801, 2803, 2819, 2833, 2837, 2843, 2851, 2857, 2861,
    2879, 2887, 2897, 2903, 2909, 2917, 2927, 2939, 2953, 2957, 2963, 2969, 2971, 2999, 3001, 3011, 3019, 3023, 3037,
    3041, 3049, 3061, 3067, 3079, 3083, 3089, 3109, 3119, 3121, 3137, 3163, 3167, 3169, 3181, 3187, 3191, 3203, 3209,
    3217, 3221, 3229, 3251, 3253, 3257, 3259, 3271, 3299, 3301, 3307, 3313, 3319, 3323, 3329, 3331, 3343, 3347, 3359,
    3361, 3371, 3373, 3389, 3391, 3407, 3413, 3433, 3449, 3457, 3461, 3463, 3467, 3469, 3491, 3499, 3511, 3517, 3527,
    3529, 3533, 3539, 3541, 3547, 3557, 3559, 3571, 3581, 3583, 3593, 3607, 3613, 3617, 3623, 3631, 3637, 3643, 3659,
    3671, 3673, 3677, 3691, 3697, 3701, 3709, 3719, 3727, 3733, 3739, 3761, 3767, 3769, 3779, 3793, 3797, 3803, 3821,
    3823, 3833, 3847, 3851, 3853, 3863, 3877, 3881, 3889, 3907, 3911, 3917, 3919, 3923, 3929, 3931, 3943, 3947, 3967,
    3989, 4001, 4003, 4007, 4013, 4019, 4021, 4027, 4049, 4051, 4057, 4073, 4079, 4091, 4093, 4099, 4111, 4127, 4129,
    4133, 4139, 4153, 4157, 4159, 4177, 4201, 4211, 4217, 4219, 4229, 4231, 4241, 4243, 4253, 4259, 4261, 4271, 4273,
    4283, 4289, 4297, 4327, 4337, 4339, 4349, 4357, 4363, 4373, 4391, 4397, 4409, 4421, 4423, 4441, 4447, 4451, 4457,
    4463, 4481, 4483, 4493, 4507, 4513, 4517, 4519, 4523, 4547, 4549, 4561, 4567, 4583, 4591, 4597, 4603, 4621, 4637,
    4639, 4643, 4649, 4651, 4657, 4663, 4673, 4679, 4691, 4703, 4721, 4723, 4729, 4733, 4751, 4759, 4783, 4787, 4789,
    4793, 4799, 4801, 4813, 4817, 4831, 4861, 4871, 4877, 4889, 4903, 4909, 4919, 4931, 4933, 4937, 4943, 4951, 4957,
    4967, 4969, 4973, 4987, 4993, 4999, 5003, 5009, 5011, 5021, 5023, 5039, 5051, 5059, 5077, 5081, 5087, 5099, 5101,
    5107, 5113, 5119, 5147, 5153, 5167, 5171, 5179, 5189, 5197, 5209, 5227, 5231, 5233, 5237, 5261, 5273, 5279, 5281,
    5297, 5303, 5309, 5323, 5333, 5347, 5351, 5381, 5387, 5393, 5399, 5407, 5413, 5417, 5419, 5431, 5437, 5441, 5443,
    5449, 5471, 5477, 5479, 5483, 5501, 5503, 5507, 5519, 5521, 5527, 5531, 5557, 5563, 5569, 5573, 5581, 5591, 5623,
    5639, 5641, 5647, 5651, 5653, 5657, 5659, 5669, 5683, 5689, 5693, 5701, 5711, 5717, 5737, 5741, 5743, 5749, 5779,
    5783, 5791, 5801, 5807, 5813, 5821, 5827, 5839, 5843, 5849, 5851, 5857, 5861, 5867, 5869, 5879, 5881, 5897, 5903,
    5923, 5927, 5939, 5953, 5981, 5987, 6007, 6011, 6029, 6037, 6043, 6047, 6053, 6067, 6073, 6079, 6089, 6091, 6101,
    6113, 6121, 6131, 6133, 6143, 6151, 6163, 6173, 6197, 6199, 6203, 6211, 6217, 6221, 6229, 6247, 6257, 6263, 6269,
    6271, 6277, 6287, 6299, 6301, 6311, 6317, 6323, 6329, 6337, 6343, 6353, 6359, 6361, 6367, 6373, 6379, 6389, 6397,
    6421, 6427, 6449, 6451, 6469, 6473, 6481, 6491, 6521, 6529, 6547, 6551, 6553, 6563, 6569, 6571, 6577, 6581, 6599,
    6607, 6619, 6637, 6653, 6659, 6661, 6673, 6679, 6689, 6691, 6701, 6703, 6709, 6719, 6733, 6737, 6761, 6763, 6779,
    6781, 6791, 6793, 6803, 6823, 6827, 6829, 6833, 6841, 6857, 6863, 6869, 6871, 6883, 6899, 6907, 6911, 6917, 6947,
    6949, 6959, 6961, 6967, 6971, 6977, 6983, 6991, 6997, 7001, 7013, 7019, 7027, 7039, 7043, 7057, 7069, 7079, 7103,
    7109, 7121, 7127, 7129, 7151, 7159, 7177, 7187, 7193, 7207, 7211, 7213, 7219, 7229, 7237, 7243, 7247, 7253, 7283,
    7297, 7307, 7309, 7321, 7331, 7333, 7349, 7351, 7369, 7393, 7411, 7417, 7433, 7451, 7457, 7459, 7477, 7481, 7487,
    7489, 7499, 7507, 7517, 7523, 7529, 7537, 7541, 7547, 7549, 7559, 7561, 7573, 7577, 7583, 7589, 7591, 7603, 7607,
    7621, 7639, 7643, 7649, 7669, 7673, 7681, 7687, 7691, 7699, 7703, 7717, 7723, 7727, 7741, 7753, 7757, 7759, 7789,
    7793, 7817, 7823, 7829, 7841, 7853, 7867, 7873, 7877, 7879, 7883, 7901, 7907, 7919, 7927, 7933, 7937, 7949, 7951,
    7963, 7993, 8009, 8011, 8017, 8039, 8053, 8059, 8069, 8081, 8087, 8089, 8093, 8101, 8111, 8117, 8123, 8147, 8161,
    8167, 8171, 8179, 8191, 8209, 8219, 8221, 8231, 8233, 8237, 8243, 8263, 8269, 8273, 8287, 8291, 8293, 8297, 8311,
    8317, 8329, 8353, 8363, 8369, 8377, 8387, 8389, 8419, 8423, 8429, 8431, 8443, 8447, 8461, 8467, 8501, 8513, 8521,
    8527, 8537, 8539, 8543, 8563, 8573, 8581, 8597, 8599, 8609, 8623, 8627, 8629, 8641, 8647, 8663, 8669, 8677, 8681,
    8689, 8693, 8699, 8707, 8713, 8719, 8731, 8737, 8741, 8747, 8753, 8761, 8779, 8783, 8803, 8807, 8819, 8821, 8831,
    8837, 8839, 8849, 8861, 8863, 8867, 8887, 8893, 8923, 8929, 8933, 8941, 8951, 8963, 8969, 8971, 8999, 9001, 9007,
    9011, 9013, 9029, 9041, 9043, 9049, 9059, 9067, 9091, 9103, 9109, 9127, 9133, 9137, 9151, 9157, 9161, 9173, 9181,
    9187, 9199, 9203, 9209, 9221, 9227, 9239, 9241, 9257, 9277, 9281, 9283, 9293, 9311, 9319, 9323, 9337, 9341, 9343,
    9349, 9371, 9377, 9391, 9397, 9403, 9413, 9419, 9421, 9431, 9433, 9437, 9439, 9461, 9463, 9467, 9473, 9479, 9491,
    9497, 9511, 9521, 9533, 9539, 9547, 9551, 9587, 9601, 9613, 9619, 9623, 9629, 9631, 9643, 9649, 9661, 9677, 9679,
    9689, 9697, 9719, 9721, 9733, 9739, 9743, 9749, 9767, 9769, 9781, 9787, 9791, 9803, 9811, 9817, 9829, 9833, 9839,
    9851, 9857, 9859, 9871, 9883, 9887, 9901, 9907, 9923, 9929, 9931, 9941, 9949, 9967, 9973};
unichar pgpBase64[65] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
      'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
      'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/', '='};





@implementation FGInt
@synthesize sign;

-(id) init {
    if (self = [super init]) {
        number = [[NSMutableData alloc] init];
        sign = YES;
    }
    return self;
}

-(id) initWithCapacity: (FGIntOverflow) capacity {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithLength: capacity * 4];
    }
    return self;
}

-(id) initWithNumber: (NSMutableData *) initNumber {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithData: initNumber];
        sign = YES;
    }
    return self;
}

-(id) initWithoutNumber {
    if (self = [super init]) {
        number = nil;
        sign = YES;
    }
    return self;
}

-(id) initWithRandomNumberOfBitSize: (FGIntOverflow) bitSize {
    FGIntOverflow byteLength = (bitSize + 7) / 8, length;
    NSMutableData *tmpData = [[NSMutableData alloc] initWithLength: byteLength];
    int result = SecRandomCopyBytes(kSecRandomDefault, byteLength, tmpData.mutableBytes);
    if (result != 0) {
        [tmpData release];
        return nil;
    }
    FGInt *randomFGInt = [[FGInt alloc] initWithNSData: tmpData];
    [tmpData release];
    FGIntBase* numberArray = [[randomFGInt number] mutableBytes];
    FGIntBase j = (bitSize % 32), firstNumberBase, firstBit;
    firstBit = (1u << 31) >> ((32 - j) % 32);
    firstNumberBase = 4294967295u >> ((32 - j) % 32);
    length = [[randomFGInt number] length]/4;
    j = numberArray[length - 1];
    j = j & firstNumberBase;
    j = j | firstBit;
    numberArray[length - 1] = j;

    return randomFGInt;
}

-(id) initWithRandomNumberAtMost: (FGInt *) atMost {
    if (self = [super init]) {
        FGInt *randomFGInt = nil;
        int i = 10;

        do {
            if (randomFGInt) {
                [randomFGInt release];
            }
            randomFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: [atMost bitSize]];

            [randomFGInt reduceBySubtracting: atMost atMost: 1];

            --i;
        } while ((i > 0) && ([randomFGInt isZero]));

        number = [[randomFGInt number] retain];

        sign = YES;

        [randomFGInt release];
    }
    return self;
}


-(FGInt *) initWithCurve25519SecretKey {
    if (self = [super init]) {
        FGInt *secretKeyFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: 252];
        [secretKeyFGInt shiftLeftBy: 3];

        number = [[secretKeyFGInt number] mutableCopy];

        sign = YES;

        [secretKeyFGInt release];
    }
    return self;
}


-(FGInt *) initWithNZeroes: (FGIntOverflow) n {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithLength: n * 4];
        sign = YES;
    }
    return self;
}

-(FGInt *) initAsP25519 {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithLength: 32];
        sign = YES;
        FGIntBase* numberArray = [number mutableBytes];
        numberArray[7] = 2147483647u;
        for ( int i = 1; i < 7; ++i ) {
            numberArray[i] = 4294967295u;
        }
        numberArray[0] = 4294967295u - 18;
    }
    return self;
}


-(FGInt *) initAsZero {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithLength: 4];
        sign = YES;
    }
    return self;
}
-(FGInt *) initAsOne {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithLength: 4];
        sign = YES;
        FGIntBase* numberArray = [number mutableBytes];
        numberArray[0] = 1u;
    }
    return self;
}


-(NSMutableData *) number {
    return number;
}

-(void) setNumber: (NSMutableData *) inputNumber {
    number = inputNumber;
}



-(void) dealloc {
    [number release];
    [super dealloc];
}

-(void) eraseAndRelease {
//    int result = SecRandomCopyBytes(kSecRandomDefault, [number length], [number mutableBytes]);
    SecRandomCopyBytes(kSecRandomDefault, [number length], [number mutableBytes]);
    [number release];
    [super dealloc];
}



-(id) mutableCopyWithZone: (NSZone *) zone {
    FGInt *newFGInt = [[FGInt allocWithZone: zone] initWithoutNumber];

    [newFGInt setSign: sign];
    [newFGInt setNumber: [number mutableCopy]];

    return newFGInt;
}



-(void) verifyAdjust {
    if (([number length] % 4) != 0) {
        [number setLength: 4*([number length]/4) + 4];
    }
}

+(void) verifyAdjustNumber: (NSMutableData *) numberData {
    if (([numberData length] % 4) != 0) {
        [numberData setLength: 4*([numberData length]/4) + 4];
    }
}

/* divides the number by a 32 bit unsigned int (divInt) and returns the remainder, it alters fGIntNumber */

+(FGIntBase) divideFGIntNumberByIntBis: (NSMutableData *) fGIntNumber divideBy: (FGIntBase) divInt {
    FGIntBase mod = 0;
    FGIntOverflow tempMod = 0;
    
    [FGInt verifyAdjustNumber: fGIntNumber];

    FGIntBase* fGIntNumberArray = [fGIntNumber mutableBytes];
    FGIntOverflow length = [fGIntNumber length] / 4;

    for( FGIntIndex i = length - 1; i >= 0; i-- ) {
        tempMod =  (((FGIntOverflow) mod << 32) | (FGIntOverflow) fGIntNumberArray[i]);
        fGIntNumberArray[i] = (FGIntBase) (tempMod / divInt);
        mod = (FGIntOverflow) tempMod % divInt;
    }

    while ((length > 1) && (fGIntNumberArray[length - 1] == 0)) {
        length--;
    }
    if (length*4 < [fGIntNumber length]) {
        [fGIntNumber setLength: length*4];
    }
    return mod;
}


/* returns a deep copy of the number */

-(NSMutableData *) duplicateNumber {
    return [[NSMutableData alloc] initWithData: number];
}



/* returns a decimal (base 10) string of the FGInt */

-(NSString *) toBase10String {
    @autoreleasepool{
        NSMutableData *tempNumber = [self duplicateNumber], *zeroNumber = [[NSMutableData alloc] initWithLength: 4];
        NSMutableString *tempString = [[NSMutableString alloc] init], *tmpStr;
        NSString *zeroStr = @"0";

        while (![tempNumber isEqualToData: zeroNumber]) {
            tmpStr = (NSMutableString *) [NSString stringWithFormat:@"%u", [FGInt divideFGIntNumberByIntBis: tempNumber divideBy: 1000000000]];
            [tempString insertString: tmpStr atIndex:0];
            while (([tempString length] % 9) != 0) {
                [tempString insertString: zeroStr atIndex:0];
            }
        }
        [tempString insertString: zeroStr atIndex:0];
        while (([tempString characterAtIndex: 0] == '0') && ([tempString length] > 1))
            [tempString deleteCharactersInRange: NSMakeRange(0, 1)];
        if (!sign) [tempString insertString: @"-" atIndex:0];
        
        [tempNumber release];
        return tempString;
    }
}



-(FGIntBase) divideByFGIntBaseMaxBis: (NSMutableData *) base10Number {
    @autoreleasepool{
        FGIntBase mod = 0;
        FGIntOverflow tempMod = 0;
        NSMutableString *base10StringResult = [[NSMutableString alloc] init], *tmpString;
        NSString *zeroStr = @"0", *tmpStr;
    
        [FGInt verifyAdjustNumber: base10Number];

        FGIntBase* fGIntNumberArray = [base10Number mutableBytes];
        FGIntOverflow length = [base10Number length] / 4;

        for( FGIntIndex i = length - 1; i >= 0; i-- ) {
            tempMod =  (FGIntOverflow) mod*1000000000 + (FGIntOverflow) fGIntNumberArray[i];
            tmpString = [NSMutableString stringWithFormat:@"%u", (FGIntBase) (tempMod >> 32)];
            while (([tmpString length] % 9) != 0) {
                [tmpString insertString: zeroStr atIndex:0];
            }
            [base10StringResult appendString: tmpString];
            mod = (FGIntBase) tempMod;
        }

        while (([base10StringResult length] > 1) && ([base10StringResult characterAtIndex: 0] == '0')) {
            [base10StringResult deleteCharactersInRange: NSMakeRange(0, 1)];
        }

        FGIntOverflow nlength = [base10StringResult length];
        [base10Number setLength: 0];
        
        for( FGIntOverflow i = 1; i <= (nlength/9); ++i ) {
            tmpStr = [base10StringResult substringWithRange: NSMakeRange(nlength - i*9, 9)];
            FGIntBase tmpBase = (FGIntBase) [tmpStr longLongValue];
            [base10Number appendData: [NSData dataWithBytes: &tmpBase length: sizeof(tmpBase)]];
        }
        if ((nlength % 9) != 0) {
            tmpStr = [base10StringResult substringWithRange: NSMakeRange(0, nlength % 9)];
            FGIntBase tmpBase = (FGIntBase) [tmpStr longLongValue];
            [base10Number appendData: [NSData dataWithBytes: &tmpBase length: sizeof(tmpBase)]];
        }
    
        [base10StringResult release];
        [zeroStr release];
            
        return mod;
    }
}


/* provide a decimal (base 10) NSString to initialize the FGInt, possibly preceded by a minus sign (a dash "-") */

-(FGInt *) initWithBase10String: (NSString *) base10String {
    @autoreleasepool{

        self = [super init];
    
        FGIntOverflow nlength = [base10String length];
        FGIntBase tmpBase;
    
        if ([base10String characterAtIndex: 0] == '-') {
            sign = NO;
            --nlength;
        } else {
            sign = YES;
        }
//        FGIntBase lengthInt = 1 + nlength / 9 + (((nlength % 9)==0) ? 0 : 1);
    
        NSMutableData *base10Number = [[NSMutableData alloc] init];
        NSString *tmpStr;
    
        for(FGIntBase i = 1; i <= (nlength/9); ++i) {
            tmpStr = [base10String substringWithRange: NSMakeRange(nlength + (sign ? 0 : 1) - i*9, 9)];
            tmpBase = (FGIntBase) [tmpStr longLongValue];
            [base10Number appendData: [NSData dataWithBytes: &tmpBase length: sizeof(tmpBase)]];
        }
        if ((nlength % 9) != 0) {
            tmpStr = [base10String substringWithRange: NSMakeRange(sign ? 0 : 1, nlength % 9)];
            tmpBase = (FGIntBase) [tmpStr longLongValue];
            [base10Number appendData: [NSData dataWithBytes: &tmpBase length: sizeof(tmpBase)]];
        }

        NSMutableData *zeroNumber = [[NSMutableData alloc] initWithLength: 4];

        number = [[NSMutableData alloc] init];
        while (![base10Number isEqualToData: zeroNumber]) {
            tmpBase = [self divideByFGIntBaseMaxBis: base10Number];
            [number appendData: [NSData dataWithBytes: &tmpBase length: sizeof(tmpBase)]];
        }
        // while (([number count] > 1) && ([[number lastObject] digit] == 0)) {
        //     [number removeLastObject];
        // }
        if ([number length] == 0) {
            tmpBase = 0;
            tmpBase = [self divideByFGIntBaseMaxBis: base10Number];
            [number appendData: [NSData dataWithBytes: &tmpBase length: sizeof(tmpBase)]];
        }
        
        [base10Number release];

        return self;
    }
}


/* provide an unsigned 32bit integer to initialize the FGInt */

-(FGInt *) initWithFGIntBase: (FGIntBase) fGIntBase {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithBytes: &fGIntBase length: 4];
        sign = YES;
    }
        
    return self;
}


-(FGInt *) initWithNegativeFGIntBase: (FGIntBase) fGIntBase {
    FGInt *nFGInt = [self initWithFGIntBase: fGIntBase];
    [nFGInt setSign: NO];
        
    return nFGInt;
}



/* provide a NSString to initialize the FGInt */

-(FGInt *) initWithNSString: (NSString *) string {
    @autoreleasepool{
        self = [super init];

        NSData *stringBytes = [string dataUsingEncoding:NSUTF8StringEncoding];

        return [self initWithNSData: stringBytes];
    }
}


/* provide NSData to initialize the FGInt */

-(FGInt *) initWithNSData: (NSData *) nsData {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithData: nsData];
        if ([number length] == 0) {
            [number setLength: 4];
        }
        if (([number length] % 4) != 0) {
            [number setLength: 4 * (([number length] + 3) / 4)];
        }
        FGIntOverflow length = [number length]/4;
        FGIntBase* numberArray = [number mutableBytes];
        while ((length > 1) && (numberArray[length - 1] == 0)) {
            --length;
        }
        if (length*4 < [number length]) {
            [number setLength: length*4];
        }
        sign = YES;
    }

    return self;
}

-(FGInt *) initWithMPINSData: (NSData *) mpiNSData {
    FGIntOverflow byteLength = [mpiNSData length];
    if (byteLength < 3) {
        return nil;
    }
    byteLength -= 2;

    unsigned char mpiLength[2];
    [mpiNSData getBytes: mpiLength range: NSMakeRange(0, 2)];
    FGIntBase length = (((((FGIntBase) mpiLength[0]) << 8) + mpiLength[1]) + 7) / 8;
    if (length != byteLength) {
        NSLog(@"Badly formatted MPI");
        return nil;
    }

    NSMutableData *inputData = [[NSMutableData alloc] init];
    const unsigned char* mpiBytes = [mpiNSData bytes];
    for ( FGIntIndex i = 0; i < byteLength; i++ ) {
        [inputData appendBytes: &mpiBytes[byteLength + 1 - i] length: 1];
    }
    // [FGInt verifyAdjustNumber: inputData];
    FGInt *mpiFGInt = [[FGInt alloc] initWithNumber: inputData];
    [mpiFGInt verifyAdjust];

    return mpiFGInt;
}


-(FGInt *) initWithNSDataToEd25519FGInt: (NSData *) nsData {
    if (self = [super init]) {
        number = [[NSMutableData alloc] initWithData: nsData];
        [number setLength: 32];
        unsigned char* numberArray = [number mutableBytes];
        numberArray[31] = numberArray[31] | 64;
        numberArray[31] = numberArray[31] & 127;
        numberArray[0] = numberArray[0] & 248;
        sign = YES;
    }
    return self;
}




/* returns NSData of self */

-(NSData *) toNSData {
    return [number mutableCopy];
}


-(NSData *) toMPINSData {
    NSMutableData *mpiData = [[NSMutableData alloc] init];
    FGIntOverflow bitLength = [self bitSize], byteLength = [self byteSize]; 
    unsigned char aBuffer[2];
    aBuffer[0] = (bitLength / 256) & 255;
    aBuffer[1] = (bitLength) & 255;
    [mpiData appendBytes: aBuffer length: 2];
    unsigned char* numberBytes = [number mutableBytes];
    for ( FGIntIndex i = 0; i < byteLength; i++ ) {
        [mpiData appendBytes: &numberBytes[byteLength - 1 - i] length: 1];
    }

    return mpiData;
}


-(FGInt *) initWithBigEndianNSData: (NSData *) bigEndianNSData {
    if (self = [super init]) {
        FGIntOverflow byteLength = [bigEndianNSData length];
        number = [[NSMutableData alloc] init];
        unsigned char* bigEndianBytes = (unsigned char*) [bigEndianNSData bytes];
        for ( FGIntIndex i = 0; i < byteLength; i++ ) {
            [number appendBytes: &bigEndianBytes[byteLength - 1 - i] length: 1];
        }
        if ([number length] == 0) {
            [number setLength: 4];
        }
        if (([number length] % 4) != 0) {
            [number increaseLengthBy: 4 - ([number length] % 4)];
        }
        FGIntOverflow length = [number length]/4;
        FGIntBase* numberArray = [number mutableBytes];
        while ((length > 1) && (numberArray[length - 1] == 0)) {
            --length;
        }
        if (length*4 < [number length]) {
            [number setLength: length*4];
        }
        sign = YES;
    }

    return self;
}

-(NSData *) toBigEndianNSData {
    NSMutableData *bigEndianNSData = [[NSMutableData alloc] init];
    FGIntOverflow byteLength = [self byteSize]; 
    unsigned char* numberBytes = [number mutableBytes];
    for ( FGIntIndex i = 0; i < byteLength; i++ ) {
        [bigEndianNSData appendBytes: &numberBytes[byteLength - 1 - i] length: 1];
    }

    return bigEndianNSData;
}


-(NSData *) toBigEndianNSDataOfLength: (FGIntOverflow) length {
    FGIntOverflow byteLength = [self byteSize];
    if (byteLength > length) {
        return nil;
    }
    NSMutableData *bigEndianNSData = [[NSMutableData alloc] initWithLength: length - byteLength];
    unsigned char* numberBytes = [number mutableBytes];
    for ( FGIntIndex i = 0; i < byteLength; i++ ) {
        [bigEndianNSData appendBytes: &numberBytes[byteLength - 1 - i] length: 1];
    }

    return bigEndianNSData;
}


/* convert self to an NSString, this does assume the self was previously a UTF8String, a random FGInt will not be */

-(NSString *) toNSString {
    NSData *tmpData = [self toNSData];
    NSString *str = [[NSString alloc] initWithData: tmpData encoding: NSUTF8StringEncoding];
    [tmpData release];
    return str;
}



/* Compare 2 FGInts in absolute value, returns
   larger if fGInt1 > fGInt2, smaller if fGInt1 < fGInt2, equal if fGInt1 = fGInt2,
   error otherwise */

+(tCompare) compareAbsoluteValueOf: (FGInt *) fGInt1 with: (FGInt *) fGInt2 {
    FGIntOverflow size1 = [[fGInt1 number] length]/4, size2 = [[fGInt2 number] length]/4;
    FGIntIndex i;

    FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];

    while ((fGInt1Number[size1 - 1] == 0) && (size1 > 0)) {
        --size1;
    }
    while ((fGInt2Number[size2 - 1] == 0) && (size2 > 0)) {
        --size2;
    }

    if (size1 > size2) {
        return larger;
    }
    if (size1 < size2) {
        return smaller;
    }

    i = size1 - 1;
    while ((i >= 0) && (fGInt1Number[i] == fGInt2Number[i])) {
        --i;
    }
    if (i < 0) {
        return equal;
    }
    // if (fGInt1Number[i] == fGInt2Number[i]) {
    //     return equal;
    // }
    if (fGInt1Number[i] < fGInt2Number[i]) {
        return smaller;
    }
    if (fGInt1Number[i] > fGInt2Number[i]) {
        return larger;
    }
    return error;
}


-(BOOL) isZero {
    FGIntBase* numberArray = [number mutableBytes];
    FGIntIndex i = [number length]/4 - 1;
    while ((i >= 0) && (numberArray[i] == 0)) {
        --i;
    }
    if (i < 0) {
        return YES;
    } else {
        return NO;
    }
}
-(BOOL) isOne {
    if ([number length] > 4) {
        FGIntBase* numberArray = [number mutableBytes];
        FGIntIndex i = [number length]/4 - 1;
        while ((i >= 0) && (numberArray[i] == 0)) {
            --i;
        }
        if ((i == 0) && (numberArray[0] == 1)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        FGIntBase* numberArray = [number mutableBytes];
        if (numberArray[0] == 1) {
            return YES;
        } else {
            return NO;
        }
    } 
}
-(BOOL) isEven {
    if ([number length] > 0) {
        unsigned char *bytes = [number mutableBytes];
        if (bytes[0] % 2 == 0) {
            return YES;
        }
    }
    return NO;
}

// /* add fGInt1 with fGInt2 and return a FGInt */


+(FGInt *) add: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [[fGInt1 number] length] / 4, length2 = [[fGInt2 number] length] / 4, sumLength;

    if (length1 < length2) {
        return [FGInt add: fGInt2 and: fGInt1];
    }

    if ([fGInt1 sign] == [fGInt2 sign]) {
        FGInt *sum = [fGInt1 mutableCopy];
        FGIntBase* sumNumber = [[sum number] mutableBytes];
        FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];
        // FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
        FGIntOverflow tmpMod, mod = 0;

        for ( FGIntIndex i = 0; i < length2; i++ ) {
            tmpMod = (FGIntOverflow) sumNumber[i] + fGInt2Number[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( FGIntIndex i = length2; i < length1; ++i ) {
            if (!mod) {
                break;
            }
            tmpMod = (FGIntOverflow) sumNumber[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        if (mod) {
            [[sum number] setLength: 4*(length1 + 1)];
            sumNumber = [[sum number] mutableBytes];
            sumNumber[length1] = (FGIntBase) mod;
        }
        [sum setSign: [fGInt1 sign]];
        return sum;
    } else {
        if ([FGInt compareAbsoluteValueOf: fGInt2 with: fGInt1] == larger) {
            return [FGInt add: fGInt2 and: fGInt1];
        }
        FGIntIndex tmpMod, mod = 0;
        FGInt *sum = [fGInt1 mutableCopy];
        FGIntBase* sumNumber = [[sum number] mutableBytes];
        FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];

        for ( FGIntIndex i = 0; i < length2; i++ ) {
            tmpMod = (FGIntIndex) sumNumber[i] - fGInt2Number[i] + mod;
            sumNumber[i] =  (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( FGIntIndex i = length2; i < length1; ++i ) {
            if (!mod) {
                break;
            }
            tmpMod = (FGIntOverflow) sumNumber[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }

        sumLength = length1;
        while ((sumLength > 1) && (sumNumber[sumLength - 1] == 0)) {
            sumLength -= 1;
        }
        if ((sumLength == 1) && (sumNumber[0] == 0)) {
            [sum setSign: YES];
        } else {
            [sum setSign: [fGInt1 sign]];
        }
        if (sumLength < length1) {
            [[sum number] setLength: sumLength*4];
        }

        return sum;
    }
}





-(void) changeSign {
    [self setSign: ![self sign]];
}


/* subtract fGInt1 with fGInt2 and return a FGInt */

+(FGInt *) subtract: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGInt *result, *smallerFGInt;

    if ([FGInt compareAbsoluteValueOf: fGInt1 with: fGInt2] == larger) {
        result = [fGInt1 mutableCopy];
        smallerFGInt = fGInt2;
    } else {
        result = [fGInt2 mutableCopy];
        smallerFGInt = fGInt1;
        [result setSign: ![fGInt2 sign]];
    }

    if ([fGInt1 sign] == [fGInt2 sign]) {
        [result subtractWith: smallerFGInt];
    } else {
        [result addWith: smallerFGInt];
    }
    return result;
}


/* Multiply 2 FGInts, and return fGInt1 * fGInt2 */

+(FGInt *) pencilPaperMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [[fGInt1 number] length] / 4,
              length2 = [[fGInt2 number] length] / 4,
              productLength = length1 + length2, length;
    FGIntOverflow tempMod, mod;
    FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];

    FGInt *product = [[FGInt alloc] initWithNZeroes: productLength];
    FGIntBase* productNumber = [[product number] mutableBytes];

    FGIntIndex i, j;
    for( j = 0; j < length2; j++ ) {
        mod = 0;
        for( i = 0; i < length1; i++ ) {
            tempMod = (FGIntOverflow) fGInt1Number[i] * fGInt2Number[j] + productNumber[j + i] + mod;
            productNumber[j + i] = (FGIntBase) tempMod;
            mod = tempMod >> 32;
        }
        productNumber[j + i] = (FGIntBase) mod;
    }

    length = productLength;
    while ((productLength > 1) && (productNumber[productLength - 1] == 0)) {
        --productLength;
    }
    if ((productLength == 1) && (productNumber[0] == 0)) {
        [product setSign: YES];
    } else {
        [product setSign: ([fGInt1 sign]==[fGInt2 sign])];
    }
    if (productLength < length) {
        [[product number] setLength: productLength * 4];
    }
    return product;
}



+(FGInt *) karatsubaMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [[fGInt1 number] length]/4,
              length2 = [[fGInt2 number] length]/4,
              karatsubaLength = MAX(length1, length2);

    if (karatsubaLength <= karatsubaThreshold) return [FGInt pencilPaperMultiply: fGInt1 and: fGInt2];

    if (length1 != karatsubaLength) return [FGInt karatsubaMultiply: fGInt2 and: fGInt1];

    FGIntOverflow halfLength = (karatsubaLength / 2) + (karatsubaLength % 2);

    FGInt *f1a = [[FGInt alloc] initWithoutNumber], *f1b = [[FGInt alloc] initWithoutNumber],
    *f2a, *f2b,
    *faa, *fbb, *fab, *f1ab, *f2ab, *zero;
    FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];


    zero = [[FGInt alloc] initWithFGIntBase: 0];

    [f1b setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &fGInt1Number[0] length: halfLength*4 freeWhenDone: NO]];
    [f1a setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &fGInt1Number[halfLength] length: (length1 - halfLength)*4 freeWhenDone: NO]];
    [f1a setSign: [fGInt1 sign]];
    [f1b setSign: [fGInt1 sign]];

    f2b = [[FGInt alloc] initWithoutNumber];
    if ( length2 <= halfLength ) {
        f2a = [zero mutableCopy];
        [f2b setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &fGInt2Number[0] length: length2*4 freeWhenDone: NO]];
    } else {
        f2a = [[FGInt alloc] initWithoutNumber];
        [f2b setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &fGInt2Number[0] length: halfLength*4 freeWhenDone: NO]];
        [f2a setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &fGInt2Number[halfLength] length: (length2 - halfLength)*4 freeWhenDone: NO]];
    }
    [f2a setSign: [fGInt2 sign]];
    [f2b setSign: [fGInt2 sign]];

    if (([FGInt compareAbsoluteValueOf: f1a with: zero] != equal) && ([FGInt compareAbsoluteValueOf: f2a with: zero] != equal)) {
        faa = [FGInt karatsubaMultiply: f1a and: f2a];
    } else {
        faa = [zero mutableCopy];
        [faa setSign: [f1a sign] == [f2a sign]];
    }
    if (([FGInt compareAbsoluteValueOf: f1b with: zero] != equal) && ([FGInt compareAbsoluteValueOf: f2b with: zero] != equal)) {
        fbb = [FGInt karatsubaMultiply: f1b and: f2b];
    } else {
        fbb = [zero mutableCopy];
        [fbb setSign: [f1b sign] == [f2b sign]];
    }
    f1ab = [FGInt add: f1a and: f1b];
    f2ab = [FGInt add: f2a and: f2b];
    if (([FGInt compareAbsoluteValueOf: f1ab with: zero] != equal) && ([FGInt compareAbsoluteValueOf: f2ab with: zero] != equal)) {
        fab = [FGInt karatsubaMultiply: f1ab and: f2ab];
    } else {
        fab = [zero mutableCopy];
        [fab setSign: [f1a sign] == [f2a sign]];
    }


    [zero release];
    [f1a release];
    [f2a release];
    [f1ab release];
    [f2ab release];
    [f1b release];
    [f2b release];
    [fab subtractWith: faa];
    [fab subtractWith: fbb];
    FGInt *product = faa;
    [product shiftLeftBy32Times: halfLength*2];
    [fab shiftLeftBy32Times: halfLength];
    [product addWith: fab];
    [fab release];
    [product addWith: fbb];
    [fbb release];
    [product setSign: [fGInt1 sign] == [fGInt2 sign]];

    return product;
}


+(FGInt *) multiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [[fGInt1 number] length]/4,
              length2 = [[fGInt2 number] length]/4,
              length = MAX(length1,length2);
    if (length >= karatsubaThreshold) {
        return [FGInt karatsubaMultiply: fGInt1 and: fGInt2];
    } else {
        return [FGInt pencilPaperMultiply: fGInt1 and: fGInt2];
    }
}


/* square a FGInt, return fGInt^2 */

+(FGInt *) pencilPaperSquare: (FGInt *) fGInt {
    FGIntOverflow length1 = [[fGInt number] length]/4, tempMod, mod, overflow,
              squareLength = 2 * length1, tempInt;
    FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];

    FGInt *square = [[FGInt alloc] initWithNZeroes: squareLength];
    FGIntBase* squareNumber = [[square number] mutableBytes];

    for( FGIntIndex i = 0; i < length1; i++ ) {
        tempInt = fGIntNumber[i];
        tempMod = (FGIntOverflow) tempInt*tempInt + squareNumber[2*i];
        squareNumber[2*i] = (FGIntBase) tempMod;
        mod = (tempMod >> 32);
        for( FGIntIndex j = i + 1; j < length1; j++ ) {
            tempMod = (FGIntOverflow) tempInt * fGIntNumber[j];
            overflow = tempMod >> 63;
            tempMod = (tempMod << 1) + squareNumber[i + j] + mod;
            squareNumber[i + j] = (FGIntBase) tempMod;
            mod = (overflow << 32) | (tempMod >> 32);
        }
        if (mod != 0) {
            tempMod = (FGIntOverflow) squareNumber[i + length1] + mod;
            squareNumber[i + length1] = (FGIntBase) tempMod;
            mod = tempMod >> 32;
            if (mod != 0) {
                tempMod = (FGIntOverflow) squareNumber[i + length1 + 1] + mod;
                squareNumber[i + length1 + 1] = (FGIntBase) tempMod;
                mod = tempMod >> 32;
            }
        }
    }

    if ((squareLength > 1) && (squareNumber[squareLength - 1] == 0)) {
        --squareLength;
        [[square number] setLength: squareLength*4];
    }
    return square;
}


+(FGInt *) karatsubaSquare: (FGInt *) fGInt {
    FGIntOverflow karatsubaLength = [[fGInt number] length]/4;
    FGIntOverflow halfLength = (karatsubaLength / 2) + (karatsubaLength % 2);

    if (karatsubaLength <= karatsubaThreshold) {
        return [FGInt pencilPaperSquare: fGInt];
    }

    FGInt *fa = [[FGInt alloc] initWithoutNumber], *fb = [[FGInt alloc] initWithoutNumber],
    *faa, *fbb, *fab, *zero;
    zero = [[FGInt alloc] initWithFGIntBase: 0];
    FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];

    [fb setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &fGIntNumber[0] length: halfLength*4 freeWhenDone: NO]];
    [fa setNumber: [[NSMutableData alloc] initWithBytes: &fGIntNumber[halfLength] length: (karatsubaLength - halfLength)*4]];

    faa = [FGInt karatsubaSquare: fa];
    fbb = [FGInt karatsubaSquare: fb];

    [fa addWith: fb];
    fab = [FGInt karatsubaSquare: fa];
    
    [zero release];
    [fa release];
    [fb release];
    [fab subtractWith: faa];
    [fab subtractWith: fbb];
    FGInt *square = faa;
    [square shiftLeftBy32Times: halfLength*2];
    [fab shiftLeftBy32Times: halfLength];
    [square addWith: fab];
    [fab release];
    [square addWith: fbb];
    [fbb release];
    [square setSign: YES];

    return square;
}


+(FGInt *) square: (FGInt *) fGInt {
    FGIntOverflow length = [[fGInt number] length];

    if (length >= karatsubaThreshold) {
        return [FGInt karatsubaSquare: fGInt];
    } else {
        return [FGInt pencilPaperSquare: fGInt];
    }
}



/* raise fGInt to the power fGIntN, and return fGInt ^ fGIntN */

+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN {
    FGIntOverflow nLength = [[fGIntN number] length]/4;
    FGIntBase tmp;
    FGInt *tmpFGInt1, *tmpFGInt;
    int j;

    FGInt *power = [[FGInt alloc] initWithFGIntBase: 1];
    FGIntBase* fGIntNnumber = [[fGIntN number] mutableBytes];
    tmpFGInt1 = [fGInt mutableCopy];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmp = fGIntNnumber[i];
        for( j = 0; j < 32; ++j) {
            if (((tmp >> j) % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
                [power release];
                power = tmpFGInt;
            }
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = tmpFGInt;
        }
    }
    j = 0;
    tmp = fGIntNnumber[nLength - 1];
    while((tmp >> j)  != 0) {
        if (((tmp >> j) % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
            [power release];
            power = tmpFGInt;
        }
        ++j;
        if ((tmp >> j)  != 0) {
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = tmpFGInt;
        }
    }
    return power;
}


/* bitwise shift of self by 32 */

-(void) shiftLeftBy32 {
    if (![self isZero]) {
        NSMutableData *tmpNumber = [[NSMutableData alloc] initWithLength: 4];
        [tmpNumber appendData: number];
        [number release];
        number = tmpNumber;
    }
}

-(void) shiftRightBy32 {
    FGIntOverflow length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];
    if (length == 1) {
        numberArray[0] = 0;
        // sign = YES;
    } else {
        NSMutableData *shiftedNumber = [[NSMutableData alloc] initWithBytes: &numberArray[1] length: (length - 1)*4];
        [number release];
        number = shiftedNumber;
    }
}

-(void) shiftLeftBy32Times: (FGIntOverflow) n {
    if ((![self isZero]) && (n > 0)) {
        NSMutableData *tmpNumber = [[NSMutableData alloc] initWithLength: 4*n];
        [tmpNumber appendData: number];
        [number release];
        number = tmpNumber;
    }
}



-(void) shiftRightBy32Times: (FGIntOverflow) n {
    FGIntOverflow length = [number length]/4;
    if (n >= length) {
        [number release];
        number = [[NSMutableData alloc] initWithLength: 4];
        sign = YES;
    } else {
        FGIntBase* numberArray = [number mutableBytes];
        NSMutableData *shiftedNumber = [[NSMutableData alloc] initWithBytes: &numberArray[n] length: (length - n)*4];
        [number release];
        number = shiftedNumber;
    }
}



-(void) shiftLeft {
    FGIntOverflow tmpInt, mod = 0, length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];

    for( FGIntIndex i = 0; i < length; i++ ) {
        tmpInt = numberArray[i];
        numberArray[i] = (FGIntBase) (mod | (tmpInt << 1));
        mod = tmpInt >> 31;
    }
    if (mod != 0) {
        [number setLength: (length + 1)*4];
        numberArray = [number mutableBytes];
        numberArray[length] = (FGIntBase) mod;
    }
}


-(void) shiftRight {
    FGIntOverflow tmpInt, mod = 0, length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];

    for( FGIntIndex i = length - 1; i >= 0; i-- ) {
        tmpInt = numberArray[i];
        numberArray[i] = (FGIntBase) (mod | (tmpInt >> 1));
        mod = tmpInt << 31;
    }
    // if ((numberArray[length - 1] == 0) && (length == 1)) {
    //     sign = YES;
    // }
    if ((numberArray[length - 1] == 0) && (length > 1)) {
        [number setLength: (length - 1)*4];
    }
}


/* by can be any positive integer */

-(void) shiftRightBy: (FGIntOverflow) by {
    FGIntOverflow by32Times = by / 32, byMod32 = by % 32;

    if (by32Times != 0) {
        FGIntOverflow length = [number length]/4;
        if (by32Times >= length) {
            [number release];
            number = [[NSMutableData alloc] initWithLength: 4];
            // sign = YES;
        } else {
            FGIntBase* numberArray = [number mutableBytes];
            NSMutableData *shiftedNumber = [[NSMutableData alloc] initWithBytes: &numberArray[by32Times] length: (length - by32Times)*4];
            [number release];
            number = shiftedNumber;
        }
    }
        
    if (byMod32 != 0) {
        FGIntOverflow tmpInt, mod = 0, length = [number length]/4;
        FGIntBase* numberArray = [number mutableBytes];

        for( FGIntIndex i = length - 1; i >= 0; i-- ) {
            tmpInt = numberArray[i];
            numberArray[i] = (FGIntBase) (mod | (tmpInt >> byMod32));
            mod = tmpInt << (32 - byMod32);
        }
        // if ((numberArray[length - 1] == 0) && (length == 1)) {
        //     sign = YES;
        // }
        if ((numberArray[length - 1] == 0) && (length > 1)) {
            [number setLength: (length - 1)*4];
        }
    }
}


-(void) shiftLeftBy: (FGIntOverflow) by {
    FGIntOverflow by32Times = by / 32, byMod32 = by % 32;

    if (byMod32 != 0) {
        FGIntOverflow tmpInt, mod = 0, length = [number length]/4;
        FGIntBase* numberArray = [number mutableBytes];

        for( FGIntIndex i = 0; i < length; i++ ) {
            tmpInt = numberArray[i];
            numberArray[i] = (FGIntBase) (mod | (tmpInt << byMod32));
            mod = tmpInt >> (32 - byMod32);
        }
        if (mod != 0) {
            [number setLength: (length + 1)*4];
            numberArray = [number mutableBytes];
            numberArray[length] = (FGIntBase) mod;
        }
    }

    FGIntOverflow length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];
    if (((length != 1) || (numberArray[0] != 0)) && (by32Times > 0)) {
        NSMutableData *tmpNumber = [[NSMutableData alloc] initWithLength: 4*by32Times];
        [tmpNumber appendData: number];
        [number release];
        number = tmpNumber;
    }
}


-(void) increment {
    FGIntOverflow mod = 1, tmpMod, length = [number length]/4;
    FGIntBase* fGIntNumber = [number mutableBytes];

    for( FGIntIndex i = 0; i < length; i++ ) {
        tmpMod = (FGIntOverflow) fGIntNumber[i] + mod;
        fGIntNumber[i] = (FGIntBase) tmpMod;
        mod = tmpMod >> 32;
        if (mod == 0) {
            break;
        }
    }
    
    if (mod != 0) {
        [number setLength: 4*length + 4];
        fGIntNumber = [number mutableBytes];
        fGIntNumber[length] = (FGIntBase) mod;
    }
}

-(void) decrement {
    FGIntIndex mod = - 1, tmpMod;
    FGIntOverflow length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];

    if ((length > 1) || (numberArray[0] != 0)) {
        for ( FGIntIndex i = 0; i < length; i++ ) {
            tmpMod = (FGIntIndex) numberArray[i] + mod;
            numberArray[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            if (mod == 0)
                break;
        }
        while ((length > 1) && (numberArray[length - 1] == 0)) {
            --length;
        }
        if ((numberArray[length - 1] == 0) && (length == 1)) {
            sign = YES;
        }
        if (length*4 < [number length]) {
            [number setLength: length*4];
        }
    } 
}




/* multiply the self by a 32bit unsigned integer */

-(void) multiplyByInt: (FGIntBase) multInt {
    FGIntOverflow tmpInt, mod = 0, length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];

    for( FGIntIndex i = 0; i < length; i++ ) {
        tmpInt = (FGIntOverflow) numberArray[i] * multInt + mod;
        numberArray[i] = (FGIntBase) tmpInt;
        mod = tmpInt >> 32;
    }
    if (mod != 0) {
        [number setLength: 4*(length + 1)];
        numberArray = [number mutableBytes];
        numberArray[length] = (FGIntBase) mod;
    }
}


/* replaces self with self - fGInt, assumes that 0 < fGInt < self */

-(void) subtractWith: (FGInt *) fGInt {
    FGIntOverflow length1 = [[self number] length]/4, length2 = [[fGInt number] length]/4;
    FGIntIndex mod = 0, tmpMod, i = 0;

    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* fGIntNumberArray = [[fGInt number] mutableBytes];

    for( i = 0; i < length2; ++i ) {
        tmpMod = (FGIntIndex) numberArray[i] - fGIntNumberArray[i] + mod;
        mod = tmpMod >>  32;
        numberArray[i] = (FGIntBase) tmpMod;
    }
    for( i = length2; i < length1; ++i ) {
        // if (mod == 0) {
        if (!mod) {
            break;
        }
        tmpMod = (FGIntIndex) numberArray[i] + mod;
        mod = tmpMod >>  32;
        numberArray[i] = (FGIntBase) tmpMod;
    }
    while ((length1 > 1) && (numberArray[length1 - 1] == 0)) {
        --length1;
    }
    if ((length1 == 1) && (numberArray[0] == 0)) {
        sign = YES;
    }
    if (length1*4 < [number length]) {
        [number setLength: length1*4];
    }
}

/* replaces self with self + fGInt */

-(void) addWith: (FGInt *) fGInt {
    FGIntOverflow length1 = [number length]/4, length2 = [[fGInt number] length]/4, mod = 0, tmpMod, i = 0, minLength = MIN(length1, length2);

    if (length1 < MAX(length1, length2)) {
        [number setLength: length2*4];
    }

    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* fGIntNumberArray = [[fGInt number] mutableBytes];

    for( i = 0; i < minLength; ++i ) {
        tmpMod = (FGIntOverflow) numberArray[i] + fGIntNumberArray[i] + mod;
        numberArray[i] = (FGIntBase) tmpMod;
        mod = tmpMod >> 32;
    }
    for( i = minLength; i < length1; ++i ) {
        if (!mod) {
            break;
        }
        tmpMod = (FGIntOverflow) numberArray[i] + mod;
        mod = tmpMod >> 32;
        numberArray[i] = (FGIntBase) tmpMod;
    }
    for( i = minLength; i < length2; ++i ) {
        tmpMod = (FGIntOverflow) fGIntNumberArray[i] + mod;
        numberArray[i] = (FGIntBase) tmpMod;
        mod = tmpMod >> 32;
    }
    
    if (mod) {
        [number setLength: (MAX(length1, length2) + 1)*4];
        numberArray = [number mutableBytes];
        numberArray[MAX(length1, length2)] = (FGIntBase) mod;
    }
}




-(void) makePositive {
    [self setSign: YES];
}


/* divide using the digital long division equivalent. fGInt / divisorFGInt = result */

+(NSDictionary *) longDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    NSMutableDictionary *quotientAndRemainder = [[NSMutableDictionary alloc] init];
    
    FGInt *modFGInt, *resFGInt, *tmpFGInt;
    FGIntBase divInt;
    FGIntOverflow j, divisorLength = [[divisorFGInt number] length]/4, tmpFGIntHead1, tmpFGIntHead2, modFGIntLength,
                length = [[fGInt number] length]/4, tmpFGIntLength;
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        j = (length + 1 > divisorLength) ? (length - divisorLength + 1) : 0;
        resFGInt = [[FGInt alloc] initWithNZeroes: j];
        tmpFGInt = [divisorFGInt mutableCopy];
        modFGInt = [fGInt mutableCopy];
            
        FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];
        FGIntBase* resFGIntNumber = [[resFGInt number] mutableBytes];

        if (j > 0) {
            [tmpFGInt shiftLeftBy32Times: j - 1];
        }

        FGIntBase* tmpFGIntNumber = [[tmpFGInt number] mutableBytes];
        tmpFGIntLength = [[tmpFGInt number] length]/4;

        tmpFGIntHead1 = ((FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] + 1);
        if (tmpFGIntLength > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] << 32) + 
                                      tmpFGIntNumber[tmpFGIntLength - 2] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }

        modFGIntLength = [[modFGInt number] length]/4;

        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            while ([FGInt compareAbsoluteValueOf: modFGInt with: tmpFGInt] != smaller) {
                if (modFGIntLength > [[tmpFGInt number] length]/4) {
                    divInt = (FGIntBase) ((((FGIntOverflow) modFGIntNumber[modFGIntLength - 1] << 32) +
                                              modFGIntNumber[modFGIntLength - 2]) / tmpFGIntHead1);
                } else {
                    if ((modFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                        divInt = (FGIntBase) ((((FGIntOverflow) modFGIntNumber[modFGIntLength - 1] << 32) +
                                              modFGIntNumber[modFGIntLength - 2]) / tmpFGIntHead2);
                    } else {
                        divInt = (FGIntBase) ((modFGIntNumber[modFGIntLength - 1]) / tmpFGIntHead1);
                    }
                }
                if (divInt != 0) {
                    [modFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                    resFGIntNumber[j - 1] = resFGIntNumber[j - 1] + divInt;
                } else {
                    [modFGInt subtractWith: tmpFGInt];
                    resFGIntNumber[j - 1] = resFGIntNumber[j - 1] + 1;
                }
                modFGIntNumber = [[modFGInt number] mutableBytes];
                modFGIntLength = [[modFGInt number] length]/4;
            }
            if ((modFGIntLength <= [[tmpFGInt number] length]/4) && ([[tmpFGInt number] length]/4 > divisorLength)) {
                [tmpFGInt shiftRightBy32];
                --j;
            }
        }
        [tmpFGInt release];
    } else {
        if ([fGInt sign]) {
            resFGInt = [[FGInt alloc] initWithFGIntBase: 0];
            modFGInt = [fGInt mutableCopy];
        } else {
            resFGInt = [[FGInt alloc] initWithFGIntBase: 1];
            if ([divisorFGInt sign])
                [resFGInt setSign: NO];
            modFGInt = [divisorFGInt mutableCopy];
            [modFGInt makePositive];
            [modFGInt subtractWith: fGInt];
        }
        [quotientAndRemainder setObject: resFGInt forKey: quotientKey];
        [quotientAndRemainder setObject: modFGInt forKey: remainderKey];
        [resFGInt release];
        [modFGInt release];

        return quotientAndRemainder;
    }

    FGIntOverflow resFGIntLength = [[resFGInt number] length]/4;
    FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];
    FGIntBase* resFGIntNumber = [[resFGInt number] mutableBytes];

    while ((resFGIntLength > 1) && (resFGIntNumber[resFGIntLength - 1] == 0)) {
        resFGIntLength--;
    }
    if (resFGIntLength*4 < [[resFGInt number] length]) {
        [[resFGInt number] setLength: resFGIntLength*4];
    }

    [resFGInt setSign: [fGInt sign] == [divisorFGInt sign]];
    if ((![fGInt sign]) && (!(([[modFGInt number] length]/4 == 1) && (modFGIntNumber[0] == 0)))) {
        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1];
        [resFGInt addWith: one];
        tmpFGInt = [divisorFGInt mutableCopy];
        [tmpFGInt subtractWith: modFGInt];
        [modFGInt release];
        modFGInt = tmpFGInt;
        [modFGInt setSign: YES];
        [one release];
    }
    
    [quotientAndRemainder setObject:resFGInt forKey:quotientKey];
    [quotientAndRemainder setObject:modFGInt forKey:remainderKey];
    [resFGInt release];
    [modFGInt release];

    return quotientAndRemainder;
}



/* compute the initial bits for newton inversion with kZero fraction digits */

+(FGInt *) newtonInitialValue: (FGInt *) fGInt precision: (FGIntOverflow) kZero {
    FGInt *resFGInt, *tmpFGInt, *bFGInt;
    FGIntOverflow i, j, k, l, isTwo = 0, divisorLength = [[fGInt number] length]/4,
    tmpFGIntHead1, tmpFGIntHead2, bFGIntLength, tmpFGIntLength;
    FGIntBase divInt;
    
    k = divisorLength;
    FGIntBase* fGIntNumberArray = [[fGInt number] mutableBytes];
    for ( FGIntIndex i = 0; i < divisorLength; i++ ) {
        if (fGIntNumberArray[i] != 0 ) {
            for ( l = 0; l <= 31; ++l ) {
                if ((fGIntNumberArray[i] & (1 << l)) != 0)
                    ++isTwo;
            }
        }
    }

    if (isTwo != 1) {
        j = (FGIntOverflow) ceil( (double) kZero / 32 );
        k = divisorLength + j;
        
        bFGInt = [[FGInt alloc] initWithNZeroes: 4*(k + 1)];
        FGIntBase* bFGIntNumber = [[bFGInt number] mutableBytes];
        bFGIntNumber[k] = 1;

        j = (k + 1 > divisorLength) ? (k - divisorLength + 1) : 0;
            
        tmpFGInt = [fGInt mutableCopy];
    
        if (j > 0) {
            [tmpFGInt shiftLeftBy32Times: j - 1];
        }

        resFGInt = [[FGInt alloc] initWithNZeroes: j];

        FGIntBase* resFGIntNumber = [[resFGInt number] mutableBytes];
        FGIntBase* tmpFGIntNumber = [[tmpFGInt number] mutableBytes];
        tmpFGIntLength = [[tmpFGInt number] length]/4;
        tmpFGIntHead1 = (FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] + 1;
        if (tmpFGIntLength > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] << 32) + 
                                      tmpFGIntNumber[tmpFGIntLength - 2] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }
        
        bFGIntLength = k + 1;
        while ([FGInt compareAbsoluteValueOf: bFGInt with: fGInt] != smaller) {
            while ([FGInt compareAbsoluteValueOf: bFGInt with: tmpFGInt] != smaller) {
                if (bFGIntLength > tmpFGIntLength) {
                    divInt = (FGIntBase) ((((FGIntOverflow) bFGIntNumber[bFGIntLength - 1] << 32) +
                                              bFGIntNumber[bFGIntLength - 2]) / tmpFGIntHead1);
                } else {
                    if ((bFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                       divInt = (FGIntBase) ((((FGIntOverflow) bFGIntNumber[bFGIntLength - 1] << 32) +
                              bFGIntNumber[bFGIntLength - 2]) / tmpFGIntHead2);
                    } else {
                        divInt = (FGIntBase) ((FGIntOverflow) bFGIntNumber[bFGIntLength - 1] /
                                 tmpFGIntHead1);
                    }
                }
                if (divInt != 0) {
                    [bFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                    resFGIntNumber[j - 1] = resFGIntNumber[j - 1] + divInt;
                } else {
                    [bFGInt subtractWith: tmpFGInt];
                    resFGIntNumber[j - 1] = resFGIntNumber[j - 1] + 1;
                }
                bFGIntLength = [[bFGInt number] length]/4;
                bFGIntNumber = [[bFGInt number] mutableBytes];
            }
            if ((bFGIntLength <= tmpFGIntLength) && (tmpFGIntLength > divisorLength)) {
                [tmpFGInt shiftRightBy32];
                --j;
                --tmpFGIntLength;
            }
        }

        FGIntOverflow resFGIntLength = [[resFGInt number] length]/4;
        while ((resFGIntLength > 1) && (resFGIntNumber[resFGIntLength - 1] == 0)) {
            --resFGIntLength;
        }
        if (resFGIntLength*4 < [[resFGInt number] length]) {
            [[resFGInt number] setLength: resFGIntLength*4];
            resFGIntNumber = [[resFGInt number] mutableBytes];
        }
    
        j = kZero + 1; 

        i = 32 * (resFGIntLength - 1);
        while ((resFGIntNumber[resFGIntLength - 1] >> i) != 0) {
            ++i;
        }

        if (i > j) {
            [resFGInt shiftRightBy: i - j];
        } else {
            [resFGInt shiftLeftBy: j - i];
        }

        [bFGInt release];
        [tmpFGInt release];
    } else {
        resFGInt = [[FGInt alloc] initWithFGIntBase: 2];
        [resFGInt shiftLeftBy: kZero];
    }

    return resFGInt;
}


/*  newtonInversion returns the 1/fGInt with precision fraction digits */

+(FGInt *) newtonInversion: (FGInt *) fGInt withPrecision: (FGIntOverflow) precision {
    FGInt *z, *zSquare, *vFGInt, *tFGInt, *uFGInt;
    FGIntOverflow h, i, k = precision, baseCaseLength = 128, vLength, uRadix,
    zRadix, zSquareRadix, tRadix, vIndex;
    NSMutableArray *kValues = [[NSMutableArray alloc] init];

    vFGInt = [fGInt mutableCopy];
    vLength = [[vFGInt number] length]/4;
    i = 0;
    FGIntBase* vFGIntNumber = [[vFGInt number] mutableBytes];
    FGIntBase tmpInt = vFGIntNumber[vLength - 1];
    while ((tmpInt << i) < 2147483648) {
        ++i;
    }
    [vFGInt shiftLeftBy: i];


    while (k > baseCaseLength) {
        k = (FGIntOverflow) ceil( (double) k / 2);
        [kValues insertObject: [NSNumber numberWithInteger: k] atIndex: 0];
    }
    z = [FGInt newtonInitialValue: vFGInt precision: k];
    zRadix = k;
    vIndex = 0;
    tRadix = 0;
    tFGInt = [[FGInt alloc] init];
    
    for ( id kValue in kValues ) {
        k = [kValue longLongValue];
        zSquare = [FGInt square: z];
        zSquareRadix = zRadix * 2;

        tRadix = 32 * ((2*k + 3) / 32);
        if ((2*k + 3) % 32 != 0) {
            tRadix += 32;
        }
        [tFGInt release];
        tFGInt = [[FGInt alloc] initWithoutNumber];
        if (tRadix/32 <= vLength) {
            [tFGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &vFGIntNumber[vLength - tRadix/32] length: tRadix/8 freeWhenDone: NO]];
        } else {
            [tFGInt setNumber: [[NSMutableData alloc] initWithLength: tRadix/8 - vLength*4]];
            [[tFGInt number] appendData: [vFGInt number]];
        }

        h = tRadix - 2*k - 3;
        uFGInt = [FGInt multiply: tFGInt and: zSquare];
        [zSquare release];
        uRadix = tRadix + zSquareRadix;
        if (uRadix > 2*k + 1 + h) {
            [uFGInt shiftRightBy: uRadix - (2*k + 1 + h)];
            uRadix = 2*k + 1 + h;
        }
        [z shiftLeft];

        if (uRadix > zRadix) {
            [z shiftLeftBy: uRadix - zRadix];
            zRadix = uRadix;
        }
        [z subtractWith: uFGInt];
        [uFGInt release];
    }

    if (zRadix > precision) 
        [z shiftRightBy: zRadix - precision];
    [z setSign: YES];

    [kValues release];
    [vFGInt release];
    return z;    
}



+(NSDictionary *) barrettDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    NSMutableDictionary *quotientAndRemainder = [[NSMutableDictionary alloc] init];
    FGInt *modFGInt = [[FGInt alloc] init], *resFGInt = [[FGInt alloc] init], *tmpFGInt = [[FGInt alloc] init], 
          *fGIntCopy = nil, *divisorCopy = nil;
    FGIntOverflow i, m = ([[fGInt number] length] - 4) * 8, n = ([[divisorFGInt number] length] - 4) * 8;
    BOOL mnCorrect = NO, fGIntSign = [fGInt sign], divisorSign = [divisorFGInt sign];
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        FGInt *invertedDivisor, *one;
        [fGInt setSign: YES];
        [divisorFGInt setSign: YES];    
            
        FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
        FGIntBase* divisorFGIntNumber = [[divisorFGInt number] mutableBytes];
        
        FGIntBase tmpInt = fGIntNumber[[[fGInt number] length]/4 - 1];
        for ( i = 0; i < 32; ++i ) {
            if ((tmpInt >> i) == 0) 
                break;
            ++m;
        }
        tmpInt = divisorFGIntNumber[[[divisorFGInt number] length]/4 - 1];
        for ( i = 0; i < 32; ++i ) {
            if ((tmpInt >> i) == 0) 
                break;
            ++n;
        }
        
        if (m > 2*n) {
            fGIntCopy = [fGInt mutableCopy];
            divisorCopy = [divisorFGInt mutableCopy];
            mnCorrect = YES;
        }
        
        while (m > 2*n) {
            if (m >= 2*n + 32) {
                [fGInt shiftLeftBy32];
                [divisorFGInt shiftLeftBy32];
                m += 32;
                n += 32;
            } else {
                [fGInt shiftLeft];
                [divisorFGInt shiftLeft];
                ++m;
                ++n;
            }
        }

        invertedDivisor = [FGInt newtonInversion: divisorFGInt withPrecision: m - n];

        tmpFGInt = [fGInt mutableCopy];
        i = n - 1;
        if (i > 0) {
            [tmpFGInt shiftRightBy: i];
        }
        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];

        i = m - n + 1;
        if (i > 0) {
            [resFGInt shiftRightBy: i];
        }
        
        if (mnCorrect) {
            [fGInt setNumber: [fGIntCopy number]];
            [divisorFGInt setNumber: [divisorCopy number]];
        }
        [fGInt setSign: fGIntSign];
        [divisorFGInt setSign: divisorSign];

        tmpFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        modFGInt = [FGInt subtract: fGInt and: tmpFGInt];
        [tmpFGInt release];
        one = [[FGInt alloc] initWithFGIntBase: 1];
        
        while (!([modFGInt sign] && ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] == smaller))) {
            if (![modFGInt sign]) {
                tmpFGInt = [FGInt add: modFGInt and: divisorFGInt];
                [modFGInt release];
                modFGInt = tmpFGInt;
                [resFGInt subtractWith: one];
            } else {
                [modFGInt subtractWith: divisorFGInt];
                [resFGInt addWith: one];
            }
        }
        if (!fGIntSign) {
                modFGInt = [FGInt subtract: divisorFGInt and: modFGInt];
                [resFGInt addWith: one];
        }
        [resFGInt setSign: fGIntSign == divisorSign];


        [invertedDivisor release];
        [one release];
        
        [quotientAndRemainder setObject:resFGInt forKey:quotientKey];
        [quotientAndRemainder setObject:modFGInt forKey:remainderKey];
        [resFGInt release];
        [modFGInt release];

        return quotientAndRemainder;
    } else {
        if ([fGInt sign]) {
            resFGInt = [[FGInt alloc] initWithFGIntBase: 0];
            modFGInt = [fGInt mutableCopy];
        } else {
            resFGInt = [[FGInt alloc] initWithFGIntBase: 1];
            if ([divisorFGInt sign]) {
                [resFGInt setSign: NO];
            }
            modFGInt = [divisorFGInt mutableCopy];
            [modFGInt makePositive];
            [modFGInt subtractWith: fGInt];
        }
        [quotientAndRemainder setObject:resFGInt forKey:quotientKey];
        [quotientAndRemainder setObject:modFGInt forKey:remainderKey];
        [resFGInt release];
        [modFGInt release];

        return quotientAndRemainder;
    }
}

+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    FGInt *modFGInt = [[FGInt alloc] init], *resFGInt = [[FGInt alloc] init], *tmpFGInt = [[FGInt alloc] init],
          *fGIntCopy = nil, *divisorCopy = nil;
    FGIntOverflow i, m = ([[fGInt number] length] - 4) * 8, n = ([[divisorFGInt number] length] - 4) * 8;
    BOOL mnCorrect = NO, fGIntSign = [fGInt sign], divisorSign = [divisorFGInt sign];
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        FGInt *invertedDivisor, *one;
        [fGInt setSign: YES];
        [divisorFGInt setSign: YES];    
            
        FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
        FGIntBase* divisorFGIntNumber = [[divisorFGInt number] mutableBytes];
        
        FGIntBase tmpInt = fGIntNumber[[[fGInt number] length]/4 - 1];
        for ( i = 0; i < 32; ++i ) {
            if ((tmpInt >> i) == 0) 
                break;
            ++m;
        }
        tmpInt = divisorFGIntNumber[[[divisorFGInt number] length]/4 - 1];
        for ( i = 0; i < 32; ++i ) {
            if ((tmpInt >> i) == 0) 
                break;
            ++n;
        }
        
        if (m > 2*n) {
            fGIntCopy = [fGInt mutableCopy];
            divisorCopy = [divisorFGInt mutableCopy];
            mnCorrect = YES;
        }
        
        while (m > 2*n) {
            if (m >= 2*n + 32) {
                [fGInt shiftLeftBy32];
                [divisorFGInt shiftLeftBy32];
                m += 32;
                n += 32;
            } else {
                [fGInt shiftLeft];
                [divisorFGInt shiftLeft];
                ++m;
                ++n;
            }
        }

        invertedDivisor = [FGInt newtonInversion: divisorFGInt withPrecision: m - n];

        tmpFGInt = [fGInt mutableCopy];
        i = n - 1;
        if (i > 0) {
            [tmpFGInt shiftRightBy: i];
        }
        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];

        i = m - n + 1;
        if (i > 0) {
            [resFGInt shiftRightBy: i];
        }
        
        if (mnCorrect) {
            [fGInt setNumber: [fGIntCopy number]];
            [divisorFGInt setNumber: [divisorCopy number]];
        }
        [fGInt setSign: fGIntSign];
        [divisorFGInt setSign: divisorSign];

        tmpFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        modFGInt = [FGInt subtract: fGInt and: tmpFGInt];
        [tmpFGInt release];
        one = [[FGInt alloc] initWithFGIntBase: 1];
        
        while (!([modFGInt sign] && ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] == smaller))) {
            if (![modFGInt sign]) {
                tmpFGInt = [FGInt add: modFGInt and: divisorFGInt];
                [modFGInt release];
                modFGInt = tmpFGInt;
            } else {
                [modFGInt subtractWith: divisorFGInt];
            }
        }
        if (!fGIntSign) {
                modFGInt = [FGInt subtract: divisorFGInt and: modFGInt];
        }

        [invertedDivisor release];
        [one release];
        
        [resFGInt release];

        return modFGInt;
    } else {
        if ([fGInt sign])
            return [fGInt mutableCopy];
        else {
            modFGInt = [divisorFGInt mutableCopy];
            [modFGInt makePositive];
            [modFGInt subtractWith: fGInt];
            return modFGInt;
        }
    }
}


/* _ONLY_ use if self <= fGInt * multInt */

-(void) subtractWith: (FGInt *) fGInt multipliedByInt: (FGIntBase) multInt {
    FGIntOverflow length1 = [number length]/4, length2 = [[fGInt number] length]/4;
    FGIntIndex mod = 0, tmpMod;
    FGIntOverflow mTmpMod, mMod = 0;

   // if (length2 > length1) {
   //     NSLog(@"Oh-oh, length1 = %lu, and length2 is %lu",length1, length2);
   //     NSLog(@"the base10 string of  self %@",[self toBase10String]);
   //     NSLog(@"the base10 string of fgint %@",[fGInt toBase10String]);
   // }
    FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
    FGIntBase* numberArray = [number mutableBytes];

    for( FGIntIndex i = 0; i < length2; i++ ) {
        mTmpMod = (FGIntOverflow) fGIntNumber[i] * multInt + mMod;
        mMod = mTmpMod >> 32;
        tmpMod = (FGIntIndex) numberArray[i] - (mTmpMod & 4294967295u) + mod;
        mod = tmpMod >> 32;
        numberArray[i] = (FGIntBase) tmpMod;
    }
    for( FGIntIndex i = length2; i < length1; i++ ) {
        if ((mod == 0) && (mMod == 0)) {
            break;
        }
        tmpMod = (FGIntIndex) numberArray[i] - mMod + mod;
        mMod >>= 32;
        mod = tmpMod >> 32;
        numberArray[i] = (FGIntBase) tmpMod;
    }
    while ((length1 > 1) && (numberArray[length1 - 1] == 0)) {
        --length1;
    }
    if ((length1 == 1) && (numberArray[0] == 0)) {
        sign = YES;
    }
    if (length1*4 < [number length]) {
        [number setLength: length1*4];
    }
}


+(FGInt *) reduce: (FGInt *) fGInt bySubtracting: (FGInt *) nFGInt atMost: (FGIntBase) nTimes {
    FGInt *result = [fGInt mutableCopy];
    FGIntBase tries = 0;
    while ((tries < nTimes) && ([FGInt compareAbsoluteValueOf: result with: nFGInt] != smaller)) {
        [result subtractWith: nFGInt];
        ++tries;
    }

    return result;
}

-(FGInt *) reduceBySubtracting: (FGInt *) nFGInt atMost: (FGIntBase) nTimes {
    FGIntBase tries = 0;
    while ((tries < nTimes) && ([FGInt compareAbsoluteValueOf: self with: nFGInt] != smaller)) {
        [self subtractWith: nFGInt];
        ++tries;
    }
    return self;
}





+(FGInt *) longDivisionMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    FGInt *modFGInt, *tmpFGInt;
    FGIntBase divInt;
    FGIntOverflow j, divisorLength = [[divisorFGInt number] length]/4, tmpFGIntHead1, tmpFGIntHead2, modFGIntLength,
                length = [[fGInt number] length]/4, tmpFGIntLength;
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        j = (length + 1 > divisorLength) ? (length - divisorLength + 1) : 0;
        tmpFGInt = [divisorFGInt mutableCopy];
        modFGInt = [fGInt mutableCopy];
            
        FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];

        if (j > 0) {
            [tmpFGInt shiftLeftBy32Times: j - 1];
        }

        FGIntBase* tmpFGIntNumber = [[tmpFGInt number] mutableBytes];
        tmpFGIntLength = [[tmpFGInt number] length]/4;

        tmpFGIntHead1 = ((FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] + 1);
        if (tmpFGIntLength > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] << 32) + 
                                      tmpFGIntNumber[tmpFGIntLength - 2] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }

        modFGIntLength = [[modFGInt number] length]/4;


        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            while ([FGInt compareAbsoluteValueOf: modFGInt with: tmpFGInt] != smaller) {
                if (modFGIntLength > [[tmpFGInt number] length]/4) {
                    divInt = (FGIntBase) ((((FGIntOverflow) modFGIntNumber[modFGIntLength - 1] << 32) +
                                              modFGIntNumber[modFGIntLength - 2]) / tmpFGIntHead1);
                } else {
                    if ((modFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                        divInt = (FGIntBase) ((((FGIntOverflow) modFGIntNumber[modFGIntLength - 1] << 32) +
                                              modFGIntNumber[modFGIntLength - 2]) / tmpFGIntHead2);
                    } else {
                        divInt = (FGIntBase) (modFGIntNumber[modFGIntLength - 1] / tmpFGIntHead1);
                    }
                }
                if (divInt != 0) {
                    [modFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                } else {
                    [modFGInt subtractWith: tmpFGInt];
                }
                modFGIntNumber = [[modFGInt number] mutableBytes];
                modFGIntLength = [[modFGInt number] length]/4;
            }
            if ((modFGIntLength <= [[tmpFGInt number] length]/4) && ([[tmpFGInt number] length]/4 > divisorLength)) {
                [tmpFGInt shiftRightBy32];
                --j;
            }
        }
        [tmpFGInt release];
    } else {
        if ([fGInt sign]) {
            modFGInt = [fGInt mutableCopy];
        } else {
            modFGInt = [divisorFGInt mutableCopy];
            [modFGInt makePositive];
            [modFGInt subtractWith: fGInt];
        }
        
        return modFGInt;
    }

    if ((![fGInt sign]) && (![modFGInt isZero])) {
        tmpFGInt = [divisorFGInt mutableCopy];
        [tmpFGInt subtractWith: modFGInt];
        [modFGInt release];
        modFGInt = tmpFGInt;
        [modFGInt setSign: YES];
    }
    
    return modFGInt;
}


+(FGInt *) longDivisionModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    FGInt *modFGInt, *tmpFGInt;
    FGIntBase divInt;
    FGIntOverflow i, j, divisorLength = [[divisorFGInt number] length]/4, tmpFGIntHead1, tmpFGIntHead2, modFGIntLength,
                length = [[fGInt number] length]/4, tmpFGIntLength;
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        j = (length + 1 > divisorLength) ? (length - divisorLength + 1) : 0;
        tmpFGInt = [divisorFGInt mutableCopy];
        modFGInt = fGInt;
            
        FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];

        if (j > 0) {
            [tmpFGInt shiftLeftBy32Times: j - 1];
        }

        tmpFGIntLength = [[tmpFGInt number] length]/4;
        NSMutableData *retainTmpFGInt = [[tmpFGInt number] retain];
        FGIntBase* tmpFGIntNumber = [retainTmpFGInt mutableBytes];

        tmpFGIntHead1 = ((FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] + 1);
        if (tmpFGIntLength > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) tmpFGIntNumber[tmpFGIntLength - 1] << 32) + 
                                      tmpFGIntNumber[tmpFGIntLength - 2] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }

        modFGIntLength = [[modFGInt number] length]/4;
        i = 0;
        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            while ([FGInt compareAbsoluteValueOf: modFGInt with: tmpFGInt] != smaller) {
                if (modFGIntLength > tmpFGIntLength) {
                    divInt = (FGIntBase) ((((FGIntOverflow) modFGIntNumber[modFGIntLength - 1] << 32) +
                                              modFGIntNumber[modFGIntLength - 2]) / tmpFGIntHead1);
                } else {
                    if ((modFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                        divInt = (FGIntBase) ((((FGIntOverflow) modFGIntNumber[modFGIntLength - 1] << 32) +
                                              modFGIntNumber[modFGIntLength - 2]) / tmpFGIntHead2);
                    } else {
                        divInt = (FGIntBase) (modFGIntNumber[modFGIntLength - 1] / tmpFGIntHead1);
                    }
                }
                if (divInt != 0) {
                    [modFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                } else {
                    [modFGInt subtractWith: tmpFGInt];
                }
                modFGIntNumber = [[modFGInt number] mutableBytes];
                modFGIntLength = [[modFGInt number] length]/4;
            }
            if ((modFGIntLength <= tmpFGIntLength) && (tmpFGIntLength > divisorLength)) {
                ++i;
                --tmpFGIntLength;
                [[tmpFGInt number] release];
                [tmpFGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &tmpFGIntNumber[i] length: tmpFGIntLength*4 freeWhenDone: NO]];
                // tmpFGIntNumber = [[tmpFGInt number] mutableBytes];
            }
        }
        [tmpFGInt release];
        [retainTmpFGInt release];
    } else {
        if ([fGInt sign])
            return fGInt;
        else 
            modFGInt = fGInt;
    }
    FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];
    if ((![fGInt sign]) && (!(([[modFGInt number] length]/4 == 1) && (modFGIntNumber[0] == 0)))) {
        tmpFGInt = [divisorFGInt mutableCopy];
        [tmpFGInt subtractWith: modFGInt];
        [modFGInt release];
        modFGInt = tmpFGInt;
        [modFGInt setSign: YES];
    }
    return modFGInt;
}




/*  barrettMod expects fGInt to contain not more than double the amount of significant bits of divisorFGInt,
    invertedDivisor has double the amount of significant bits of divisorFGInt as fraction bits.
*/


+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision {
    FGInt *modFGInt, *resFGInt, *tmpFGInt;
    FGIntOverflow i, j, k;

    // BOOL fGIntSign = [fGInt sign];
    // [fGInt setSign: YES];
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {

        tmpFGInt = [[FGInt alloc] initWithoutNumber];
        FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
        i = precision - 1;
        k = i / 32;
        [tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: &fGIntNumber[k] length: [[fGInt number] length] - k*4]];
        j = i % 32;
        if (j > 0) {
            fGIntNumber = [[tmpFGInt number] mutableBytes];
            fGIntNumber[0] &= (4294967295u << j);            
        }

        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];
        i = precision + 1 + j;
        [resFGInt shiftRightBy: i];
        
        tmpFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        [resFGInt release];


        while ([FGInt compareAbsoluteValueOf: tmpFGInt with: fGInt] != smaller) {
            [tmpFGInt subtractWith: divisorFGInt];
        }
        modFGInt = [fGInt mutableCopy];
        [modFGInt subtractWith: tmpFGInt];
        [tmpFGInt release];

        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            [modFGInt subtractWith: divisorFGInt];
        }
        
        [modFGInt setSign: [fGInt sign]];
        return modFGInt;
        
    } else {
        if ([fGInt sign]) {
            return [fGInt mutableCopy];
        } else {
            return [FGInt add: divisorFGInt and: fGInt];
        }
    }
}
+(FGInt *) barrett: (FGInt *) fGInt modulo: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision {
    FGInt *modFGInt, *resFGInt, *tmpFGInt;
    FGIntOverflow i, j, k;

    // BOOL fGIntSign = [fGInt sign];
    // [fGInt setSign: YES];
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {

        tmpFGInt = [[FGInt alloc] initWithoutNumber];
        FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
        i = precision - 1;
        k = i / 32;
        [tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: &fGIntNumber[k] length: [[fGInt number] length] - k*4]];
        j = i % 32;
        if (j > 0) {
            fGIntNumber = [[tmpFGInt number] mutableBytes];
            fGIntNumber[0] &= (4294967295u << j);            
        }

        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];
        i = precision + 1 + j;
        [resFGInt shiftRightBy: i];
        
        tmpFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        [resFGInt release];

        while ([FGInt compareAbsoluteValueOf: tmpFGInt with: fGInt] != smaller) {
            [tmpFGInt subtractWith: divisorFGInt];
        }
        modFGInt = [fGInt mutableCopy];
        [modFGInt subtractWith: tmpFGInt];
        [tmpFGInt release];

        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            [modFGInt subtractWith: divisorFGInt];
        }
        
        if ([fGInt sign]) {
            return modFGInt;
        } else {
            FGInt *result = [divisorFGInt mutableCopy];
            [result subtractWith: modFGInt];
            [modFGInt release];
            return result;
        }

    } else {
        if ([fGInt sign]) {
            return [fGInt mutableCopy];
        } else {
            return [FGInt add: divisorFGInt and: fGInt];
        }
    }
}




+(FGInt *) barrettModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision {
    FGInt *modFGInt, *resFGInt, *tmpFGInt;
    FGIntOverflow i, j, k;
    
    BOOL fGIntSign = [fGInt sign];
    [fGInt setSign: YES];

    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {

        tmpFGInt = [[FGInt alloc] initWithoutNumber];
        FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
        i = precision - 1;
        j = i / 32;
        k = 0;
        [tmpFGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &fGIntNumber[j] length: [[fGInt number] length] - j*4 freeWhenDone: NO]];
        j = i % 32;
        if (j > 0) {
            [tmpFGInt shiftRightBy: j];
        }
        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];
        i = precision + 1;
        if (i > 0) {
            [resFGInt shiftRightBy: i];
        }
        
        modFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        [resFGInt release];
        if ([FGInt compareAbsoluteValueOf: modFGInt with: fGInt] == larger) {
            [modFGInt subtractWith: fGInt];
            [fGInt release];
            fGInt = modFGInt;
            [modFGInt setSign: NO];
        } else {
            [fGInt subtractWith: modFGInt];
            [modFGInt release];
            modFGInt = fGInt;
        }

        i = 0;
        while (!([modFGInt sign] && ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] == smaller))) {
            if (![modFGInt sign]) {
                tmpFGInt = [FGInt add: modFGInt and: divisorFGInt];
                [modFGInt release];
                modFGInt = tmpFGInt;
                fGInt = modFGInt;
            } else {
                [modFGInt subtractWith: divisorFGInt];
            }
        }
        
        if (fGIntSign) {
            return modFGInt;
        } else {
            [fGInt setSign: NO];
            FGInt *result = [FGInt subtract: divisorFGInt and: modFGInt];
            [modFGInt release];
            return result;
        }
    } else {
        if (fGIntSign) {
            return fGInt;
        } else {
            [fGInt setSign: NO];
            return [FGInt add: divisorFGInt and: fGInt];
        }
    }
}




/* raise fGInt to the power fGIntN mod modFGInt, and return (fGInt ^ fGIntN) % modFGInt */

+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN barrettMod: (FGInt *) modFGInt {
    FGInt *power = [[FGInt alloc] initWithFGIntBase: 1];
    FGIntOverflow nLength = [[fGIntN number] length]/4, precision = ([[modFGInt number] length]/4 - 1) * 32;
    FGIntBase tmp;
    FGInt *tmpFGInt1, *tmpFGInt;
    FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];
    
    tmp = modFGIntNumber[[[modFGInt number] length]/4 - 1];
    for ( int i = 0; i < 32; ++i ) {
        if ((tmp >> i) == 0) {
            break;
        }
        ++precision;
    }

    FGInt *invertedDivisor = [FGInt newtonInversion: modFGInt withPrecision: precision];
    tmpFGInt1 = [fGInt retain];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmp = nFGIntNumber[i];
        for( FGIntIndex j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
                [power release];
                power = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//                power = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//                [tmpFGInt release];
            }
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            tmpFGInt1 = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            [tmpFGInt release];
            tmp >>= 1;
        }
    }
    tmp = nFGIntNumber[nLength - 1];
    while(tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
            [power release];
            power = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            power = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            [tmpFGInt release];
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            tmpFGInt1 = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            [tmpFGInt release];
        }
    }

    [invertedDivisor release];
    [tmpFGInt1 release];

    return power;
}


+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN longDivisionMod: (FGInt *) modFGInt {
    FGInt *power = [[FGInt alloc] initWithFGIntBase: 1];
    FGIntOverflow nLength = [[fGIntN number] length]/4;
    FGIntBase tmp;
    FGInt *tmpFGInt1, *tmpFGInt;
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];

    tmpFGInt1 = [fGInt retain];
    // tmpFGInt1 = [fGInt mutableCopy];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmp = nFGIntNumber[i];
        for( FGIntIndex j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
                [power release];
                power = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
             // power = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
             // [tmpFGInt release];
            }
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            // tmpFGInt1 = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
           tmpFGInt1 = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
           [tmpFGInt release];
            tmp >>= 1;
        }
    }
    tmp = nFGIntNumber[nLength - 1];
    while(tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
            [power release];
            power = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
           // power = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
           // [tmpFGInt release];
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
           // tmpFGInt1 = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
           // [tmpFGInt release];
        }
    }
    
    [tmpFGInt1 release];
    
    return power;
}


+(FGInt *) mod: (FGInt *) fGInt by: (FGInt *) modFGInt {
    if (([[fGInt number] length] > [[modFGInt number] length]) && ([[fGInt number] length]/4 - [[modFGInt number] length]/4 > barrettThreshold))
        return [FGInt barrettMod: fGInt by: modFGInt];
    else
        return [FGInt longDivisionMod: fGInt by: modFGInt];
}


+(NSDictionary *) divide: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    if (([[fGInt number] length] > [[divisorFGInt number] length]) && ([[fGInt number] length]/4 - [[divisorFGInt number] length]/4 > barrettThreshold))
        return [FGInt barrettDivision: fGInt by: divisorFGInt];
    else
        return [FGInt longDivision: fGInt by: divisorFGInt];
}


/* compute the greatest common divisor of fGInt1 and fGInt2 */

+(FGInt *) gcd: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    if ( [FGInt compareAbsoluteValueOf: fGInt1 with: fGInt2] == equal) 
        return [fGInt1 mutableCopy];
        else {
            if ([FGInt compareAbsoluteValueOf: fGInt1 with: fGInt2] == smaller)
                return [FGInt gcd: fGInt2 and: fGInt1];
            else {
                FGInt *tmpFGInt1, *tmpFGInt2, *tmpFGInt, *zero = [[FGInt alloc] initWithFGIntBase: 0];
                tmpFGInt1 = [fGInt1 mutableCopy];
                tmpFGInt2 = [fGInt2 mutableCopy];
                while ([FGInt compareAbsoluteValueOf: tmpFGInt2 with: zero] != equal) {
                    tmpFGInt = tmpFGInt2;
                    tmpFGInt2 = [FGInt longDivisionModBis: tmpFGInt1 by: tmpFGInt2];
                    tmpFGInt1 = tmpFGInt;
                }
                [zero release];
                [tmpFGInt2 release];
                return tmpFGInt1;
            }
        }
}


/* compute the greatest common divisor of fGInt1 and fGInt2 */

+(FGInt *) binaryGCD: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGInt *zero = [[FGInt alloc] initAsZero];
    if ([FGInt compareAbsoluteValueOf: fGInt1 with: zero] == equal) {
        [zero release];
        return [fGInt2 mutableCopy];
    }
    if ([FGInt compareAbsoluteValueOf: fGInt2 with: zero] == equal) {
        [zero release];
        return [fGInt1 mutableCopy];
    }

    FGInt *fGInt1Copy = [fGInt1 mutableCopy], *fGInt2Copy = [fGInt2 mutableCopy];
    FGIntBase* fGInt1Number = [[fGInt1Copy number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2Copy number] mutableBytes];
    FGIntOverflow length1 = [[fGInt1Copy number] length]/4, length2 = [[fGInt2Copy number] length]/4, minLength = (length1 < length2) ? length1 : length2, i = 0, shift = 0;

    while (((shift / 32) < minLength) && ((((fGInt1Number[shift / 32] | fGInt2Number[shift / 32]) >> (shift % 32)) & 1) == 0)) {
        ++shift;
    }
    if (shift > 0) {
        [fGInt1Copy shiftRightBy: shift];
        [fGInt2Copy shiftRightBy: shift];
    }
    fGInt1Number = [[fGInt1Copy number] mutableBytes];
    length1 = [[fGInt1Copy number] length]/4;
    while (((i / 32) < length1) && (((fGInt1Number[i / 32] >> (i % 32)) & 1) == 0)) {
        ++i;
    }
    if (i > 0) {
        [fGInt1Copy shiftRightBy: i];
    }

    do {
        fGInt2Number = [[fGInt2Copy number] mutableBytes];
        length2 = [[fGInt2Copy number] length]/4;
        i = 0;
        while (((i / 32) < length2) && (((fGInt2Number[i / 32] >> (i % 32)) & 1) == 0)) {
            ++i;
        }
        if (i > 0) {
            [fGInt2Copy shiftRightBy: i];
        }

        if ([FGInt compareAbsoluteValueOf: fGInt1Copy with: fGInt2Copy] == larger) {
            FGInt *tmp = fGInt2Copy;
            fGInt2Copy = fGInt1Copy;
            fGInt1Copy = tmp;
        }
        [fGInt2Copy subtractWith: fGInt1Copy];
    } while([FGInt compareAbsoluteValueOf: fGInt2Copy with: zero] != equal);

    if (shift > 0) {
        [fGInt1Copy shiftLeftBy: shift];
    }
    [zero release];
    [fGInt2Copy release];
    return fGInt1Copy;
}



/* compute the greatest common divisor of fGInt1 and fGInt2 */

+(FGInt *) lcm: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGInt *tmpFGInt1, *tmpFGInt2, *resFGInt;
    tmpFGInt1 = [FGInt multiply: fGInt1 and: fGInt2];
    tmpFGInt2 = [FGInt gcd: fGInt1 and: fGInt2];
    NSDictionary *divMod = [FGInt divide: tmpFGInt1 by: tmpFGInt2];
    resFGInt = [[divMod objectForKey: quotientKey] retain];
    [tmpFGInt1 release];
    [tmpFGInt2 release];
    [divMod release];
    return resFGInt;
}



/* returns the modular inverse of fGInt mod modFGInt*/

+(FGInt *) modularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt {
    FGInt *r1, *r2, *zero, *one, *tmpB, *tmpFGInt, *tmpFGInt1,
            *tmpFGInt2, *inverse, *gcd;
    NSDictionary *tmpDivMod;


    one = [[FGInt alloc] initWithFGIntBase: 1];
    gcd = [FGInt gcd: fGInt and: modFGInt];

    if ([FGInt compareAbsoluteValueOf: one with: gcd] == equal) {
        zero = [[FGInt alloc] initWithFGIntBase: 0];
        [gcd release];
        r2 = [fGInt mutableCopy];
        r1 = [modFGInt mutableCopy];
        inverse = [zero mutableCopy];
        tmpB = [one mutableCopy];
        do {
            tmpDivMod = [FGInt divide: r1 by: r2];
            [r1 release];
            r1 = r2;
            r2 = [tmpDivMod objectForKey: remainderKey];
            [r2 retain];
            tmpFGInt1 = [FGInt multiply: [tmpDivMod objectForKey: quotientKey] and: tmpB];
            [tmpDivMod release];
            tmpFGInt2 = [FGInt subtract: inverse and: tmpFGInt1];
            [tmpFGInt1 release];
            [inverse release];
            inverse = tmpB;
            tmpB = tmpFGInt2;
        } while ([FGInt compareAbsoluteValueOf: r2 with: zero] != equal);
        [r1 release];
        [r2 release];
        [tmpB release];
        if (![inverse sign]) {
            tmpFGInt = [FGInt add: inverse and: modFGInt];
            [inverse release];
            inverse = tmpFGInt;
        }
        [one release];
        [zero release];

        return inverse;
    }
    [gcd release];
    [one release];
    return zero;
}






+(FGInt *) invert: (FGInt *) fGInt moduloPrime: (FGInt *) pFGInt {
    FGInt *uFGInt = [FGInt mod: fGInt by: pFGInt], *vFGInt = [pFGInt mutableCopy], *one = [[FGInt alloc] initWithFGIntBase: 1];
    FGInt *x1 = [[FGInt alloc] initWithFGIntBase: 1], *x2 = [[FGInt alloc] initWithFGIntBase: 0], *tmpFGInt;
    FGIntBase* numberArray;


    while (([FGInt compareAbsoluteValueOf: uFGInt with: one] != equal) && ([FGInt compareAbsoluteValueOf: vFGInt with: one] != equal)) {
        numberArray = [[uFGInt number] mutableBytes];
        while ((numberArray[0] & 1) == 0) {
            [uFGInt shiftRight];
            numberArray = [[x1 number] mutableBytes];
            if ((numberArray[0] & 1) == 0) {
                [x1 shiftRight];
            } else {
                [x1 addWith: pFGInt];
                [x1 shiftRight];
            }
            numberArray = [[uFGInt number] mutableBytes];
        }
        numberArray = [[vFGInt number] mutableBytes];
        while ((numberArray[0] & 1) == 0) {
            [vFGInt shiftRight];
            numberArray = [[x2 number] mutableBytes];
            if ((numberArray[0] & 1) == 0) {
                [x2 shiftRight];
            } else {
                [x2 addWith: pFGInt];
                [x2 shiftRight];
            }
            numberArray = [[vFGInt number] mutableBytes];
        }
        if ([FGInt compareAbsoluteValueOf: uFGInt with: vFGInt] == smaller) {
            [vFGInt subtractWith: uFGInt];
            tmpFGInt = [FGInt subtract: x2 and: x1];
            [x2 release];
            x2 = tmpFGInt;
        } else {
            [uFGInt subtractWith: vFGInt];
            tmpFGInt = [FGInt subtract: x1 and: x2];
            [x1 release];
            x1 = tmpFGInt;
        }
    }
    if ([FGInt compareAbsoluteValueOf: uFGInt with: one] == equal) {
        [uFGInt release];
        [vFGInt release];
        [x2 release];
        [one release];
        tmpFGInt = [FGInt mod: x1 by: pFGInt];
        [x1 release];
        return tmpFGInt;
    } else {
        [uFGInt release];
        [vFGInt release];
        [x1 release];
        [one release];
        tmpFGInt = [FGInt mod: x2 by: pFGInt];
        [x2 release];
        return tmpFGInt;
    }

}




+(FGInt *) shiftEuclideanInvert: (FGInt *) aFGInt mod: (FGInt *) nFGInt {
    FGInt *u, *v, *r, *s, *tmp, *shifted;

    if ([FGInt compareAbsoluteValueOf: aFGInt with: nFGInt] == smaller) {
        u = [nFGInt mutableCopy];
        v = [aFGInt mutableCopy];
        r = [[FGInt alloc] initAsZero];
        s = [[FGInt alloc] initWithFGIntBase: 1]; 
    } else {
        v = [nFGInt mutableCopy];
        u = [aFGInt mutableCopy];
        s = [[FGInt alloc] initAsZero];
        r = [[FGInt alloc] initWithFGIntBase: 1]; 
    }
    while ([v bitSize] > 1) {
        FGIntOverflow f = [u bitSize] - [v bitSize];
        if ([u sign] == [v sign]) {
            shifted = [v mutableCopy];
            [shifted shiftLeftBy: f];
            tmp = [FGInt subtract: u and: shifted];
            [u release];
            u = tmp;
            [shifted release];
            shifted = [s mutableCopy];
            [shifted shiftLeftBy: f];
            tmp = [FGInt subtract: r and: shifted];
            [r release];
            r = tmp;
            [shifted release];
        } else {
            shifted = [v mutableCopy];
            [shifted shiftLeftBy: f];
            tmp = [FGInt add: u and: shifted];
            [u release];
            u = tmp;
            [shifted release];
            shifted = [s mutableCopy];
            [shifted shiftLeftBy: f];
            tmp = [FGInt add: r and: shifted];
            [r release];
            r = tmp;
            [shifted release];
        }
        if ([u bitSize] < [v bitSize]) {
            tmp = u;
            u = v;
            v = tmp;
            tmp = r;
            r = s;
            s = tmp;
        }
    }
    if ([[v number] length] == 4) {
        FGIntBase* numberArray = [[v number] mutableBytes];
        if (numberArray[0] == 0) {
            [u release];
            [r release];
            [s release];
            return v;
        }
    }
    if (![v sign]) {
        [s setSign: ![s sign]];
    }
    if ([FGInt compareAbsoluteValueOf: s with: nFGInt] == larger) {
        [s subtractWith: nFGInt];
        [u release];
        [v release];
        [r release];
        return s;
    }
    if (![s sign]) {
        tmp = [FGInt add: s and: nFGInt];
        [u release];
        [v release];
        [r release];
        [s release];
        return tmp;
    }
    [u release];
    [v release];
    [r release];
    return s;
}







+(FGInt *) montgomeryMod: (FGInt *) fGInt withBase: (FGInt *) baseFGInt andInverseBase: (FGInt *) inverseBaseFGInt withLength: (FGIntOverflow) bLength andHead: (FGIntBase) head {
    FGInt *tmpFGInt, *mFGInt;
    FGIntOverflow length = [[fGInt number] length]/4, length1 = MIN(length, bLength), length2 = [[inverseBaseFGInt number] length]/4, resLength = MIN(bLength, length1 + length2), 
                    i, j, t, mod, tmpMod = 0;
    FGInt *product = [[FGInt alloc] initWithNZeroes: resLength];
    FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
    FGIntBase* inverseNumber = [[inverseBaseFGInt number] mutableBytes]; 
    FGIntBase *productNumber = [[product number] mutableBytes];
    
    for ( i = 0; i < length2; i++ ) {
        mod = 0;
        t = MIN(length1, bLength - i);
        if (i == 0) {
            for ( j = 0; j < t; j++ ) {
                if (j < bLength - 1) {
                    tmpMod = (FGIntOverflow) inverseNumber[i]*fGIntNumber[j] + productNumber[j + i] + mod;
                } else {
                    tmpMod = (FGIntOverflow) inverseNumber[i]*(fGIntNumber[j] & head) + productNumber[j + i] + mod;
                }
                productNumber[j + i] = (FGIntBase) tmpMod;
                mod = tmpMod >> 32;    
            }
        } else {
            for ( j = 0; j < t; j++ ) {
                tmpMod = (FGIntOverflow) inverseNumber[i]*fGIntNumber[j] + productNumber[j + i] + mod;
                productNumber[j + i] = (FGIntBase) tmpMod;
                mod = tmpMod >> 32;    
            }
        }
        if (i + length1 <= bLength - 1) {
            productNumber[i + length1] = (FGIntBase) mod;
        }
    }
    if (resLength == bLength) {
        productNumber[resLength - 1] = productNumber[resLength - 1] & head;
    }
    i = resLength;
    while ((i > 1) && (productNumber[i - 1] == 0)) {
        --i;
    }
    if (i < resLength) {
       [[product number] setLength: i*4];
    }

    mFGInt = [FGInt multiply: product and: baseFGInt];
    [product release];
    if ([mFGInt sign] == [fGInt sign]) {
        [mFGInt addWith: fGInt];
    } else {
        if ([FGInt compareAbsoluteValueOf: mFGInt with: fGInt] == larger) {
            [mFGInt subtractWith: fGInt];
        } else {
            tmpFGInt = mFGInt;
            mFGInt = [FGInt subtract: fGInt and: tmpFGInt];
            [tmpFGInt release];
        }
    }

    if (bLength > 1) {
        [mFGInt shiftRightBy32Times: bLength - 1];
    }
    [mFGInt setSign: YES];
    if (head < 2147483648) {
        [FGInt divideFGIntNumberByIntBis: [mFGInt number] divideBy: head + 1];
    } else {
        [mFGInt shiftRightBy32];
    }
    if ([FGInt compareAbsoluteValueOf: mFGInt with: baseFGInt] != smaller) {
        [mFGInt subtractWith: baseFGInt];
    }
    return mFGInt;
}


+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN montgomeryMod: (FGInt *) modFGInt {
    FGInt *tmpFGInt2, *tmpFGInt, *power, *rFGInt, *inverseBaseFGInt;
    FGIntOverflow bLength = [[modFGInt number] length]/4, i, nLength = [[fGIntN number] length]/4,
                    tmpLength;
    int j;
    FGIntBase head, tmp;
    FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];
    tmpLength = bLength + (((modFGIntNumber[bLength - 1] >> 31) == 0) ? 0 : 1);

    power = [FGInt mod: fGInt by: modFGInt];
    FGIntBase* powerNumber = [[power number] mutableBytes];
    if (([[power number] length] == 4) && (powerNumber[0] == 0)) {
        return power;
    }
    [power release];
    
    rFGInt = [[FGInt alloc] initWithNZeroes: tmpLength];
    FGIntBase* rNumber = [[rFGInt number] mutableBytes];
    i = [[rFGInt number] length]/4;
    if (tmpLength == bLength) {
        head = 4294967295u;
        tmp = modFGIntNumber[tmpLength - 1];
        for ( j = 30; j >= 0; --j ) {
            head >>= 1;
            if ((tmp >> j) == 1) {
                rNumber[i - 1] = 1 << (j + 1);
                break;
            }
        }
    } else {
        rNumber[i - 1] = 1;
        head = 4294967295u;
    }

    // tmpFGInt2 = [FGInt modularInverse: modFGInt mod: rFGInt];
    tmpFGInt2 = [FGInt leftShiftModularInverse: modFGInt mod: rFGInt];
    if (![tmpFGInt2 sign]) {
        inverseBaseFGInt = tmpFGInt2;
    } else {
        inverseBaseFGInt = [rFGInt mutableCopy];
        [inverseBaseFGInt subtractWith: tmpFGInt2];
        [tmpFGInt2 release];
    }
    [inverseBaseFGInt makePositive];

    power = [FGInt mod: rFGInt by: modFGInt];
    tmpFGInt = [FGInt multiply: fGInt and: power];
    tmpFGInt2 = [FGInt mod: tmpFGInt by: modFGInt];
    [tmpFGInt release];
    
    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmp = nFGIntNumber[i];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt2];
                [power release];
                // power = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
                power = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
                [tmpFGInt release];
            }
            tmpFGInt = [FGInt square: tmpFGInt2];
            [tmpFGInt2 release];
            // tmpFGInt2 = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            tmpFGInt2 = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
            tmp >>= 1;
        }
    }
    tmp = nFGIntNumber[nLength - 1];
    while(tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt2];
            [power release];
            // power = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            power = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpFGInt = [FGInt square: tmpFGInt2];
            [tmpFGInt2 release];
            // tmpFGInt2 = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            tmpFGInt2 = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
        }
    }
    power = [FGInt montgomeryMod: power withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
    
    [tmpFGInt2 release];
    
    return power;
}

+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN montgomeryMod: (FGInt *) modFGInt withStop: (BOOL *) stop {
    FGInt *tmpFGInt2, *tmpFGInt, *power, *rFGInt, *inverseBaseFGInt;
    FGIntOverflow bLength = [[modFGInt number] length]/4, i, nLength = [[fGIntN number] length]/4,
                    tmpLength;
    int j;
    FGIntBase head, tmp;
    FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];
    tmpLength = bLength + (((modFGIntNumber[bLength - 1] >> 31) == 0) ? 0 : 1);

    power = [FGInt mod: fGInt by: modFGInt];
    if ([power isZero]) {
        return power;
    }
    [power release];
    
    rFGInt = [[FGInt alloc] initWithNZeroes: tmpLength];
    FGIntBase* rNumber = [[rFGInt number] mutableBytes];
    i = [[rFGInt number] length]/4;
    if (tmpLength == bLength) {
        head = 4294967295u;
        tmp = modFGIntNumber[tmpLength - 1];
        for ( j = 30; j >= 0; --j ) {
            head >>= 1;
            if ((tmp >> j) == 1) {
                rNumber[i - 1] = 1 << (j + 1);
                break;
            }
        }
    } else {
        rNumber[i - 1] = 1;
        head = 4294967295u;
    }

    // tmpFGInt2 = [FGInt modularInverse: modFGInt mod: rFGInt];
    tmpFGInt2 = [FGInt leftShiftModularInverse: modFGInt mod: rFGInt];
    if (![tmpFGInt2 sign]) {
        inverseBaseFGInt = tmpFGInt2;
    } else {
        inverseBaseFGInt = [rFGInt mutableCopy];
        [inverseBaseFGInt subtractWith: tmpFGInt2];
        [tmpFGInt2 release];
    }
    [inverseBaseFGInt makePositive];

    power = [FGInt mod: rFGInt by: modFGInt];
    tmpFGInt = [FGInt multiply: fGInt and: power];
    tmpFGInt2 = [FGInt mod: tmpFGInt by: modFGInt];
    [tmpFGInt release];
    
    for( FGIntIndex i = 0; (i < nLength - 1) && !(*stop); i++ ) {
        tmp = nFGIntNumber[i];
        for( j = 0; (j < 32) && !(*stop); ++j ) {
            if ((tmp % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt2];
                [power release];
                // power = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
                power = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
                [tmpFGInt release];
            }
            tmpFGInt = [FGInt square: tmpFGInt2];
            [tmpFGInt2 release];
            // tmpFGInt2 = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            tmpFGInt2 = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
            tmp >>= 1;
            // if (*stop) {
            //     break;
            // }
        }
        // if (*stop) {
        //     break;
        // }
    }
    tmp = nFGIntNumber[nLength - 1];
    while ((tmp != 0)  && !(*stop)) {
        if ((tmp % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt2];
            [power release];
            // power = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            power = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpFGInt = [FGInt square: tmpFGInt2];
            [tmpFGInt2 release];
            // tmpFGInt2 = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            tmpFGInt2 = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
        }
        // if (*stop) {
        //     break;
        // }
    }
    power = [FGInt montgomeryMod: power withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
    
    [tmpFGInt2 release];
    
    return power;
}

// work in progress, maybe 

+(FGInt *) leftShiftModularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt {
    FGIntOverflow cU = 0, cV = 0, modLength = [[modFGInt number] length]/4;
    FGIntBase* modFGIntNumber = [[modFGInt number] mutableBytes];
    FGInt *u = [modFGInt mutableCopy], *v = [fGInt mutableCopy],  *cU2 = [[FGInt alloc] initWithFGIntBase: 1], *cV2 = [cU2 mutableCopy], 
        *r = [[FGInt alloc] initWithFGIntBase: 0], *s = [cU2 mutableCopy], *tmpFGInt, *modBits = [[FGInt alloc] initWithNZeroes: modLength];
    FGIntBase modHead = (1 << 31), tmpInt = modFGIntNumber[modLength - 1];
    FGIntBase* modBitsNumber = [[modBits number] mutableBytes];
    while (modHead > tmpInt) {
        modHead >>= 1;
    }
    modBitsNumber[modLength - 1] = modHead;
    
    while (([FGInt compareAbsoluteValueOf: u with: cU2] != equal) && ([FGInt compareAbsoluteValueOf: v with: cV2] != equal)) {
        if ([FGInt compareAbsoluteValueOf: modBits with: u] == larger) {
            if (cU >= cV) {
                [r shiftLeft];
            } else {
                [s shiftRight];
            }
            [u shiftLeft];
            ++cU;
            [cU2 shiftLeft];
        } else if ([FGInt compareAbsoluteValueOf: modBits with: v] == larger) {
            if (cV >= cU) {
                [s shiftLeft];
            } else {
                [r shiftRight];
            }
            [v shiftLeft];
            ++cV;
            [cV2 shiftLeft];
        } else {
            if ([u sign] == [v sign]) {
                if (cU <= cV) {
                    tmpFGInt = [FGInt subtract: u and: v];
                    [u release];
                    u = tmpFGInt;
                    tmpFGInt = [FGInt subtract: r and: s];
                    [r release];
                    r = tmpFGInt;
                } else {
                    tmpFGInt = [FGInt subtract: v and: u];
                    [v release];
                    v = tmpFGInt;
                    tmpFGInt = [FGInt subtract: s and: r];
                    [s release];
                    s = tmpFGInt;
                }
            } else {
                if (cU <= cV) {
                    tmpFGInt = [FGInt add: u and: v];
                    [u release];
                    u = tmpFGInt;
                    tmpFGInt = [FGInt add: r and: s];
                    [r release];
                    r = tmpFGInt;
                } else {
                    tmpFGInt = [FGInt add: v and: u];
                    [v release];
                    v = tmpFGInt;
                    tmpFGInt = [FGInt add: s and: r];
                    [s release];
                    s = tmpFGInt;
                }
            }
        }
    }
    if ([FGInt compareAbsoluteValueOf: v with: cV2] == equal) {
        [r release];
        r = s;
        [u release];
        u = v;
    } else {
        [s release];
        [v release];
    }
    if (![u sign]) {
        if (![r sign]) {
            [r makePositive];
        } else {
            tmpFGInt = [FGInt subtract: modFGInt and: r];
            [r release];
            r = tmpFGInt;
        }
    } 
    if (![r sign]) {
        tmpFGInt = [FGInt add: modFGInt and: r];
        [r release];
        r = tmpFGInt;
    } 
    
    [u release];
//        NSLog(@" kitty %llu and %llu", cU, cV);
    [cU2 release];
    [cV2 release];
    [modBits release];
    return r;
}



/* divides the number by a 32 bit unsigned int (divInt) and returns the remainder, it does not alter fGIntNumber */

-(FGIntBase) modFGIntByInt: (FGIntBase) divInt {
    FGIntBase mod = 0;
    FGIntOverflow tempMod = 0, length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];

    for( FGIntIndex i = length - 1; i >= 0; i-- ) {
        tempMod =  (((FGIntOverflow) mod << 32) | (FGIntOverflow) numberArray[i]);
        mod = (FGIntOverflow) tempMod % divInt;
    }
    
    return mod;
}

-(void) divideByInt: (FGIntBase) divInt {
    FGIntBase mod = 0;
    FGIntOverflow tempMod = 0, length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];
    
    for( FGIntIndex i = length - 1; i >= 0; i-- ) {
        tempMod =  (((FGIntOverflow) mod << 32) | (FGIntOverflow) numberArray[i]);
        numberArray[i] = (FGIntBase) (tempMod / divInt);
        mod = (FGIntOverflow) tempMod % divInt;
    }

    while ((length > 1) && (numberArray[length - 1] == 0)) {
        --length;
    }
    if (length*4 < [number length]) {
        [number setLength: length*4];
    }
}

// Trialdivision of a FGInt upto 9999 and stopping when a divisor is found, returning ok=false

-(BOOL) trialDivision {
    FGIntOverflow length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];
    if ((numberArray[0] % 2) == 0) {
        return NO;
    }
    BOOL isPrime = YES;
    FGIntBase i = 0;
    while (isPrime && (i < 1228)) {
        isPrime = ([self modFGIntByInt: primes[i]] != 0);
        if ((!isPrime) && (length == 1) && (numberArray[0] == primes[i])) {
            isPrime = YES;
            break;
        }
        ++i;
    }
    return isPrime;
}

-(BOOL) trialDivisionWithStop: (BOOL *) stop  {
    FGIntOverflow length = [number length]/4;
    FGIntBase* numberArray = [number mutableBytes];
    if ((numberArray[0] % 2) == 0) {
        return NO;
    }
    BOOL isPrime = YES;
    FGIntBase i = 0;
    while (isPrime && (i < 1228) && !(*stop)) {
        isPrime = ([self modFGIntByInt: primes[i]] != 0);
        if ((!isPrime) && (length == 1) && (numberArray[0] == primes[i])) {
            isPrime = YES;
            break;
        }
        ++i;
    }
    return (isPrime && !(*stop));
}



/* Compute the coefficients from the Bezout-Bachet theorem, fGInt1 * aFGInt + fGInt2 * bFGInt = gcd(fGInt1, fGInt2) */

+(NSDictionary *) bezoutBachet: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGInt *r1, *r2, *zero, *one, *tmpA, *aFGInt, *bFGInt, *tmpFGInt1, *tmpFGInt2 = [[FGInt alloc] init], *gcd;
    NSMutableDictionary *bezoutBachetCoefficients = [[NSMutableDictionary alloc] init];
    NSDictionary *tmpDivMod;
    
    one = [[FGInt alloc] initWithFGIntBase: 1];
    zero = [[FGInt alloc] initWithFGIntBase: 0];

    r1 = [fGInt1 mutableCopy];
    r2 = [fGInt2 mutableCopy];
    aFGInt = [zero mutableCopy];
    tmpA = [one mutableCopy];
    do {
        tmpDivMod = [FGInt divide: r1 by: r2];
        [r1 release];
        r1 = r2;
        r2 = [[tmpDivMod objectForKey: remainderKey] retain];
        tmpFGInt1 = [FGInt multiply: [tmpDivMod objectForKey: quotientKey] and: tmpA];
        [tmpDivMod release];
        tmpFGInt2 = [FGInt subtract: bFGInt and: tmpFGInt1];
        [tmpFGInt1 release];
        aFGInt = tmpA;
        tmpA = tmpFGInt2;
    } while ([FGInt compareAbsoluteValueOf: r2 with: zero] != equal);
    [tmpA release];
    [r1 release];
    [r2 release];
    gcd = [FGInt gcd: fGInt1 and: fGInt2];
    tmpFGInt1 = [FGInt multiply: aFGInt and: fGInt1];
    [tmpFGInt2 release];
    tmpFGInt2 = [FGInt subtract: gcd and: tmpFGInt1];
    [tmpFGInt1 release];
    [gcd release];
    tmpDivMod = [FGInt divide: tmpFGInt2 by: fGInt2];
    bFGInt = [[tmpDivMod objectForKey: quotientKey] retain];
    [tmpDivMod release];
    [tmpFGInt2 release];
    
    [one release];

    [bezoutBachetCoefficients setObject: aFGInt forKey:A_KEY];
    [bezoutBachetCoefficients setObject: bFGInt forKey:B_KEY];
    [aFGInt release];
    [bFGInt release];
    
    return bezoutBachetCoefficients;
}


-(BOOL) rabinMillerTest: (FGIntBase) numberOfTests {
    BOOL isPrime = YES;
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *pMinusOne = [FGInt subtract: self and: one], *mFGInt = [pMinusOne mutableCopy],
            *zFGInt, *tmpFGInt;
    FGIntOverflow i = 0, j, b = 0;
    FGIntBase* mFGIntNumber = [[mFGInt number] mutableBytes];
    
    while ((mFGIntNumber[0] % 2) == 0) {
        if (mFGIntNumber[0] == 0) {
            b += 32;
            [mFGInt shiftRightBy32];
        } else {
            ++b;
            [mFGInt shiftRight];
        }
        mFGIntNumber = [[mFGInt number] mutableBytes];
    }
    
    while ((i < numberOfTests) && isPrime) {
        ++i;
        tmpFGInt = [[FGInt alloc] initWithFGIntBase: primes[arc4random() % 1228]];
        zFGInt = [FGInt raise: tmpFGInt toThePower: mFGInt montgomeryMod: self];
        [tmpFGInt release];
        j = 0;
        if (([FGInt compareAbsoluteValueOf: zFGInt with: one] != equal) && ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal)) { 
            while (isPrime && (j < b)) {
                if ((j > 0) && ([FGInt compareAbsoluteValueOf: zFGInt with: one] == equal)) 
                    isPrime = NO;
                else {
                    ++j;
                    if ((j < b) && ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal)) {
                        tmpFGInt = [FGInt square: zFGInt];
                        [zFGInt release];
                        zFGInt = [FGInt mod: tmpFGInt by: self];
                        [tmpFGInt release];
                        if ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] == equal) 
                            j = b;
                    } else {
                        if (([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal) && ( j >= b)) {
                            isPrime = NO;
                        }
                    }
                }
            }
        }
        [zFGInt release];
    }
    [one release];
    [pMinusOne release];
    [mFGInt release];
    return isPrime;
}


-(BOOL) rabinMillerTest: (FGIntBase) numberOfTests withStop: (BOOL *) stop {
    BOOL isPrime = YES;
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *pMinusOne = [FGInt subtract: self and: one], *mFGInt = [pMinusOne mutableCopy],
            *zFGInt, *tmpFGInt;
    FGIntOverflow i = 0, j, b = 0;
    FGIntBase* mFGIntNumber = [[mFGInt number] mutableBytes];
    
    while ((mFGIntNumber[0] % 2) == 0) {
        if (mFGIntNumber[0] == 0) {
            b += 32;
            [mFGInt shiftRightBy32];
        } else {
            ++b;
            [mFGInt shiftRight];
        }
        mFGIntNumber = [[mFGInt number] mutableBytes];
    }
    
    while ((i < numberOfTests) && isPrime && !(*stop)) {
        ++i;
        tmpFGInt = [[FGInt alloc] initWithFGIntBase: primes[arc4random() % 1228]];
        zFGInt = [FGInt raise: tmpFGInt toThePower: mFGInt montgomeryMod: self withStop: stop];
        [tmpFGInt release];
        j = 0;
        if (([FGInt compareAbsoluteValueOf: zFGInt with: one] != equal) && ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal)) { 
            while (isPrime && (j < b) && !(*stop)) {
                if ((j > 0) && ([FGInt compareAbsoluteValueOf: zFGInt with: one] == equal)) 
                    isPrime = NO;
                else {
                    ++j;
                    if ((j < b) && ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal)) {
                        tmpFGInt = [FGInt square: zFGInt];
                        [zFGInt release];
                        zFGInt = [FGInt mod: tmpFGInt by: self];
                        [tmpFGInt release];
                        if ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] == equal) 
                            j = b;
                    } else {
                        if (([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal) && ( j >= b)) {
                            isPrime = NO;
                        }
                    }
                }
            }
        }
        [zFGInt release];
    }
    [one release];
    [pMinusOne release];
    [mFGInt release];
    return (isPrime && !(*stop));
}


/* 
   Perform a (combined) primality test on FGIntp consisting of a trialdivision upto 9973,
   if the FGInt passes perform numberOfTests Rabin Miller primality tests, returns ok when a
   FGInt is probably prime
*/

-(BOOL) primalityTest: (FGIntBase) numberOfTests {
    if ([self trialDivision]) {
        FGIntOverflow length = [number length]/4;
        FGIntBase* numberArray = [number mutableBytes];
        if ((length == 1) && (numberArray[0] < 9974)) {
            return YES;
        } else {
            return [self rabinMillerTest: numberOfTests];
        }
    } else {
        return NO;
    }
}

-(BOOL) primalityTest: (FGIntBase) numberOfTests withStop: (BOOL *) stop {
    if ([self trialDivisionWithStop: stop]) {
        FGIntOverflow length = [number length]/4;
        FGIntBase* numberArray = [number mutableBytes];
        if ((length == 1) && (numberArray[0] < 9974)) {
            return YES;
        } else {
            return [self rabinMillerTest: numberOfTests withStop: stop];
        }
    } else {
        return NO;
    }
}



/* divide fGInt by a 32bit integer divInt and return the result = fGInt / divInt */

+(FGInt *) divide: (FGInt *) fGInt byFGIntBase: (FGIntBase) divInt {
    FGIntOverflow mod = 0, tmpMod, resultLength, length = [[fGInt number] length]/4;
    FGInt *result = [[FGInt alloc] initWithNZeroes: length];
    FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];
    FGIntBase* resultNumber = [[result number] mutableBytes];
    
    for ( FGIntIndex i = length - 1; i >= 0; i-- ) {
        tmpMod = (mod << 32) | fGIntNumber[i];
        resultNumber[i] = (FGIntBase) (tmpMod / divInt);
        mod = tmpMod % divInt;
    }
    resultLength = length;
    while ((resultLength > 1) && (resultNumber[resultLength - 1] == 0)) {
        --resultLength;
    }
    if (resultLength < length) {
        [[result number] setLength: resultLength*4];
    }
    [result setSign: [fGInt sign]];
    return result;
}

/* Computes the Legendre symbol for any number aFGInt and
   a prime number pFGInt, returns 0 if pFGInt divides aFGInt, 1 if aFGInt is a
   quadratic residu mod pFGInt, -1 if aFGInt is a quadratic
   nonresidu mod pFGInt
*/

-(int) legendreSymbolMod: (FGInt *) pFGInt {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0], 
        *tmpFGInt = [FGInt mod: self by: pFGInt];
    if ([FGInt compareAbsoluteValueOf: zero with: tmpFGInt] == equal) {
        [tmpFGInt release];
        [one release];
        [zero release];
        return 0;
    } else {
        [tmpFGInt release];
        FGInt *tmpFGInt1 = [pFGInt mutableCopy], *tmpFGInt2 = [self mutableCopy], *tmpFGInt3, *tmpFGInt4, *tmpFGInt5;
        int legendre = 1;
        FGIntBase* tmpNumber;

        while ([FGInt compareAbsoluteValueOf: tmpFGInt1 with: one] != equal) {
            tmpNumber = [[tmpFGInt2 number] mutableBytes];
            if ((tmpNumber[0] % 2) == 0) {
                tmpFGInt3 = [FGInt square: tmpFGInt1];
                [tmpFGInt3 decrement];
                [tmpFGInt3 shiftRightBy: 3];
                tmpNumber = [[tmpFGInt3 number] mutableBytes];
                if ((tmpNumber[0] % 2) != 0) {
                    legendre *= (-1);
                }
                [tmpFGInt3 release];
                [tmpFGInt2 shiftRight];
            } else {
                tmpFGInt3 = [FGInt subtract: tmpFGInt1 and: one];
                tmpFGInt4 = [FGInt subtract: tmpFGInt2 and: one];
                tmpFGInt5 = [FGInt multiply: tmpFGInt3 and: tmpFGInt4];
                [tmpFGInt3 release];
                [tmpFGInt4 release];
                [tmpFGInt5 shiftRightBy: 2];

                // tmpNumber = [[tmpFGInt5 number] mutableBytes];
                // if ((tmpNumber[0] % 2) != 0) {
                if (![tmpFGInt5 isEven]) {
                    legendre *= (-1);
                }
                [tmpFGInt5 release];
                tmpFGInt3 = [FGInt mod: tmpFGInt1 by: tmpFGInt2];
                [tmpFGInt1 release];
                tmpFGInt1 = tmpFGInt2;
                tmpFGInt2 = tmpFGInt3;
            }
        }
        [tmpFGInt1 release];
        [tmpFGInt2 release];
        [one release];
        [zero release];
        return legendre;
    }
}


-(int) legendreSymbolMod: (FGInt *) pFGInt withStop: (BOOL *) stop {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0], 
        *tmpFGInt = [FGInt mod: self by: pFGInt];
    if ([FGInt compareAbsoluteValueOf: zero with: tmpFGInt] == equal) {
        [tmpFGInt release];
        [one release];
        [zero release];
        return 0;
    } else {
        [tmpFGInt release];
        FGInt *tmpFGInt1 = [pFGInt mutableCopy], *tmpFGInt2 = [self mutableCopy], *tmpFGInt3, *tmpFGInt4, *tmpFGInt5;
        int legendre = 1;
        FGIntBase* tmpNumber;

        while (([FGInt compareAbsoluteValueOf: tmpFGInt1 with: one] != equal) && !(*stop)) {
            tmpNumber = [[tmpFGInt2 number] mutableBytes];
            if ((tmpNumber[0] % 2) == 0) {
                tmpFGInt3 = [FGInt square: tmpFGInt1];
                [tmpFGInt3 decrement];
                [tmpFGInt3 shiftRightBy: 3];
                tmpNumber = [[tmpFGInt3 number] mutableBytes];
                if ((tmpNumber[0] % 2) != 0) {
                    legendre *= (-1);
                }
                [tmpFGInt3 release];
                [tmpFGInt2 shiftRight];
            } else {
                tmpFGInt3 = [FGInt subtract: tmpFGInt1 and: one];
                tmpFGInt4 = [FGInt subtract: tmpFGInt2 and: one];
                tmpFGInt5 = [FGInt multiply: tmpFGInt3 and: tmpFGInt4];
                [tmpFGInt3 release];
                [tmpFGInt4 release];
                [tmpFGInt5 shiftRightBy: 2];

                tmpNumber = [[tmpFGInt5 number] mutableBytes];
                if ((tmpNumber[0] % 2) != 0) {
                    legendre *= (-1);
                }
                [tmpFGInt5 release];
                tmpFGInt3 = [FGInt mod: tmpFGInt1 by: tmpFGInt2];
                [tmpFGInt1 release];
                tmpFGInt1 = tmpFGInt2;
                tmpFGInt2 = tmpFGInt3;
            }
        }
        [tmpFGInt1 release];
        [tmpFGInt2 release];
        [one release];
        [zero release];
        if (*stop) {
            legendre = -1;
        }
        return legendre;
    }
}



/* Compute a square root modulo a prime number
  SquareRoot^2 mod Prime = Square
*/

+(FGInt *) squareRootOf: (FGInt *) fGInt mod: (FGInt *) pFGInt {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *nFGInt = [[FGInt alloc] initWithFGIntBase: 2], 
            *sFGInt = [pFGInt mutableCopy], *bFGInt, *rFGInt, *tmpFGInt, *tmpFGInt1, 
            *tmpFGInt2 = [[FGInt alloc] init], *tempFGInt;
        
    FGIntOverflow a = 0, i, j;

    while ([nFGInt legendreSymbolMod: pFGInt] != -1) {
        [nFGInt increment];
    }
    [sFGInt decrement];
    FGIntBase* sFGIntNumber = [[sFGInt number] mutableBytes];
    while ((sFGIntNumber[0] % 2) == 0) {
        if (sFGIntNumber[0] == 0) {
            a += 32;
            [sFGInt shiftRightBy32];
        } else {
            ++a;
            [sFGInt shiftRight];
        }
        sFGIntNumber = [[sFGInt number] mutableBytes];
    }
    bFGInt = [FGInt raise: nFGInt toThePower: sFGInt montgomeryMod: pFGInt];
    tmpFGInt = [FGInt add: sFGInt and: one];
    [tmpFGInt shiftRight];
    rFGInt = [FGInt raise: fGInt toThePower: tmpFGInt montgomeryMod: pFGInt];
    tmpFGInt1 = [FGInt modularInverse: fGInt mod: pFGInt];
    for ( i = 0; i < a - 1; ++i ) {
        tempFGInt = [FGInt square: rFGInt];
        [tmpFGInt2 release];
        tmpFGInt2 = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
        tempFGInt = [FGInt multiply: tmpFGInt1 and: tmpFGInt2];
        [tmpFGInt release];
        tmpFGInt = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
        for ( j = 0; j < a - i - 2; ++j ) {
            tempFGInt = [FGInt square: tmpFGInt];
            [tmpFGInt release];
            tmpFGInt = [FGInt mod: tempFGInt by: pFGInt];
            [tempFGInt release];
        }
        if ([FGInt compareAbsoluteValueOf: tmpFGInt with: one] != equal) {
            tempFGInt = [FGInt multiply: rFGInt and: bFGInt];
            [rFGInt release];
            rFGInt = [FGInt mod: tempFGInt by: pFGInt];
            [tempFGInt release];
        }
        if (i >= a - 2) {
            break;
        }
        tempFGInt = [FGInt square: bFGInt];
        [bFGInt release];
        bFGInt = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
    }
    [one release];
    [nFGInt release];
    [sFGInt release];
    [bFGInt release];
    [tmpFGInt release];
    [tmpFGInt1 release];
    [tmpFGInt2 release];
    return rFGInt;
}


+(FGInt *) squareRootOf: (FGInt *) fGInt mod: (FGInt *) pFGInt withStop: (BOOL *) stop {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *nFGInt = [[FGInt alloc] initWithFGIntBase: 2], 
            *sFGInt = [pFGInt mutableCopy], *bFGInt, *rFGInt, *tmpFGInt, *tmpFGInt1, 
            *tmpFGInt2 = [[FGInt alloc] init], *tempFGInt;
        
    FGIntOverflow a = 0, i, j;

    while (!(*stop) && ([nFGInt legendreSymbolMod: pFGInt withStop: stop] != -1)) {
        [nFGInt increment];
    }
    [sFGInt decrement];
    FGIntBase* sFGIntNumber = [[sFGInt number] mutableBytes];
    while ((sFGIntNumber[0] % 2) == 0) {
        if (sFGIntNumber[0] == 0) {
            a += 32;
            [sFGInt shiftRightBy32];
        } else {
            ++a;
            [sFGInt shiftRight];
        }
        sFGIntNumber = [[sFGInt number] mutableBytes];
    }
    bFGInt = [FGInt raise: nFGInt toThePower: sFGInt montgomeryMod: pFGInt withStop: stop];
    tmpFGInt = [FGInt add: sFGInt and: one];
    [tmpFGInt shiftRight];
    rFGInt = [FGInt raise: fGInt toThePower: tmpFGInt montgomeryMod: pFGInt withStop: stop];
    tmpFGInt1 = [FGInt modularInverse: fGInt mod: pFGInt];
    for ( i = 0; (i < a - 1) && !(*stop); ++i ) {
        tempFGInt = [FGInt square: rFGInt];
        [tmpFGInt2 release];
        tmpFGInt2 = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
        tempFGInt = [FGInt multiply: tmpFGInt1 and: tmpFGInt2];
        [tmpFGInt release];
        tmpFGInt = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
        for ( j = 0; (j < a - i - 2) && !(*stop); ++j ) {
            tempFGInt = [FGInt square: tmpFGInt];
            [tmpFGInt release];
            tmpFGInt = [FGInt mod: tempFGInt by: pFGInt];
            [tempFGInt release];
        }
        if ([FGInt compareAbsoluteValueOf: tmpFGInt with: one] != equal) {
            tempFGInt = [FGInt multiply: rFGInt and: bFGInt];
            [rFGInt release];
            rFGInt = [FGInt mod: tempFGInt by: pFGInt];
            [tempFGInt release];
        }
        if (i >= a - 2) {
            break;
        }
        tempFGInt = [FGInt square: bFGInt];
        [bFGInt release];
        bFGInt = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
    }
    [one release];
    [nFGInt release];
    [sFGInt release];
    [bFGInt release];
    [tmpFGInt release];
    [tmpFGInt1 release];
    [tmpFGInt2 release];
    if (*stop) {
        [rFGInt release];
        rFGInt = nil;
    }
    return rFGInt;
}


/* Compute and return self! = self * (self - 1) * (self - 2) * ... * 3 * 2 * 1 */

-(FGInt *) factorial {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *result = [[FGInt alloc] initWithFGIntBase: 1], 
        *tmpFGInt = [self mutableCopy], *tmpFGInt1;
    while ([FGInt compareAbsoluteValueOf: tmpFGInt with: one] == larger) {
        tmpFGInt1 = [FGInt multiply: result and: tmpFGInt];
        [result release];
        result = tmpFGInt1;
        [tmpFGInt subtractWith: one];
    }
    return result;
}



/* Searches for a nearest prime number p larger than the number self is initialized with */

//-(FGInt *) findNearestLargerPrime {
//    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2], *prime = [self mutableCopy];
//    if (([[[prime number] objectAtIndex: 0] digit] % 2) == 0)
//        [[[prime number] objectAtIndex: 0] setDigit: [[[prime number] objectAtIndex: 0] digit] + 1];
//    while (![prime primalityTest: 5])
//        [prime addWith: two];
//    [two release];
//    return prime;
//}


-(void) findNearestLargerPrime {
    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2];
    FGIntBase* numberArray = [number mutableBytes];

    if ((numberArray[0] % 2) == 0) {
        numberArray[0] = numberArray[0] + 1;
    } else {
            [self addWith: two];
    }
    while (![self primalityTest: 5]) {
        [self addWith: two];
    }
    [two release];
}


-(void) findLargerPrime {
    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2];

    FGInt *start = [self mutableCopy];
    if ([start isEven]) {
        [start increment];
    }
    FGInt *gapIncrement = [[FGInt alloc] initWithFGIntBase: 1];
    [gapIncrement shiftLeftBy: [start bitSize] / 2];
    FGInt *gap = [[FGInt alloc] initAsZero];

    NSUInteger b = [[NSProcessInfo processInfo] activeProcessorCount];
    NSMutableArray *candidates = [[NSMutableArray alloc] init];
    __block BOOL found = NO;
    __block FGInt *prime = nil;

    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for ( int i = 0; i < b; ++i ) {
        [candidates addObject: [FGInt add: start and: gap]];
        [gap addWith: gapIncrement];
        dispatch_group_async(d_group, bg_queue, ^{
            FGInt *primeCandidate = [candidates objectAtIndex: i];
            while (!found) {
                BOOL isPrime = [primeCandidate primalityTest: 5 withStop: &found];
                if (!isPrime) {
                    [primeCandidate addWith: two];
                } else {
                    found = YES;
                    prime = primeCandidate;
                }
            }
        });
    }
    dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    dispatch_release(d_group);

    [number release];
    number = [[prime number] mutableCopy];

    [candidates release];
    [gap release];
    [gapIncrement release];
    [start release];
    [two release];
}


-(void) findNearestLargerPrimeWithRabinMillerTests: (FGIntBase) numberOfTests {
    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2];
    FGIntBase* numberArray = [number mutableBytes];

    if ((numberArray[0] % 2) == 0) {
        numberArray[0] = numberArray[0] + 1;
    } else {
            [self addWith: two];
    }
    while (![self primalityTest: numberOfTests]) {
        [self addWith: two];
    }
    [two release];
}

-(void) findLargerPrimeWithRabinMillerTests: (FGIntBase) numberOfTests {
    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2];

    FGInt *start = [self mutableCopy];
    if ([start isEven]) {
        [start increment];
    }
    FGInt *gapIncrement = [[FGInt alloc] initWithFGIntBase: 1];
    [gapIncrement shiftLeftBy: [start bitSize] / 2];
    FGInt *gap = [[FGInt alloc] initAsZero];

    NSUInteger b = [[NSProcessInfo processInfo] activeProcessorCount];
    NSMutableArray *candidates = [[NSMutableArray alloc] init];
    __block BOOL found = NO;
    __block FGInt *prime = nil;

    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for ( int i = 0; i < b; ++i ) {
        [candidates addObject: [FGInt add: start and: gap]];
        [gap addWith: gapIncrement];
        dispatch_group_async(d_group, bg_queue, ^{
            FGInt *primeCandidate = [candidates objectAtIndex: i];
            while (!found) {
                BOOL isPrime = [primeCandidate primalityTest: numberOfTests withStop: &found];
                if (!isPrime) {
                    [primeCandidate addWith: two];
                } else {
                    found = YES;
                    prime = primeCandidate;
                }
            }
        });
    }
    dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    dispatch_release(d_group);

    [number release];
    number = [[prime number] mutableCopy];

    [candidates release];
    [gap release];
    [gapIncrement release];
    [start release];
    [two release];
}

// /* Searches for a nearest prime number p larger than self, such that (p mod q = 1), make sure qFGInt is a prime number */

//-(FGInt *) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt {
//    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2], *one = [[FGInt alloc] initWithFGIntBase: 1], 
//        *prime = [self mutableCopy], *doubleQ = [qFGInt mutableCopy], *tmpFGInt;
//    [doubleQ shiftRight];
//    tmpFGInt = [FGInt mod: prime by: qFGInt];
//    [prime addWith: tmpFGInt];
//    [tmpFGInt release];
//    [prime addWith: one];
//    [one release];
//    if (([[[prime number] objectAtIndex: 0] digit] % 2) == 0)
//        [prime addWith: qFGInt];
//    while (![prime primalityTest: 5])
//        [prime addWith: doubleQ];
//    [two release];
//    [doubleQ release];
//    return prime;
//}

-(void) findLargerDSAPrimeWith: (FGInt *) qFGInt {
    FGInt *doubleQ = [qFGInt mutableCopy], *tmpFGInt;
    [doubleQ shiftLeft];
    FGInt *start = [self mutableCopy];
    tmpFGInt = [FGInt mod: start by: qFGInt];
    [start subtractWith: tmpFGInt];
    [tmpFGInt release];
    [start increment];
    FGIntBase* numberArray = [[start number] mutableBytes];
    if ((numberArray[0] % 2) == 0) {
        [start addWith: qFGInt];
    }

    FGInt *gapIncrement = [qFGInt mutableCopy];
    [gapIncrement shiftLeftBy: [self bitSize]/2 - [qFGInt bitSize]];
    FGInt *gap = [[FGInt alloc] initAsZero];

    NSUInteger b = [[NSProcessInfo processInfo] activeProcessorCount];
    NSMutableArray *candidates = [[NSMutableArray alloc] init];
    __block BOOL found = NO;
    __block FGInt *prime = nil;

    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for ( int i = 0; i < b; ++i ) {
        [candidates addObject: [FGInt add: start and: gap]];
        [gap addWith: gapIncrement];
        dispatch_group_async(d_group, bg_queue, ^{
            FGInt *primeCandidate = [candidates objectAtIndex: i];
            while (!found) {
                BOOL isPrime = [primeCandidate primalityTest: 5 withStop: &found];
                if (!isPrime) {
                    [primeCandidate addWith: doubleQ];
                } else {
                    found = YES;
                    prime = primeCandidate;
                }
            }
        });
    }
    dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    dispatch_release(d_group);

    [number release];
    number = [[prime number] mutableCopy];

    [candidates release];
    [gap release];
    [gapIncrement release];
    [start release];
    [doubleQ release];
}


-(void) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt {
    FGInt *doubleQ = [qFGInt mutableCopy], *tmpFGInt;
    [doubleQ shiftLeft];
    tmpFGInt = [FGInt mod: self by: qFGInt];
    [self subtractWith: tmpFGInt];
    [tmpFGInt release];
    [self increment];
    FGIntBase* numberArray = [number mutableBytes];
    if ((numberArray[0] % 2) == 0) {
        [self addWith: qFGInt];
    }
    while (![self primalityTest: 5]) {
        [self addWith: doubleQ];
    }
    [doubleQ release];
}


/* Tests whether nFGInt is smooth wrt to primes and has a prime factor of at least 
    leastSize bits, which it returns. If not it returns nil.
*/

-(FGInt *) isNearlyPrimeAndAtLeast: (FGIntOverflow) leastSize {
    FGInt *rFGInt = [self mutableCopy];
    FGIntBase* rNumber = [[rFGInt number] mutableBytes];
    while ((rNumber[0] % 2) == 0) {
        if (rNumber[0] == 0) {
            [rFGInt shiftRightBy32];
        } else {
            [rFGInt shiftRight];
        }
        rNumber = [[rFGInt number] mutableBytes];
    }
    for ( FGIntBase i = 0; i < 1228; ++i ) {
        while ([rFGInt modFGIntByInt: primes[i]] == 0) {
            [rFGInt divideByInt: primes[i]];
        }
    }
    FGIntOverflow bitSize = [rFGInt bitSize];
    if (bitSize < leastSize) {
        [rFGInt release];
        return nil;
    }
    FGIntBase rmTests = 4;
    if (bitSize < 460) {
        rmTests = 7;
    }
    if (bitSize < 300) {
        rmTests = 13;
    }
    if (bitSize < 260) {
        rmTests = 19;
    }
    if (bitSize < 200) {
        rmTests = 29;
    }
    if (bitSize < 160) {
        rmTests = 37;
    }
    if ([rFGInt rabinMillerTest: rmTests]) {
        return rFGInt;
    }
    else {
        [rFGInt release];
        return nil;
    }
}



/* Convert NSData to a base64 NSString
*/

+(NSString *) convertNSDataToBase64: (NSData *) nsData {
    if (!nsData) {
        NSLog(@"No nsData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    @autoreleasepool{
        FGIntOverflow i;
        NSMutableString *string = [[NSMutableString alloc] init];
    
        unsigned char aBuffer[3];
        NSRange bytesRange;
        
        for ( i = 0; i < ([nsData length] / 3); ++i ) {
            bytesRange = NSMakeRange(i*3, 3);
            [nsData getBytes: aBuffer range: bytesRange];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[0] >> 2] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[0] & 3) << 4) | (aBuffer[1] >> 4)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[1] & 15) << 2) | (aBuffer[2] >> 6)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[2] & 63] length: 1]];
        }
        if (([nsData length] % 3) == 1) {
            bytesRange = NSMakeRange(3*([nsData length]/3), [nsData length] % 3);
            [nsData getBytes: aBuffer range: bytesRange];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[0] >> 2] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[0] & 3) << 4)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[64] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[64] length: 1]];
        }
        if (([nsData length] % 3) == 2) {
            bytesRange = NSMakeRange(3*([nsData length]/3), [nsData length] % 3);
            [nsData getBytes: aBuffer range: bytesRange];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[0] >> 2] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[0] & 3) << 4) | (aBuffer[1] >> 4)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[1] & 15) << 2)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[64] length: 1]];
        }
        return string;
    }
}


/* Convert an NSString to a base64 NSString
*/

+(NSString *) convertNSStringToBase64: (NSString *) nsString {
    if (!nsString) {
        NSLog(@"No nsString available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    return [FGInt convertNSDataToBase64: [nsString dataUsingEncoding:NSUTF8StringEncoding]];
}


+(int) getBase64Index: (char) base64Char {
    if (base64Char == 43) {
        return 62;
    }
    if (base64Char == 47) {
        return 63;
    }
    if (base64Char < 58) {
        return (base64Char - 48) + 52;
    }
    if (base64Char == 61) {
        return 0;
    }
    if (base64Char < 91) {
        return (base64Char - 65);
    }
    if (base64Char < 123) {
        return (base64Char - 97) + 26;
    }
    return 0;
}


/* Convert a base64 NSString to NSData (binary data)
*/

+(NSData *) convertBase64ToNSData: (NSString *) base64String {
    if (!base64String) {
        NSLog(@"No base64String available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    @autoreleasepool{
        FGIntOverflow i;
        FGIntBase j, all24Bits;
        NSMutableData *nsData = [[NSMutableData alloc] init];
    
        unsigned char aBuffer[3];
        unsigned char a64Buffer[4];
        NSRange bytesRange;
        NSData *stringBytes=[base64String dataUsingEncoding: NSASCIIStringEncoding];

        for ( i = 0; i < ([stringBytes length] / 4); ++i ) {
            bytesRange = NSMakeRange(i*4, 4);
            [stringBytes getBytes: a64Buffer range: bytesRange];
            all24Bits = 0;
            for ( j = 0; j < 4; ++j ) {
                all24Bits = (all24Bits << 6) | [FGInt getBase64Index: a64Buffer[j]];
            }
            for ( j = 0; j < 3; ++j ) {
                aBuffer[j] = (all24Bits >> ((2-j)*8)) & 255;
            }
            [nsData appendBytes: aBuffer length: 3];
        }
        if (a64Buffer[3] == 61) {
            [nsData setLength: [nsData length] - 1];
            if (a64Buffer[2] == 61) {
                [nsData setLength: [nsData length] - 1];
            }
        }

        return nsData;
    }
}


/* Convert a base64 NSString to NSString
   This is tricky, it expects the outcome to be UTF8 encoded
*/

+(NSString *) convertBase64ToNSString: (NSString *) base64String {
    if (!base64String) {
        NSLog(@"No base64String available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    return [[NSString alloc] initWithData: [FGInt convertBase64ToNSData: base64String] encoding: NSUTF8StringEncoding];
}



-(FGIntOverflow) bitSize {
    FGIntOverflow length = [number length]/4, bits = (length - 1) * 32;
    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase lastDigit = numberArray[length - 1];
    while ((lastDigit == 0) && (length > 1)) {
        --length;
        lastDigit = numberArray[length - 1];
        bits -= 32;
    }
    while (lastDigit != 0) {
        ++bits;
        lastDigit >>= 1;
    }
    if (bits == 0) {
        bits = 1;
    }
    return bits;
}

-(FGIntOverflow) byteSize {
    FGIntOverflow byteLength = [number length];
    unsigned char* numberBytes = [number mutableBytes];
    while ((numberBytes[byteLength - 1] == 0) && (byteLength > 1)) {
        --byteLength;
    }
    if (byteLength == 0) {
        byteLength = 1;
    }
    return byteLength;
}








-(FGInt *) modNISTP192 {
    FGInt *p192FGInt = [[FGInt alloc] initWithoutNumber];
    unsigned char p192BytesArray[] = p192Bytes; 
    [p192FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p192BytesArray length: 24 freeWhenDone: NO]];

    FGIntBase* numberArray; 
    
    FGIntOverflow length = [number length]/4;
    [number setLength: 12*4];
    numberArray = [number mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 7]; 

    FGIntBase mod = 0;
    FGIntOverflow tmpMod;
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    tmpMod = (FGIntOverflow) numberArray[0] + numberArray[6] + numberArray[10];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[1] + numberArray[7] + numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[2] + numberArray[6] + numberArray[8] + numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[3] + numberArray[7] + numberArray[9] + numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[4] + numberArray[8] + numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[5] + numberArray[9] + numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    if (mod != 0) {
        tmpNumber[6] = mod;
    } else {
        [[result number] setLength: 24];
    }

    while ([FGInt compareAbsoluteValueOf: result with: p192FGInt] != smaller) {
        [result subtractWith: p192FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [FGInt subtract: p192FGInt and: result]; 
        [result release];
        result = tmpFGInt;
    }
    [p192FGInt release];

    return result;
}


-(FGInt *) modNISTP192: (FGInt *) p192FGInt {
    FGIntBase* numberArray; 
    
    FGIntOverflow length = [number length]/4;
    [number setLength: 12*4];
    numberArray = [number mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 7]; 

    FGIntBase mod = 0;
    FGIntOverflow tmpMod;
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    tmpMod = (FGIntOverflow) numberArray[0] + numberArray[6] + numberArray[10];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[1] + numberArray[7] + numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[2] + numberArray[6] + numberArray[8] + numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[3] + numberArray[7] + numberArray[9] + numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[4] + numberArray[8] + numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntOverflow) numberArray[5] + numberArray[9] + numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    if (mod != 0) {
        tmpNumber[6] = mod;
    } else {
        [[result number] setLength: 24];
    }

    while ([FGInt compareAbsoluteValueOf: result with: p192FGInt] != smaller) {
        [result subtractWith: p192FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [FGInt subtract: p192FGInt and: result]; 
        [result release];
        result = tmpFGInt;
    }

    return result;
}


-(FGInt *) modNISTP224 {
    FGInt *p224FGInt = [[FGInt alloc] initWithoutNumber];
    unsigned char p224BytesArray[] = p224Bytes; 
    [p224FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p224BytesArray length: 28 freeWhenDone: NO]];

    FGIntOverflow length = [number length]/4;
    [number setLength: 14*4];
    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* p224NumberArray = [[p224FGInt number] mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    FGIntIndex mod, tmpMod;

    tmpMod = (FGIntIndex) numberArray[0] + p224NumberArray[0] - numberArray[7] - numberArray[11];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[1] + p224NumberArray[1] - numberArray[8] - numberArray[12] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[2] + p224NumberArray[2] - numberArray[9] - numberArray[13] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[3] + numberArray[7] + numberArray[11] + p224NumberArray[3] - numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[4] + numberArray[8] + numberArray[12] + p224NumberArray[4] - numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[5] + numberArray[9] + numberArray[13] + p224NumberArray[5] - numberArray[12] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[6] + numberArray[10] + p224NumberArray[6] - numberArray[13] + mod;
    mod = tmpMod >> 32;
    tmpNumber[6] = (FGIntBase) tmpMod;
    if (mod != 0) {
        tmpNumber[7] = (FGIntBase) mod;
    } else {
        [[result number] setLength: 28];
    }

    while ([FGInt compareAbsoluteValueOf: result with: p224FGInt] != smaller) {
        [result subtractWith: p224FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [p224FGInt mutableCopy];
        [tmpFGInt subtractWith: result];
        [result release];
        result = tmpFGInt;
    }

    [p224FGInt release];

    return result;
}

-(FGInt *) modNISTP224: (FGInt *) p224FGInt {
    FGIntOverflow length = [number length]/4;
    [number setLength: 14*4];
    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* p224NumberArray = [[p224FGInt number] mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    FGIntIndex mod, tmpMod;

    tmpMod = (FGIntIndex) numberArray[0] + p224NumberArray[0] - numberArray[7] - numberArray[11];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[1] + p224NumberArray[1] - numberArray[8] - numberArray[12] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[2] + p224NumberArray[2] - numberArray[9] - numberArray[13] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[3] + numberArray[7] + numberArray[11] + p224NumberArray[3] - numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[4] + numberArray[8] + numberArray[12] + p224NumberArray[4] - numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[5] + numberArray[9] + numberArray[13] + p224NumberArray[5] - numberArray[12] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) numberArray[6] + numberArray[10] + p224NumberArray[6] - numberArray[13] + mod;
    mod = tmpMod >> 32;
    tmpNumber[6] = (FGIntBase) tmpMod;
    if (mod != 0) {
        tmpNumber[7] = (FGIntBase) mod;
    } else {
        [[result number] setLength: 28];
    }

    while ([FGInt compareAbsoluteValueOf: result with: p224FGInt] != smaller) {
        [result subtractWith: p224FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [p224FGInt mutableCopy];
        [tmpFGInt subtractWith: result];
        [result release];
        result = tmpFGInt;
    }

    return result;
}


-(FGInt *) modNISTP256 {
    FGInt *p256FGInt = [[FGInt alloc] initWithoutNumber];
    unsigned char p256BytesArray[] = p256Bytes; 
    [p256FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p256BytesArray length: 32 freeWhenDone: NO]];

    FGIntOverflow length = [number length]/4;
    [number setLength: 16*4];
    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* p256NumberArray = [[p256FGInt number] mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 9];
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    FGIntIndex mod, tmpMod;

    tmpMod = (FGIntIndex) 6*p256NumberArray[0] + numberArray[0] + numberArray[8] + numberArray[9] - numberArray[11] - numberArray[12] - numberArray[13] - numberArray[14];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[1] + numberArray[1] + numberArray[9] + numberArray[10] - numberArray[12] - numberArray[13] - numberArray[14] - numberArray[15] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[2] + numberArray[2] + numberArray[10] + numberArray[11] - numberArray[13] - numberArray[14] - numberArray[15] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[3] + numberArray[3] + numberArray[11] + numberArray[11] + numberArray[12] + numberArray[12] + numberArray[13] - numberArray[15] - numberArray[8] - numberArray[9] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[4] + numberArray[4] + numberArray[12] + numberArray[12] + numberArray[13] + numberArray[13] + numberArray[14] - numberArray[9] - numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[5] + numberArray[5] + numberArray[13] + numberArray[13] + numberArray[14] + numberArray[14] + numberArray[15] - numberArray[10] - numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[6] + numberArray[6] + numberArray[14] + numberArray[14] + numberArray[15] + numberArray[15] + numberArray[14] + numberArray[13] - numberArray[8] - numberArray[9] + mod;
    mod = tmpMod >> 32;
    tmpNumber[6] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[7] + numberArray[7] + numberArray[15] + numberArray[15] + numberArray[15] + numberArray[8] - numberArray[10] - numberArray[11] - numberArray[12] - numberArray[13] + mod;
    mod = tmpMod >> 32;
    tmpNumber[7] = (FGIntBase) tmpMod;

    tmpNumber[8] = (FGIntBase) mod;
    FGIntBase t = 9;
    while ((t > 1) && (tmpNumber[t - 1] == 0)) {
        --t;
    }
    if (t < 9) {
        [[result number] setLength: 4*t];
    }


    while ([FGInt compareAbsoluteValueOf: result with: p256FGInt] != smaller) {
        [result subtractWith: p256FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [p256FGInt mutableCopy];
        [tmpFGInt subtractWith: result];
        [result release];
        result = tmpFGInt;
    } 

    [p256FGInt release];

    return result;
}


-(FGInt *) modNISTP256: (FGInt *) p256FGInt {
    FGIntOverflow length = [number length]/4;
    [number setLength: 16*4];
    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* p256NumberArray = [[p256FGInt number] mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 9];
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    FGIntIndex mod, tmpMod;

    tmpMod = (FGIntIndex) 6*p256NumberArray[0] + numberArray[0] + numberArray[8] + numberArray[9] - numberArray[11] - numberArray[12] - numberArray[13] - numberArray[14];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[1] + numberArray[1] + numberArray[9] + numberArray[10] - numberArray[12] - numberArray[13] - numberArray[14] - numberArray[15] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[2] + numberArray[2] + numberArray[10] + numberArray[11] - numberArray[13] - numberArray[14] - numberArray[15] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[3] + numberArray[3] + numberArray[11] + numberArray[11] + numberArray[12] + numberArray[12] + numberArray[13] - numberArray[15] - numberArray[8] - numberArray[9] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[4] + numberArray[4] + numberArray[12] + numberArray[12] + numberArray[13] + numberArray[13] + numberArray[14] - numberArray[9] - numberArray[10] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[5] + numberArray[5] + numberArray[13] + numberArray[13] + numberArray[14] + numberArray[14] + numberArray[15] - numberArray[10] - numberArray[11] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[6] + numberArray[6] + numberArray[14] + numberArray[14] + numberArray[15] + numberArray[15] + numberArray[14] + numberArray[13] - numberArray[8] - numberArray[9] + mod;
    mod = tmpMod >> 32;
    tmpNumber[6] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) 6*p256NumberArray[7] + numberArray[7] + numberArray[15] + numberArray[15] + numberArray[15] + numberArray[8] - numberArray[10] - numberArray[11] - numberArray[12] - numberArray[13] + mod;
    mod = tmpMod >> 32;
    tmpNumber[7] = (FGIntBase) tmpMod;

    tmpNumber[8] = (FGIntBase) mod;
    FGIntBase t = 9;
    while ((t > 1) && (tmpNumber[t - 1] == 0)) {
        --t;
    }
    if (t < 9) {
        [[result number] setLength: 4*t];
    }


    while ([FGInt compareAbsoluteValueOf: result with: p256FGInt] != smaller) {
        [result subtractWith: p256FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [p256FGInt mutableCopy];
        [tmpFGInt subtractWith: result];
        [result release];
        result = tmpFGInt;
    } 

    return result;
}



-(FGInt *) modNISTP384 {
    FGInt *p384FGInt = [[FGInt alloc] initWithoutNumber];
    unsigned char p384BytesArray[] = p384Bytes; 
    [p384FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p384BytesArray length: 48 freeWhenDone: NO]];

    FGIntOverflow length = [number length]/4;
    [number setLength: 24*4];
    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* p384NumberArray = [[p384FGInt number] mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 13];
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    FGIntIndex mod, tmpMod;

    tmpMod = (FGIntIndex) p384NumberArray[0] + numberArray[0] + numberArray[12] + numberArray[21] + numberArray[20] - numberArray[23];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[1] + numberArray[1] + numberArray[13] + numberArray[22] + numberArray[23] - numberArray[12] - numberArray[20] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[2] + numberArray[2] + numberArray[14] + numberArray[23] - numberArray[13] - numberArray[21] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[3] + numberArray[3] + numberArray[15] + numberArray[12] + numberArray[20] + numberArray[21] - numberArray[14] - numberArray[22] - numberArray[23] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[4] + numberArray[4] + numberArray[21] + numberArray[21] + numberArray[16] + numberArray[13] + numberArray[12] + numberArray[20] + numberArray[22] - numberArray[15] - numberArray[23] - numberArray[23] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[5] + numberArray[5] + numberArray[22] +numberArray[22] + numberArray[17] + numberArray[14] + numberArray[13] + numberArray[21] + numberArray[23] - numberArray[16] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[6] + numberArray[6] + numberArray[23] +numberArray[23] + numberArray[18] + numberArray[15] + numberArray[14] + numberArray[22] - numberArray[17] + mod;
    mod = tmpMod >> 32;
    tmpNumber[6] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[7] + numberArray[7] + numberArray[19] + numberArray[16] + numberArray[15] + numberArray[23] - numberArray[18] + mod;
    mod = tmpMod >> 32;
    tmpNumber[7] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[8] + numberArray[8] + numberArray[20] +numberArray[17] + numberArray[16] - numberArray[19] + mod;
    mod = tmpMod >> 32;
    tmpNumber[8] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[9] + numberArray[9] + numberArray[21] +numberArray[18] + numberArray[17] - numberArray[20] + mod;
    mod = tmpMod >> 32;
    tmpNumber[9] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[10] + numberArray[10] + numberArray[22] +numberArray[19] + numberArray[18] - numberArray[21] + mod;
    mod = tmpMod >> 32;
    tmpNumber[10] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[11] + numberArray[11] + numberArray[23] +numberArray[20] + numberArray[19] - numberArray[22] + mod;
    mod = tmpMod >> 32;
    tmpNumber[11] = (FGIntBase) tmpMod;
    tmpNumber[12] = (FGIntBase) mod;
    FGIntBase t = 13;
    while ((t > 1) && (tmpNumber[t - 1] == 0)) {
        --t;
    }
    if (t < 13) {
        [[result number] setLength: 4*t];
    }

    while ([FGInt compareAbsoluteValueOf: result with: p384FGInt] != smaller) {
        [result subtractWith: p384FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [p384FGInt mutableCopy];
        [tmpFGInt subtractWith: result];
        [result release];
        result = tmpFGInt;
    } 

    [p384FGInt release];

    return result;
}


-(FGInt *) modNISTP384: (FGInt *) p384FGInt {
    FGIntOverflow length = [number length]/4;
    [number setLength: 24*4];
    FGIntBase* numberArray = [number mutableBytes];
    FGIntBase* p384NumberArray = [[p384FGInt number] mutableBytes];
    FGInt *result = [[FGInt alloc] initWithNZeroes: 13];
    FGIntBase* tmpNumber = [[result number] mutableBytes];
    FGIntIndex mod, tmpMod;

    tmpMod = (FGIntIndex) p384NumberArray[0] + numberArray[0] + numberArray[12] + numberArray[21] + numberArray[20] - numberArray[23];
    mod = tmpMod >> 32;
    tmpNumber[0] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[1] + numberArray[1] + numberArray[13] + numberArray[22] + numberArray[23] - numberArray[12] - numberArray[20] + mod;
    mod = tmpMod >> 32;
    tmpNumber[1] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[2] + numberArray[2] + numberArray[14] + numberArray[23] - numberArray[13] - numberArray[21] + mod;
    mod = tmpMod >> 32;
    tmpNumber[2] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[3] + numberArray[3] + numberArray[15] + numberArray[12] + numberArray[20] + numberArray[21] - numberArray[14] - numberArray[22] - numberArray[23] + mod;
    mod = tmpMod >> 32;
    tmpNumber[3] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[4] + numberArray[4] + numberArray[21] + numberArray[21] + numberArray[16] + numberArray[13] + numberArray[12] + numberArray[20] + numberArray[22] - numberArray[15] - numberArray[23] - numberArray[23] + mod;
    mod = tmpMod >> 32;
    tmpNumber[4] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[5] + numberArray[5] + numberArray[22] +numberArray[22] + numberArray[17] + numberArray[14] + numberArray[13] + numberArray[21] + numberArray[23] - numberArray[16] + mod;
    mod = tmpMod >> 32;
    tmpNumber[5] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[6] + numberArray[6] + numberArray[23] +numberArray[23] + numberArray[18] + numberArray[15] + numberArray[14] + numberArray[22] - numberArray[17] + mod;
    mod = tmpMod >> 32;
    tmpNumber[6] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[7] + numberArray[7] + numberArray[19] + numberArray[16] + numberArray[15] + numberArray[23] - numberArray[18] + mod;
    mod = tmpMod >> 32;
    tmpNumber[7] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[8] + numberArray[8] + numberArray[20] +numberArray[17] + numberArray[16] - numberArray[19] + mod;
    mod = tmpMod >> 32;
    tmpNumber[8] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[9] + numberArray[9] + numberArray[21] +numberArray[18] + numberArray[17] - numberArray[20] + mod;
    mod = tmpMod >> 32;
    tmpNumber[9] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[10] + numberArray[10] + numberArray[22] +numberArray[19] + numberArray[18] - numberArray[21] + mod;
    mod = tmpMod >> 32;
    tmpNumber[10] = (FGIntBase) tmpMod;
    tmpMod = (FGIntIndex) p384NumberArray[11] + numberArray[11] + numberArray[23] +numberArray[20] + numberArray[19] - numberArray[22] + mod;
    mod = tmpMod >> 32;
    tmpNumber[11] = (FGIntBase) tmpMod;
    tmpNumber[12] = (FGIntBase) mod;
    FGIntBase t = 13;
    while ((t > 1) && (tmpNumber[t - 1] == 0)) {
        --t;
    }
    if (t < 13) {
        [[result number] setLength: 4*t];
    }

    while ([FGInt compareAbsoluteValueOf: result with: p384FGInt] != smaller) {
        [result subtractWith: p384FGInt];
    }

    if (length < [number length]/4) {
        [number setLength: length*4];
    }

    if (!sign) {
        FGInt *tmpFGInt = [p384FGInt mutableCopy];
        [tmpFGInt subtractWith: result];
        [result release];
        result = tmpFGInt;
    } 

    return result;
}


-(FGInt *) modNISTP521 {
    FGInt *s1, *s2;
    FGIntOverflow bitSize = [self bitSize];
    FGInt *p521FGInt = nil;

    if (bitSize < 522) {
        if (!sign) {
            p521FGInt = [[FGInt alloc] initWithoutNumber];
            unsigned char p521BytesArray[] = p521Bytes; 
            [p521FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p521BytesArray length: 68 freeWhenDone: NO]];
            FGInt *tmpFGInt = [FGInt add: self and: p521FGInt];
            [p521FGInt release];
            return tmpFGInt;
        } 
        return [self mutableCopy];
    }

    s1 = [[FGInt alloc] initWithNZeroes: 17];
    [number getBytes: [[s1 number] mutableBytes] range: NSMakeRange(0, 66)];
    unsigned char* numberArray = [[s1 number] mutableBytes];
    numberArray[65] = numberArray[65] & 1;

    s2 = [[FGInt alloc] initWithNZeroes: (bitSize - 521 + 32)/32];
    [number getBytes: [[s2 number] mutableBytes] range: NSMakeRange(65, (bitSize - 521 + 8)/8)];
    [s2 shiftRight];

    [s1 addWith: s2];
    [s2 release];

    unsigned char* numberBytes = [[s1 number] mutableBytes];
    if (numberBytes[65] == 1) {
        for ( int i = 0; i < 65; i++ ) {
            if (numberBytes[i] != 255) {
                if (!sign) {
                    p521FGInt = [[FGInt alloc] initWithoutNumber];
                    unsigned char p521BytesArray[] = p521Bytes; 
                    [p521FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p521BytesArray length: 68 freeWhenDone: NO]];
                    s2 = [FGInt subtract: p521FGInt and: s1];
                    [s1 release];
                    s1 = s2;
                } 
                return s1;
            }
        }
        [s1 release];
        return [[FGInt alloc] initWithFGIntBase: 0];
    }
    if (numberBytes[65] > 1) {
        p521FGInt = [[FGInt alloc] initWithoutNumber];
        unsigned char p521BytesArray[] = p521Bytes; 
        [p521FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p521BytesArray length: 68 freeWhenDone: NO]];
        [s1 subtractWith: p521FGInt];
    }

    if (!sign) {
        if (p521FGInt == nil) {
            p521FGInt = [[FGInt alloc] initWithoutNumber];
            unsigned char p521BytesArray[] = p521Bytes; 
            [p521FGInt setNumber: [[NSMutableData alloc] initWithBytesNoCopy: &p521BytesArray length: 68 freeWhenDone: NO]];
        }
        s2 = [FGInt subtract: p521FGInt and: s1];
        [s1 release];
        s1 = s2;
    } 

    if (p521FGInt != nil) {
        [p521FGInt release];
    }

    return s1;
}

-(FGInt *) modNISTP521: (FGInt *) p521FGInt {
    FGInt *s1, *s2;
    FGIntOverflow bitSize = [self bitSize];

    if (bitSize < 522) {
        if (!sign) {
            return [FGInt add: self and: p521FGInt];
        } 
        return [self mutableCopy];
    }

    s1 = [[FGInt alloc] initWithNZeroes: 17];
    [number getBytes: [[s1 number] mutableBytes] range: NSMakeRange(0, 66)];
    unsigned char* numberArray = [[s1 number] mutableBytes];
    numberArray[65] = numberArray[65] & 1;

    s2 = [[FGInt alloc] initWithNZeroes: (bitSize - 521 + 32)/32];
    [number getBytes: [[s2 number] mutableBytes] range: NSMakeRange(65, (bitSize - 521 + 8)/8)];
    [s2 shiftRight];

    [s1 addWith: s2];
    [s2 release];

    unsigned char* numberBytes = [[s1 number] mutableBytes];
    if (numberBytes[65] == 1) {
        for ( int i = 0; i < 65; i++ ) {
            if (numberBytes[i] != 255) {
                if (!sign) {
                    s2 = [FGInt subtract: p521FGInt and: s1];
                    [s1 release];
                    s1 = s2;
                } 
                return s1;
            }
        }
        [s1 release];
        return [[FGInt alloc] initWithFGIntBase: 0];
    }
    if (numberBytes[65] > 1) {
        [s1 subtractWith: p521FGInt];
    }

    if (!sign) {
        s2 = [FGInt subtract: p521FGInt and: s1];
        [s1 release];
        s1 = s2;
    } 

    return s1;
}


-(FGInt *) modNISTprime: (FGInt *) nistFGInt andTag: (tag) nistTag {
    NSAssert((nistTag == p192) || ( nistTag == p224) || ( nistTag == p256) || ( nistTag == p384) || ( nistTag == p521), @"Tag for NIST prime not recognized, received tag %i", nistTag);
    switch (nistTag) {
        case p192: 
            return [self modNISTP192: nistFGInt];
            break;
        case p224: 
            return [self modNISTP224: nistFGInt];
            break;
        case p256: 
            return [self modNISTP256: nistFGInt];
            break;
        case p384: 
            return [self modNISTP384: nistFGInt];
            break;
        case p521: 
            return [self modNISTP521: nistFGInt];
            break;
        default:
            return [FGInt mod: self by: nistFGInt];
            break;
    }
}



// /* add fGInt1 with fGInt2, they're both expected to be 256 bit or less */


+(FGInt *) addModulo25638: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = MIN(9 ,[[fGInt1 number] length] / 4), length2 = MIN(9, [[fGInt2 number] length] / 4), sumLength;
    FGIntIndex i;

    FGInt *sum = [[FGInt alloc] initWithNZeroes: 9];
    FGIntBase* sumNumber = [[sum number] mutableBytes];
    FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];
    FGIntOverflow tmpMod, mod = 0;

    for ( i = 0; i < MIN(length1, length2); i++ ) {
        tmpMod = (FGIntOverflow) fGInt1Number[i] + fGInt2Number[i] + mod;
        sumNumber[i] = (FGIntBase) tmpMod;
        mod = tmpMod >> 32;
    }
    for ( i = length2; i < length1; ++i ) {
        tmpMod = (FGIntOverflow) fGInt1Number[i] + mod;
        sumNumber[i] = (FGIntBase) tmpMod;
        mod = tmpMod >> 32;
    }
    for ( i = length1; i < length2; ++i ) {
        tmpMod = (FGIntOverflow) fGInt2Number[i] + mod;
        sumNumber[i] = (FGIntBase) tmpMod;
        mod = tmpMod >> 32;
    }
    sumNumber[MAX(length1, length2)] = (FGIntBase) mod;

    sumLength = 9;
    while ((sumLength > 1) && (sumNumber[sumLength - 1] == 0)) {
        sumLength -= 1;
    }
    if (sumLength < 9) {
        [[sum number] setLength: sumLength*4];
    }

    return sum;
}

/* both inputs must be less than 256 bits */

+(FGInt *) subtractModulo25638: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = MIN(8 ,[[fGInt1 number] length] / 4), length2 = MIN(8, [[fGInt2 number] length] / 4), sumLength;
    FGIntIndex tmpMod, mod = 0, i = 0;

    FGInt *sum = [[FGInt alloc] initWithNZeroes: 9];
    FGIntBase* sumNumber = [[sum number] mutableBytes];
    FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];

    if ([FGInt compareAbsoluteValueOf: fGInt1 with: fGInt2] == smaller) {
        tmpMod = (FGIntIndex) fGInt1Number[0] - fGInt2Number[0] + (4294967295u - 37);
        sumNumber[0] = (FGIntBase) tmpMod;
        mod = tmpMod >> 32;
        for ( i = 1; i < MIN(length1, length2); i++ ) {
            tmpMod = (FGIntIndex) fGInt1Number[i] - fGInt2Number[i] + 4294967295u + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( i = length2; i < length1; ++i ) {
            tmpMod = (FGIntIndex) 4294967295u + fGInt1Number[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( i = length1; i < length2; ++i ) {
            tmpMod = (FGIntIndex) 4294967295u - fGInt2Number[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( i = MAX(length1, length2); i < 8; ++i ) {
            tmpMod = (FGIntIndex) 4294967295u + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        sumNumber[8] = (FGIntBase) mod;
    } else {
        for ( i = 0; i < MIN(length1, length2); i++ ) {
            tmpMod = (FGIntIndex) fGInt1Number[i] - fGInt2Number[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( i = length2; i < length1; ++i ) {
            tmpMod = (FGIntIndex) fGInt1Number[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( i = length1; i < length2; ++i ) {
            tmpMod = (FGIntIndex) fGInt2Number[i] + mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        for ( i = MAX(length1, length2); i < 9; ++i ) {
            if (mod == 0) {
                break;
            }
            tmpMod = (FGIntIndex) mod;
            sumNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        // sumNumber[8] = mod;

    }
    sumLength = 9;
    while ((sumLength > 1) && (sumNumber[sumLength - 1] == 0)) {
        sumLength -= 1;
    }
    if (sumLength < 8) {
        [[sum number] setLength: sumLength*4];
    }

    return sum;
}





/* Multiply 2 FGInts, and return fGInt1 * fGInt2 modulo (2^256 - 38) */

+(FGInt *) multiplyModulo25638: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [[fGInt1 number] length] / 4,
              length2 = [[fGInt2 number] length] / 4,
              productLength = length1 + length2, length;
    FGIntOverflow tmpMod, mod;
    FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];

    FGInt *product = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* productNumber = [[product number] mutableBytes];
    FGInt *tmpFGInt = [[FGInt alloc] initWithNZeroes: productLength];
    FGIntBase* tmpNumber = [[tmpFGInt number] mutableBytes];


    FGIntIndex i, j;
    for( j = 0; j < length2; j++ ) {
        mod = 0;
        for( i = 0; i < length1; i++ ) {
            tmpMod = (FGIntOverflow) fGInt1Number[i] * fGInt2Number[j] + tmpNumber[j + i] + mod;
            tmpNumber[j + i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        tmpNumber[j + length1] = (FGIntBase) mod;
    }

    FGIntOverflow tmpLength = ([[tmpFGInt number] length] >> 2), maxLen;
    while ((tmpNumber[0] != 0) || (tmpLength > 1)) {
        if (tmpLength < 8) {
            maxLen = tmpLength;
        } else {
            maxLen = 8;
        }
        mod = 0;
        for ( i = 0; i < maxLen; i++ ) {
            tmpMod = (FGIntOverflow) productNumber[i] + tmpNumber[i] + mod;
            productNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        i = maxLen & 7;
        while (mod != 0) {
            if ((i & 7) == 0) {
                i = 0;
                mod *= 38;
            }
            tmpMod = (FGIntOverflow) productNumber[i] + mod;
            productNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++i;
        }
        [tmpFGInt shiftRightBy: 256];
        [tmpFGInt multiplyByInt: 38];
        tmpLength = ([[tmpFGInt number] length] >> 2);
        tmpNumber = [[tmpFGInt number] mutableBytes];
    }

    // BOOL lessThan25519;
    // for ( i = 7; i > 0; i-- ) {
    //     lessThan25519 = productNumber[i] < 4294967295u;
    //     if (lessThan25519) {
    //         break;
    //     }
    // }
    // if (!lessThan25519) {
    //     lessThan25519 = productNumber[0] < (4294967295u - 37);
    // }
    // if (!lessThan25519) {
    //     productNumber[0] = (productNumber[0] - (4294967295u - 37));
    //     for ( i = 1; i < 8; i++ ) {
    //         productNumber[i] = 0;
    //     }
    // }

    [tmpFGInt release];

    length = 8;
    while ((length > 1) && (productNumber[length - 1] == 0)) {
        --length;
    }
    if (length < 8) {
        [[product number] setLength: length * 4];
    }

    // [product setSign: [fGInt1 sign] == [fGInt2 sign]];
    
    return product;
}



/* square a FGInt, return fGInt^2 modulo (2^256 - 38) */

+(FGInt *) squareModulo25638: (FGInt *) fGInt {
    FGIntOverflow length1 = [[fGInt number] length]/4, tmpMod, mod, overflow,
              squareLength = 2 * length1, i, j, k, tempInt;
    FGIntBase* fGIntNumber = [[fGInt number] mutableBytes];

    FGInt *square = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* squareNumber = [[square number] mutableBytes];
    FGInt *tmpFGInt = [[FGInt alloc] initWithNZeroes: squareLength];
    FGIntBase* tmpNumber = [[tmpFGInt number] mutableBytes];

    for( FGIntIndex i = 0; i < length1; i++ ) {
        tempInt = fGIntNumber[i];
        tmpMod = (FGIntOverflow) tempInt*tempInt + tmpNumber[2*i];
        tmpNumber[2*i] = (FGIntBase) tmpMod;
        mod = (tmpMod >> 32);
        j = 0;
        for( FGIntIndex j = i + 1; j < length1; j++ ) {
            tmpMod = (FGIntOverflow) tempInt * fGIntNumber[j];
            overflow = tmpMod >> 63;
            tmpMod = (tmpMod << 1) + tmpNumber[i + j] + mod;
            tmpNumber[i + j] = (FGIntBase) tmpMod;
            mod = (overflow << 32) | (tmpMod >> 32);
        }
        k = 0;
        while (mod != 0) {
            tmpMod = (FGIntOverflow) tmpNumber[i + length1 + k] + mod;
            tmpNumber[i + length1 + k] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++k;
        }
    }

    FGIntOverflow tmpLength = ([[tmpFGInt number] length] >> 2), maxLen;
    while ((tmpNumber[0] != 0) || (tmpLength > 1)) {
        if (tmpLength < 8) {
            maxLen = tmpLength;
        } else {
            maxLen = 8;
        }
        mod = 0;
        for ( i = 0; i < maxLen; i++ ) {
            tmpMod = (FGIntOverflow) squareNumber[i] + tmpNumber[i] + mod;
            squareNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        i = maxLen & 7;
        while (mod != 0) {
            if ((i & 7) == 0) {
                i = 0;
                mod *= 38;
            }
            tmpMod = (FGIntOverflow) squareNumber[i] + mod;
            squareNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++i;
        }
        [tmpFGInt shiftRightBy: 256];
        [tmpFGInt multiplyByInt: 38];
        tmpLength = ([[tmpFGInt number] length] >> 2);
        tmpNumber = [[tmpFGInt number] mutableBytes];
    }

    // BOOL lessThan25519;
    // for ( i = 7; i > 0; i-- ) {
    //     lessThan25519 = squareNumber[i] < 4294967295u;
    //     if (lessThan25519) {
    //         break;
    //     }
    // }
    // if (!lessThan25519) {
    //     lessThan25519 = squareNumber[0] < (4294967295u - 37);
    // }
    // if (!lessThan25519) {
    //     squareNumber[0] = (squareNumber[0] - (4294967295u - 37));
    //     for ( i = 1; i < 8; i++ ) {
    //         squareNumber[i] = 0;
    //     }
    // }

    [tmpFGInt release];

    int length = 8;
    while ((length > 1) && (squareNumber[length - 1] == 0)) {
        --length;
    }
    if (length < 8) {
        [[square number] setLength: length * 4];
    }

    return square;
}


/* Reduce a number modulo 2^255-19 */

-(void) mod25519 {
    FGIntBase* numberArray = [number mutableBytes];
    FGIntOverflow length = [number length]/4, maxLen, tmpMod, mod;
    FGInt *tmpFGInt = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* tmpNumber = [[tmpFGInt number] mutableBytes];
    FGIntIndex i;


    while ((numberArray[0] != 0) || (length > 1)) {
        if (length < 8) {
            maxLen = length;
        } else {
            maxLen = 8;
        }
        mod = 0;
        for ( i = 0; i < maxLen; i++ ) {
            tmpMod = (FGIntOverflow) numberArray[i] + tmpNumber[i] + mod;
            tmpNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        i = maxLen & 7;
        while (mod != 0) {
            if ((i & 7) == 0) {
                i = 0;
                mod *= 38;
            }
            tmpMod = (FGIntOverflow) tmpNumber[i] + mod;
            tmpNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++i;
        }
        [self shiftRightBy: 256];
        [self multiplyByInt: 38];
        length = ([number length] >> 2);
        numberArray = [number mutableBytes];
    }

    while ((tmpNumber[7] >> 31) == 1) {
        tmpNumber[7] = tmpNumber[7] - (1u << 31);
        mod = 1;
        i = 0;
        while (mod != 0) {
            if ((i & 7) == 0) {
                i = 0;
                mod *= 19;
            }
            tmpMod = (FGIntOverflow) tmpNumber[i] + mod;
            tmpNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++i;
        }
    }

    BOOL lessThan25519 = (tmpNumber[7] < 2147483647u);
    if (!lessThan25519) {
        for ( i = 6; i > 0; i-- ) {
            lessThan25519 = tmpNumber[i] < 4294967295u;
            if (lessThan25519) {
                break;
            }
        }
    }
    if (!lessThan25519) {
        lessThan25519 = tmpNumber[0] < (4294967295u - 18);
    }

    if (!lessThan25519) {
        tmpNumber[0] = (tmpNumber[0] - (4294967295u - 18));
        for ( i = 1; i < 8; i++ ) {
            tmpNumber[i] = 0;
        }
    }

    FGIntIndex tmp, rem;
    if (!sign) {
        tmp = (FGIntIndex) (4294967295u - 18) - tmpNumber[0];
        tmpNumber[0] = (FGIntBase) tmp;
        rem = tmp >> 32;
        for ( i = 1; i < 7; i++ ) {
            tmp = (FGIntIndex) 4294967295u - tmpNumber[i] + rem;
            tmpNumber[i] = (FGIntBase) tmp;
            rem = tmp >> 32;
        }
        tmp = (FGIntIndex) 2147483647u - tmpNumber[7] + rem;
        tmpNumber[7] = (FGIntBase) tmp;
        sign = YES;
    }

    [number release];
    length = 8;
    while ((tmpNumber[length - 1] == 0) && (length > 1)) {
        length--;
    }
    if (length < 8) {
        [[tmpFGInt number] setLength: length*4];
    }

    number = [[tmpFGInt number] retain];
    [tmpFGInt release];
}


+(FGInt *) invertMod25519: (FGInt *) fGInt {
    FGInt *uFGInt = [fGInt mutableCopy], *vFGInt = [[FGInt alloc] initAsP25519], *pFGInt = [[FGInt alloc] initAsP25519];
    [uFGInt mod25519];
    FGInt *x1 = [[FGInt alloc] initWithFGIntBase: 1], *x2 = [[FGInt alloc] initAsZero], *tmpFGInt;
    
    
    while ((![uFGInt isOne]) && (![vFGInt isOne])) {
        while ([uFGInt isEven]) {
            [uFGInt shiftRight];
            if ([x1 isEven]) {
                [x1 shiftRight];
            } else {
                [x1 addWith: pFGInt];
                [x1 shiftRight];
            }
        }
        while ([vFGInt isEven]) {
            [vFGInt shiftRight];
            if ([x2 isEven]) {
                [x2 shiftRight];
            } else {
                [x2 addWith: pFGInt];
                [x2 shiftRight];
            }
        }
        if ([FGInt compareAbsoluteValueOf: uFGInt with: vFGInt] == smaller) {
            [vFGInt subtractWith: uFGInt];
            tmpFGInt = [FGInt subtract: x2 and: x1];
            [x2 release];
            x2 = tmpFGInt;
        } else {
            [uFGInt subtractWith: vFGInt];
            tmpFGInt = [FGInt subtract: x1 and: x2];
            [x1 release];
            x1 = tmpFGInt;
        }
    }
    if ([uFGInt isOne]) {
        [uFGInt release];
        [vFGInt release];
        [x2 release];
        [x1 mod25519];
        return x1;
    } else {
        [uFGInt release];
        [vFGInt release];
        [x1 release];
        [x2 mod25519];
        return x2;
    }
    
}



+(void) doubleAdd25519of: (FGInt **) x1 andZ1: (FGInt **) z1 andX2: (FGInt **) x2 andZ2: (FGInt **) z2 withBasePoint: (FGInt *) x0 {

    if ([*z1 isZero]) {
        return;
    }

    FGInt *x1mz1 = [FGInt subtractModulo25638: *x1 and: *z1], *x1pz1 = [FGInt addModulo25638: *x1 and: *z1];
    FGInt *s1 = [FGInt squareModulo25638: x1pz1], *s2 = [FGInt squareModulo25638: x1mz1];
    FGInt *dX = [FGInt multiplyModulo25638: s1 and: s2];
    FGInt *t1A = [FGInt subtractModulo25638: s1 and: s2], *t1 = [t1A mutableCopy];
    [s2 release];
    [t1A multiplyByInt: 121665];
    FGInt *t2 = [FGInt addModulo25638: t1A and: s1];
    [s1 release];
    [t1A release];
    FGInt *dZ = [FGInt multiplyModulo25638: t1 and: t2];
    [t1 release];
    [t2 release];


    if ([*z2 isZero]) {
        [x1pz1 release];
        [x1mz1 release];
        [*x2 release];
        *x2 = *x1;
        [*z2 release];
        *z2 = *z1;
        *x1 = dX;
        *z1 = dZ;
        return;
    }

    FGInt *x2mz2 = [FGInt subtractModulo25638: *x2 and: *z2], *x2pz2 = [FGInt addModulo25638: *x2 and: *z2];
    t1 = [FGInt multiplyModulo25638: x2pz2 and: x1mz1];
    t2 = [FGInt multiplyModulo25638: x2mz2 and: x1pz1];
    [x1pz1 release];
    [x1mz1 release];
    [x2pz2 release];
    [x2mz2 release];
    FGInt *t1pt2 = [FGInt addModulo25638: t1 and: t2];
    FGInt *sX = [FGInt squareModulo25638: t1pt2];
    [t1pt2 release];
    FGInt *t1mt2 = [FGInt subtractModulo25638: t1 and: t2];
    [t1 release];
    [t2 release];
    s1 = [FGInt squareModulo25638: t1mt2];
    [t1mt2 release];
    FGInt *sZ = [FGInt multiplyModulo25638: s1 and: x0];
    [s1 release];

    [*x1 release];
    *x1 = dX;
    [*z1 release];
    *z1 = dZ;
    [*x2 release];
    *x2 = sX;
    [*z2 release];
    *z2 = sZ;
}


+(FGInt *) addBasePointOnCurve25519: (FGInt *) x0 kTimes: (FGInt *) kTimes {
    FGInt *x1 = [[FGInt alloc] initWithFGIntBase: 1], *z1 = [[FGInt alloc] initAsZero];
    FGInt *x2 = [x0 mutableCopy], *z2 = [[FGInt alloc] initWithFGIntBase: 1];

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
            [FGInt doubleAdd25519of: &x1 andZ1: &z1 andX2: &x2 andZ2: &z2 withBasePoint: x0];
        } else {
            [FGInt doubleAdd25519of: &x2 andZ1: &z2 andX2: &x1 andZ2: &z1 withBasePoint: x0];
        }
        --j;
    }
    for( FGIntIndex i = kLength - 2; i >= 0; i-- ) {
        tmp = kFGIntNumber[i];
        for( j = 31; j >= 0; --j ) {
            if ((tmp & (1 << j)) == 0) {
                [FGInt doubleAdd25519of: &x1 andZ1: &z1 andX2: &x2 andZ2: &z2 withBasePoint: x0];
            } else {
                [FGInt doubleAdd25519of: &x2 andZ1: &z2 andX2: &x1 andZ2: &z1 withBasePoint: x0];
            }
        }
    }

    [x2 release];
    [z2 release];

    FGInt *p25519 = [[FGInt alloc] initAsP25519];
    FGInt *zInv;
    if (![z1 isZero]) {
        zInv = [FGInt invert: z1 moduloPrime: p25519]; 
    } else {
        zInv = [z1 mutableCopy];
    }

    // FGInt *zInv = [FGInt shiftEuclideanInvert: z1 mod: p25519];
    [p25519 release];

    FGInt  *tmpFGInt = [FGInt multiply: x1 and: zInv];
    [zInv release];
    [tmpFGInt mod25519];

    [x1 release];
    [z1 release];

    return tmpFGInt;
}



+(FGInt *) raise: (FGInt *) fGInt  toThePowerMod25519: (FGInt *) fGIntN {
    FGIntOverflow nLength = [[fGIntN number] length]/4;
    FGIntBase tmp;
    FGInt *tmpFGInt1, *tmpFGInt;
    int j;

    FGInt *power = [[FGInt alloc] initWithFGIntBase: 1];
    FGIntBase* fGIntNnumber = [[fGIntN number] mutableBytes];
    tmpFGInt1 = [fGInt mutableCopy];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmp = fGIntNnumber[i];
        for( j = 0; j < 32; ++j) {
            if (((tmp >> j) % 2) == 1) {
                tmpFGInt = [FGInt multiplyModulo25638: power and: tmpFGInt1];
                [power release];
                power = tmpFGInt;
            }
            tmpFGInt = [FGInt squareModulo25638: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = tmpFGInt;
        }
    }
    j = 0;
    tmp = fGIntNnumber[nLength - 1];
    while((tmp >> j)  != 0) {
        if (((tmp >> j) % 2) == 1) {
            tmpFGInt = [FGInt multiplyModulo25638: power and: tmpFGInt1];
            [power release];
            power = tmpFGInt;
        }
        ++j;
        if ((tmp >> j)  != 0) {
            tmpFGInt = [FGInt squareModulo25638: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = tmpFGInt;
        }
    }

    [power mod25519];

    return power;
}



-(void) shiftRightBy136 {
    FGIntOverflow length = [number length];
    if (length > 17) {
        NSMutableData *tmpNumber = [[NSMutableData alloc] initWithLength: (length - 17) + 1];
         memcpy([tmpNumber mutableBytes], &[number mutableBytes][17], length - 17);
         [number release];
         number = tmpNumber;
    } else {
        [number release];
        number = [[NSMutableData alloc] initWithLength: 4];
    }
}

-(void) mod1305 {
    FGIntBase* numberArray = [number mutableBytes];
    FGIntOverflow length = [number length]/4, maxLen, tmpMod, mod;
    FGInt *tmpFGInt = [[FGInt alloc] initWithNZeroes: 5];
    FGIntBase* tmpNumber = [[tmpFGInt number] mutableBytes];
    FGIntIndex i;
    FGIntBase head;

    while ((numberArray[0] != 0) || (length > 1)) {
        if (length < 5) {
            maxLen = length;
            head = 0;
        } else {
            maxLen = 5;
            head = numberArray[4];
            numberArray[4] = head & 255;
        }
        mod = 0;
        for ( i = 0; i < maxLen; i++ ) {
            tmpMod = (FGIntOverflow) numberArray[i] + tmpNumber[i] + mod;
            tmpNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        i = maxLen % 5;
        while (mod != 0) {
            tmpMod = (FGIntOverflow) tmpNumber[i] + mod;
            tmpNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++i;
        }
        if (maxLen == 5) {
            mod = (tmpNumber[4] >> 8) * 320;
            tmpNumber[4] = tmpNumber[4] & 255;
            i = 0;
            while (mod != 0) {
                tmpMod = (FGIntOverflow) tmpNumber[i] + mod;
                tmpNumber[i] = (FGIntBase) tmpMod;
                mod = tmpMod >> 32;
                ++i;
            }
        }

        if (head > 0) {
            numberArray[4] = head;
        }        
        [self shiftRightBy136];
        [self multiplyByInt: 320];
        length = ([number length] >> 2);
        numberArray = [number mutableBytes];
    }

    while ((tmpNumber[4] >> 2) > 0) {
        mod = (tmpNumber[4] >> 2) * 5;
        tmpNumber[4] = tmpNumber[4] & 3;
        i = 0;
        while (mod != 0) {
            tmpMod = (FGIntOverflow) tmpNumber[i] + mod;
            tmpNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++i;
        }
    }

    BOOL lessThan1305 = (tmpNumber[4] < 3u);
    if (!lessThan1305) {
        for ( i = 3; i > 0; i-- ) {
            lessThan1305 = tmpNumber[i] < 4294967295u;
            if (lessThan1305) {
                break;
            }
        }
    }
    if (!lessThan1305) {
        lessThan1305 = tmpNumber[0] < (4294967295u - 4);
    }

    if (!lessThan1305) {
        tmpNumber[0] = (tmpNumber[0] - (4294967295u - 4));
        for ( i = 1; i < 5; i++ ) {
            tmpNumber[i] = 0;
        }
    }

    FGIntIndex tmp, rem;
    if (!sign) {
        tmp = (FGIntIndex) (4294967295u - 4) - tmpNumber[0];
        tmpNumber[0] = (FGIntBase) tmp;
        rem = tmp >> 32;
        for ( i = 1; i < 4; i++ ) {
            tmp = (FGIntIndex) 4294967295u - tmpNumber[i] + rem;
            tmpNumber[i] = (FGIntBase) tmp;
            rem = tmp >> 32;
        }
        tmp = (FGIntIndex) 3u - tmpNumber[4] + rem;
        tmpNumber[4] = (FGIntBase) tmp;
        sign = YES;
    }

    [number release];
    length = 5;
    while ((tmpNumber[length - 1] == 0) && (length > 1)) {
        length--;
    }
    if (length < 5) {
        [[tmpFGInt number] setLength: length*4];
    }

    number = [[tmpFGInt number] retain];
    [tmpFGInt release];
}



/* Multiply 2 FGInts, and return fGInt1 * fGInt2 modulo (2^256 - 38) */

+(FGInt *) multiplyModulo1305ish: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [[fGInt1 number] length] / 4,
              length2 = [[fGInt2 number] length] / 4,
              productLength = length1 + length2, length, head;
    FGIntOverflow tmpMod, mod;
    FGIntBase* fGInt1Number = [[fGInt1 number] mutableBytes];
    FGIntBase* fGInt2Number = [[fGInt2 number] mutableBytes];

    FGInt *product = [[FGInt alloc] initWithNZeroes: 5];
    FGIntBase* productNumber = [[product number] mutableBytes];
    FGInt *tmpFGInt = [[FGInt alloc] initWithNZeroes: productLength];
    FGIntBase* tmpNumber = [[tmpFGInt number] mutableBytes];


    FGIntIndex i, j;
    for( j = 0; j < length2; j++ ) {
        mod = 0;
        for( i = 0; i < length1; i++ ) {
            tmpMod = (FGIntOverflow) fGInt1Number[i] * fGInt2Number[j] + tmpNumber[j + i] + mod;
            tmpNumber[j + i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        tmpNumber[j + length1] = (FGIntBase) mod;
    }

    FGIntOverflow tmpLength = ([[tmpFGInt number] length] >> 2), maxLen;
    length = 5;
    while ((tmpNumber[0] != 0) || (tmpLength > 1)) {
        if (tmpLength < 5) {
            maxLen = tmpLength;
            head = 0;
        } else {
            maxLen = 5;
            head = tmpNumber[4];
            tmpNumber[4] = head & 255;
        }
        mod = 0;
        for ( i = 0; i < maxLen; i++ ) {
            tmpMod = (FGIntOverflow) productNumber[i] + tmpNumber[i] + mod;
            productNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
        }
        i = maxLen;
        while (mod != 0) {
            if (i > length - 1) {
                ++length;
                [[product number] setLength: 4*length];
                productNumber = [[product number] mutableBytes];
            }
            tmpMod = (FGIntOverflow) productNumber[i] + mod;
            productNumber[i] = (FGIntBase) tmpMod;
            mod = tmpMod >> 32;
            ++i;
        }

        if (head > 0) {
            tmpNumber[4] = (FGIntBase) head;
        }        
        [tmpFGInt shiftRightBy136];
        [tmpFGInt multiplyByInt: 320];
        tmpLength = ([[tmpFGInt number] length] >> 2);
        tmpNumber = [[tmpFGInt number] mutableBytes];
    }

    [tmpFGInt release];

    while ((length > 1) && (productNumber[length - 1] == 0)) {
        --length;
    }
    if (length < 8) {
        [[product number] setLength: length * 4];
    }

    // [product setSign: [fGInt1 sign] == [fGInt2 sign]];
    
    return product;
}






@end









