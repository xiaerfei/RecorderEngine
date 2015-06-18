//
//  RecorderEngine.m
//  录音
//
//  Created by xiaerfei on 15-5-25.
//  Copyright (c) 2015年 xiaerfei. All rights reserved.
//

#import "RecorderEngine.h"

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "VoiceConverter.h"

@implementation RecorderEngine
{
    NSString *_filaPath;
    NSDictionary *recorderSettingsDict;
    NSTimer *_timer;
    double lowPassResults;
    BOOL   _isRecorder;
    NSString *_currentRecorderName;
}

+(id)sharedEngine
{
    static RecorderEngine *_e = nil;
    if (!_e) {
        _e = [[RecorderEngine alloc]init];
    }
    return _e;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([[[UIDevice currentDevice]systemVersion]doubleValue]>=7.0) {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            if (session) {
                [session setActive:YES error:nil];
            }
        }
        _refrechTime = 1.0f;
    }
    return self;
}
-(void)setRefrechTime:(double)refrechTime
{
    _refrechTime = refrechTime;
    if (!_timer) {
        [self initTimer];
    }
}

- (void)initTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:_refrechTime target:self selector:@selector(refreshAction) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
}
#pragma mark - file path
/**
 *   @author xiaerfei
 *
 *   wav 格式文件路径
 *
 *   @param name 文件名
 *
 *   @return 文件路径
 */
- (NSString *)getRecorderOfWavPathWithName:(NSString *)name
{
    return [self getRecorderFilePathWithName:name isWav:YES];
}
/**
 *   @author xiaerfei
 *
 *   amr 格式文件路径
 *
 *   @param name 文件名
 *
 *   @return 文件路径
 */
- (NSString *)getRecorderOfAmrPathWithName:(NSString *)name
{
    return [self getRecorderFilePathWithName:name isWav:NO];
}

- (NSString *)getRecorderFilePathWithName:(NSString *)name isWav:(BOOL)isWav
{
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (isWav) {
        path = [[paths lastObject] stringByAppendingPathComponent:@"recorder/wav"];
    } else {
        path = [[paths lastObject] stringByAppendingPathComponent:@"recorder/amr"];
    }
    [self checkFilePathIsExists:path];
    return [path stringByAppendingPathComponent:[[name stringFromMD5] stringByAppendingString:isWav?@".wav":@".amr"]];
}
/**
 *   @author xiaerfei
 *
 *   检查文件目录是否存在 不存在就创建
 *
 *   @param path 文件目录
 *
 *   @return 是否存在
 */
- (BOOL)checkFilePathIsExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExits = [fileManager fileExistsAtPath:path];
    BOOL ret = NO;
    if (!fileExits) {
        NSError *error = nil;
        ret = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return ret;
}
#pragma mark - AVAudioRecorder
- (void)startRecorderWithName:(NSString *)recorderName
{
    _currentRecorderName = recorderName;
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:[self getRecorderOfWavPathWithName:recorderName]] settings:[VoiceConverter GetAudioRecorderSettingDict] error:nil];
    _recorder.delegate = self;
    if (!_timer) {
        [self initTimer];
    }
    if (_recorder) {
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [_recorder record];
        [_timer setFireDate:[NSDate distantPast]];
        _isRecorder = YES;
    }
    else
    {
//        NSLog(@"录音失败");
        if ([_delegate respondsToSelector:@selector(audioRecorderEncodeErrorWithEngine:error:)]) {
            [_delegate audioRecorderEncodeErrorWithEngine:self error:nil];
        }
    }

}

/**
 *   @author xiaerfei
 *
 *   声波 录音进度、播放进度
 */
-(void)refreshAction
{
    NSLog(@"timers-------------->");
    if (_isRecorder) {
        [_recorder updateMeters];
        const double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
        lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
        
        if ([_delegate respondsToSelector:@selector(recorderRefreshWithEngine:peak:)]) {
            [_delegate recorderRefreshWithEngine:self peak:[_recorder averagePowerForChannel:0]];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(audioPlayerProgressWithEngine:)]) {
            [_delegate audioPlayerProgressWithEngine:self];
        }
    }
}

-(void)stopRecorder
{
    [_timer setFireDate:[NSDate distantFuture]];
    [_recorder stop];
    
}
#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    // TODO: 转为amr格式...
    
    if ([VoiceConverter ConvertWavToAmr:[self getRecorderOfWavPathWithName:_currentRecorderName] amrSavePath:[self getRecorderOfAmrPathWithName:_currentRecorderName]]) {
        // wav 转 amr 成功
    } else {
        // wav 转 amr 失败
    }
    
    
    if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishWithEngine:)]) {
        [_delegate audioRecorderDidFinishWithEngine:self];
    }
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [_timer setFireDate:[NSDate distantFuture]];
    if ([_delegate respondsToSelector:@selector(audioRecorderEncodeErrorWithEngine:error:)]) {
        [_delegate audioRecorderEncodeErrorWithEngine:self error:error];
    }
}

#pragma mark - AVAudioPlayer
-(void)playRecorderWithName:(NSString *)name
{
    [_player stop];
    _player = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[self getRecorderOfWavPathWithName:name]] error:nil];
    _player.volume = 1.0f;
    _player.delegate = self;
    if (!_timer) {
        [self initTimer];
    }
}

- (void)audioPlay
{
    if (_player) {
        _isRecorder = NO;
        [_timer setFireDate:[NSDate distantPast]];
        [_player play];
    }
}

- (void)audioPause
{
    if (_player) {
        [_player pause];
    }
}

- (void)audioStop
{
    if (_player) {
        [_player stop];
    }
}
#pragma mark  AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_timer setFireDate:[NSDate distantFuture]];
    if ([_delegate respondsToSelector:@selector(audioPlayerDidFinishWithEngine:)]) {
        [_delegate audioPlayerDidFinishWithEngine:self];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [_timer setFireDate:[NSDate distantFuture]];
    if ([_delegate respondsToSelector:@selector(audioPlayerDecodeErrorWithEngine:error:)]) {
        [_delegate audioPlayerDecodeErrorWithEngine:self error:error];
    }
}
#pragma mark - 读取录音文件
- (NSData *)readRecorderDataWithName:(NSString *)name
{
    NSData *data = [NSData dataWithContentsOfFile:[self getRecorderOfAmrPathWithName:name]];
    return data;
}
#pragma mark - 删除录音
- (BOOL)deleteRecorderWithName:(NSString *)name
{
    BOOL ret = [self deleteFileWithPath:[self getRecorderOfAmrPathWithName:name]];
    ret = [self deleteFileWithPath:[self getRecorderOfWavPathWithName:name]];
    return  ret;
}

- (BOOL)deleteFileWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:path];
    if (ret) {
        NSError *error = nil;
        if ([fileManager removeItemAtPath:path error:&error]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - dealloc
-(void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}
@end






#if __has_feature(objc_arc)
#define SAFE_AUTORELEASE(a) (a)
#else
#define SAFE_AUTORELEASE(a) [(a) autorelease]
#endif
@implementation NSString(MD5Addition)

- (NSString *) stringFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return SAFE_AUTORELEASE(outputString);
}

@end


















