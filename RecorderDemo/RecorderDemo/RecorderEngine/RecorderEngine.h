//
//  RecorderEngine.h
//  录音
//
//  Created by xiaerfei on 15-5-25.
//  Copyright (c) 2015年 xiaerfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class RecorderEngine;

@protocol RecorderDelegate <NSObject>
@optional
/******************录制音频Delegate***********************/
//录音结束
- (void)audioRecorderDidFinishWithEngine:(RecorderEngine *)engine;
//录音编码出错
- (void)audioRecorderEncodeErrorWithEngine:(RecorderEngine *)engine error:(NSError *)error;
//录音声波 或者进度条
- (void)recorderRefreshWithEngine:(RecorderEngine *)engine peak:(double)peak;
/******************播放音频Delegate***********************/
//播放结束
- (void)audioPlayerDidFinishWithEngine:(RecorderEngine *)engine;
//播放编码出错
- (void)audioPlayerDecodeErrorWithEngine:(RecorderEngine *)engine error:(NSError *)error;
//播放进度条
- (void)audioPlayerProgressWithEngine:(RecorderEngine *)engine;
/******************转为amr Delegate***********************/
- (void)convertRecorderToAmrSuccessWithEngine:(RecorderEngine *)engine;
- (void)convertRecorderToAmrFailedWithEngine:(RecorderEngine *)engine;
@end

@interface RecorderEngine : NSObject <AVAudioPlayerDelegate,AVAudioRecorderDelegate>
/// 定时器刷新时间
@property (nonatomic,assign) double refrechTime;

@property (nonatomic,copy) NSString *recorderFileName;

@property (nonatomic,strong) AVAudioRecorder *recorder;

@property (nonatomic,strong) AVAudioPlayer   *player;


@property (nonatomic,weak) id<RecorderDelegate> delegate;

+(id)sharedEngine;

/******************录制音频***********************/
- (void)startRecorderWithName:(NSString *)recorderName;

- (void)stopRecorder;

/******************播放音频***********************/
- (void)playRecorderWithName:(NSString *)name;

- (void)audioPlay;

- (void)audioPause;

- (void)audioStop;
/******************得到该录音文件的路径***********************/
/// wav格式的路径
- (NSString *)getRecorderOfWavPathWithName:(NSString *)name;
/// amr格式的路径
- (NSString *)getRecorderOfAmrPathWithName:(NSString *)name;

/******************读取录音文件***********************/
- (NSData *)readRecorderDataWithName:(NSString *)name;

/******************删除录音***********************/
- (BOOL)deleteRecorderWithName:(NSString *)name;

@end



@interface NSString(MD5Addition)

- (NSString *) stringFromMD5;

@end
