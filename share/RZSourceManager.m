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


- (void)videoCapturer:(RZVideoCapturer *)videoCapturer didReceiveSampleBuffer:(CMSampleBufferRef)sampleBuffer isFromFrontCamera:(BOOL)isFromFrontCamera
{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    uint64_t timestamp = rz_milliseconds();
    CVPixelBufferRetain(pixelBuffer);
    dispatch_async(self.encodeQueue, ^{
        [self.videoEncoder encodeNv12PixelBuffer:pixelBuffer timestamp:timestamp];
        CVPixelBufferRelease(pixelBuffer);
    });
}

- (void)videoEncoder:(nonnull RZVideoEncoder *)videoEncoder didEncodeH264:(nonnull void *)h264Data dataLength:(int)length isKeyFrame:(BOOL)isKeyFrame timestamp:(NSTimeInterval)timestamp
{
//    NSLog(@"%s, lenght = %d, isKey = %d, timestamp = %f", __FUNCTION__, length, isKeyFrame, timestamp);
    
    //发送
    if (self.masterVideoSource.consumer) {
        [self.masterVideoSource.consumer consumePacket:h264Data length:length bufferType:RZVideoBufferTypeH264 isKeyframe:isKeyFrame timestamp:timestamp];
    }

    //本地预览
    if (self.masterVideoSink) {
        [self.masterVideoSink renderPacket:h264Data length:length bufferType:RZVideoBufferTypeH264 timestamp:timestamp];
    }

//    [self.videoDecoder decodeH264:h264Data length:length timestamp:timestamp];
}

//- (void)videoDecoder:(RZVideoDecoder *)videoDecoder
//  receiveDecodedData:(uint8_t * _Nonnull *)data
//           yuvStride:(int *)yuvStride
//               width:(int)width
//              height:(int)height
//          pix_format:(RZYUVType)pix_format
//{
////    NSLog(@"%s, width = %d, heigth = %d, format = %@", __FUNCTION__, width, height, pix_format == RZYUVTypeNV12 ? @"nv12" : @"I420" );
//
//    if (pix_format == RZYUVTypeI420) {
//
//        uint8_t *y =  data[0];
//        uint8_t *u =  data[1];
//        uint8_t *v =  data[2];
//        int stride_y = yuvStride[0];
//        int stride_u = yuvStride[1];
//        int stride_v = yuvStride[2];
//
//        [self.playView displayI420:y
//                                 u:u
//                                 v:v
//                          stride_y:stride_y
//                          stride_u:stride_u
//                          stride_v:stride_v
//                             width:width
//                            height:height];
//    }
//}


@end
