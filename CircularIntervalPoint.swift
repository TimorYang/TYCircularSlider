//
//  CircularIntervalPoint.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/14.
//

import UIKit

class CircularIntervalPoint: NSObject {
    
    var start: CGFloat = CGFLOAT_MAX {
        didSet {
            print("start: \(start)")
        }
    }
    var end: CGFloat = CGFLOAT_MAX {
        didSet {
            print("end: \(end)")
        }
    }
    var startThumbCenter: CGPoint = CGPoint.zero
    var endThumbCenter: CGPoint = CGPoint.zero
    var next: CircularIntervalPoint?
    weak var previous: CircularIntervalPoint?

    
    init(start: CGFloat, end: CGFloat) {
        self.start = start
        self.end = end
    }
}

