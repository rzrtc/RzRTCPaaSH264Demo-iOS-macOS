//
//  RZSourceManager.h
//  rzpaas_sdk_demo_264_macos
//
//  Created by ding yusong on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import "RZMVideoSourceImp.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZSourceManager : NSObject
//自定义推流 master
@property (strong, nonatomic, readonly) RZMVideoSourceImp *masterVideoSource;
//自定义推流 master 本地预览
@property (nonatomic, strong) id<RZVideoSinkProtocol> masterVideoSink;


- (void)start;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
