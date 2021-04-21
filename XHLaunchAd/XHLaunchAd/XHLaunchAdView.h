//
//  XHLaunchAdView.h
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 16/12/3.
//  Copyright © 2016年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
    #import <FLAnimatedImage/FLAnimatedImage.h>
#else
    #import "FLAnimatedImage.h"
#endif


#if __has_include(<alphaVideoPlayTool/SLMaskVideoPlayerLayer.h>)
    #import<alphaVideoPlayTool/SLMaskVideoPlayerLayer.h>
#else
    #import "SLMaskVideoPlayerLayer.h"
#endif

#if __has_include(<FLAnimatedImage/FLAnimatedImageView.h>)
    #import <FLAnimatedImage/FLAnimatedImageView.h>
#else
    #import "FLAnimatedImageView.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
    #import <Masonry/Masonry.h>
#else
    #import "Masonry.h"
#endif

#pragma mark - image
@interface XHLaunchAdImageView : UIView

@property (nonatomic, copy) void(^click)(CGPoint point);
// 图片容器View
@property (nonatomic,strong) FLAnimatedImageView *adImageContainView;
/// 底部展示View
/// @param bottomAdView bottomAdView description

-(void)insertBottomAdView:(UIView *)bottomAdView;

@end

#pragma mark - video
@interface XHLaunchAdVideoView : UIView

@property (nonatomic, copy) void(^click)(CGPoint point);


@property (nonatomic, strong) SLMaskVideoPlayerLayer *videoPlayer;
@property (nonatomic, assign) MPMovieScalingMode videoScalingMode;
@property (nonatomic, assign) AVLayerVideoGravity videoGravity;
@property (nonatomic, assign) BOOL videoCycleOnce;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, strong) NSURL *contentURL;

-(void)stopVideoPlayer;

/// 底部展示View
/// @param bottomAdView bottomAdView description

-(void)insertBottomAdView:(UIView *)bottomAdView;


@end

