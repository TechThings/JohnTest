//
//  RFC3339DateTime.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/03/2016.
//  Copyright © 2016 NazihShoura. All rights reserved.
//

import Foundation

private let RFC3339DateFormatFractional = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
private let RFC3339DateFormat           = "yyyy-MM-dd'T'HH:mm:ssZ"
private let DateFormat           = "yyyy-MM-dd"
private let DiscoveryDateFormat = "EEE, d MMM"
private let TimeslotDateTimeFormat = "EEE, d MMM, hh:mm"
private let PromoDateStringFormat = "dd MMM yyyy"
private let RedeemDateStringFormat = "d MMM yyyy"
private let HoursMinutsSecondsFormat = "HH:mm:ss"
private let RefundEndDateTimeFormat = "EEE, dd MMM YYYY, HH:mm"

private let dateFormatterUnlocalized: NSDateFormatter = {
    let dateFormatterUnlocalized = NSDateFormatter()
    let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatterUnlocalized.locale = enUSPOSIXLocale
    return dateFormatterUnlocalized
}()

private let dateFormatterLocalized: NSDateFormatter = {
    let dateFormatterLocalized = NSDateFormatter()
    return dateFormatterLocalized
}()

extension String {

    var RFC3339DateTime: NSDate? {
        var result: NSDate?

        dateFormatterUnlocalized.dateFormat = RFC3339DateFormatFractional
        result = dateFormatterUnlocalized.dateFromString(self)

        if (result == nil) {
            dateFormatterUnlocalized.dateFormat = RFC3339DateFormat
            result = dateFormatterUnlocalized.dateFromString(self)
        }
        return result
    }

    var PromoDateTime: NSDate? {
        var result: NSDate?

        dateFormatterUnlocalized.dateFormat = DateFormat
        result = dateFormatterUnlocalized.dateFromString(self)

        return result
    }

    var APIDate: NSDate? {
        var result: NSDate?

        dateFormatterUnlocalized.dateFormat = DateFormat
        result = dateFormatterUnlocalized.dateFromString(self)

        return result
    }
}

public extension NSDate {
    private var componentFlags: NSCalendarUnit {
        get {
            return [.Year, .Month, .Day, .WeekOfMonth, .WeekOfYear, .Hour, .Minute, .Second, .Weekday, .WeekdayOrdinal]
        }
    }

    final class var currentCalendar: NSCalendar {
        get {
            return NSCalendar.autoupdatingCurrentCalendar()
        }
    }

    internal struct Seconds {
        static let minute = 60
        static let hour = minute * 60
        static let day = hour * 24
        static let week = day * 7
        //        static let year = day * 365...
        //            ...31556926 = 365.2422 days
    }

    var RFC3339DateTimeString: String {
        dateFormatterUnlocalized.dateFormat = RFC3339DateFormatFractional
        let result = dateFormatterUnlocalized.stringFromDate(self)
        return result
    }

    var APIDateString: String {
        dateFormatterUnlocalized.dateFormat = DateFormat
        let result = dateFormatterUnlocalized.stringFromDate(self)
        return result
    }

    /// format: "EEE, d MMM" if the date is the current date, the returns "TODAY"
    var DiscoveryDateString: String? {
        let localeFormatString = NSDateFormatter.dateFormatFromTemplate(DiscoveryDateFormat, options: 0, locale: dateFormatterLocalized.locale)
        dateFormatterLocalized.dateFormat = localeFormatString
        var result: String?
        if(NSCalendar.currentCalendar().isDateInToday(self)) {
            result = NSLocalizedString("today", comment: "")
        } else {
            result = dateFormatterLocalized.stringFromDate(self).uppercaseString
        }
        return result
    }

    var RefundEndDateString: String? {
        let localeFormatString = RefundEndDateTimeFormat
        dateFormatterLocalized.dateFormat = localeFormatString
        let result: String? = dateFormatterLocalized.stringFromDate(self)

        return result
    }

    /// format: "dd mm yyy" if the date is the current date, the returns "TODAY"
    var PromoDateString: String? {
        dateFormatterUnlocalized.dateFormat = PromoDateStringFormat
        let result = dateFormatterUnlocalized.stringFromDate(self)
        return result

//        let localeFormatString = NSDateFormatter.dateFormatFromTemplate(PromoDateStringFormat, options: 0, locale: dateFormatterLocalized.locale)
//        dateFormatterLocalized.dateFormat = localeFormatString
//        var result: String?
//        if(NSCalendar.currentCalendar().isDateInToday(self)) {
//            result = NSLocalizedString("TODAY", tableName: "LocalizableUnmanaged", comment: "")
//        } else {
//            result = dateFormatterLocalized.stringFromDate(self)
//        }
//        return result
    }

    /// format: "dd mmm yyy"
    var RedeemDateString: String? {
        let localeFormatString = NSDateFormatter.dateFormatFromTemplate(RedeemDateStringFormat, options: 0, locale: dateFormatterLocalized.locale)
        dateFormatterLocalized.dateFormat = localeFormatString
        let result = dateFormatterLocalized.stringFromDate(self)
        return result
    }

    /// format: "HH:mm:ss"
    var timeDateString: String? {
        let localeFormatString = NSDateFormatter.dateFormatFromTemplate(HoursMinutsSecondsFormat, options: 0, locale: dateFormatterLocalized.locale)
        dateFormatterLocalized.dateFormat = localeFormatString
        var result: String?
        result = dateFormatterLocalized.stringFromDate(self)
        return result
    }

    /// format: "HH:mm:ss"
    var timeslotTimeDateString: String? {
        let localeFormatString = NSDateFormatter.dateFormatFromTemplate(TimeslotDateTimeFormat, options: 0, locale: dateFormatterLocalized.locale)
        dateFormatterLocalized.dateFormat = localeFormatString
        var result: String?
        result = dateFormatterLocalized.stringFromDate(self)
        return result
    }

    //MARK: - Relative Dates
    //MARK: Days
    final class func daysFromNow(days: Int) -> NSDate {
        return NSDate().addDays(days)
    }

    final class func daysBeforeNow(days: Int) -> NSDate {
        return NSDate().subtractDays(days)
    }

    final class func now() -> NSDate {
        return NSDate()
    }

    final class func today() -> NSDate {
        return NSDate.now()
    }

    final class func tomorrow() -> NSDate {
        return NSDate.daysFromNow(1)
    }

    final class func yesterday() -> NSDate {
        return NSDate.daysBeforeNow(1)
    }

    //MARK: Hours
    final class func hoursFromNow(hours: Int) -> NSDate {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate + Double(Seconds.hour * hours)
        return NSDate(timeIntervalSinceReferenceDate: timeInterval)
    }

    final class func hoursBeforeNow(hours: Int) -> NSDate {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate - Double(Seconds.hour * hours)
        return NSDate(timeIntervalSinceReferenceDate: timeInterval)
    }

    //MARK: Minutes
    final class func minutesFromNow(minutes: Int) -> NSDate {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate + Double(Seconds.minute * minutes)
        return NSDate(timeIntervalSinceReferenceDate: timeInterval)
    }

    final class func minutesBeforeNow(minutes: Int) -> NSDate {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate - Double(Seconds.minute * minutes)
        return NSDate(timeIntervalSinceReferenceDate: timeInterval)
    }

    //MARK: - String Properties
    //MARK: Format and Style
    func stringWithFormat(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }

    func stringWithDateStyle(dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.stringFromDate(self)
    }

    //MARK: Short Formats
    func shortString() -> String {
        return self.stringWithDateStyle(.ShortStyle, timeStyle: .ShortStyle)
    }

    func shortTimeString() -> String {
        return self.stringWithDateStyle(.NoStyle, timeStyle: .ShortStyle)
    }

    func shortDateString() -> String {
        return self.stringWithDateStyle(.ShortStyle, timeStyle: .NoStyle)
    }

    //MARK: Medium Formats
    func mediumString() -> String {
        return self.stringWithDateStyle(.MediumStyle, timeStyle: .MediumStyle)
    }

    func mediumTimeString() -> String {
        return self.stringWithDateStyle(.NoStyle, timeStyle: .MediumStyle)
    }

    func mediumDateString() -> String {
        return self.stringWithDateStyle(.MediumStyle, timeStyle: .NoStyle)
    }

    //MARK: Long Formats
    func longString() -> String {
        return self.stringWithDateStyle(.LongStyle, timeStyle: .LongStyle)
    }

    func longTimeString() -> String {
        return self.stringWithDateStyle(.NoStyle, timeStyle: .LongStyle)
    }

    func longDateString() -> String {
        return self.stringWithDateStyle(.LongStyle, timeStyle: .NoStyle)
    }

    func relativeString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.doesRelativeDateFormatting = true

        if self.today() {
            return self.shortTimeString()
        } else if self.yesterday() {
            return self.mediumDateString()
        } else if self.inThePast() && self.daysAgo() < 6 {
            return dateFormatter.weekdaySymbols[self.weekday-1]
        } else {
            return self.shortDateString()
        }
    }

    //MARK: - Comparing Dates
    //MARK: Equal Dates
    func equalToDateIgnoringTime(date: NSDate) -> Bool {
        let components1 = NSDate.currentCalendar.components(componentFlags, fromDate:self)
        let components2 = NSDate.currentCalendar.components(componentFlags, fromDate:date)
        return ((components1.day == components2.day) && (components1.month == components2.month) && (components1.year == components2.year))
    }

    //MARK: Days
    func today() -> Bool {
        return self.equalToDateIgnoringTime(NSDate())
    }

    func tomorrow() -> Bool {
        return self.equalToDateIgnoringTime(NSDate.tomorrow())
    }

    func yesterday() -> Bool {
        return self.equalToDateIgnoringTime(NSDate.yesterday())
    }

    //MARK: Weeks
    func sameWeekAsDate(date: NSDate) -> Bool {
        let components1 = NSDate.currentCalendar.components(componentFlags, fromDate:self)
        let components2 = NSDate.currentCalendar.components(componentFlags, fromDate:date)
        if components1.weekOfYear != components2.weekOfYear { return false }
        return (fabs(self.timeIntervalSinceDate(date)) < Double(Seconds.week))
    }

    func thisWeek() -> Bool {
        return self.sameWeekAsDate(NSDate())
    }

    func nextWeek() -> Bool {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate + Double(Seconds.week)
        let date = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return self.sameWeekAsDate(date)
    }

    func lastWeek() -> Bool {
        let timeInterval = NSDate().timeIntervalSinceReferenceDate - Double(Seconds.week)
        let date = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return self.sameWeekAsDate(date)
    }

    //MARK: Months
    func sameMonthAsDate(date: NSDate) -> Bool {
        let components1 = NSDate.currentCalendar.components([.Year, .Month], fromDate:self)
        let components2 = NSDate.currentCalendar.components([.Year, .Month], fromDate:date)
        return ((components1.month == components2.month) && (components1.year == components2.year))
    }

    func thisMonth() -> Bool {
        return self.sameMonthAsDate(NSDate())
    }

    func lastMonth() -> Bool {
        return self.sameMonthAsDate(NSDate().subtractMonths(1))
    }

    func nextMonth() -> Bool {
        return self.sameMonthAsDate(NSDate().addMonths(1))
    }

    //MARK: Years
    func sameYearAsDate(date: NSDate) -> Bool {
        let components1 = NSDate.currentCalendar.components(.Year, fromDate:self)
        let components2 = NSDate.currentCalendar.components(.Year, fromDate:date)
        return (components1.year == components2.year)
    }

    func thisYear() -> Bool {
        return self.sameYearAsDate(NSDate())
    }

    func nextYear() -> Bool {
        let components1 = NSDate.currentCalendar.components(.Year, fromDate: self)
        let components2 = NSDate.currentCalendar.components(.Year, fromDate: NSDate())
        return (components1.year == (components2.year + 1))
    }

    func lastYear() -> Bool {
        let components1 = NSDate.currentCalendar.components(.Year, fromDate: self)
        let components2 = NSDate.currentCalendar.components(.Year, fromDate: NSDate())
        return (components1.year == (components2.year - 1))
    }

    //MARK: Relativity
    func earlierThanDate(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedAscending)
    }

    func laterThanDate(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedDescending)
    }

    func inTheFuture() -> Bool {
        return self.laterThanDate(NSDate())
    }

    func inThePast() -> Bool {
        return self.earlierThanDate(NSDate())
    }

    //MARK: - Roles
    func typicallyWeekend() -> Bool {
        let components = NSDate.currentCalendar.components(.Weekday, fromDate: self)
        return ((components.weekday == 1) || (components.weekday == 7))
    }

    func typicallyWeekday() -> Bool {
        return !typicallyWeekend()
    }

    //MARK: - Adjusting Dates
    //MARK: Years
    func addYears(years: Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.year = years
        return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: self, options: .WrapComponents)!
    }

    func subtractYears(years: Int) -> NSDate {
        return addYears(-years)
    }

    //MARK: Months
    func addMonths(months: Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.month = months
        return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: self, options: .WrapComponents)!
    }

    func subtractMonths(months: Int) -> NSDate {
        return addMonths(-months)
    }

    //MARK: Days
    func addDays(days: Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.day = days
        return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: self, options: .WrapComponents)!
    }

    func subtractDays(days: Int) -> NSDate {
        return addDays(-days)
    }

    //MARK: Hours
    func addHours(hours: Int) -> NSDate {
        let timeInterval = self.timeIntervalSinceReferenceDate + Double(Seconds.hour * hours)
        return NSDate(timeIntervalSinceReferenceDate: timeInterval)
    }

    func subtractHours(hours: Int) -> NSDate {
        return addHours(-hours)
    }

    //MARK: Minutes
    func addMinutes(minutes: Int) -> NSDate {
        let timeInterval = self.timeIntervalSinceReferenceDate + Double(Seconds.minute * minutes)
        return NSDate(timeIntervalSinceReferenceDate: timeInterval)
    }

    func subtractMinutes(minutes: Int) -> NSDate {
        return addMinutes(-minutes)
    }

    //MARK: Relative Components
    func componentsWithOffsetToDate(date: NSDate) -> NSDateComponents {
        return NSDate.currentCalendar.components(componentFlags, fromDate: self, toDate: date, options: .WrapComponents)
    }

    func componentsWithOffsetFromDate(date: NSDate) -> NSDateComponents {
        return NSDate.currentCalendar.components(componentFlags, fromDate: date, toDate: self, options: .WrapComponents)
    }

    func daysFromNow() -> Int {
        let components = self.componentsWithOffsetFromDate(NSDate())
        return components.day
    }

    //MARK: - Extremes
    func startOfDay() -> NSDate {
        let components = NSDate.currentCalendar.components(componentFlags, fromDate: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSDate.currentCalendar.dateFromComponents(components)!
    }

    func endOfDay() -> NSDate {
        let components = NSDate.currentCalendar.components(componentFlags, fromDate: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return NSDate.currentCalendar.dateFromComponents(components)!
    }

    //MARK: - Intervals
    //MARK: Minutes
    func minutesAfterDate(date: NSDate) -> Int {
        let timeInterval = self.timeIntervalSinceDate(date)
        return Int(timeInterval / Double(Seconds.minute))
    }

    func minutesBeforeDate(date: NSDate) -> Int {
        let timeInterval = date.timeIntervalSinceDate(self)
        return Int(timeInterval / Double(Seconds.minute))
    }

    //MARK: Hours
    func hoursAfterDate(date: NSDate) -> Int {
        let timeInterval = self.timeIntervalSinceDate(date)
        return Int(timeInterval / Double(Seconds.hour))
    }

    func hoursBeforeDate(date: NSDate) -> Int {
        let timeInterval = date.timeIntervalSinceDate(self)
        return Int(timeInterval / Double(Seconds.hour))
    }

    //MARK: Days
    func daysAfterDate(date: NSDate) -> Int {
        let timeInterval = self.timeIntervalSinceDate(date)
        return Int(timeInterval / Double(Seconds.day))
    }

    func daysBeforeDay(date: NSDate) -> Int {
        let timeInterval = date.timeIntervalSinceDate(self)
        return Int(timeInterval / Double(Seconds.day))
    }

    //    func distanceInDaysToDate(date: NSDate) -> Int {
    //        let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    //        let components = gregorianCalendar?.components(.Day, fromDate: self, toDate: date, options: .WrapComponents)
    //        return components.day
    //    }

    //MARK: - Component Properties
    var nearestHour: Int {
        get {
            let timeInterval: NSTimeInterval = NSDate().timeIntervalSinceReferenceDate + Double(Seconds.minute * 30)
            let date = NSDate(timeIntervalSinceReferenceDate: timeInterval)
            let components = NSDate.currentCalendar.components(componentFlags, fromDate: date)
            return components.hour
        }
    }

    var hourMinutesAMPM: String {
        get {
            if self.hour < 12 {
                return "\(self.hour).\(self.minute) AM"
            } else {
                return "\(self.hour - 12).\(self.minute) PM"
            }
        }
    }
}
