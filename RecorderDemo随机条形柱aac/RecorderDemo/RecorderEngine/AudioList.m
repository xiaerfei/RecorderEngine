//
//  AudioList.m
//  RecorderDemo
//
//  Created by xiaerfei on 15/6/30.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "AudioList.h"

@implementation AudioList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _listAudioArray = [[NSMutableArray alloc] init];
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2*2);
        self.transform = transform;
    }
    return self;
}

- (void)configUI
{
//    self.backgroundColor = [UIColor redColor];
    CGFloat pad = 1;
    CGFloat columWidth = (self.bounds.size.width-pad*_numOfBins)/_numOfBins;
    for (int i = 0; i < _numOfBins; i++) {
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake((columWidth + pad)*i, 0,columWidth, self.frame.size.height)];
        bg.backgroundColor = [UIColor colorWithRed:214.0f/225.0f green:214.0f/225.0f blue:215.0f/225.0f alpha:1];
        [self addSubview:bg];
        UIView *list = [[UIView alloc] initWithFrame:CGRectMake((columWidth + pad)*i, 0,columWidth, 0)];
        list.tag = 219+i;
        list.backgroundColor = [UIColor colorWithRed:32 / 255.0 green:151 / 255.0 blue:255 / 255.0 alpha:1];
        [self addSubview:list];
        [_listAudioArray addObject:list];
    }
}


-(void)refreshPeak:(double)peak
{
    //    NSLog(@"peak----->%f",peak);
    NSInteger index = 0;
    
    if (0<peak<=0.01) {
        index = 0;
    }else if (0.01<peak<=0.02) {
        index = 1;
    }else if (0.02<peak<=0.030) {
        index = 3;
    }else if (0.030<peak<=0.04) {
        index = 4;
    }else if (0.04<peak<=0.05) {
        index = 5;
    }else if (0.05<peak<=0.06) {
        index = 6;
    }else if (0.06<peak<=0.07) {
        index = 7;
    }else if (0.07<peak<=0.08) {
        index = 8;
    }else if (0.08<peak<=0.1) {
        index = 9;
    }
    [self viewHeightChangeWithIndex:index value:ceil(peak*1000000)];
    CGFloat perHeight = self.frame.size.height/15;
    for (int i = 0; i < _listAudioArray.count; i++) {
        
        UIView *listView = _listAudioArray[i];
        CGRect rect = listView.frame;
        rect.size.height -= perHeight;
        if (rect.size.height < 0) {
            rect.size.height = 0;
        }
        listView.frame = rect;
    }
}

- (void)viewHeightChangeWithIndex:(NSInteger)index value:(double)value
{
//    NSLog(@"%ld",(long)value);
    NSInteger valueInt = (long)value;
    if (_isPlay) {
        if (valueInt < 300) {
            return;
        }
    } else {
        if (valueInt < 10000) {
            return;
        }
    }

    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    while (valueInt > 10) {
        
        [array addObject:@(valueInt%10)];
        valueInt /= 10;
    }
    if (valueInt < 10) {
        [array addObject:@(valueInt)];
    }
    CGFloat perHeight = self.frame.size.height/10;
    for (NSNumber *number in array) {
        UIView *listView = _listAudioArray[[number integerValue]];
        CGRect rect = listView.frame;
        rect.size.height += perHeight;
        if (rect.size.height > self.frame.size.height) {
            rect.size.height = self.frame.size.height;
        }
        listView.frame = rect;
        
    }
}

- (void)setAllListHeightZero
{
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *list in _listAudioArray) {
            CGRect rect = list.frame;
            rect.size.height = 0;
            list.frame = rect;
        }
    }];

}




@end
