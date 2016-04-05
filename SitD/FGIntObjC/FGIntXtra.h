#import <Foundation/Foundation.h>
#import <Security/SecRandom.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "FGInt.h"


@interface FGIntXtra : NSObject


+(NSData *) SHA256HMACForKey: (NSData *) key AndData: (NSData *)data;
+(NSData *) SHA256: (NSData *) plainText;
+(NSData *) SHA512: (NSData *) plainText;
+(NSData *) randomDataOfLength: (long) length;
+(void) incrementNSMutableData: (NSMutableData *) data;
+(NSString *) dataToHexString: (NSData *) data;
+(NSData *) hexStringToNSData: (NSString *) str;
+(NSString *) dataToBase32String: (NSData *) data;
+(NSData *) base32StringToNSData: (NSString *) str;
+(NSString *) dataToBase64String: (NSData *) data;
+(NSData *) base64StringToNSData: (NSString *) str;
+(NSData *) scryptPassphrase: (NSString *) passphrase withSalt: (NSData *) salt cost: (unsigned long long) cost parallelism: (unsigned int) parallelism blockSize: (unsigned int) blocksize keyLength: (unsigned int) keyLength;

@end