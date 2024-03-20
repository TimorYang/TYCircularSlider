//
//  CircularIntervalPointList.swift
//  HGCircularSlider
//
//  Created by TeemoYang on 2024/3/14.
//

import UIKit

class CircularIntervalPointList: NSObject {
    private var head: CircularIntervalPoint?
    private var nodeCount = 0  // 维护链表中的节点数
    
    // 判断链表是否为空
    var isEmpty: Bool {
        return head == nil
    }
    
    // 返回链表的头节点
    var first: CircularIntervalPoint? {
        return head
    }
    
    // 链表的节点数
    var count: Int {
        return nodeCount
    }
    
    // 添加新元素到链表
    func append(node: CircularIntervalPoint) {
        guard let headNode = head else {
            head = node
            node.next = node
            node.previous = node
            nodeCount = 1  // 链表之前为空，现在有一个节点
            return
        }
        
        let tailNode = headNode.previous
        node.next = headNode
        node.previous = tailNode
        tailNode?.next = node
        headNode.previous = node
        nodeCount += 1  // 添加节点后，节点数增加
    }
    
    func insert(node newNode: CircularIntervalPoint, afterNode: CircularIntervalPoint) {
        let nextNode = afterNode.next
        newNode.next = nextNode
        newNode.previous = afterNode
        afterNode.next = newNode
        nextNode?.previous = newNode
        nodeCount += 1  // 插入节点后，节点数增加
    }
    
    // 删除节点
    func remove(node: CircularIntervalPoint) {
        guard let nextNode = node.next, let prevNode = node.previous, nextNode != node else {
            head = nil
            nodeCount = 0  // 如果链表变为空，节点数重置为0
            return
        }
        
        if node === head {
            head = nextNode
        }
        nextNode.previous = prevNode
        prevNode.next = nextNode
        
        node.previous = nil
        node.next = nil
        nodeCount -= 1  // 删除节点后，节点数减少
    }
    
    func remove(start: CGFloat, end: CGFloat) {
        var currentNode = head
        var nodesToRemove: [CircularIntervalPoint] = []

        // 首先，遍历链表找到所有需要删除的节点
        repeat {
            if let node = currentNode, node.start >= start && node.end <= end {
                nodesToRemove.append(node)
            }
            currentNode = currentNode?.next
        } while currentNode !== head && currentNode != nil
        
        // 然后，删除所有标记的节点
        for node in nodesToRemove {
            remove(node: node)
        }
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

