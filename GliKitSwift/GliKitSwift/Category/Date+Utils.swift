//
//  Date+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/5/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension Date{
    
    ///大写的Y会导致时间多出一年
    
    //yyyy-MM-dd HH:mm:ss
    static let dateFormatYMdHms = "yyyy-MM-dd HH:mm:ss"
    
    //yyyy-MM-dd HH:mm
    static let dateFormatYMdHm = "yyyy-MM-dd HH:mm"
    
    //yyyy-MM-dd
    static let dateFormatYMd = "yyyy-MM-dd"
    
    ///DateFormatter 的单例 因为频繁地创建 DateFormatter 是非常耗资源的、耗时的，不要修改 dateFormat，这样有多个线程同时访问时，会格式不对
    private static var sharedDateFormatters: [String: DateFormatter] = [:]
    static func sharedDateFormatter(for format: String) -> DateFormatter {
        var formatter = sharedDateFormatters[format]
        if formatter == nil {
            objc_sync_enter(self)
            formatter = sharedDateFormatters[format]
            if formatter == nil {
                formatter = DateFormatter()
                formatter!.dateFormat = format
                formatter!.locale = .current
                sharedDateFormatters[format] = formatter
            }
            objc_sync_exit(self)
        }
        return formatter!
    }
   
    
    // MARK: - 单个时间
    
    ///获取当前时间的 秒
    var gkSecond: Int{
        Calendar.current.component(.second, from: self)
    }
    
    ///获取当前时间的 分
    var gkMinute: Int{
        Calendar.current.component(.minute, from: self)
    }
    
    ///获取当前时间的 小时
    var gkHour: Int{
        Calendar.current.component(.hour, from: self)
    }
    
    ///获取当前时间的 日期
    var gkDay: Int{
        Calendar.current.component(.day, from: self)
    }
    
    ///获取当前时间的 月份
    var gkMonth: Int{
        Calendar.current.component(.month, from: self)
    }
    
    ///获取当前时间的 年份
    var gkYear: Int{
        Calendar.current.component(.year, from: self)
    }
    
    ///获取当前时间的 星期几 1-7 星期日 到星期六
    var gkWeekday: Int{
        Calendar.current.component(.weekday, from: self)
    }
    
    // MARK: - 时间获取

    ///获取当前时间格式为
    static func gkCurrentTime(format: String = dateFormatYMdHms, offset: TimeInterval = 0) -> String {
        let formatter = sharedDateFormatter(for: format)
        var date = Date()
        if offset > 0 {
            date = Date(timeInterval: offset, since: date)
        }
        return formatter.string(from: date)
    }

    // MARK: - 时间转换

    ///把时间转换成另一种时间格式
    static func gkFormatTime(_ time: String, fromFormat: String = dateFormatYMdHms, toFormat: String) -> String? {
        var formatter = sharedDateFormatter(for: fromFormat)
        if let date = formatter.date(from: time) {
            formatter = sharedDateFormatter(for: toFormat)
            return formatter.string(from: date)
        }
        
        return nil
    }
    
    ///把时间戳转换成另一种时间格式
    static func gkFormatTimeStamp(_ timeStamp: TimeInterval, format: String = dateFormatYMdHms) -> String {
    
        let timeStamp = timeStamp > 100000000000 ? timeStamp / 1000 : timeStamp
        let date = Date(timeIntervalSince1970: timeStamp)
        var formatter = sharedDateFormatter(for: format)
        return formatter.string(from: date)
    }

    ///获取时间对象
    static func gkDate(from time: String, format: String = dateFormatYMdHms) -> Date? {

        var formatter = sharedDateFormatter(for: format)
        return formatter.date(from: time)
    }
    
    ///获取时间
    static func gkTime(from date: Date, format: String = dateFormatYMdHms) -> String {

        var formatter = sharedDateFormatter(for: format)
        return formatter.string(from: date)
    }
    
    ///格式化秒
    static func gkFormatSeconds(_ seconds: Int) -> String{
        let result = seconds / 60
        let second = seconds % 60
        let minute = result % 60
        let hour = result / 60
        
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }

    ///计算时间距离现在有多少秒
    static func gkTimeIntervalFromNow(_ time: String, format: String = dateFormatYMdHms) -> TimeInterval {
        var formatter = sharedDateFormatter(for: format)
        if let date = formatter.date(from: time) {
            return date.timeIntervalSinceNow
        }
        return 0
    }
}
