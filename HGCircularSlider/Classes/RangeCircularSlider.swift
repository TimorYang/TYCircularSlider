//
//  RangeCircularSlider.swift
//  Pods
//
//  Created by Hamza Ghazouani on 25/10/2016.
//
//

import UIKit

/**
 A visual control used to select a range of values (between start point and the end point) from a continuous range of values.
 RangeCircularSlider use the target-action mechanism to report changes made during the course of editing:
 ValueChanged, EditingDidBegin and EditingDidEnd
 */
open class RangeCircularSlider: CircularSlider {
    
    public struct TYCircularTimeRange {
        var start: CGFloat? // 起始时间，使用整数表示（例如，秒数）
        var end: CGFloat? // 结束时间，使用整数表示（例如，秒数）
    }
    
    public var timeRangeList: [TYCircularTimeRange]? {
        if midIntervalPoints.isEmpty {
            return [TYCircularTimeRange(start: startPointValue, end: endPointValue)]
        } else {
            return intervalPointList2TimeRangeList(from: midIntervalPoints)
        }
    }

    public enum SelectedThumb {
        case startThumb
        case endThumb
        case internalPointStart
        case internalPointEnd
        case none

        var isStart: Bool {
            return  self == SelectedThumb.startThumb
        }
        var isEnd: Bool {
            return  self == SelectedThumb.endThumb
        }
    }

    // MARK: Changing the Slider’s Appearance
    
    /**
     * The color used to tint start thumb
     * Ignored if the startThumbImage != nil
     *
     * The default value of this property is the groupTableViewBackgroundColor.
     */
    @IBInspectable
    open var startThumbTintColor: UIColor = UIColor.groupTableViewBackground
    
    /**
     * The color used to tint the stroke of the start thumb
     * Ignored if the startThumbImage != nil
     *
     * The default value of this property is the green color.
     */
    @IBInspectable
    open var startThumbStrokeColor: UIColor = UIColor.green
    
    /**
     * The stroke highlighted color of start thumb
     * The default value of this property is blue color
     */
    @IBInspectable
    open var startThumbStrokeHighlightedColor: UIColor = UIColor.purple
    
    
    /**
     * The image of the end thumb
     * Clears any custom color you may have provided for end thumb.
     *
     * The default value of this property is nil
     */
    open var startThumbImage: UIImage?
    
    
    // MARK: Accessing the Slider’s Value Limits
    
    /**
     * The minimum value of the receiver.
     *
     * If you change the value of this property, and the start value of the receiver is below the new minimum, the start value is adjusted to match the new minimum value automatically.
     * The end value is also adjusted to match (startPointValue + distance) automatically if the distance is different to -1 (SeeAlso: startPointValue, distance)
     * The default value of this property is 0.0.
     */
    override open var minimumValue: CGFloat {
        didSet {
            if startPointValue < minimumValue {
                startPointValue = minimumValue
            }
        }
    }
    
    /**
     * The maximum value of the receiver.
     *
     * If you change the value of this property, and the end value of the receiver is above the new maximum, the end value is adjusted to match the new maximum value automatically.
     * The start value is also adjusted to match (endPointValue - distance) automatically  if the distance is different to -1 (see endPointValue, distance)
     * The default value of this property is 1.0.
     */
    @IBInspectable
    override open var maximumValue: CGFloat {
        didSet {
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
        }
    }
    
    /*
     * Minimum distance between two points
     * -1 is an invalid value
     */
    open var minDistance: CGFloat = -1 {
        didSet {
            assert(minDistance > 0, "Any number less than 0 is an invalid value")
        }
    }
    
    /**
    * The fixed distance between the start value and the end value
    *
    * If you change the value of this property, the end value is adjusted to match (startPointValue + distance)
    * If the end value is above the maximum value, the end value is adjusted to match the maximum value and the start value is adjusted to match (endPointValue - distance)
    * To disable distance use -1 (by default)
    *
    * The default value of this property is -1
    */
    @IBInspectable
    open var distance: CGFloat = -1 {
        didSet {
            assert(distance <= maximumValue - minimumValue, "The distance value is greater than distance between max and min value")
            endPointValue = startPointValue + distance
        }
    }
    
    
    /**
     * The value in the start thumb.
     *
     * If you try to set a value that is below the minimum value, the minimum value is set instead.
     * If you try to set a value that is above the (endPointValue - distance), the (endPointValue - distance) is set instead.
     *
     * The default value of this property is 0.0.
     */
    open var startPointValue: CGFloat = 0.0 {
        didSet {
            guard oldValue != startPointValue else { return }
            
            if startPointValue < minimumValue {
                startPointValue = minimumValue
            }
            
            if distance > 0 {
                endPointValue = startPointValue + distance
            }
            
            setNeedsDisplay()
        }
    }
    
    /**
     * The value in the end thumb.
     *
     * If you try to set a value that is above the maximum value, the maximum value is set instead.
     * If you try to set a value that is below the (startPointValue + distance), the (startPointValue + distance) is set instead.
     *
     * The default value of this property is 0.5
     */
    override open var endPointValue: CGFloat {
        didSet {
            if oldValue == endPointValue && distance <= 0 {
                return
            }
            
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
            
            if distance > 0 {
                startPointValue = endPointValue - distance
            }
            
            setNeedsDisplay()
        }
    }
    
    // MARK: - Override methods
    public override init(frame: CGRect) {
        super .init(frame: frame)
        self.addGestureRecognizer(self.longPressGestureRecognizer)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addGestureRecognizer(self.longPressGestureRecognizer)
    }
    
    // MARK: private properties / methods
    
    /**
     * The center of the start thumb
     * Used to know in which thumb is the user gesture
     */
    fileprivate var startThumbCenter: CGPoint = CGPoint.zero
    
    /**
     * The center of the end thumb
     * Used to know in which thumb is the user gesture
     */
    fileprivate var endThumbCenter: CGPoint = CGPoint.zero
    
    /**
     * Interval point
     */
    fileprivate var intervalThumbPoint: CircularIntervalPoint?
    
    /**
     * The last touched thumb
     * By default the value is none
     */
    fileprivate var selectedThumb: SelectedThumb = .none
    
    /**
     Checks if the touched point affect the thumb
     
     The point affect the thumb if :
     The thumb rect contains this point
     Or the angle between the touched point and the center of the thumb less than 15°
     
     - parameter thumbCenter: the center of the thumb
     - parameter touchPoint:  the touched point
     
     - returns: true if the touched point affect the thumb, false if not.
     */
    internal func isThumb(withCenter thumbCenter: CGPoint, containsPoint touchPoint: CGPoint) -> Bool {
        // the coordinates of thumb from its center
        let rect = CGRect(x: thumbCenter.x - thumbRadius, y: thumbCenter.y - thumbRadius, width: thumbRadius * 2, height: thumbRadius * 2)
        if rect.contains(touchPoint) {
            return true
        }
        
        let angle = CircularSliderHelper.angle(betweenFirstPoint: thumbCenter, secondPoint: touchPoint, inCircleWithCenter: bounds.center)
        let degree =  CircularSliderHelper.degrees(fromRadians: angle)
        
        // tolerance 15°
        let isInside = degree < 15 || degree > 345
        return isInside
    }
    
    internal func isPointInArcCentered(_ point: CGPoint, _ start: CGFloat, _ end: CGFloat) -> Bool {
        
        let innerRadius = radius - lineWidth / 2
        let outerRadius = radius + lineWidth / 2
        
        // 计算点到圆心的距离
        let distanceToCenter = hypot(point.x - bounds.center.x, point.y - bounds.center.y)
        
        // 检查点是否在内圆和外圆之间
        guard distanceToCenter >= innerRadius && distanceToCenter <= outerRadius else {
            return false
        }
        
        // 计算点相对于圆心的角度
        let angle = atan2(point.y - bounds.center.y, point.x - bounds.center.x)
        let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        let startAngle = CircularSliderHelper.scaleToAngle(value: start, inInterval: interval) + CircularSliderHelper.circleInitialAngle
        // get end angle from end value
        let endAngle = CircularSliderHelper.scaleToAngle(value: end, inInterval: interval) + CircularSliderHelper.circleInitialAngle
        // 将角度转换为0到2π之间的值
        let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
        
        let normalizedStartAngle = startAngle < 0 ? startAngle + 2 * .pi : startAngle
        let normalizedEndAngle = endAngle < 0 ? endAngle + 2 * .pi : endAngle
        
        // 判断点的角度是否在弧线的角度范围内
        if normalizedStartAngle < normalizedEndAngle {
            return normalizedAngle >= normalizedStartAngle && normalizedAngle <= normalizedEndAngle
        } else {
            return normalizedAngle >= normalizedStartAngle || normalizedAngle <= normalizedEndAngle
        }
    }
    
    // MARK: Drawing
    
    /**
     See superclass documentation
     */
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCircularSlider(inContext: context)
        
        let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        if midIntervalPoints.isEmpty {
            // get start angle from start value
            let startAngle = CircularSliderHelper.scaleToAngle(value: startPointValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
            // get end angle from end value
            let endAngle = CircularSliderHelper.scaleToAngle(value: endPointValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
            
            drawShadowArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
            drawFilledArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
            
            // end thumb
            endThumbTintColor.setFill()
            (isHighlighted == true && selectedThumb == .endThumb) ? endThumbStrokeHighlightedColor.setStroke() : endThumbStrokeColor.setStroke()
            endThumbCenter = drawThumbAt(endAngle, with: endThumbImage, inContext: context)
            
            // start thumb
            startThumbTintColor.setFill()
            (isHighlighted == true && selectedThumb == .startThumb) ? startThumbStrokeHighlightedColor.setStroke() : startThumbStrokeColor.setStroke()
            
            startThumbCenter = drawThumbAt(startAngle, with: startThumbImage, inContext: context)
        } else {
            startThumbCenter = CGPoint.zero
            endThumbCenter = CGPoint.zero
            var index = 1
            midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                // get start angle from start value
                let startAngle = CircularSliderHelper.scaleToAngle(value: item.start, inInterval: interval) + CircularSliderHelper.circleInitialAngle
                // get end angle from end value
                let endAngle = CircularSliderHelper.scaleToAngle(value: item.end, inInterval: interval) + CircularSliderHelper.circleInitialAngle
                
                drawShadowArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
                drawFilledArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
                
                // end thumb
                endThumbTintColor.setFill()
                (isHighlighted == true && selectedThumb == .endThumb) ? endThumbStrokeHighlightedColor.setStroke() : endThumbStrokeColor.setStroke()
                if index == midIntervalPoints.count {
                    item.endThumbCenter = drawThumbAt(endAngle, with: endThumbImage, inContext: context)
                } else {
                    item.endThumbCenter = drawThumbAt(endAngle, with: UIImage(named: "interval_end"), inContext: context)
                }
                
                // start thumb
                startThumbTintColor.setFill()
                (isHighlighted == true && selectedThumb == .startThumb) ? startThumbStrokeHighlightedColor.setStroke() : startThumbStrokeColor.setStroke()
                if index == 1 {
                    item.startThumbCenter = drawThumbAt(startAngle, with: startThumbImage, inContext: context)
                } else {
                    item.startThumbCenter = drawThumbAt(startAngle, with: UIImage(named: "interval_start"), inContext: context)
                }
                index += 1
                return true
            }
        }
    }
    
    // MARK: User interaction methods
    
    /**
     See superclass documentation
     */
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        sendActions(for: .editingDidBegin)
        // the position of the pan gesture
        let touchPosition = touch.location(in: self)
        selectedThumb = thumb(for: touchPosition)

        return selectedThumb != .none
    }
    
    /**
     See superclass documentation
     */
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard selectedThumb != .none else {
            return false
        }

        // the position of the pan gesture
        let touchPosition = touch.location(in: self)
        let startPoint = CGPoint(x: bounds.center.x, y: 0)
        switch selectedThumb {
        case .startThumb:
            let oldValue = startPointValue
            let newValue = newValue(from: oldValue, touch: touchPosition, start: startPoint)
            startPointValue = newValue
            let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
            let oldRadian = CircularSliderHelper.scaleToAngle(value: oldValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
            let newRadian = CircularSliderHelper.scaleToAngle(value: newValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
            let movementDirection = determineMovementDirection(oldRadian: oldRadian, newRadian: newRadian)
            switch movementDirection {
            case .clockwise:
                /// 顺时针旋转
                print("999111: ------------开始顺时针旋转------------")
                let result = arePointsTouchingOnSameCircle(point1: startPointValue, point2: endPointValue)
                if result {
                    endPointValue = startPointValue + minDistance <= maximumValue ? startPointValue + minDistance : startPointValue + minDistance - maximumValue
                }
                print("999111: ------------结束顺时针旋转------------")
            case .counterclockwise:
                /// 逆时针旋转
                print("999111: ------------开始逆时针旋转------------")
                let result = arePointsTouchingOnSameCircle(point1: startPointValue, point2: endPointValue)
                if result {
                    endPointValue = startPointValue - minDistance >= 0 ? startPointValue - minDistance : startPointValue - minDistance + maximumValue
                }
                print("999111: ------------结束逆时针旋转------------")
            case .stationary:
                print("101010666: 点没有移动或在完全对称的位置")
            }
        case .endThumb:
            let oldValue = endPointValue
            let newValue = newValue(from: oldValue, touch: touchPosition, start: startPoint)
            endPointValue = newValue
            print("999222: end: \(endPointValue)")
            let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
            let oldRadian = CircularSliderHelper.scaleToAngle(value: oldValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
            let newRadian = CircularSliderHelper.scaleToAngle(value: newValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
            let movementDirection = determineMovementDirection(oldRadian: oldRadian, newRadian: newRadian)
            switch movementDirection {
            case .clockwise:
                /// 顺时针旋转
                print("999222: ------------开始顺时针旋转------------")
                let result = arePointsTouchingOnSameCircle(point1: endPointValue, point2: startPointValue)
                if result {
                    startPointValue = endPointValue + minDistance <= maximumValue ? endPointValue + minDistance : endPointValue + minDistance - maximumValue
                    print("999222: start: \(endPointValue) end: \(startPointValue)")
                }
                print("999222: ------------结束顺时针旋转------------")
            case .counterclockwise:
                /// 逆时针旋转
                print("999222: ------------开始逆时针旋转------------")
                let result = arePointsTouchingOnSameCircle(point1: endPointValue, point2: startPointValue)
                if result {
                    print("999222: 变更前 end: \(endPointValue) start: \(startPointValue)")
                    startPointValue = endPointValue - minDistance >= 0 ? endPointValue - minDistance : endPointValue - minDistance + maximumValue
                    print("999222: 变更后 end: \(endPointValue) start: \(startPointValue)")
                }
                print("999222: ------------结束逆时针旋转------------")
            case .stationary:
                print("999222: 点没有移动或在完全对称的位置")
            }
        case .internalPointStart:
            if let _intervalThumbPoint = intervalThumbPoint {
                let oldValue = _intervalThumbPoint.start
                let newValue = newValue(from: _intervalThumbPoint.start, touch: touchPosition, start: startPoint)
                _intervalThumbPoint.start = newValue
                // 前面的点是否碰撞
                let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
                let startAngle = CircularSliderHelper.scaleToAngle(value: oldValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
                let endAngle = CircularSliderHelper.scaleToAngle(value: newValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
                if endAngle > startAngle {
                    print("222: ------------ 开始顺时针方向 ------------")
                    print("222: 所有计划集合: **********")
                    midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                        print("222: 计划: \(item)")
                        return true
                    }
                    print("222: 所有计划集合: **********")
                    print("222: 自定义计划集合: =========")
                    midIntervalPoints.traverse(from: _intervalThumbPoint, forward: true) { (item: CircularIntervalPoint) in
                        print("222: 自定义计划: \(item)")
                        return true
                    }
                    print("222: 自定义计划集合: =========")
                    var isPointsInSameLine = true
                    var loop = 0
                    midIntervalPoints.traverse(from: _intervalThumbPoint, forward: true) { (item: CircularIntervalPoint) in
                        print("222: isPointsInSameLine: \(isPointsInSameLine)")
                        print("222: currentPoint: \(item)")
                        loop+=1
                        if isPointsInSameLine {
                            if let _previous = item.previous, loop != 1{
                                print("222: loop: \(loop)")
                                let result2 = arePointsTouchingOnSameCircle(point1: _previous.end, point2: item.start)
                                print("222: 碰撞结果: \(result2) point1: \(_previous.end), point2: \(item.start)")
                                if result2 {
                                    item.start = _previous.end + minDistance <= maximumValue ? _previous.end + minDistance : _previous.end + minDistance - maximumValue
                                } else {
                                    return false
                                }
                            }
                            let result = arePointsTouchingOnSameCircle(point1: item.start, point2: item.end)
                            print("222: 碰撞结果: \(result) point1: \(item.start), point2: \(item.end)")
                            if result {
                                item.end = item.start + minDistance <= maximumValue ? item.start + minDistance : item.start + minDistance - maximumValue
                            } else {
                                return false
                            }
                            
                        } else {
                            if let _previous = item.previous {
                                print("222: previous: \(_previous)")
                                let result = arePointsTouchingOnSameCircle(point1: _previous.end, point2: item.start)
                                print("222: 碰撞结果: \(result)")
                                if result {
                                    item.start = _previous.end + minDistance < maximumValue ? _previous.end + minDistance : _previous.end + minDistance - maximumValue
                                } else {
                                    return false
                                }
                                
                                let result2 = arePointsTouchingOnSameCircle(point1: item.start, point2: item.end)
                                print("222: 碰撞结果: \(result2)")
                                if result2 {
                                    item.end = item.start + minDistance < maximumValue ? item.start + minDistance : item.start + minDistance - maximumValue
                                } else {
                                    return false
                                }
                            }
                        }
                        isPointsInSameLine = !isPointsInSameLine
                        return true
                    }
                    print("2222: 循环了\(loop)次")
                    print("222:------------ 结束顺时针方向 ------------")
                } else if endAngle < startAngle {
                    print("333: ------------ 开始逆时针方向 ------------")
                    print("333: 所有计划集合: **********")
                    midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                        print("333: 计划: \(item)")
                        return true
                    }
                    print("333: 所有计划集合: **********")
                    var loop = 0
                    var stop = false
                    let startPoint = _intervalThumbPoint
                    var currentPoint = _intervalThumbPoint
                    repeat {
                        print("333: currentPoint: \(currentPoint)")
                        if loop == 0 {
                            if let _previous = currentPoint.previous {
                                let result2 = arePointsTouchingOnSameCircle(point1: currentPoint.start, point2: _previous.end)
                                print("333: 碰撞结果: \(result2), point1: \(currentPoint), point2: \(_previous)")
                                if result2 {
                                    _previous.end = currentPoint.start - minDistance > 0 ? currentPoint.start - minDistance : maximumValue - minDistance + currentPoint.start
                                } else {
                                    stop = true
                                }
                            } else {
                                stop = true
                            }
                        } else {
                            let result = arePointsTouchingOnSameCircle(point1: currentPoint.end, point2: currentPoint.start)
                            print("333: 碰撞结果: \(result), point1: \(currentPoint), point2: \(currentPoint)")
                            if result {
                                currentPoint.start = currentPoint.end - minDistance >= 0 ? currentPoint.end - minDistance : maximumValue - minDistance + currentPoint.end
                                if let _previous = currentPoint.previous {
                                    let result = arePointsTouchingOnSameCircle(point1: currentPoint.start, point2: _previous.end)
                                    print("333: 碰撞结果: \(result), point1: \(currentPoint), point2: \(_previous)")
                                    if result {
                                        _previous.end = currentPoint.start - minDistance >= 0 ? currentPoint.start - minDistance : maximumValue - minDistance + currentPoint.start
                                    } else {
                                        stop = true
                                    }
                                } else {
                                    stop = true
                                }
                            } else {
                                stop = true
                            }
                        }
                        if let _previous = currentPoint.previous {
                            currentPoint = _previous
                        } else {
                            stop = true
                        }
                        loop+=1
                    } while currentPoint != startPoint && !stop
                    print("333: ------------ 结束逆时针方向 ------------")
                } else {
                    print("222333: 点没有移动或在完全对称的位置, distance: \(distance)")
                }
            }
            print("")
        case .internalPointEnd:
            if let _intervalThumbPoint = intervalThumbPoint {
                print("888666: ***********开始***********")
                let oldValue = _intervalThumbPoint.end
                let newValue = newValue(from: _intervalThumbPoint.end, touch: touchPosition, start: startPoint)
                _intervalThumbPoint.end = newValue
                let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
                let oldRadian = CircularSliderHelper.scaleToAngle(value: oldValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
                let newRadian = CircularSliderHelper.scaleToAngle(value: newValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
                print("123123: startAngle: \(oldRadian), endAngle: \(newRadian)")
                let movementDirection = determineMovementDirection(oldRadian: oldRadian, newRadian: newRadian)
                let pointList = lineList2PointList(from: midIntervalPoints, startPoint: _intervalThumbPoint, isBegin: false)
                switch movementDirection {
                case .clockwise:
                        /// 顺时针旋转
                        print("888666: ------------开始顺时针旋转------------")
                        if let _firstPoint = pointList.head {
                            print("888666: firstPoint: \(_firstPoint)")
                            var currentPoint = _firstPoint
                            repeat {
                                let nextPoint = currentPoint.next!
                                let result = arePointsTouchingOnSameCircle(point1: currentPoint.value, point2: nextPoint.value)
                                print("888666: currentPoint: \(currentPoint), nextPoint: \(nextPoint), 碰撞: \(result)")
                                if result {
                                    nextPoint.value = currentPoint.value + minDistance <= maximumValue ? currentPoint.value + minDistance : currentPoint.value + minDistance - maximumValue
                                    print("888666: new currentPoint: \(currentPoint)")
                                } else {
                                    print("888666: 跳出循环")
                                    break
                                }
                                currentPoint = nextPoint
                            } while currentPoint !== _firstPoint
                            modifyLineList(by: pointList, selectLine: _intervalThumbPoint)
                        }
                        print("888666: ------------结束顺时针旋转------------")
                case .counterclockwise:
                    /// 逆时针旋转
                    print("999666: ------------开始逆时针旋转------------")
                    if let _firstPoint = pointList.head {
                        var currentPoint = _firstPoint
                        print("2341: >>>>>>>>>>>>>开始逆时针旋转>>>>>>>>>>>>>")
                        repeat {
                            print("2341: |__ \(currentPoint)")
                            currentPoint = currentPoint.previous!
                        } while currentPoint !== _firstPoint
                        print("2341: ------------------------")
                        repeat {
                            print("2341: |__ \(currentPoint)")
                            let previousPoint = currentPoint.previous!
                            let result = arePointsTouchingOnSameCircle(point1: currentPoint.value, point2: previousPoint.value)
                            if result {
                                previousPoint.value = currentPoint.value >= minDistance ? currentPoint.value - minDistance : currentPoint.value - minDistance + maximumValue
                            } else {
                                break
                            }
                            currentPoint = previousPoint
                        } while currentPoint !== _firstPoint
                        print("2341: ------------------------")
                        currentPoint = _firstPoint
                        repeat {
                            print("2341: |__ 最新的 \(currentPoint)")
                            currentPoint = currentPoint.previous!
                        } while currentPoint !== _firstPoint
                        print("2341: ------------------------")
                        print("2341: <<<<<<<<<<<<<结束逆时针旋转<<<<<<<<<<<<<")
                        modifyLineList(by: pointList, selectLine: _intervalThumbPoint)
                    }
                    print("999666: ------------结束逆时针旋转------------")
                case .stationary:
                    print("101010666: 点没有移动或在完全对称的位置")
                }
                print("888666: ***********结束***********")
            }
        case .none:
            print("none")
        }
        sendActions(for: .valueChanged)
        
        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        intervalThumbPoint = nil
    }


    // MARK: - Helpers
    open func thumb(for touchPosition: CGPoint) -> SelectedThumb {
        if midIntervalPoints.isEmpty {
            if isThumb(withCenter: startThumbCenter, containsPoint: touchPosition) {
                print("找到控制点了 - 起点")
                return .startThumb
            } else if isThumb(withCenter: endThumbCenter, containsPoint: touchPosition) {
                print("找到控制点了 - 终点")
                return .endThumb
            } else {
                return .none
            }
        } else {
            var result: SelectedThumb = .none
            midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                if isThumb(withCenter: item.startThumbCenter, containsPoint: touchPosition) {
                    result = .internalPointStart
                    intervalThumbPoint = item
                    print("找到控制点了 - 起点")
                    return false
                } else if isThumb(withCenter: item.endThumbCenter, containsPoint: touchPosition) {
                    result = .internalPointEnd
                    intervalThumbPoint = item
                    print("找到控制点了 - 终点")
                    return false
                }
                return true
            }
            return result
        }
    }
    
    func arePointsTouchingOnSameCircle(point1: CGFloat, point2: CGFloat) -> Bool {
        if minDistance > 0 {
            let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
            let minRadian = CircularSliderHelper.scaleToAngle(value: minDistance, inInterval: interval)
            let minAngle = CircularSliderHelper.degrees(fromRadians: minRadian)
            return arePointsTouchingOnSameCircle(point1: point1, point2: point2, touchRadius: radius, minAngle: minAngle)
        } else {
            return false
        }
    }
    
    /// 判断两个同圆上的点是否触碰
    /// - Parameters:
    ///   - angle1: 第一个点的角度位置（单位：度）
    ///   - angle2: 第二个点的角度位置（单位：度）
    ///   - touchRadius: 两个点的触碰半径（单位：度），假设两点有相同的触碰半径
    /// - Returns: 如果两点触碰返回true，否则返回false
    func arePointsTouchingOnSameCircle(point1: CGFloat, point2: CGFloat, touchRadius: CGFloat, minAngle: CGFloat) -> Bool {
        print("point1: \(point1), point2: \(point2)")
        let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        let angle1 = CircularSliderHelper.degrees(fromRadians: CircularSliderHelper.scaleToAngle(value: point1, inInterval: interval) + CircularSliderHelper.circleInitialAngle)
        // get end angle from end value
        let angle2 = CircularSliderHelper.degrees(fromRadians: CircularSliderHelper.scaleToAngle(value: point2, inInterval: interval) + CircularSliderHelper.circleInitialAngle)
        // 计算两点之间的最小角度差
        let angleDifference = min(abs(angle1 - angle2), 360 - abs(angle1 - angle2))
        let result = angleDifference <= minAngle
        print("angle1: \(angle1), angle2: \(angle2), angleDifference: \(angleDifference) 碰撞: \(result)")
        return result
    }
    
    // MARK: - Action
    @objc func longPressAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPosition = sender.location(in: self)
            if midIntervalPoints.isEmpty {
                let result = isPointInArcCentered(touchPosition, startPointValue, endPointValue)
                print("\(touchPosition) 是否在弧线\(startPointValue) - \(endPointValue)内：\(result)")
                if result {
                    let startTime = TimeInterval(startPointValue)
                    let endTime = TimeInterval(endPointValue)
                    let offset = endTime > startTime ? endTime - startTime : maximumValue - startTime + endTime
                    if offset >= 3 * 60 * 60 {
                        var midValue = CGFLOAT_MAX
                        if startPointValue < endPointValue {
                            midValue = (startPointValue + endPointValue) * 0.5
                        } else {
                            let halfDistance = (maximumValue - startPointValue + endPointValue) * 0.5
                            midValue = startPointValue + halfDistance <= maximumValue ? startPointValue + halfDistance : endPointValue - halfDistance
                        }
                        if midValue == CGFLOAT_MAX {
                            return
                        }
                        let unitValue = 60.0
                        let midStartValue = midValue - 30 * unitValue
                        let midEndValue = midValue + 30 * unitValue
                        let startIntervalPoint = CircularIntervalPoint(start: startPointValue, end: midStartValue)
                        let endIntervalPoint = CircularIntervalPoint(start: midEndValue, end: endPointValue)
                        midIntervalPoints.append(node: startIntervalPoint)
                        midIntervalPoints.append(node: endIntervalPoint)
                    }
                    print("111: ---------当前计划---------")
                    midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                        print("111: \(item)")
                        return true
                    }
                    print("111: ---------end---------")
                }
            } else {
                var selectedIntervalPoint: CircularIntervalPoint?
                print("计划集合: \(midIntervalPoints)")
                midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                    let result = isPointInArcCentered(touchPosition, item.start, item.end)
                    print("\(touchPosition) 是否在弧线\(item.start) - \(item.end)内：\(result)")
                    if result {
                        let offset = abs(item.end - item.start)
                        if offset >= 3 * 60 * 60 {
                            selectedIntervalPoint = item
                        }
                        return false
                    } else {
                        return true
                    }
                }
                if let _selectedIntervalPoint = selectedIntervalPoint {
                    let unitValue = 60.0
                    // 判断起点和终点
                    var midValue = CGFLOAT_MAX
                    if _selectedIntervalPoint.start < _selectedIntervalPoint.end {
                        midValue = (_selectedIntervalPoint.start + _selectedIntervalPoint.end) * 0.5
                    } else {
                        let halfDistance = (maximumValue - _selectedIntervalPoint.start + _selectedIntervalPoint.end) * 0.5
                        midValue = _selectedIntervalPoint.start + halfDistance <= maximumValue ? _selectedIntervalPoint.start + halfDistance : _selectedIntervalPoint.end - halfDistance
                    }
                    if midValue == CGFLOAT_MAX {
                        return
                    }
                    let midStartValue = midValue - 30 * unitValue
                    let midEndValue = midValue + 30 * unitValue
                    let endIntervalPoint = CircularIntervalPoint(start: midEndValue, end: _selectedIntervalPoint.end)
                    _selectedIntervalPoint.end = midStartValue
                    midIntervalPoints.insert(node: endIntervalPoint, afterNode: _selectedIntervalPoint)
                }
                print("111: ---------当前计划---------")
                midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                    print("111: \(item.start) - \(item.end)")
                    return true
                }
                print("111: ---------end---------")
            }
            setNeedsDisplay()
        }
    }
    
    // MARK: - Private Properties
    private lazy var longPressGestureRecognizer = {
       let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        return longPressGestureRecognizer
    }()
    
    private enum MovementDirection {
        case clockwise
        case counterclockwise
        case stationary
    }
    
    // MARK: - Private Properties
    var midIntervalPoints = CircularIntervalPointList() {
        didSet {
            print("2341: @@@@@@@@@@@@@@@我变更了@@@@@@@@@@@@@@@")
            print("2341: --------------新值开始-------------------")
            midIntervalPoints.traverse { (item: CircularIntervalPoint) in
                print("2341: |__ \(item)")
                return true
            }
            print("2341: --------------新值结束-------------------")
        }
    }
    
    private func lineList2PointList(from lineList: CircularIntervalPointList, startPoint target:CircularIntervalPoint, isBegin begin: Bool ) -> CircularPointList {
        let result = CircularPointList()
        var lastValue: CGFloat? = nil
        var loop = 1
        print("666: -------------point start-------------)")
        lineList.traverse(from: target, forward: true) { (item: CircularIntervalPoint) in
            print("666: \(item)")
            if loop == 1 {
                if begin == false {
                    result.append(value: item.end, isStart: false, isEnd: true)
                    lastValue = item.start
                } else {
                    result.append(value: item.start, isStart: true, isEnd: false)
                    result.append(value: item.end, isStart: false, isEnd: false)
                }
            } else if loop == lineList.count {
                if begin == true {
                    result.append(value: item.start, isStart: false, isEnd: false)
                    result.append(value: item.end, isStart: false, isEnd: true)
                } else {
                    result.append(value: item.start, isStart: false, isEnd: false)
                    result.append(value: item.end, isStart: false, isEnd: false )
                }
            } else {
                result.append(value: item.start, isStart: false, isEnd: false)
                result.append(value: item.end, isStart: false, isEnd: false)
            }
            loop+=1
            return true
        }
        if let _lastValue = lastValue {
            result.append(value: _lastValue, isStart: true, isEnd: false)
        }
        print("666: -------------point end-------------)")
        print("666: -------------start-------------)")
        result.traverse { (item: CircularPoint) in
            print("666: \(item)")
            return true
        }
        print("666: -------------end-------------)")
        return result
    }
    
    private func modifyLineList(by pointList: CircularPointList, selectLine line: CircularIntervalPoint) {
        var currentLine = line
        print("2341: @@@@@@@@@@@@@@@@@旧值开始@@@@@@@@@@@@@@@@@")
        currentLine = line
        repeat {
            print("2341: |__ \(currentLine)")
            currentLine = currentLine.next!
        } while currentLine != line
        print("2341: @@@@@@@@@@@@@@@@@旧值结束@@@@@@@@@@@@@@@@@")
        
        currentLine = line
        var index = 0
        var startPoint = pointList.findFirstNode()!
        var currentPoint = startPoint
        repeat {
            if index == 0 {
                currentLine.start = currentPoint.value
                if currentPoint.next!.isEnd {
                    currentLine.end = currentPoint.next!.value
                    currentPoint = currentPoint.next!.next!
                } else {
                    currentLine.end = currentPoint.previous!.value
                    currentPoint = currentPoint.next!
                }
            } else {
                currentLine.start = currentPoint.value
                currentLine.end = currentPoint.next!.value
                currentPoint = currentPoint.next!.next!
            }
            currentLine = currentLine.next!
            index += 1
        } while currentLine != line
        print("2341: @@@@@@@@@@@@@@@@@新值开始@@@@@@@@@@@@@@@@@")
        currentLine = line
        repeat {
            print("2341: |__ \(currentLine)")
            currentLine = currentLine.next!
        } while currentLine != line
        print("2341: @@@@@@@@@@@@@@@@@新值结束@@@@@@@@@@@@@@@@@")
    }

    private func pointList2LineList(from pointList: CircularPointList) -> CircularIntervalPointList? {
        print("777: ------------strat-------------")
        pointList.traverse { (item: CircularPoint) in
            print("777: \(item)")
            return true
        }
        print("777: ------------end-------------")
        let result = CircularIntervalPointList()
        // 找到 isStart 为 true
        guard let startPoint = pointList.findFirstNode() else {
            print("777: 数据存在问题")
            return nil
        }
        
        guard let endPoint = pointList.findEndNode() else {
            print("777: 数据存在问题")
            return nil
        }
        
        guard let nextPoint = startPoint.next else {
            print("777: 数据存在问题")
            return nil
        }
        
        if endPoint != nextPoint {
            let intervalPoint = CircularIntervalPoint(start: endPoint.value, end: startPoint.value)
            result.append(node: intervalPoint)
            nextPoint.isStart = true
            pointList.remove(node: startPoint)
            pointList.remove(node: endPoint)
        }
        
        guard let newStartPoint = pointList.findFirstNode() else {
            print("777: 数据存在问题")
            return nil
        }
        
        var currentPoint = newStartPoint
        
        let beginPoint = currentPoint
        
        repeat {
            let start = currentPoint.value
            currentPoint = currentPoint.next!
            let end = currentPoint.value
            currentPoint = currentPoint.next!
            result.append(node: CircularIntervalPoint(start: start, end: end))
        } while currentPoint != beginPoint
        
        print("777666: ----------begin recover----------")
        result.traverse { (item: CircularIntervalPoint) in
            print("777666: \(item)")
            return true
        }
        print("777666: ----------end recover----------")
        
        return result
    }
    
    private func determineMovementDirection(oldRadian: Double, newRadian: Double) -> MovementDirection {
        // 角度正规化到0到360度
        let oldAngle = CircularSliderHelper.degrees(fromRadians: oldRadian)
        let newAngle = CircularSliderHelper.degrees(fromRadians: newRadian)
        
        // 计算角度变化
        var angleChange = newAngle - oldAngle
        
        // 角度差调整为-180到180度之间，以便判断方向
        if angleChange > 180 {
            angleChange -= 360
        } else if angleChange < -180 {
            angleChange += 360
        }
        
        // 根据角度变化判断方向
        if angleChange > 0 {
            print("5555: 顺时针")
            return .clockwise
        } else if angleChange < 0 {
            print("5555: 逆时针")
            return .counterclockwise
        } else {
            print("5555: 不动")
            return .stationary
        }
    }
    
    private func intervalPointList2TimeRangeList(from pointList: CircularIntervalPointList) -> [TYCircularTimeRange] {
        var list = [TYCircularTimeRange]()
        pointList.traverse { (item: CircularIntervalPoint) in
            var tmp = TYCircularTimeRange()
            tmp.start = item.start
            tmp.end = item.end
            list.append(tmp)
            return true
        }
        return list
    }
}
