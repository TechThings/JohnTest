//
//  KFITStepper.h
//  KFIT
//
//  Created by Kevin Mun on 14/01/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface KFITStepper : UIControl
@property(nonatomic, assign) IBInspectable int maxCount;
@property(nonatomic, assign) IBInspectable int minCount;

- (int)getCurrentCount;

- (void)setMessage:(NSString *)message;
@end
