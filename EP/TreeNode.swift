//
//  TreeNode.swift
//  EP
//
//  Created by Robert Zhang on 15/10/21.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import Foundation
import UIKit

public class TreeNode {
    
    public static let NODE_TYPE_GROUP  = 0; //部门类型
    public static let NODE_TYPE_USER   = 1; //用户类型
    
    var type: Int?
    var id: String?
    var pId: String?
    var name: String?
    var level: Int?
    var isExpand: Bool = false
    var icon: String?
    var children: [TreeNode] = []
    var parent: TreeNode?
    
    init (type: Int?, id:String? , pId: String? , name: String?) {
        self.type = type
        self.id = id
        self.pId = pId
        self.name = name
    }
    
    //是否为根节点
    func isRoot() -> Bool{
        return parent == nil
    }
    
    //判断父节点是否打开
    func isParentExpand() -> Bool {
        if parent == nil {
            return false
        }
        return (parent?.isExpand)!
    }
    
    //是否是叶子节点
    func isLeaf() -> Bool {
        return children.count == 0
    }
    
    //获取level,用于设置节点内容偏左的距离
    func getLevel() -> Int {
        return parent == nil ? 0 : (parent?.getLevel())!+1
    }
    
    //设置展开
    func setExpand(isExpand: Bool) {
        self.isExpand = isExpand
        if !isExpand {
            for (var i=0;i<children.count;i++) {
                children[i].setExpand(isExpand)
            }
        }
    }
    
}

class TreeNodeHelper {
    
    // 单例模式
    class var sharedInstance: TreeNodeHelper {
        struct Static {
            static var instance: TreeNodeHelper?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) { // 该函数意味着代码仅会被运行一次，而且此运行是线程同步
            Static.instance = TreeNodeHelper()
        }
        return Static.instance!
    }
    
    
    //传入普通节点，转换成排序后的Node
    func getSortedNodes(groups: [EPGroup], users: [ContactCompanyItem], defaultExpandLevel: Int) -> [TreeNode] {
        var result: [TreeNode] = []
        let nodes = convetData2Node(groups, users: users)
        let rootNodes = getRootNodes(nodes)
        for item in rootNodes{
            addNode(&result, node: item, defaultExpandLeval: defaultExpandLevel, currentLevel: 1)
        }
        
        return result
    }
    
    //过滤出所有可见节点
    func filterVisibleNode(nodes: [TreeNode]) -> [TreeNode] {
        var result: [TreeNode] = []
        for item in nodes {
            if item.isRoot() || item.isParentExpand() {
                setNodeIcon(item)
                result.append(item)
            }
        }
        return result
    }
    
    //将数据转换成书节点
    func convetData2Node(groups: [EPGroup], users: [ContactCompanyItem]) -> [TreeNode] {
        var nodes: [TreeNode] = []
        
        var node: TreeNode
        var nodetype: Int?
        var id: String?
        var pId: String?
        var label: String?
        
        for item in groups {
            nodetype = TreeNode.NODE_TYPE_GROUP
            id = item.id
            pId = item.parent_group_id
            label = item.label
            node = TreeNode(type: nodetype, id: id, pId: pId, name: label)
            nodes.append(node)
        }
        for item in users {
            nodetype = TreeNode.NODE_TYPE_USER
            id = item.userid
            pId = item.group_id
            label = item.firstName! + item.lastName!
            node = TreeNode(type: nodetype, id: id, pId: pId, name: label)
            nodes.append(node)
        }
        /**
        * 设置Node间，父子关系;让每两个节点都比较一次，即可设置其中的关系
        */
        var n: TreeNode
        var m: TreeNode
        for (var i=0; i<nodes.count; i++) {
            n = nodes[i]
            
            for (var j=i+1; j<nodes.count;j++) {
                m = nodes[j]
                if m.pId == n.id {
                    n.children.append(m)
                    m.parent = n
                } else if n.pId == m.id {
                    m.children.append(n)
                    n.parent = m
                }
            }
        }
        for item in nodes {
            setNodeIcon(item)
        }
        
        return nodes
    }
    
    // 获取根节点集
    func getRootNodes(nodes: [TreeNode]) -> [TreeNode] {
        var root: [TreeNode] = []
        for item in nodes {
            if item.isRoot() {
                root.append(item)
            }
        }
        return root
    }
    
    //把一个节点的所有子节点都挂上去
    func addNode(inout nodes: [TreeNode], node: TreeNode, defaultExpandLeval: Int, currentLevel: Int) {
        nodes.append(node)
        if defaultExpandLeval >= currentLevel {
            node.setExpand(true)
        }
        if node.isLeaf() {
            return
        }
        for (var i=0; i<node.children.count;i++) {
            addNode(&nodes, node: node.children[i], defaultExpandLeval: defaultExpandLeval, currentLevel: currentLevel+1)
        }
    }
    
    // 设置节点图标
    func setNodeIcon(node: TreeNode) {
        if node.type == TreeNode.NODE_TYPE_GROUP {
            if node.children.count > 0 && node.isExpand {
                // 设置icon为向下的箭头
                node.icon = "tree_ex.png"
            } else if node.children.count>0 && !node.isExpand {
                // 设置icon为向右的箭头
                node.icon = "tree_ec.png"
            }
        } else {
            //设置为默认User的默认头像
            node.icon = "default_icon.png"
        }
    }
    
    func getIconURLforUserID(userid: String) -> String {
        for item in ContactsCompany.sharedInstance._users {
            if userid == item.userid {
                return item.headimage!
            }
        }
        return "default_icon.png"
    }
    
    
    /*
    通过userid获取用户实例
    */
    func getUserforUserID(userid: String) -> ContactCompanyItem? {
        for item in ContactsCompany.sharedInstance._users {
            if userid == item.userid {
                return item
            }
        }
        return nil
    }
    
    func getGroupNameforGroupID(id: String?) -> String? {
        if (id == nil) {
         return ""
        }
        for item in ContactsCompany.sharedInstance._groups {
            if id == item.id {
                return item.label
            }
        }
        return ""
    }
}