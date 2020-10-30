//
//  ConversionUtils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///值转换扩展
public extension BinaryFloatingPoint{
    
    var intValue: Int{
        Int(self)
    }
    
    var int8Value: Int8{
        Int8(self)
    }
    
    var int16Value: Int16{
        Int16(self)
    }
    
    var int32Value: Int32{
        Int32(self)
    }
    
    var int64Value: Int64{
        Int64(self)
    }
    
    var uIntValue: UInt{
        UInt(self)
    }
    
    var uInt8Value: UInt8{
        UInt8(self)
    }
    
    var uInt16Value: UInt16{
        UInt16(self)
    }
    
    var uInt32Value: UInt32{
        UInt32(self)
    }
    
    var uInt64Value: UInt64{
        UInt64(self)
    }
    
    var floatValue: Float{
        Float(self)
    }
    
    var float32Value: Float32{
        Float32(self)
    }
    
    var float64Value: Float64{
        Float64(self)
    }
    
    var float80Value: Float80{
        Float80(self)
    }
    
    var doubleValue: Double{
        Double(self)
    }
    
    var cgFloatValue: CGFloat{
        CGFloat(self)
    }
    
    var boolValue: Bool{
        Int(self) == 0 ? false : true
    }
    
    var toString: String {
        "\(self)"
    }
}

public extension BinaryInteger{
    
    var intValue: Int{
        Int(self)
    }
    
    var int8Value: Int8{
        Int8(self)
    }
    
    var int16Value: Int16{
        Int16(self)
    }
    
    var int32Value: Int32{
        Int32(self)
    }
    
    var int64Value: Int64{
        Int64(self)
    }
    
    var uIntValue: UInt{
        UInt(self)
    }
    
    var uInt8Value: UInt8{
        UInt8(self)
    }
    
    var uInt16Value: UInt16{
        UInt16(self)
    }
    
    var uInt32Value: UInt32{
        UInt32(self)
    }
    
    var uInt64Value: UInt64{
        UInt64(self)
    }
    
    var floatValue: Float{
        Float(self)
    }
    
    var float32Value: Float32{
        Float32(self)
    }
    
    var float64Value: Float64{
        Float64(self)
    }
    
    var float80Value: Float80{
        Float80(self)
    }
    
    var doubleValue: Double{
        Double(self)
    }
    
    var cgFloatValue: CGFloat{
        CGFloat(self)
    }
    
    var boolValue: Bool{
        Int(self) == 0 ? false : true
    }
    
    var binaryString: String{
        String(self, radix: 2)
    }
    
    var hexString: String{
        String(self, radix: 16)
    }
    
    var toString: String {
        String(self)
    }
}

public extension String{
    
    var intValue: Int{
        Int(self) ?? 0
    }
    
    var int8Value: Int8{
        Int8(self) ?? 0
    }
    
    var int16Value: Int16{
        Int16(self) ?? 0
    }
    
    var int32Value: Int32{
        Int32(self) ?? 0
    }
    
    var int64Value: Int64{
        Int64(self) ?? 0
    }
    
    var uIntValue: UInt{
        UInt(self) ?? 0
    }
    
    var uInt8Value: UInt8{
        UInt8(self) ?? 0
    }
    
    var uInt16Value: UInt16{
        UInt16(self) ?? 0
    }
    
    var uInt32Value: UInt32{
        UInt32(self) ?? 0
    }
    
    var uInt64Value: UInt64{
        UInt64(self) ?? 0
    }
    
    var floatValue: Float{
        Float(self) ?? 0
    }
    
    var float32Value: Float32{
        Float32(self) ?? 0
    }
    
    var float64Value: Float64{
        Float64(self) ?? 0
    }
    
    var float80Value: Float80{
        Float80(self) ?? 0
    }
    
    var doubleValue: Double{
        Double(self) ?? 0
    }
    
    var cgFloatValue: CGFloat{
        CGFloat(Double(self) ?? 0)
    }
    
    var boolValue: Bool{
        Bool(self) ?? false
    }
    
    var hexToDecimal: Int {
        Int(strtoul(self, nil, 16))
    }
    
    var binaryToDecimal: Int {
        Int(strtoul(self, nil, 2))
    }
}
