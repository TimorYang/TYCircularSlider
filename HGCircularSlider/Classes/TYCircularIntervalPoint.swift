//
//  TYCircularIntervalPoint.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/14.
//

import UIKit

class TYCircularIntervalPoint:NSObject {
    
    var start: CGFloat = CGFLOAT_MAX
    var end: CGFloat = CGFLOAT_MAX
    var startThumbCenter: CGPoint = CGPoint.zero
    var endThumbCenter: CGPoint = CGPoint.zero
    var next: TYCircularIntervalPoint?
    weak var previous: TYCircularIntervalPoint?

    
    init(start: CGFloat, end: CGFloat) {
        self.start = start
        self.end = end
    }
    
    override var description: String {
        return "CircularIntervalPoint(start: \(start), end: \(end))"
    }
}

