//
//  ZXDGifView.m
//  ImageIO加载图片
//
//  Created by 张雪东 on 16/2/25.
//  Copyright © 2016年 张雪东. All rights reserved.
//

#import "ZXDGifView.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>

void getFrameInfo(CFURLRef url, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime,CGFloat *gifWidth, CGFloat *gifHeight)
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL(url, NULL);
    
    // get frame count
    size_t frameCount = CGImageSourceGetCount(gifSource);
    for (size_t i = 0; i < frameCount; ++i) {
        // get each frame
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:(__bridge id)frame];
        CGImageRelease(frame);
        
        // get gif info with each frame
        NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
        NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
        
        // get gif size
        if (gifWidth != NULL && gifHeight != NULL) {
            *gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            *gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        }
        
        // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
        NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        if (totalTime) {
            *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
        
        CFRelease((__bridge CFTypeRef)(dict));
    }
    
    if (gifSource) {
        CFRelease(gifSource);
    }
}

@interface ZXDGifView() {

    NSMutableArray *frames;
    NSMutableArray *frameDelayTimes;
    
    CGFloat gifViewWidth;
    CGFloat gifViewHeight;
    
    CGFloat totalTime;
    
}

@end

@implementation ZXDGifView

-(instancetype)initWithFrame:(CGRect)frame fileUrl:(NSURL *)fileURL{

    if (self = [super initWithFrame:frame]) {
        
        [self getImageInfoWithFileUrl:fileURL];
        [self addAimation];
    }
    return self;
}

-(void)getImageInfoWithFileUrl:(NSURL *)fileURL{

    frames = [[NSMutableArray alloc] init];
    frameDelayTimes = [[NSMutableArray alloc] init];
    if (fileURL) {
        getFrameInfo((__bridge CFURLRef)fileURL, frames, frameDelayTimes, &totalTime, &gifViewWidth, &gifViewHeight);
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, gifViewWidth, gifViewHeight);
}

-(void)addAimation{

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    NSInteger count = frameDelayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / totalTime)]];
        currentTime += [[frameDelayTimes objectAtIndex:i] floatValue];
    }
    [animation setKeyTimes:times];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < count; ++i) {
        [images addObject:[frames objectAtIndex:i]];
    }
    
    [animation setValues:images];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = totalTime;
    animation.delegate = self;
    animation.repeatCount = MAXFLOAT;
    
    [self.layer addAnimation:animation forKey:@"gitView"];
    
}

@end
