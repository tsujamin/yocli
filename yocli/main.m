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
    if(argc != 3) {
        NSLog(@"%s: apikey yosername\n", argv[0]);
        exit(1);
    }
    
    @autoreleasepool {
        YoContext *benContext = [YoContext
                contextFromAPIToken:[NSString stringWithFormat:@"%s", argv[1]]];
        
        if([benContext yo:[NSString stringWithFormat:@"%s", argv[2]]])
            NSLog(@"sent yo to %s\n", argv[2]);
        else
            NSLog(@"failed to send yo\n");
    }
    return 0;
}
