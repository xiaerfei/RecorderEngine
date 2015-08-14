//
//  RecorderEngine.h
//  录音
//
//  Created by xiaerfei on 15-5-25.
//  Copyright (c) 2015年 xiaerfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioList.h"
@class RecorderEngine;

@protocol RecorderDelegate <NSObject>
@optional
/******************录制音频Delegate***********************/
//录音结束
- (void)audioRecorderDidFinishWithEngine:(RecorderEngine *)engine;
//录音编码出错
- (void)audioRecorderEncodeErrorWithEngine:(RecorderEngine *)engine error:(NSError *)error;
/******************播放音频Delegate***********************/
//播放结束
- (void)audioPlayerDidFinishWithEngine:(RecorderEngine *)engine;
//播放编码出错
- (void)audioPlayerDecodeErrorWithEngine:(RecorderEngine *)engine error:(NSError *)error;
//进度条
- (void)audioProgressWithEngine:(RecorderEngine *)engine currentTime:(NSTimeInterval)currentTime;
/******************URL播放音频Delegate***********************/
- (void)netPlayerDidPlaySuccessWithEngine:(RecorderEngine *)engine;
- (void)netPlayerDidPlayFailWithEngine:(RecorderEngine *)engine error:(NSString *)error;
- (void)netPlayerDidPlayEndWithEngine:(RecorderEngine *)engine;
//播放进度
- (void)netPlayerDidPlayWithEngine:(RecorderEngine *)engine progress:(NSString *)progress;
//缓冲进度
- (void)netPlayerDidPlayWithEngine:(RecorderEngine *)engine
                 availableDuration:(NSString *)availableDuration //缓冲进度时间
                     totalDuration:(NSString *)totalDuration;    //总时间
@end

@interface RecorderEngine : NSObject <AVAudioPlayerDelegate,AVAudioRecorderDelegate>
/// 定时器刷新时间
@property (nonatomic,assign) double refrechTime;

@property (nonatomic,copy) NSString *recorderFileName;

@property (nonatomic,strong) AVAudioRecorder *recorder;

@property (nonatomic,strong) AVAudioPlayer   *player;

@property (nonatomic,strong) AVPlayer *mp3Player;
//播放时长 调用playRecorderWithName方法之后才能获得
@property (nonatomic,assign) double duration;

@property (nonatomic,strong) AudioList *leftListView;
@property (nonatomic,strong) AudioList *rightListView;

@property (nonatomic,weak) id<RecorderDelegate> delegate;

+(id)sharedEngine;

/******************录制音频***********************/
- (void)startRecorderWithName:(NSString *)recorderName;

- (void)startRecorder;

- (void)stopRecorder;

/******************播放音频***********************/
- (void)playRecorderWithName:(NSString *)name;

- (void)audioPlay;

- (void)audioPause;

- (void)audioStop;
/******************URL播放音频***********************/
- (void)netPlayWithURL:(NSString *)url;
- (void)netPlayPause;
/******************得到该录音文件的路径***********************/

/******************读取录音文件***********************/
- (NSData *)readRecorderDataWithName:(NSString *)name;

/******************删除录音***********************/
- (BOOL)deleteRecorderWithName:(NSString *)name;

@end



@interface NSString(MD5Addition)

- (NSString *) stringFromMD5;

@end
