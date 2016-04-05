#import <Foundation/Foundation.h>
#import "FGInt.h"

#define pNumber {1577621095u, 408726636u, 548779422u, 3998976209u, 1636097057u, 2859461816u, 1252231161u, 2411004387u}
#define invertedPnumber {1365351366u, 944690863u, 742653073u, 3002872055u, 1686588978u, 506207177u, 284644895u, 3356094714u, 1u}
#define nNumber {1470919265u, 439284827u, 4163582244u, 781028882u, 1636097057u, 2859461816u, 1252231161u, 2411004387u}
#define invertedNnumber {2575760811u, 3636569892u, 2945167224u, 329778435u, 1686588981u, 506207177u, 284644895u, 3356094714u, 1u}
#define iPlus3ToPm1o6aNumber {2370578088u, 1265180496u, 127941360u, 77329873u, 4244342130u, 2670201218u, 3667409756u, 741768489u}
#define iPlus3ToPm1o6bNumber {940766700u, 1437220759u, 1909096265u, 3616181351u, 4130158640u, 979801363u, 1763672258u, 321565175u}
#define iPlus3ToPm1o3aNumber {1018688899u, 2290046606u, 1705980085u, 2239813062u, 319048878u, 589583672u, 4134597472u, 590931931u}
#define iPlus3ToPm1o3bNumber {516587795u, 2363704681u, 3741661415u, 1376237439u, 1892602503u, 3352308990u, 1958136493u, 968029913u}
#define iPlus3ToPm1o2aNumber {3047380905u, 2322708607u, 1891862020u, 1516263544u, 558333209u, 2579796938u, 729038355u, 1434200016u}
#define iPlus3ToPm1o2bNumber {3269554324u, 2264431890u, 831839343u, 549814424u, 38902570u, 584961702u, 934883905u, 1891595661u}
#define iPlus3To2Pm2o3aNumber {129224923u, 813854891u, 1000177946u, 399121254u, 4035104969u, 894611274u, 4286216352u, 802880663u}
#define iPlus3To2Pm2o3bNumber {2420468926u, 1242471078u, 1988546336u, 1616144927u, 2854065208u, 2150459854u, 3097483714u, 737580514u}
#define iPlus3ToPsm1o3Number {3074813240u, 1583182934u, 1736840252u, 1725814081u, 3717193513u, 3743017720u, 1252231160u, 2411004387u}
#define iPlus3ToPsm1o6Number {3074813241u, 1583182934u, 1736840252u, 1725814081u, 3717193513u, 3743017720u, 1252231160u, 2411004387u}
#define iPlus3To2Psm2o3Number {2797775150u, 3120510997u, 3106906465u, 2273162127u, 2213870840u, 3411411391u, 0u, 0u}
#define cnstLength 32
#define invertedLength 36
#define precisionBits 256






@interface GFP2 : NSObject <NSMutableCopying> {
	FGInt *a, *b;
}
@property (assign, readwrite) FGInt *a, *b;

-(id) initOne;
-(id) initZero;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(void) changeSign;
-(void) conjugate;
-(BOOL) isZero;
+(GFP2 *) add: (GFP2 *) p1 and: (GFP2 *) p2 with: (FGInt *) pFGInt;
+(GFP2 *) subtract: (GFP2 *) p1 and: (GFP2 *) p2 with: (FGInt *) pFGInt;
+(GFP2 *) multiply: (GFP2 *) p1 and: (GFP2 *) p2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP2 *) square: (GFP2 *) p1 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP2 *) multiplyByResiduePlus3: (GFP2 *) p1 with: (FGInt *) pFGInt;
-(void) shiftLeftWith: (FGInt *) pFGInt;
-(void) shiftRightWith: (FGInt *) pFGInt;
-(void) multiplyByInt: (unsigned char) c with: (FGInt  *) p;
-(void) multiplyByFGInt: (FGInt *) fGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(GFP2 *) invertWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP2 *) raise: (GFP2 *) gfp2 toThePower: (FGInt *) fGIntN with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(NSString *) toBase10String;
-(NSData *) marshal;

@end



@interface GFP6 : NSObject <NSMutableCopying> {
	GFP2 *a, *b, *c;
}
@property (assign, readwrite) GFP2 *a, *b, *c;

-(id) initOne;
-(id) initZero;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(void) changeSign;
-(BOOL) isZero;
+(GFP6 *) add: (GFP6 *) p1 and: (GFP6 *) p2 with: (FGInt *) pFGInt;
+(GFP6 *) subtract: (GFP6 *) p1 and: (GFP6 *) p2 with: (FGInt *) pFGInt;
+(GFP6 *) multiply: (GFP6 *) p1 and: (GFP6 *) p2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP6 *) square: (GFP6 *) p1 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(GFP6 *) multiplyByRootWith: (FGInt *) pFGInt;
-(void) shiftLeftWith: (FGInt *) pFGInt;
-(void) multiplyByFGInt: (FGInt *) fGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(void) multiplyByGFP2: (GFP2 *) gfp2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(void) frobeniusWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(void) frobenius2With: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(GFP6 *) invertWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(NSString *) toBase10String;
-(NSData *) marshal;

@end




@interface GFP12 : NSObject <NSMutableCopying> {
	GFP6 *a, *b;
}
@property (assign, readwrite) GFP6 *a, *b;

-(id) initOne;
-(id) initZero;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(void) conjugate;
-(void) changeSign;
-(BOOL) isZero;
+(GFP12 *) add: (GFP12 *) p1 and: (GFP12 *) p2 with: (FGInt *) pFGInt;
+(GFP12 *) subtract: (GFP12 *) p1 and: (GFP12 *) p2 with: (FGInt *) pFGInt;
+(GFP12 *) multiply: (GFP12 *) p1 and: (GFP12 *) p2 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(void) multiplyByFGInt: (FGInt *) fGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP12 *) square: (GFP12 *) p1 with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(void) frobeniusWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(void) frobenius2With: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(GFP12 *) invertWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(GFP12 *) invert;
+(GFP12 *) raise: (GFP12 *) gfp12 toThePower: (FGInt *) fGIntN withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP12 *) raise: (GFP12 *) gfp12 toThePower: (FGInt *) fGIntN with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
-(NSString *) toBase10String;
-(NSData *) marshal;

@end



@interface G2Point : NSObject <NSMutableCopying> {
	GFP2 *x, *y, *z, *t;
	BOOL infinity;
}
@property (assign, readwrite) GFP2 *x, *y, *z, *t;
@property (assign, readwrite) BOOL infinity;

-(id) initInfinity;
-(id) initGenerator;
-(id) initRandomPoint;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(void) changeSign;
-(void) makeAffine;
-(void) makeProjective;
-(void) makeExtendedProjective;
+(G2Point *) add: (G2Point *) p1 and: (G2Point *) p2;
-(void) makeAffineWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt;
+(G2Point *) addGeneratorKTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(G2Point *) addGeneratorKTimes: (FGInt *) kFGInt;
-(NSString *) toBase10String;
-(NSData *) marshal;

@end


@interface G1Point : NSObject <NSMutableCopying> {
	FGInt *x, *y, *z;
	BOOL infinity;
}
@property (assign, readwrite) FGInt *x, *y, *z;
@property (assign, readwrite) BOOL infinity;

-(id) initInfinity;
-(id) initGenerator;
-(id) initRandomPoint;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(void) changeSign;
-(void) makeProjective;
+(G1Point *) add: (G1Point *) p1 and: (G1Point *) p2;
-(void) makeAffineWith: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(G1Point *) add: (G1Point *) g1Point kTimes: (FGInt *) kFGInt with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(G1Point *) add: (G1Point *) g1Point kTimes: (FGInt *) kFGInt;
+(G1Point *) addGeneratorKTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(G1Point *) addGeneratorKTimes: (FGInt *) kFGInt;
-(NSString *) toBase10String;
-(NSData *) marshal;

@end








@interface BN256 : NSObject


+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p;
+(BOOL) testPairing;

@end













































