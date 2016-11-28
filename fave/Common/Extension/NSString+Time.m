//
//  NSString+Time.m
//  KFIT
//
//  Created by KFIT on 5/17/15.
//  Copyright (c) 2015 kfit. All rights reserved.
//

#import "NSString+Time.h"

@implementation NSString (Time)
static NSString * const RFC3339DateFormatFractional = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
static NSString * const RFC3339DateFormat           = @"yyyy-MM-dd'T'HH:mm:ssZ";

static NSString * const DateOnlyAPIFormat           = @"yyyy-MM-dd";

static NSString * const DateMonthOnlyAPIFormat      = @"dd MMM yyyy";

static NSString * const TimeOnly24hFormat           = @"HH':'mm";

+ (NSDate *)dateFromRFC3339DateTimeString:(NSString *)RFC3339DateTimeString
{
    static NSDateFormatter *RFC3339DateFormatter;
    if (RFC3339DateFormatter == nil) {
        RFC3339DateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [RFC3339DateFormatter setLocale:enUSPOSIXLocale];
    }
    //fractional seconds are optional in RFC339
    [RFC3339DateFormatter setDateFormat:RFC3339DateFormatFractional];
    NSDate *date = [RFC3339DateFormatter dateFromString:RFC3339DateTimeString];
    if(date == nil) {
        [RFC3339DateFormatter setDateFormat:RFC3339DateFormat];
        date = [RFC3339DateFormatter dateFromString:RFC3339DateTimeString];
    }
    
    return date;
}

+ (NSString *)RFC3339DateTimeStringFromDate:(NSDate *)date
{
    static NSDateFormatter *RFC3339DateFormatter;
    if (RFC3339DateFormatter == nil) {
        RFC3339DateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [RFC3339DateFormatter setLocale:enUSPOSIXLocale];
    }
    //fractional seconds are optional in RFC339
    [RFC3339DateFormatter setDateFormat:RFC3339DateFormatFractional];
    NSString *RFC3339DateTimeString = [RFC3339DateFormatter stringFromDate:date];
    if([RFC3339DateTimeString length] == 0) {
        [RFC3339DateFormatter setDateFormat:RFC3339DateFormat];
        RFC3339DateTimeString = [RFC3339DateFormatter stringFromDate:date];
    }
    
    return RFC3339DateTimeString;
}

+ (NSString *)APIMonthDateStringFromDate:(NSDate *)date
{
    static NSDateFormatter *APIDateFormatter;;
    if (APIDateFormatter == nil) {
        APIDateFormatter = [[NSDateFormatter alloc] init];
        [APIDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [APIDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [APIDateFormatter setDateFormat:DateMonthOnlyAPIFormat];
    }
    NSString *APIDateString = [APIDateFormatter stringFromDate:date];
    return APIDateString;
}

+ (NSString *)APIDateStringFromDate:(NSDate *)date
{
    static NSDateFormatter *APIDateFormatter;;
    if (APIDateFormatter == nil) {
        APIDateFormatter = [[NSDateFormatter alloc] init];
        [APIDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [APIDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [APIDateFormatter setDateFormat:DateOnlyAPIFormat];
    }
    NSString *APIDateString = [APIDateFormatter stringFromDate:date];
    return APIDateString;
}

+ (NSString *)userVisibleTime24StringFromDate:(NSDate *)date
{
    static NSDateFormatter *userVisibleTimeDateFormater;
    if (userVisibleTimeDateFormater == nil) {
        userVisibleTimeDateFormater = [[NSDateFormatter alloc] init];
        [userVisibleTimeDateFormater setTimeZone:[NSTimeZone localTimeZone]];
        [userVisibleTimeDateFormater setDateFormat:TimeOnly24hFormat];
    }
    NSString *userVisibleTimeString = [userVisibleTimeDateFormater stringFromDate:date];
    return userVisibleTimeString;
}

+ (NSString *)userVisibleLongWeekDayStringFromDate:(NSDate *)date
{
    static NSDateFormatter *userVisibleLongWeekDayDateFormater;
    if (userVisibleLongWeekDayDateFormater == nil) {
        userVisibleLongWeekDayDateFormater = [[NSDateFormatter alloc] init];
        [userVisibleLongWeekDayDateFormater setTimeZone:[NSTimeZone localTimeZone]];
        [userVisibleLongWeekDayDateFormater setDateFormat:@"EEEE"];
    }
    NSString *userVisibleLongWeekDayString = [userVisibleLongWeekDayDateFormater stringFromDate:date];
    return userVisibleLongWeekDayString;
}

+ (NSDate *) toLocalTime:(NSDate *)date
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

+ (NSDate *)kfitDate:(NSString *)string
{
    static NSDateFormatter *    sRFC3339DateFormatter;
    NSDate *                    date;
    
    if (sRFC3339DateFormatter == nil) {
        sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
        [sRFC3339DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    date = [sRFC3339DateFormatter dateFromString:string];
    return date;
}

+ (NSString *)userVisibleHoursMinutesForTimeString:(NSString *)rfc3339DateTimeString
// Returns a user-visible date time string that corresponds to the
// specified RFC 3339 date time string. Note that this does not handle
// all possible RFC 3339 date time strings, just one of the most common
// styles.
{
    static NSDateFormatter *    sRFC3339DateFormatter;
    static NSDateFormatter *    sUserVisibleDateFormatter;
    NSString *                  userVisibleDateTimeString;
    NSDate *                    date;
    // If the date formatters aren't already set up, do that now and cache them
    // for subsequence reuse.
    
    if (sRFC3339DateFormatter == nil) {
        sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
        [sRFC3339DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [sRFC3339DateFormatter setDateFormat:@"HH':'mm"];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    if (sUserVisibleDateFormatter == nil) {
        sUserVisibleDateFormatter = [[NSDateFormatter alloc] init];
        [sUserVisibleDateFormatter setDateFormat:@"HH':'mm  a"];
    }
    // Convert the RFC 3339 date time string to an NSDate.
    // Then convert the NSDate to a user-visible date string.
    userVisibleDateTimeString = nil;
    date = [sRFC3339DateFormatter dateFromString:rfc3339DateTimeString];
    if (date != nil) {
        userVisibleDateTimeString = [sUserVisibleDateFormatter stringFromDate:date];
    }
    return userVisibleDateTimeString;
}

+ (NSString *)userVisibleHoursMinutesFromDate:(NSDate *)date
{
    static NSDateFormatter *    sUserVisibleDateFormatter;
    NSString *                  userVisibleDateTimeString;
    if (sUserVisibleDateFormatter == nil) {
        sUserVisibleDateFormatter = [[NSDateFormatter alloc] init];
        //[sUserVisibleDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [sUserVisibleDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
        [sUserVisibleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [sUserVisibleDateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    }
    userVisibleDateTimeString = nil;
    if (date != nil) {
        userVisibleDateTimeString = [sUserVisibleDateFormatter stringFromDate:date];
    }
    return userVisibleDateTimeString;
}

+ (NSDate*)dateFromString:(NSString*)aStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate   *aDate = [dateFormatter dateFromString:aStr];
    return aDate;
}

+ (NSString *)stringFromDate:(NSDate *)aDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString   *aString = [dateFormatter stringFromDate:aDate];
    return aString;
}

+ (NSString *)stringFromDateMonth:(NSDate *)aDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString *localeFormatString = [NSDateFormatter dateFormatFromTemplate:@"dMMM yyyy" options:0 locale:dateFormatter.locale];
    dateFormatter.dateFormat = localeFormatString;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString   *aString = [dateFormatter stringFromDate:aDate];
    return aString;
}

+ (NSString *)stringFromDateMonthDay:(NSDate *)aDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *localeFormatString = [NSDateFormatter dateFormatFromTemplate:@"E, dMMM yyyy" options:0 locale:dateFormatter.locale];
    dateFormatter.dateFormat = localeFormatString;
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString   *aString = [dateFormatter stringFromDate:aDate];
    return aString;
}

+ (NSString *)stringFromDateCancelDay:(NSDate *)aDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *localeFormatString = [NSDateFormatter dateFormatFromTemplate:@"E, d MMM yyyy, hh':'mm" options:0 locale:dateFormatter.locale];
    dateFormatter.dateFormat = localeFormatString;
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString   *aString = [dateFormatter stringFromDate:aDate];
    return aString;
}

+ (NSString *)stringFrom:(NSString *)fromTime to:(NSString *)toTime
{
    NSString *stringTime = @"";
    if ([fromTime length] > 0 && [toTime length] > 0) {
        stringTime = [[fromTime stringByAppendingString:@" - "] stringByAppendingString:toTime];
    }
    if ([fromTime length] > 0 && [toTime length] <= 0) {
        stringTime = fromTime;
    }
    if ([fromTime length] <= 0 && [toTime length] > 0) {
        stringTime = toTime;
    }
    return stringTime;
}

+ (NSString *)userVisibleDate:(NSDate *)date
{
    static NSDateFormatter *    sUserVisibleDateFormatter;
    NSString *                  userVisibleDateTimeString;
    if (sUserVisibleDateFormatter == nil) {
        sUserVisibleDateFormatter = [[NSDateFormatter alloc] init];
        [sUserVisibleDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [sUserVisibleDateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss Z"];
    }
    userVisibleDateTimeString = nil;
    if (date != nil) {
        [sUserVisibleDateFormatter setDateFormat:@"dd'-'MMM'-'yyyy"];
        userVisibleDateTimeString = [sUserVisibleDateFormatter stringFromDate:date];
    }
    return userVisibleDateTimeString;
}

+ (NSString*)ordinalNumberFormat:(NSNumber *)numObj {
    NSString *ending;
    NSInteger num = [numObj integerValue];
    
    NSInteger ones = num % 10;
    NSInteger tens = floor(num / 10);
    tens = tens % 10;
    
    if(tens == 1){
        ending = @"th";
    } else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    
    return [NSString stringWithFormat:@"%zd%@", num, ending];
}

+ (NSString *)stringFromTimePromotionInterval:(NSTimeInterval)timeInterval {
    if(timeInterval <= 0){
        return @"00:00:00";
    } else {
        div_t hourStruct = div(timeInterval, 3600);
        int hours = hourStruct.quot;
        div_t minuteStruct = div(hourStruct.rem, 60);
        int minutes = minuteStruct.quot;
        int seconds = minuteStruct.rem;
        
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
    }
}

+ (NSString *)stringMinutesFromTimePromotionInterval:(NSTimeInterval)timeInterval {
    if(timeInterval <= 0){
        return @"0";
    } else {
        div_t minuteStruct = div(timeInterval,60);
        return [NSString stringWithFormat:@"%d",minuteStruct.quot];
    }
}

+ (NSString *)elapsedDurationWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    CGFloat start = [fromDate timeIntervalSince1970];
    CGFloat end = [toDate timeIntervalSince1970];
    CGFloat difference = end - start;
    CGFloat secondExists = (float)((int)difference % (int)3600);
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    dcFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute;
    if (secondExists > 0) {
        dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        if (difference < 3600) {
            dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        }
    }else{
        dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    }
    return [dcFormatter stringFromTimeInterval:difference];
}

@end
