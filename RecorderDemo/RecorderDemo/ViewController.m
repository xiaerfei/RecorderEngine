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


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RecorderEngine *recorder = [RecorderEngine sharedEngine];
    recorder.delegate = self;
    self.recorder = recorder;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
    [self.recorder startRecorderWithName:@"recorder"];
}

- (IBAction)stop:(id)sender {
    [self.recorder stopRecorder];
}

- (IBAction)play:(id)sender {
    [self.recorder playRecorderWithName:@"recorder"];
    [self.recorder audioPlay];
    self.link.text = [NSString stringWithFormat:@"%f",self.recorder.player.duration];
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

-(void)recorderRefreshWithEngine:(RecorderEngine *)engine peak:(double)peak
{
    self.link.text = [NSString stringWithFormat:@"%f",peak];
}

- (void)audioPlayerDidFinishWithEngine:(RecorderEngine *)engine
{
    NSLog(@"播放结束了");
}
- (void)audioPlayerDecodeErrorWithEngine:(RecorderEngine *)engine error:(NSError *)error
{
    NSLog(@"播放出错了");
}

- (void)audioPlayerProgressWithEngine:(RecorderEngine *)engine
{
    self.link.text = [NSString stringWithFormat:@"%f",engine.player.currentTime];
}

@end
