//
//  ViewController.m
//  ImageIO加载图片
//
//  Created by 张雪东 on 16/2/25.
//  Copyright © 2016年 张雪东. All rights reserved.
//

#import "ViewController.h"
#import "ZXDGifView.h"
#import "ZXDIncrementallyImage.h"

@interface ViewController ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) ZXDIncrementallyImage *incrementallyImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //gif图片播放
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"detail" withExtension:@"gif"];
    
    ZXDGifView *gifView = [[ZXDGifView alloc] initWithFrame:CGRectMake(20, 100, 0, 0) fileUrl:fileURL];
    [self.view addSubview:gifView];
    
    //网络图片渐进式加载
    NSURL *url = [[NSURL alloc] initWithString:@"http://b.zol-img.com.cn/desk/bizhi/image/1/1920x1200/1348810232493.jpg"];
    ZXDIncrementallyImage *imageView = [[ZXDIncrementallyImage alloc] initWithFrame:CGRectMake(20, 350, 300, 300)];
    self.imageView = imageView;
    [imageView zxd_setImageWithURL:url];
    [self.view addSubview:imageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
