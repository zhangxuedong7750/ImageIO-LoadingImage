//
//  ZXDIncrementallyImage.m
//  ImageIO加载图片
//
//  Created by 张雪东 on 16/2/25.
//  Copyright © 2016年 张雪东. All rights reserved.
//

#import "ZXDIncrementallyImage.h"
#import <ImageIO/ImageIO.h>
#import <CoreFoundation/CoreFoundation.h>

@interface ZXDIncrementallyImage()<NSURLConnectionDelegate> {
    
    NSURLRequest    *_request;
    NSURLConnection *_conn;
    
    CGImageSourceRef _incrementallyImgSource;
    
    NSMutableData   *_recieveData;
    long long       _expectedLeght;
    bool            _isLoadFinished;
}
@property (nonatomic,strong) UIImage *incrementallyImage;
@end

@implementation ZXDIncrementallyImage

-(void)zxd_setImageWithURL:(NSURL *)imageURL{
    
    _request = [NSURLRequest requestWithURL:imageURL];
    _conn = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
    
    _incrementallyImgSource = CGImageSourceCreateIncremental(NULL);
    
    _recieveData = [[NSMutableData alloc] init];
    _isLoadFinished = false;
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _expectedLeght = response.expectedContentLength;
    NSLog(@"expected Length: %lld", _expectedLeght);
    
    NSString *mimeType = response.MIMEType;
    NSLog(@"MIME TYPE %@", mimeType);
    
    NSArray *arr = [mimeType componentsSeparatedByString:@"/"];
    if (arr.count < 1 || ![[arr objectAtIndex:0] isEqual:@"image"]) {
        NSLog(@"not a image url");
        [connection cancel];
        _conn = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection %@ error, error info: %@", connection, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection Loading Finished!!!");
    
    // if download image data not complete, create final image
    if (!_isLoadFinished) {
        CGImageSourceUpdateData(_incrementallyImgSource, (CFDataRef)_recieveData, _isLoadFinished);
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_incrementallyImgSource, 0, NULL);
        self.image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_recieveData appendData:data];
    
    _isLoadFinished = false;
    if (_expectedLeght == _recieveData.length) {
        _isLoadFinished = true;
    }
    
    CGImageSourceUpdateData(_incrementallyImgSource, (CFDataRef)_recieveData, _isLoadFinished);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_incrementallyImgSource, 0, NULL);
    self.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
}

@end
