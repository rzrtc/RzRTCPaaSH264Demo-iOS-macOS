//
//  RZSourceManager.m
//  rzpaas_sdk_demo_264_macos
//
//  Created by ding yusong on 2021/1/20.
//

#import "RZSourceManager.h"
#import "RZVideoCapturer.h"
#import "RZVideoEncoder.h"
#import "RZVideoDecoder.h"
#import <mach/mach_time.h>
#import "RZVideoPlayView.h"
#import "libyuv.h"


static uint64_t rz_milliseconds(void)
{
    static mach_timebase_info_data_t sTimebaseInfo;
    uint64_t machTime = mach_absolute_time();
    
    // Convert to nanoseconds - if this is the first time we've run, get the timebase.
    if (sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    // 得到毫秒级别时间差
    uint64_t millis = ((machTime / 1e6) * sTimebaseInfo.numer) / sTimebaseInfo.denom;
    return millis;
}


@interface RZSourceManager()<RZVideoEncoderDelegate, RZVCamDelegate, RZVideoDecoderDelegate>

@property (nonatomic, strong) RZVideoCapturer *videoCapturer;
@property (nonatomic, strong) RZVideoEncoder *videoEncoder;
@property (nonatomic, strong) RZVideoDecoder *videoDecoder;
@property (nonatomic, strong) dispatch_queue_t encodeQueue;

@end

@implementation RZSourceManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //采集
        _videoCapturer = [[RZVideoCapturer alloc] init];
        _videoCapturer.delegate = self;
        
        DbyCapturerConfig config;
        config.frameRate = 15;
        config.dimension = CGSizeMake(1280, 720);
        [_videoCapturer setVideoConfig:config];
        
        //编解码
        _videoEncoder = [[RZVideoEncoder alloc] initWithDelegate:self];
        _videoDecoder = [[RZVideoDecoder alloc] initWithDelegate:self];
        
        //发送
        _masterVideoSource = [RZMVideoSourceImp new];
        
        _encodeQueue = dispatch_queue_create("com.video.encode.queue", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}
- (void)start{
    [_videoCapturer start];
}

- (void)stop{
    [_videoCapturer stop];
}


- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer timestamp:(NSTimeInterval)timestamp {
    if (!pixelBuffer) {
        return;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);

    void *src_y = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    void *src_uv = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    int src_stride_y = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    int src_stride_uv = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    
    void *i420 = malloc(width * height * 2);

    void *dst_y = i420;
    void *dst_u = dst_y + width * height;
    void *dst_v = dst_u + width * height / 4;

    int dst_stride_y = width;
    int dst_stride_u = width / 2;
    int dst_stride_v = width / 2;

    NV12ToI420(src_y, src_stride_y,
               src_uv, src_stride_uv,
               dst_y, dst_stride_y,
               dst_u, dst_stride_u,
               dst_v, dst_stride_v,
               width, height);

    [self.masterVideoSink renderRawData:i420
                                   size:CGSizeMake(width, height)
                            pixelFormat:RZVideoPixelFormatI420
                              timestamp:timestamp];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    free(i420);
}

- (void)videoCapturer:(RZVideoCapturer *)videoCapturer didReceiveSampleBuffer:(CMSampleBufferRef)sampleBuffer isFromFrontCamera:(BOOL)isFromFrontCamera
{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    uint64_t timestamp = rz_milliseconds();
    CVPixelBufferRetain(pixelBuffer);
    dispatch_async(self.encodeQueue, ^{
        [self displayPixelBuffer:pixelBuffer timestamp:timestamp];
        [self.videoEncoder encodeNv12PixelBuffer:pixelBuffer timestamp:timestamp];
        CVPixelBufferRelease(pixelBuffer);
    });
}

- (void)videoEncoder:(nonnull RZVideoEncoder *)videoEncoder didEncodeH264:(nonnull void *)h264Data dataLength:(int)length isKeyFrame:(BOOL)isKeyFrame timestamp:(NSTimeInterval)timestamp
{
    //发送
    if (self.masterVideoSource.consumer) {
        [self.masterVideoSource.consumer consumePacket:h264Data length:length bufferType:RZVideoBufferTypeH264 isKeyframe:isKeyFrame timestamp:timestamp];
    }
    
}


@end
