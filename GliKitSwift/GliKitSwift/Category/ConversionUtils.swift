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
        get{
            Int(self)
        }
    }
    
    var int8Value: Int8{
        get{
            Int8(self)
        }
    }
    
    var int16Value: Int16{
        get{
            Int16(self)
        }
    }
    
    var int32Value: Int32{
        get{
            Int32(self)
        }
    }
    
    var int64Value: Int64{
        get{
            Int64(self)
        }
    }
    
    var uIntValue: UInt{
        get{
            UInt(self)
        }
    }
    
    var uInt8Value: UInt8{
        get{
            UInt8(self)
        }
    }
    
    var uInt16Value: UInt16{
        get{
            UInt16(self)
        }
    }
    
    var uInt32Value: UInt32{
        get{
            UInt32(self)
        }
    }
    
    var uInt64Value: UInt64{
        get{
            UInt64(self)
        }
    }
    
    var floatValue: Float{
        get{
            Float(self)
        }
    }
    
    var float32Value: Float32{
        get{
            Float32(self)
        }
    }
    
    var float64Value: Float64{
        get{
            Float64(self)
        }
    }
    
    var float80Value: Float80{
        get{
            Float80(self)
        }
    }
    
    var doubleValue: Double{
        get{
            Double(self)
        }
    }
    
    var cgFloatValue: CGFloat{
        get{
            CGFloat(self)
        }
    }
    
    var boolValue: Bool{
        get{
            Int(self) == 0 ? false : true
        }
    }
}

public extension BinaryInteger{
    
    var intValue: Int{
        get{
            Int(self)
        }
    }
    
    var int8Value: Int8{
        get{
            Int8(self)
        }
    }
    
    var int16Value: Int16{
        get{
            Int16(self)
        }
    }
    
    var int32Value: Int32{
        get{
            Int32(self)
        }
    }
    
    var int64Value: Int64{
        get{
            Int64(self)
        }
    }
    
    var uIntValue: UInt{
        get{
            UInt(self)
        }
    }
    
    var uInt8Value: UInt8{
        get{
            UInt8(self)
        }
    }
    
    var uInt16Value: UInt16{
        get{
            UInt16(self)
        }
    }
    
    var uInt32Value: UInt32{
        get{
            UInt32(self)
        }
    }
    
    var uInt64Value: UInt64{
        get{
            UInt64(self)
        }
    }
    
    var floatValue: Float{
        get{
            Float(self)
        }
    }
    
    var float32Value: Float32{
        get{
            Float32(self)
        }
    }
    
    var float64Value: Float64{
        get{
            Float64(self)
        }
    }
    
    var float80Value: Float80{
        get{
            Float80(self)
        }
    }
    
    var doubleValue: Double{
        get{
            Double(self)
        }
    }
    
    var cgFloatValue: CGFloat{
        get{
            CGFloat(self)
        }
    }
    
    var boolValue: Bool{
        get{
            Int(self) == 0 ? false : true
        }
    }
}

public extension String{
    
    var intValue: Int{
        get{
            Int(self) ?? 0
        }
    }
    
    var int8Value: Int8{
        get{
            Int8(self) ?? 0
        }
    }
    
    var int16Value: Int16{
        get{
            Int16(self) ?? 0
        }
    }
    
    var int32Value: Int32{
        get{
            Int32(self) ?? 0
        }
    }
    
    var int64Value: Int64{
        get{
            Int64(self) ?? 0
        }
    }
    
    var uIntValue: UInt{
        get{
            UInt(self) ?? 0
        }
    }
    
    var uInt8Value: UInt8{
        get{
            UInt8(self) ?? 0
        }
    }
    
    var uInt16Value: UInt16{
        get{
            UInt16(self) ?? 0
        }
    }
    
    var uInt32Value: UInt32{
        get{
            UInt32(self) ?? 0
        }
    }
    
    var uInt64Value: UInt64{
        get{
            UInt64(self) ?? 0
        }
    }
    
    var floatValue: Float{
        get{
            Float(self) ?? 0
        }
    }
    
    var float32Value: Float32{
        get{
            Float32(self) ?? 0
        }
    }
    
    var float64Value: Float64{
        get{
            Float64(self) ?? 0
        }
    }
    
    var float80Value: Float80{
        get{
            Float80(self) ?? 0
        }
    }
    
    var doubleValue: Double{
        get{
            Double(self) ?? 0
        }
    }
    
    var cgFloatValue: CGFloat{
        get{
            CGFloat(Double(self) ?? 0)
        }
    }
    
    var boolValue: Bool{
        get{
            Bool(self) ?? false
        }
    }
}
