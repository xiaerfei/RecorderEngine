//
//  ViewController.m
//  RecorderDemo
//
//  Created by xiaerfei on 15/6/10.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ViewController.h"
#import "RecorderEngine.h"

@interface ViewController ()<RecorderDelegate>
@property (nonatomic,strong) RecorderEngine *recorder;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)ReadData:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *link;

@property (strong, nonatomic) UIView *listView;

@end

@implementation ViewController
{
    NSMutableArray *_listArray;
    AVPlayer *mp3Player;
    AVPlayerItem *mp3PlayerItem;
    id audioMix;
    id volumeMixInput;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",NSHomeDirectory());
    //http://yinyueshiting.baidu.com/data2/music/242137426/242137130180000128.mp3?xcode=8419f3b67a3fb62e84b505fb6b038464
    RecorderEngine *recorder = [RecorderEngine sharedEngine];
    recorder.delegate = self;
    self.recorder = recorder;
    recorder.rightListView.frame = CGRectMake(0, 100, 60, 40);
    [recorder.rightListView configUI];
    [self.view addSubview:recorder.rightListView];
    recorder.leftListView.frame = CGRectMake(200, 100, 60, 40);
    [recorder.leftListView configUI];
    [self.view addSubview:recorder.leftListView];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],@"HAHA"];
    NSLog(@"filePath %@",filePath);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://192.168.253.33:82//Uploads/ElectronicAuthorizeInfo/431ecf04-c5cb-40e2-a412-4d79b15a4841.mp3"]];
    [data writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.mp3"] atomically:NO];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
    [self.recorder startRecorderWithName:@"recorder"];
    [self.recorder startRecorder];
}

- (IBAction)stop:(id)sender {
    [self.recorder stopRecorder];
//    [self.recorder netPlayPause];
}

- (IBAction)play:(id)sender {
    [self.recorder playRecorderWithName:@"recorder"];
    [self.recorder audioPlay];
    self.link.text = [NSString stringWithFormat:@"%f",self.recorder.player.duration];
    
//    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:@"http://sc1.111ttt.com/2015/1/07/02/100021232391.mp3"]];
//    [player play];
//    [self.recorder netPlayWithURL:@"http://192.168.253.33:82/Uploads/ElectronicAuthorizeInfo/c7ffa711-7338-4777-a27f-fb65e6d07034.mp3"];
    
}



- (IBAction)delete:(id)sender {
    [self.recorder deleteRecorderWithName:@"recorder"];
}

- (IBAction)ReadData:(id)sender {
    NSData *data = [self.recorder readRecorderDataWithName:@"recorder"];
    NSLog(@"%@",data);
}

#pragma mark - RecorderDelegate
- (void)audioRecorderDidFinishWithEngine:(RecorderEngine *)engine
{
    NSLog(@"录音结束了");
}
- (void)audioRecorderEncodeErrorWithEngine:(RecorderEngine *)engine error:(NSError *)error
{
    NSLog(@"录音失败了");
}

- (void)audioPlayerDidFinishWithEngine:(RecorderEngine *)engine
{
    NSLog(@"播放结束了");
}
- (void)audioPlayerDecodeErrorWithEngine:(RecorderEngine *)engine error:(NSError *)error
{
    NSLog(@"播放出错了");
}

- (void)audioProgressWithEngine:(RecorderEngine *)engine currentTime:(NSTimeInterval)currentTime
{
    NSLog(@"播放成功 alltime = %f",engine.duration);
    NSLog(@"当前进度-->%f",currentTime);
}

- (void)netPlayerDidPlaySuccessWithEngine:(RecorderEngine *)engine
{
    
    NSLog(@"播放成功 alltime = %f",engine.duration);
}
- (void)netPlayerDidPlayFailWithEngine:(RecorderEngine *)engine error:(NSString *)error
{
    NSLog(@"播放失败--%@",error);
}
- (void)netPlayerDidPlayEndWithEngine:(RecorderEngine *)engine
{
    NSLog(@"播放结束");
}
//播放进度
- (void)netPlayerDidPlayWithEngine:(RecorderEngine *)engine progress:(NSString *)progress
{
    NSLog(@"播放进度--->%@",progress);
}
//缓冲进度
- (void)netPlayerDidPlayWithEngine:(RecorderEngine *)engine
                 availableDuration:(NSString *)availableDuration //缓冲进度时间
                     totalDuration:(NSString *)totalDuration    //总时间
{
    NSLog(@"总时间-->%@      缓冲时间-->%@",totalDuration,availableDuration);
}





@end
