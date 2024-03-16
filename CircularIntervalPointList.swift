//
//  CircularIntervalPointList.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/14.
//

import UIKit

class CircularIntervalPointList: NSObject {
    private var head: CircularIntervalPoint?
    
    // 判断链表是否为空
    var isEmpty: Bool {
        return head == nil
    }
    
    // 返回链表的头节点
    var first: CircularIntervalPoint? {
        return head
    }
    
    // 添加新元素到链表
    func append(node: CircularIntervalPoint) {
        guard let headNode = head else {
            head = node
            node.next = node
            node.previous = node
            return
        }
        
        let tailNode = headNode.previous
        node.next = headNode
        node.previous = tailNode
        tailNode?.next = node
        headNode.previous = node
    }
    
    func insert(node newNode: CircularIntervalPoint, afterNode: CircularIntervalPoint) {
        let nextNode = afterNode.next
        newNode.next = nextNode
        newNode.previous = afterNode
        afterNode.next = newNode
        nextNode?.previous = newNode
    }
    
    // 删除节点
    func remove(node: CircularIntervalPoint) {
        guard let nextNode = node.next, let prevNode = node.previous, nextNode != node else {
            head = nil
            return
        }
        
        if node === head {
            head = nextNode
        }
        nextNode.previous = prevNode
        prevNode.next = nextNode
        
        node.previous = nil
        node.next = nil
    }
    
    // 查找节点
    func findNode(withStart value: CGFloat) -> CircularIntervalPoint? {
        var currentNode = head
        repeat {
            if currentNode?.start == value {
                return currentNode
            }
            currentNode = currentNode?.next
        } while currentNode !== head && currentNode != nil
        return nil
    }
    
    func findNode(withEnd value: CGFloat) -> CircularIntervalPoint? {
        var currentNode = head
        repeat {
            if currentNode?.end == value {
                return currentNode
            }
            currentNode = currentNode?.next
        } while currentNode !== head && currentNode != nil
        return nil
    }
    
    // 遍历链表，执行闭包操作
    func traverse(_ body: (CircularIntervalPoint) -> Bool) {
        var node = head
        repeat {
            if let currentNode = node {
                if body(currentNode) == false {
                    break
                }
                node = currentNode.next
            }
        } while node !== head && node != nil
    }
    
    // 从指定节点开始遍历链表
    func traverse(from startNode: CircularIntervalPoint, forward: Bool, _ body: (CircularIntervalPoint) -> Bool) {
        var currentNode: CircularIntervalPoint? = startNode
        repeat {
            guard let current = currentNode else { break }
            
            // 如果闭包返回false，则停止遍历
            if body(current) == false {
                break
            }
            
            // 根据遍历方向获取下一个节点
            currentNode = forward ? current.next : current.previous
            
            // 当遍历回到起始节点时停止
        } while currentNode !== startNode && currentNode != nil
    }
}

