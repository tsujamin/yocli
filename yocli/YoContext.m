//
//  YoContext.m
//  yocli
//
//  Created by Benjamin Roberts on 9/11/2014.
//  Copyright (c) 2014 tsu. All rights reserved.
//

#import "YoContext.h"

//
static NSString *yoURL = @"http://api.justyo.co/";

@implementation YoContext
+(YoContext *)contextFromAPIToken:(NSString *)accountToken;
{
    return [[YoContext alloc] initFromAPIToken:accountToken];
}

-(YoContext *)initFromAPIToken:(NSString *)accountToken;
{
    _apiToken = accountToken;
    return self;
}

-(BOOL)yo:(NSString *)yosername;
{
    NSDictionary *requestParams = @{ @"username": yosername, @"api_token": _apiToken};
    return [self sendYoquestTo:@"yo/" withParams:requestParams];
}

/*
 * endpoint must include trailing forward slash
 */
-(BOOL)sendYoquestTo:(NSString *)endpoint withParams:(NSDictionary *)params;
{
    //Build url
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", yoURL, endpoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    
    //encode parameters
    NSData *encodedParams = [NSJSONSerialization dataWithJSONObject:params options:0 error:NULL];
    
    //add required headers
    [request addValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"accept"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[encodedParams length]] forHTTPHeaderField:@"Content-Length"];
    
    //set body to request params
    [request setHTTPBody:encodedParams];
    
    //Make request
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    /*
    if(error || [response statusCode] != 200) {
        NSLog(@"error: %@", error);
        NSLog(@"url: %@, params: %@, return code: %ld, response body: %@",
              [url description], params, (long) [response statusCode], [response description]);
    }
    */
    
    return [response statusCode] == 200;
    
}

@end
