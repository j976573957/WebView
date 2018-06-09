//
//  NSString+Addition.m
//  KASHDolls
//
//  Created by apple on 2017/11/6.
//  Copyright © 2017年 CD. All rights reserved.
//

#import "NSString+Addition.h"
#include <CommonCrypto/CommonCrypto.h>


@implementation NSString (Addition)




- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}



@end
