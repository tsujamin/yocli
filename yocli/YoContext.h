//
//  YoContext.h
//  yocli
//
//  Created by Benjamin Roberts on 9/11/2014.
//  Copyright (c) 2014 tsu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoContext : NSObject

@property (readonly) NSString * apiToken;

+(YoContext *) contextFromAPIToken:(NSString *)accountToken;
-(YoContext *) initFromAPIToken:(NSString *)accountToken;
-(BOOL)yo:(NSString *)yosername;
-(BOOL)sendYoquestTo:(NSString *)endpoint withParams:(NSDictionary *)params;


@end
