//
//  TYCircularTimeRange.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/19.
//

import UIKit

open class TYCircularTimeRange: NSObject {
    open var start: CGFloat? // 起始时间
    open var end: CGFloat? // 结束时间
    
    init(start: CGFloat? = nil, end: CGFloat? = nil) {
        self.start = start
        self.end = end
    }
}
