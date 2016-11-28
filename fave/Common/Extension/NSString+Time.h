//
//  NSString+Time.h
//  KFIT
//
//  Created by KFIT on 5/17/15.
//  Copyright (c) 2015 kfit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Time)

+ (NSDate *)dateFromRFC3339DateTimeString:(NSString *)RFC3339DateTimeString;
+ (NSString *)RFC3339DateTimeStringFromDate:(NSDate *)date;
+ (NSString *)stringFrom:(NSString *)fromTime to:(NSString *)toTime;
+ (NSString *)userVisibleHoursMinutesForTimeString:(NSString *)rfc3339DateTimeString;
+ (NSDate *)kfitDate:(NSString *)string;
+ (NSString *)userVisibleHoursMinutesFromDate:(NSDate *)date;
+ (NSString *)stringFromDateMonth:(NSDate *)aDate;
+ (NSString *)stringFromDateMonthDay:(NSDate *)aDate;
+ (NSString *)stringFromDateCancelDay:(NSDate *)aDate;
+ (NSString*)ordinalNumberFormat:(NSNumber *)numObj;
+ (NSString *)userVisibleDate:(NSDate *)date;
+ (NSString *)stringFromTimePromotionInterval:(NSTimeInterval)timeInterval;
+ (NSString *)stringMinutesFromTimePromotionInterval:(NSTimeInterval)timeInterval;
+ (NSString *)userVisibleTime24StringFromDate:(NSDate *)date;
+ (NSString *)userVisibleLongWeekDayStringFromDate:(NSDate *)date;
+ (NSString *)APIDateStringFromDate:(NSDate *)date;
+ (NSString *)APIMonthDateStringFromDate:(NSDate *)date;
+ (NSDate*)dateFromString:(NSString*)aStr;
+ (NSString *)stringFromDate:(NSDate *)aDate;
+ (NSString *)elapsedDurationWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
@end
