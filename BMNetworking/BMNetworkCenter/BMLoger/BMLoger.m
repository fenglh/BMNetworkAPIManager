//
//  BMLoger.m
//  BlueMoonBlueHouse
//
//  Created by 冯立海 on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import "BMLoger.h"
#import "NSObject+AXNetworkingMethods.h"
#import "NSMutableString+AXNetworkingMethods.h"
#import "BMBaseNetworkConfigure.h"

#define configurationInstance ([BMBaseNetworkConfigure shareInstance])

@implementation BMLoger

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName url:(NSString *)url requestParams:(id)requestParams httpMethod:(NSString *)httpMethod
{
    
    if ([configurationInstance networkLogLevel] & BMNetworkLogLevelRequest) {
        NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
        
        [logString appendFormat:@"API Name:\t\t%@\n", [apiName AIF_defaultValue:@"N/A"]];
        [logString appendFormat:@"Method:\t\t\t%@\n", [httpMethod AIF_defaultValue:@"N/A"]];
        [logString appendFormat:@"url:\t\t%@\n", url];
        [logString appendFormat:@"isTestEnviront:\t\t\t%@\n", [configurationInstance isTestEnVironment] ? @"YES" : @"NO"];
        
        [logString appendFormat:@"Params:\n%@", requestParams];
        [logString appendURLRequest:request];

        [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
        NSLog(@"%@", logString);
    }


    
}


+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error
{

    
    if ([configurationInstance networkLogLevel] & BMNetworkLogLevelResponse) {
        BOOL shouldLogError = error ? YES : NO;
        NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n"];
        
        [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
        [logString appendFormat:@"Content:\n\t%@\n\n", responseString];
        if (shouldLogError) {
            [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
            [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
            [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
            [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
            [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
        }
        
        [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
        
        [logString appendURLRequest:request];
        
        [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n"];
        
        NSLog(@"%@", logString);
    }
    

}

+ (void)logDebugInfoWithCachedResponse:(BMURLResponse *)response apiName:(NSString *)apiName url:(NSString *)url
{
    if ([configurationInstance networkLogLevel] & BMNetworkLogLevelResponse) {
        NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                      Cached Response                       =\n==============================================================\n\n"];
        
        [logString appendFormat:@"API Name:\t\t%@\n", [apiName AIF_defaultValue:@"N/A"]];
        [logString appendFormat:@"url:\t\t%@\n", url];
        [logString appendFormat:@"Method Name:\t%@\n", apiName];
        [logString appendFormat:@"Params:\n%@", response.requestParams];
        [logString appendFormat:@"Content:\n\t%@\n\n", response.contentString];
        [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n"];
        NSLog(@"%@", logString);
    }


}


@end
