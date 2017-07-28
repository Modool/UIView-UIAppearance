//
//  ViewController.m
//  test
//
//  Created by xulinfeng on 16/8/7.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "ViewController.h"
#import "UITestLabel.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *colorButton;

@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation ViewController

+ (void)load{
    [super load];
    
}

- (void)loadView{
    [super loadView];
    
    self.colorButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 500, 50, 40)];
    [[self colorButton] setTitle:@"color" forState:UIControlStateNormal];
    [[self colorButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self colorButton] addTarget:self action:@selector(didClickTest:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 500, 50, 40)];
    [[self addButton] setTitle:@"add" forState:UIControlStateNormal];
    [[self addButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self addButton] addTarget:self action:@selector(didClickAdd:) forControlEvents:UIControlEventTouchUpInside];
    
    self.clearButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 500, 50, 40)];
    [[self clearButton] setTitle:@"clear" forState:UIControlStateNormal];
    [[self clearButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self clearButton] addTarget:self action:@selector(didClickClear:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:[self colorButton]];
    [[self view] addSubview:[self addButton]];
    [[self view] addSubview:[self clearButton]];
}

#pragma mark - actions

static BOOL red = YES;
static NSUInteger count = 1;

- (IBAction)didClickTest:(id)sender{
    red = !red;
    
    UITestLabel.appearance.color = red ? [UIColor redColor] : [UIColor blueColor];
}

- (IBAction)didClickAdd:(id)sender{
    
    UITestLabel *textLabel = [[UITestLabel alloc] initWithFrame:CGRectMake(50, 10 + count * 50, 200, 40)];
    textLabel.text = [NSString stringWithFormat:@"test%d", count];
    textLabel.font = [UIFont systemFontOfSize:20];
    count++;
    
    [[self view] addSubview:textLabel];
}

- (IBAction)didClickClear:(id)sender{
    count = 0;
    for (UITestLabel *label in [[[self view] subviews] copy]) {
        if ([label isKindOfClass:[UITestLabel class]]) {
            [label removeFromSuperview];
        }
    }
}

@end
