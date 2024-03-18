//
//  CircularIntervalPoint.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/14.
//

import UIKit

class CircularIntervalPoint:NSObject {
    
    var start: CGFloat = CGFLOAT_MAX
    var end: CGFloat = CGFLOAT_MAX
    var startThumbCenter: CGPoint = CGPoint.zero
    var endThumbCenter: CGPoint = CGPoint.zero
    var next: CircularIntervalPoint?
    weak var previous: CircularIntervalPoint?

    
    init(start: CGFloat, end: CGFloat) {
        self.start = start
        self.end = end
    }
    
    override var description: String {
        return "CircularIntervalPoint(start: \(start), end: \(end))"
    }
}

