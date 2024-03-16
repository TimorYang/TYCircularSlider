//
//  CircularPointList.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/16.
//

import UIKit

class CircularPointList: NSObject {
    private(set) var head: CircularPoint?
    private var count: Int = 0
    
    // 判断链表是否为空
    var isEmpty: Bool {
        return head == nil
    }
    
    // 返回链表中的节点数
    var nodeCount: Int {
        return count
    }
    
    // 添加新元素到链表
    func append(value: CGFloat, isStart: Bool, isEnd: Bool) {
        let newPoint = CircularPoint()
        newPoint.value = value
        newPoint.isStart = isStart
        newPoint.isEnd = isEnd
        
        if let headPoint = head {
            // 如果链表不为空，找到尾节点，并设置新节点为尾节点的下一个节点，同时将新节点的前一个节点设为尾节点
            var currentPoint = headPoint
            while let nextPoint = currentPoint.next, nextPoint !== headPoint {
                currentPoint = nextPoint
            }
            currentPoint.next = newPoint
            newPoint.previous = currentPoint
            newPoint.next = headPoint // 完成环形
            headPoint.previous = newPoint
        } else {
            // 如果链表为空，新节点自己形成一个环
            head = newPoint
            newPoint.next = newPoint
            newPoint.previous = newPoint
        }
        
        count += 1 // 更新节点计数器
    }
    
    // 从指定节点开始遍历链表
    func traverse(from node: CircularPoint? = nil, _ body: (CircularPoint) -> Bool) {
        guard let startNode = node ?? head else { return }
        var currentNode = startNode
        repeat {
            let shouldContinue = body(currentNode)
            guard let nextNode = currentNode.next, shouldContinue else { break }
            currentNode = nextNode
        } while currentNode !== startNode
    }
    
    // 示例：删除链表中所有的节点（重置链表）
    func removeAll() {
        head = nil
        count = 0 // 重置节点计数器
    }
}
