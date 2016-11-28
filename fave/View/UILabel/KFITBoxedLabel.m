////
////  KFITBoxedLabel.m
////  KFIT
////
////  Created by Kevin Mun on 13/01/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//#import "KFITBoxedLabel.h"
//#import "UIColor+KFIT.h"
//
//@interface KFITBoxedLabel()
//@property (nonatomic, assign) UIEdgeInsets originalEdgeInsets;
//@end
//
//@implementation KFITBoxedLabel
////
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if(self) {
//        [self load];
//    }
//    return self;
//}
////
//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if(self) {
//        [self load];
//    }
//    return self;
//}
////
//- (void)awakeFromNib {
//    [super awakeFromNib];
//    [self loadWhenAwake];
//}
////
//- (void)load {
//    self.edgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
//    self.originalEdgeInsets = self.edgeInsets;
//}
////
//- (void)loadWhenAwake {
//    self.layer.borderWidth = 0.5;
//    self.layer.cornerRadius = 2;
//    if(self.borderColor!=nil){
//        self.layer.borderColor = [self.borderColor CGColor];
//    }
//}
//
////
//- (void)setHidden:(BOOL)hidden {
//    [super setHidden:hidden];
//    [self invalidateIntrinsicContentSize];
//}
////
//- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
//    _edgeInsets = edgeInsets;
//    self.originalEdgeInsets = _edgeInsets;
//}
//
//- (void)drawTextInRect:(CGRect)rect {
//    if(self.hidden) {
//        _edgeInsets = UIEdgeInsetsZero;
//    } else {
//        _edgeInsets = self.originalEdgeInsets;
//    }
//    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
//}
////
//- (CGSize)intrinsicContentSize
//{
//    if(self.hidden) {
//        _edgeInsets = UIEdgeInsetsZero;
//    } else {
//        _edgeInsets = self.originalEdgeInsets;
//    }
//    CGSize size = [super intrinsicContentSize];
//    size.width  += self.edgeInsets.left + self.edgeInsets.right;
//    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
//    return size;
//}
//
//@end
