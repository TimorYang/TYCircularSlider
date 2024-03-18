//
//  CircularPoint.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/16.
//

import UIKit

class CircularPoint:NSObject {
    /// 值
    var value: CGFloat = CGFLOAT_MAX
    /// 是否是起点
    var isStart = false
    /// 是否是终点
    var isEnd = false
    
    var next: CircularPoint?
    
    weak var previous: CircularPoint?
    
    override var description: String {
        return "CircularPoint(value: \(value), isStart: \(isStart), isEnd: \(isEnd), hasPrevious: \(previous != nil), hasNext: \(next != nil)"
    }
    
}
