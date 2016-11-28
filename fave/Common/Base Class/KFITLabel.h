//
//  KFITLabel.h
//  KFIT
//
//  Created by KFIT on 5/20/15.
//  Copyright (c) 2015 kfit. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface KFITLabel : UILabel
@property (strong, nonatomic) NSNumber *lineSpacing;
@property (strong, nonatomic) NSNumber *letterSpacing;
@property (strong, nonatomic) NSNumber *lineHeightMultiple;
@property (assign, nonatomic) IBInspectable BOOL      strikeThrough;

- (void)replacePlaceholder:(NSString *)string withImage:(UIImage *)image;
@end
