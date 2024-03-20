//
//  TYCircularPoint.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/16.
//

import UIKit

class TYCircularPoint:NSObject {
    /// 值
    var value: CGFloat = CGFLOAT_MAX
    /// 是否是起点
    var isStart = false
    /// 是否是终点
    var isEnd = false
    
    var next: TYCircularPoint?
    
    weak var previous: TYCircularPoint?
    
    override var description: String {
        return "CircularPoint(value: \(value), isStart: \(isStart), isEnd: \(isEnd), hasPrevious: \(previous != nil), hasNext: \(next != nil)"
    }
    
}
