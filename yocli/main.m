//
//  main.m
//  yocli
//
//  Created by Benjamin Roberts on 9/11/2014.
//  Copyright (c) 2014 tsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "YoContext.h"


int main(int argc, const char * argv[]) {
    if(argc < 3) {
        NSLog(@"%s: apikey [yosernames ...]\n", argv[0]);
        exit(1);
    }
    
    @autoreleasepool {
        YoContext *serverContext = [YoContext
                contextFromAPIToken:[NSString stringWithFormat:@"%s", argv[1]]];
        for(int i = 2; i < argc; i++) {
            if([serverContext yo:[NSString stringWithFormat:@"%s", argv[i]]])
                printf("sent yo to %s\n", argv[i]);
            else
                printf("failed to yo %s\n", argv[i]);
        }
    }
    return 0;
}
