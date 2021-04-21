//
//  XHLaunchAdView.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 16/12/3.
//  Copyright © 2016年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import "XHLaunchAdView.h"
#import "XHLaunchAdConst.h"
#import "XHLaunchImageView.h"
#import "XHLaunchAdConfiguration.h"
static NSString *const VideoPlayStatus = @"status";

@interface XHLaunchAdImageView ()


/// 底部展示View
@property (nonatomic,strong) UIView *bottomAdView;
@end

@implementation XHLaunchAdImageView

-(FLAnimatedImageView *)adImageContainView{
    if (!_adImageContainView) {
        _adImageContainView = [FLAnimatedImageView new];
    }
    return _adImageContainView;
}
- (id)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.frame = [UIScreen mainScreen].bounds;
        self.layer.masksToBounds = YES;
        [self addSubview:self.adImageContainView];
        [_adImageContainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.backgroundColor = UIColor.clearColor;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

-(void)tap:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self];
    if(self.click) self.click(point);
}
/// 底部展示View
/// @param bottomAdView bottomAdView description

-(void)insertBottomAdView:(UIView *)bottomAdView{
    [self addSubview:bottomAdView];
    [self.adImageContainView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(@0);
        make.bottom.equalTo(bottomAdView.mas_top);
    }];
    [bottomAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(@0);
        make.width.equalTo(bottomAdView.mas_height).multipliedBy(375.f/106.f);
    }];
}
@end

#pragma mark - videoAdView
@interface XHLaunchAdVideoView ()<UIGestureRecognizerDelegate,maskVideoPlayDelegate>

/// 视频容器View
@property (nonatomic,strong) UIView *videoContainView;

/// 底部展示View
@property (nonatomic,strong) UIView *bottomAdView;

@end

@implementation XHLaunchAdVideoView

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.frame = [UIScreen mainScreen].bounds;
//        [self addSubview:self.videoPlayer.view];
        [self addSubview:self.videoContainView];
        [_videoContainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.videoContainView.layer addSublayer:self.videoPlayer];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

-(void)tap:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self];
    if(self.click) self.click(point);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - Action
-(void)stopVideoPlayer{
    if(_videoPlayer==nil) return;
    [_videoPlayer pause];
//    [_videoPlayer.view removeFromSuperview];
    _videoPlayer = nil;
    
    /** 释放音频焦点 */
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)runLoopTheMovie:(NSNotification *)notification{
    //需要循环播放
    if(!_videoCycleOnce){
//        [(AVPlayerItem *)[notification object] seekToTime:kCMTimeZero];
//        [_videoPlayer.player play];//重播
        [_videoPlayer play];
    }
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:VideoPlayStatus]){
        NSInteger newStatus = ((NSNumber *)change[@"new"]).integerValue;
        if (newStatus == AVPlayerItemStatusFailed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:XHLaunchAdVideoPlayFailedNotification object:nil userInfo:@{@"videoNameOrURLString":_contentURL.absoluteString}];
        }
    }
}

#pragma mark - lazy
-(SLMaskVideoPlayerLayer *)videoPlayer{
    if(_videoPlayer==nil){
        _videoPlayer = [SLMaskVideoPlayerLayer layer];
//        _videoPlayer.showsPlaybackControls = NO;
        _videoPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//        _videoPlayer.view.frame = [UIScreen mainScreen].bounds;
//        _videoPlayer.view.backgroundColor = [UIColor clearColor];
        _videoPlayer.repeatCount = _videoCycleOnce ? -1:1;
        _videoPlayer.playDelegate = self;
        //注册通知控制是否循环播放
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        /** 获取音频焦点 */
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    return _videoPlayer;
}

/// 底部展示View
-(UIView *)bottomAdView{
    if (!_bottomAdView) {
        _bottomAdView = [UIView new];
        _bottomAdView.backgroundColor = UIColor.clearColor;
    }
    return _bottomAdView;
}

/// 视频容器View
-(UIView *)videoContainView{
    if (!_videoContainView) {
        _videoContainView = [UIView new];
        _videoContainView.backgroundColor = UIColor.clearColor;
    }
    return _videoContainView;
}
#pragma mark - set
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _videoPlayer.frame = self.frame;
}

- (void)setContentURL:(NSURL *)contentURL {
    _contentURL = contentURL;
    _videoPlayer.videoURL = contentURL;
    [_videoPlayer play];
//    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:contentURL options:nil];
//    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//    _videoPlayer.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//    // 监听播放失败状态
//    [self.playerItem addObserver:self forKeyPath:VideoPlayStatus options:NSKeyValueObservingOptionNew context:nil];
}
-(void)setVideoGravity:(AVLayerVideoGravity)videoGravity{
    _videoGravity = videoGravity;
    _videoPlayer.videoGravity = videoGravity;
}
-(void)setMuted:(BOOL)muted{
    _muted = muted;
    _videoPlayer.player.muted = muted;
}
-(void)setVideoScalingMode:(MPMovieScalingMode)videoScalingMode{
    _videoScalingMode = videoScalingMode;
    switch (_videoScalingMode) {
        case MPMovieScalingModeNone:{
            _videoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
        }
            break;
        case MPMovieScalingModeAspectFit:{
            _videoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
        }
            break;
        case MPMovieScalingModeAspectFill:{
            _videoPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }
            break;
        case MPMovieScalingModeFill:{
            _videoPlayer.videoGravity = AVLayerVideoGravityResize;
        }
            break;
        default:
            break;
    }
}
-(void)maskVideoDidPlayFinish:(SLMaskVideoPlayerLayer *)playerLayer{
#if DEBUG
    NSLog(@"播放完成");
#endif
}

/// 底部展示View
/// @param bottomAdView bottomAdView description

-(void)insertBottomAdView:(UIView *)bottomAdView{
    [self addSubview:bottomAdView];
    [self.videoContainView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(@0);
        make.bottom.equalTo(bottomAdView.mas_top);
    }];
    [bottomAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(@0);
        make.width.equalTo(bottomAdView.mas_height).multipliedBy(375.f/106.f);
    }];
}
@end

