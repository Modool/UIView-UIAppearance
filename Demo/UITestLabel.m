//
//  UITestLabel.m
//  test
//
//  Created by Jave on 2017/7/28.
//  Copyright © 2017年 Marike Jave. All rights reserved.
//

#import "UITestLabel.h"

@implementation UITestLabel

- (void)setColor:(UIColor *)color{
    self.textColor = color;
}

- (UIColor *)color {
    return [self textColor];
}

- (BOOL)allowSynchronizeAppreance{
    return YES;
}

@end
