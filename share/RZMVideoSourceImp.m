//
//  RZMVideoSourceImp.m
//  rzpaas_example_mac
//
//  Created by yxibng on 2020/11/30.
//

#import "RZMVideoSourceImp.h"

@implementation RZMVideoSourceImp

- (RZVideoBufferType)bufferType {
    return RZVideoBufferTypeRawData;
}

- (void)shouldDispose {
    
}

- (BOOL)shouldInitialize {
    return YES;
}

- (int)shouldStart {
    return 0;
}

- (void)shouldStop {
    return;
}

@end
