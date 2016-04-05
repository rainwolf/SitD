#import <Foundation/Foundation.h>
#import "FGInt.h"



@interface Ed25519Point : NSObject <NSMutableCopying> {
    FGInt *x, *y, *projectiveZ, *extendedT; 
}
@property (assign, readwrite) FGInt *x, *y, *projectiveZ, *extendedT;

-(id) initEd25519BasePointWithoutCurve;
-(id) initFromCompressed25519NSDataWithoutCurve: (NSData *) compressedPoint;
-(NSData *) to25519NSData;
-(void) makeProjective25519;
-(void) makeAffine25519;
+(Ed25519Point *) addEd25519: (Ed25519Point *) tecPoint kTimes: (FGInt *) kTimes;
+(Ed25519Point *) addEd25519BasePointkTimes: (FGInt *) kTimes;
+(Ed25519Point *) addEd25519: (Ed25519Point *) tecPoint1 k1Times: (FGInt *) k1FGInt and: (Ed25519Point *) tecPoint2 k2Times: (FGInt *) k2FGInt;
-(NSData *) toMontgomery25519X;

@end










@interface Ed25519SHA512 : NSObject <NSCopying> {
    NSData *secretKey;
    Ed25519Point *publicKey;
}
@property (assign, readwrite) NSData *secretKey;
@property (assign, readwrite) Ed25519Point *publicKey;

-(void) generateNewSecretAndPublicKey;
-(NSData *) secretKeyToCurve25519Key;
-(NSData *) secretKeyToNSData;
-(NSString *) secretKeyToBase64NSString;
-(NSData *) publicKeyToNSData;
-(NSString *) publicKeyToBase64NSString;
-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData;
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString;
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData;
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString;
-(NSData *) signNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signatureData ofPlainTextNSData: (NSData *) plainText;
-(NSData *) signNSString: (NSString *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText;

@end
