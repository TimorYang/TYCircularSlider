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
                item.endThumbCenter = drawThumbAt(endAngle, with: endThumbImage, inContext: context)
                
                // start thumb
                startThumbTintColor.setFill()
                (isHighlighted == true && selectedThumb == .startThumb) ? startThumbStrokeHighlightedColor.setStroke() : startThumbStrokeColor.setStroke()
                
                item.startThumbCenter = drawThumbAt(startAngle, with: startThumbImage, inContext: context)
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
            startPointValue = newValue(from: startPointValue, touch: touchPosition, start: startPoint)
        case .endThumb:
            endPointValue = newValue(from: endPointValue, touch: touchPosition, start: startPoint)
        case .internalPointStart:
            if let _intervalThumbPoint = intervalThumbPoint {
                let oldValue = _intervalThumbPoint.start
                let newValue = newValue(from: _intervalThumbPoint.start, touch: touchPosition, start: startPoint)
                _intervalThumbPoint.start = newValue
                // 前面的点是否碰撞
                let distance = 1.0 * 60 * 60
                let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
                let startAngle = CircularSliderHelper.scaleToAngle(value: oldValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
                // get end angle from end value
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
                                let result2 = arePointsTouchingOnSameCircle(point1: _previous.end, point2: item.start, touchRadius: radius, minAngle: 30.0)
                                print("222: 碰撞结果: \(result2) point1: \(_previous.end), point2: \(item.start)")
                                if result2 {
                                    item.start = _previous.end + distance <= maximumValue ? _previous.end + distance : _previous.end + distance - maximumValue
                                } else {
                                    return false
                                }
                            }
                            let result = arePointsTouchingOnSameCircle(point1: item.start, point2: item.end, touchRadius: radius, minAngle: 30.0)
                            print("222: 碰撞结果: \(result) point1: \(item.start), point2: \(item.end)")
                            if result {
                                item.end = item.start + distance <= maximumValue ? item.start + distance : item.start + distance - maximumValue
                            } else {
                                return false
                            }
                            
                        } else {
                            if let _previous = item.previous {
                                print("222: previous: \(_previous)")
                                let result = arePointsTouchingOnSameCircle(point1: _previous.end, point2: item.start, touchRadius: radius, minAngle: 30.0)
                                print("222: 碰撞结果: \(result)")
                                if result {
                                    item.start = _previous.end + distance < maximumValue ? _previous.end + distance : _previous.end + distance - maximumValue
                                } else {
                                    return false
                                }
                                
                                let result2 = arePointsTouchingOnSameCircle(point1: item.start, point2: item.end, touchRadius: radius, minAngle: 30.0)
                                print("222: 碰撞结果: \(result2)")
                                if result2 {
                                    item.end = item.start + distance < maximumValue ? item.start + distance : item.start + distance - maximumValue
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
                    var isPointsInSameLine = false
                    var loop = 0
                    var stop = false
                    let startPoint = _intervalThumbPoint
                    var currentPoint = _intervalThumbPoint
                    repeat {
                        print("333: isPointsInSameLine: \(isPointsInSameLine)")
                        print("333: currentPoint: \(currentPoint)")
                        if isPointsInSameLine {
                            let result = arePointsTouchingOnSameCircle(point1: currentPoint.end, point2: currentPoint.start, touchRadius: radius, minAngle: 30.0)
                            print("333: 碰撞结果: \(result), point1: \(currentPoint), point2: \(currentPoint)")
                            if result {
                                currentPoint.start = currentPoint.end - distance >= 0 ? currentPoint.end - distance : maximumValue - distance + currentPoint.end
                                
                                if let _previous = currentPoint.previous {
                                    let result2 = arePointsTouchingOnSameCircle(point1: currentPoint.start, point2: _previous.end, touchRadius: radius, minAngle: 30.0)
                                    print("333: 碰撞结果: \(result2), point1: \(currentPoint), point2: \(_previous)")
                                    if result2 {
                                        _previous.end = currentPoint.start - distance > 0 ? currentPoint.start - distance : maximumValue - distance + currentPoint.start
                                    } else {
                                        stop = true
                                    }
                                } else {
                                    stop = true
                                }
                                
                            } else {
                                stop = true
                            }
                            
                        } else {
                            if loop == 0 {
                                if let _previous = _intervalThumbPoint.previous {
                                    let result = arePointsTouchingOnSameCircle(point1: currentPoint.start, point2: _previous.end, touchRadius: radius, minAngle: 30.0)
                                    print("333: 碰撞结果: \(result), point1: \(currentPoint), point2: \(_previous)")
                                    if result {
                                        _previous.end = currentPoint.start - distance >= 0 ? currentPoint.start - distance : maximumValue - distance + currentPoint.start
                                    } else {
                                        stop = true
                                    }
                                } else {
                                    stop = true
                                }
                            } else {
                                if let _next = currentPoint.next, loop != 0 {
                                    let result2 = arePointsTouchingOnSameCircle(point1: _next.start, point2: currentPoint.end, touchRadius: radius, minAngle: 30.0)
                                    print("333: 碰撞结果: \(result2), point1: \(_next), point2: \(currentPoint)")
                                    if result2 {
                                        currentPoint.end = _next.start - distance >= 0 ? _next.start - distance : maximumValue - distance + _next.start
                                        if let _previous = _intervalThumbPoint.previous {
                                            let result = arePointsTouchingOnSameCircle(point1: currentPoint.end, point2: currentPoint.start, touchRadius: radius, minAngle: 30.0)
                                            print("333: 碰撞结果: \(result), point1: \(currentPoint), point2: \(currentPoint)")
                                            if result {
                                                currentPoint.start = currentPoint.end - distance >= 0 ? currentPoint.end - distance : maximumValue - distance + currentPoint.end
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
                            }
                        }
                        isPointsInSameLine = !isPointsInSameLine
                        if let _previous = currentPoint.previous {
                            currentPoint = _previous
                        } else {
                            stop = true
                        }
                        loop+=1
                    } while currentPoint != startPoint && !stop
                    
//
//                    midIntervalPoints.traverse(from: _intervalThumbPoint, forward: false) { (item: CircularIntervalPoint) in
//                        print("333: isPointsInSameLine: \(isPointsInSameLine)")
//                        print("333: currentPoint: \(item)")
//                        loop+=1
//                        if isPointsInSameLine {
//                            let result = arePointsTouchingOnSameCircle(point1: item.end, point2: item.start, touchRadius: radius, minAngle: 30.0)
//                            print("333: 碰撞结果: \(result), point1: \(item.end), point2: \(item.start)")
//                            if result {
//                                item.start = item.end - distance > 0 ? item.end - distance : maximumValue - distance + item.end
//                            } else {
//                                return false
//                            }
//                            if let _previous = item.previous {
//                                print("333: nextPoint: \(_previous)")
//                                let result2 = arePointsTouchingOnSameCircle(point1: item.start, point2: _previous.end, touchRadius: radius, minAngle: 30.0)
//                                print("333: 碰撞结果: \(result2)")
//                                if result2 {
//                                    _previous.end = item.start - distance > 0 ? item.start - distance : maximumValue - distance + item.start
//                                } else {
//                                    return false
//                                }
//                            }
//                        } else {
//                            if let _previousPoint = item.previous {
//                                print("333: previousPoint: \(_previousPoint)")
//                                let result = arePointsTouchingOnSameCircle(point1: item.start, point2: _previousPoint.end, touchRadius: radius, minAngle: 30.0)
//                                print("333: 碰撞结果: \(result)")
//                                if result {
//                                    _previousPoint.end = item.start - distance >= 0 ? item.start - distance : maximumValue - distance + item.start
//                                } else {
//                                    return false
//                                }
//                                
//                                if loop != 1 {
//                                    print("3333: loop: \(loop)")
//                                    let result2 = arePointsTouchingOnSameCircle(point1: item.end, point2: item.start, touchRadius: radius, minAngle: 30.0)
//                                    print("333: 碰撞结果: \(result2)")
//                                    if result2 {
//                                        item.start = item.end - distance >= 0 ? item.end - distance : maximumValue - distance + item.end
//                                    } else {
//                                        return false
//                                    }
//                                }
//                            }
//                        }
//                        isPointsInSameLine = !isPointsInSameLine
//                        return true
//                    }
                    print("333: ------------ 结束逆时针方向 ------------")
                } else {
                    print("222333: 点没有移动或在完全对称的位置, distance: \(distance)")
                }
            }
        case .internalPointEnd:
            if let _intervalThumbPoint = intervalThumbPoint {
                let oldValue = _intervalThumbPoint.end
                let newValue = newValue(from: _intervalThumbPoint.end, touch: touchPosition, start: startPoint)
                _intervalThumbPoint.end = newValue
                // 后面的点是否碰撞
                if let _next = _intervalThumbPoint.next {
                    let result = arePointsTouchingOnSameCircle(point1: _intervalThumbPoint.end, point2: _next.start, touchRadius: radius, minAngle: 30.0)
                    print("是否和后面的点碰撞: \(result)")
                    if result {
                        let distance = abs(oldValue - newValue)
                        _next.start = _next.start + distance < maximumValue ? _next.start + distance : _next.start - maximumValue + distance
                    }
                }
                
                let result = arePointsTouchingOnSameCircle(point1: _intervalThumbPoint.end, point2: _intervalThumbPoint.start, touchRadius: radius, minAngle: 30.0)
                if result {
                    let distance = abs(oldValue - newValue)
                    _intervalThumbPoint.start = _intervalThumbPoint.start - distance > 0 ? _intervalThumbPoint.start - distance : maximumValue - _intervalThumbPoint.start + distance
                }
                print("是否和前面的点碰撞: \(result)")
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
                    let offset = endTime - startTime
                    if offset >= 3 * 60 * 60 {
                        let midValue = (startPointValue + endPointValue) * 0.5
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
                        print("111: \(item.start) - \(item.end)")
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
                    let midValue = (_selectedIntervalPoint.start + _selectedIntervalPoint.end) * 0.5
                    let unitValue = 60.0
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
    
    // MARK: - Private Properties
    var midIntervalPoints = CircularIntervalPointList()

}
