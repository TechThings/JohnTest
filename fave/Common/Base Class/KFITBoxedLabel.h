//
//  KFITBoxedLabel.h
//  KFIT
//
//  Created by Kevin Mun on 13/01/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFITLabel.h"

IB_DESIGNABLE
@interface KFITBoxedLabel : KFITLabel
@property(nonatomic, assign) UIEdgeInsets edgeInsets;
@property(nonatomic, strong) IBInspectable UIColor *borderColor;
@end
