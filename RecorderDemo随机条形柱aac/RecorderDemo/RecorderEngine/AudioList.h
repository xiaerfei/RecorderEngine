//
//  AudioList.h
//  RecorderDemo
//
//  Created by xiaerfei on 15/6/30.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioList : UIView

@property (nonatomic,copy) NSMutableArray *listAudioArray;
@property (nonatomic,assign) NSInteger numOfBins;

@property (nonatomic,assign) BOOL isPlay;

- (void)configUI;

-(void)refreshPeak:(double)peak;

- (void)setAllListHeightZero;
@end
