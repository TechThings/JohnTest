//
//  KFITStepper.m
//  KFIT
//
//  Created by Kevin Mun on 14/01/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

#import "KFITStepper.h"

@interface KFITStepper ()
@property(weak, nonatomic) IBOutlet UILabel *countLabel;
@property(weak, nonatomic) IBOutlet UIButton *decrementButton;
@property(weak, nonatomic) IBOutlet UIButton *incrementButton;
@property(weak, nonatomic) IBOutlet UILabel *messageLabel;

@property(assign, nonatomic) int currentCount;

@end

@implementation KFITStepper
int DEFAULT_MINCOUNT = 0;
int DEFAULT_MAXCOUNT = 10;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initalizeSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self initalizeSubviews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self load];
}

- (void)initalizeSubviews {
    NSString *nibName = NSStringFromClass([self class]);
    UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:nibName owner:self options:nil] firstObject];
    view.frame = self.bounds;
    [self addSubview:view];
    _currentCount = DEFAULT_MINCOUNT;
    _minCount = DEFAULT_MINCOUNT;
    _maxCount = DEFAULT_MAXCOUNT;
}

- (void)load {
    self.currentCount = self.minCount;
    self.messageLabel.hidden = YES;
}

- (IBAction)decrementButtonDidTapped:(id)sender {
    if (self.currentCount > self.minCount) {
        self.currentCount -= 1;
    }
    [self checkButtonState];
}

- (IBAction)incrementButtonDidTapped:(id)sender {
    if (self.currentCount < self.maxCount) {
        self.currentCount += 1;
    }
    [self checkButtonState];
}

- (void)checkButtonState {
    if (self.currentCount > self.minCount) {
        self.decrementButton.enabled = YES;
        self.decrementButton.alpha = 1.0;
    } else {
        self.decrementButton.enabled = NO;
        self.decrementButton.alpha = 0.5;
    }

    if (self.currentCount < self.maxCount) {
        self.incrementButton.enabled = YES;
        self.incrementButton.alpha = 1.0;
    } else {
        self.incrementButton.enabled = NO;
        self.incrementButton.alpha = 0.5;
    }
}

- (void)setCurrentCount:(int)currentCount {
    _currentCount = currentCount;
    self.countLabel.text = [[NSNumber numberWithInt:_currentCount] stringValue];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setMinCount:(int)minCount {
    _minCount = minCount;
    if (self.currentCount < _minCount) {
        self.currentCount = _minCount;
    }
    [self checkButtonState];
}

- (void)setMaxCount:(int)maxCount {
    _maxCount = maxCount;
    if (self.currentCount > _maxCount) {
        self.currentCount = _maxCount;
    }
    [self checkButtonState];
}

- (void)setMessage:(NSString *)message {
    if ([message length] != 0) {
        self.messageLabel.text = message;
        self.messageLabel.hidden = NO;
    } else {
        self.messageLabel.hidden = YES;
    }
}

- (int)getCurrentCount {
    return self.currentCount;
}


@end
