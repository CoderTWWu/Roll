//
//  MyLabel.m
//  类似网易新闻的频道切换
//
//  Created by wtw on 15/11/11.
//  Copyright © 2015年 jjl. All rights reserved.
//

#define MyScale(scale) (scale * 0.2 + 0.8)

#import "MyLabel.h"

@implementation MyLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textColor = [UIColor redColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = YES;
        self.scale = 0.0;
    }
    return self;
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    
    self.transform = CGAffineTransformMakeScale(MyScale(scale), MyScale(scale));
    self.textColor = [UIColor colorWithRed:1 - scale green:0 blue:scale alpha:1.0];
}

@end
