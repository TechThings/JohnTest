////
////  KFITActivityPartnerReviewTableViewCell.m
////  KFIT
////
////  Created by Shiuh Yaw Phang on 24/11/2015.
////  Copyright © 2015 kfit. All rights reserved.
////
//
//#import "KFITActivityPartnerReviewTableViewCell.h"
//#import "KFITLabel.h"
//#import "KFITRatingView.h"
//#import "fave-swift.h"
//
//@interface KFITActivityPartnerReviewTableViewCell()
//@property (weak, nonatomic) IBOutlet UILabel *imageLabel;
//@property (weak, nonatomic) IBOutlet UIView *reviewView;
//@property (weak, nonatomic) IBOutlet KFITLabel *reviewerTitleLabel;
//@property (weak, nonatomic) IBOutlet KFITLabel *reviewerDateLabel;
//@property (weak, nonatomic) IBOutlet FaveRatingView *ratingView;
//
//@property (weak, nonatomic) IBOutlet KFITLabel *reviewerCommendLabel;
//@property (weak, nonatomic) IBOutlet UIView *separatorView;
//
//@end
//
//@implementation KFITActivityPartnerReviewTableViewCell
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//    self.reviewView.layer.cornerRadius = self.reviewView.frame.size.width / 2;
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
//
//- (void)setTitleForCell:(NSString*) reviewerName {
//    NSString *firstLetter = [reviewerName substringToIndex:1];
//    firstLetter = [firstLetter uppercaseString];
//    self.imageLabel.text = firstLetter;
//    
//    self.reviewerTitleLabel.text = reviewerName;
//    self.reviewerTitleLabel.letterSpacing = @(0.2);
//    
//}
//
//- (void)setRatingForCell:(double) ratingNumber {
//    [self.ratingView setRating:ratingNumber];
//}
//
//- (void)setCommentForCell:(NSString*)commentString {
//    self.reviewerCommendLabel.text = [NSString stringWithFormat:@"%@", commentString];
//    self.reviewerCommendLabel.lineSpacing = @2.5;
//    self.reviewerCommendLabel.textAlignment = NSTextAlignmentLeft;
//}
//
//- (void)setHideSeparator:(BOOL)hideSeparator {
//    self.separatorView.hidden = hideSeparator;
//}
//
//@end
