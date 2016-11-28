//
//  KFITActivityPartnerReviewTableViewCell.h
//  KFIT
//
//  Created by Shiuh Yaw Phang on 24/11/2015.
//  Copyright © 2015 kfit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFITPartnerReview.h"

@interface KFITActivityPartnerReviewTableViewCell : UITableViewCell

- (void)setTitleForCell:(NSString*) reviewerName;

- (void)setRatingForCell:(double) ratingNumber;

- (void)setCommentForCell:(NSString*)commentString;

@property (nonatomic, assign) BOOL hideSeparator;
@end
