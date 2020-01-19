//
//  HttpError.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

/// http请求错误
public enum HttpError: Error{
    
    ///请求链接为nil
    case requestURLNil
    
    ///结果 格式不对
    case resultFormatError
}
