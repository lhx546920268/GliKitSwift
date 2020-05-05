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
    
    ///NSDateFormatter 的单例 因为频繁地创建 NSDateFormatter 是非常耗资源的、耗时的
    static let sharedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        
        return dateFormatter
    }()
    
    // MARK: - 单个时间
    
    ///获取当前时间的 秒
    var gkSecond: Int{
        get{
            Calendar.current.component(.second, from: self)
        }
    }
    
    ///获取当前时间的 分
    var gkMinute: Int{
        get{
            Calendar.current.component(.minute, from: self)
        }
    }
    
    ///获取当前时间的 小时
    var gkHour: Int{
        get{
            Calendar.current.component(.hour, from: self)
        }
    }
    
    ///获取当前时间的 日期
    var gkDay: Int{
        get{
            Calendar.current.component(.day, from: self)
        }
    }
    
    ///获取当前时间的 月份
    var gkMonth: Int{
        get{
            Calendar.current.component(.month, from: self)
        }
    }
    
    ///获取当前时间的 年份
    var gkYear: Int{
        get{
            Calendar.current.component(.year, from: self)
        }
    }
    
    ///获取当前时间的 星期几 1-7 星期日 到星期六
    var gkWeekday: Int{
        get{
            Calendar.current.component(.weekday, from: self)
        }
    }
}
