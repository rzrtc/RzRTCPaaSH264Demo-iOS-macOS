//
//  RZMVideoSourceImp.h
//  rzpaas_example_mac
//
//  Created by yxibng on 2020/11/30.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IOS
#import <RZPaas_iOS/RZRtcEngineKit.h>
#import <RZPaas_iOS/RZRtcChannel.h>
#endif


#if TARGET_OS_OSX
#import <RZPaas_macOS/RZRtcEngineKit.h>
#import <RZPaas_macOS/RZRtcChannel.h>
#endif


NS_ASSUME_NONNULL_BEGIN

@interface RZMVideoSourceImp : NSObject <RZVideoSourceProtocol>
@property (strong) id<RZVideoFrameConsumer> _Nullable consumer;
@end

NS_ASSUME_NONNULL_END
