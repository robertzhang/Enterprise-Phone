//
//  TreeTableView.swift
//  EP
//
//  Created by robertzhang on 15/10/21.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import UIKit

protocol TreeTableViewCellDelegate: NSObjectProtocol {
    func cellClick() //参数还没加，TreeNode表示节点
}


class TreeTableView: UITableView, UITableViewDataSource,UITableViewDelegate {
    
    var mAllNodes: [TreeNode]? //所有的node
    var mNodes: [TreeNode]? //可见的node
    
    var treeTableViewCellDelegate: TreeTableViewCellDelegate?
    
    let NODE_CELL_ID: String = "node_cell_id"
    
    init(frame: CGRect, withData data: [TreeNode]) {
        super.init(frame: frame, style: UITableViewStyle.Plain)
        self.delegate = self
        self.dataSource = self
        mAllNodes = data
        mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 通过nib自定义tableviewcell
        let nib = UINib(nibName: "TreeNodeTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: NODE_CELL_ID)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NODE_CELL_ID) as! TreeNodeTableViewCell
        
        let node: TreeNode = mNodes![indexPath.row]
        
        //cell缩进
        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        
        //代码修改nodeIMG---UIImageView的显示模式.
        if node.icon != nil {
            if node.icon != "default_icon.png" {
                cell.nodeIMG.contentMode = UIViewContentMode.Center
                cell.nodeIMG.image = UIImage(named: node.icon!)
            } else {
                cell.nodeIMG.contentMode = UIViewContentMode.ScaleAspectFit
                cell.nodeIMG.sd_setImageWithURL(NSURL(string: "https://webapi.easipbx.com:9443"+TreeNodeHelper.sharedInstance.getIconURLforUserID(node.id!)), placeholderImage: UIImage(named: node.icon!))
            }
        }
        
        cell.nodeName.text = node.name
        
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mNodes?.count)!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let parentNode = mNodes![indexPath.row]
        
        let startPosition = indexPath.row+1
        var endPosition = startPosition
        var expand: Bool = false;
        
        
        if parentNode.type == 1 {// 如果选中的节点为叶子节点，则表示点击在用户上
            treeTableViewCellDelegate!.cellClick()
        } else {
            expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
            //            expandOrCollapse(indexPath.row)
            //            endPosition += parentNode.children.count
            
            //修正indexpath
            var indexPathArray :[NSIndexPath] = []
            var tempIndexPath: NSIndexPath?
            for (var i = startPosition; i < endPosition ; i++) {
                tempIndexPath = NSIndexPath(forRow: i, inSection: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
            // 插入和删除节点的动画
            if parentNode.isExpand {
                self.insertRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.None)
            } else {
                self.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.None)
            }
            //更新被选组节点
            self.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            
        }
        
    }
    
    
    //展开或者关闭某个节点
    func expandOrCollapse(inout count: Int, node: TreeNode) {
        if node.isExpand { //如果当前节点是开着的，需要关闭节点下的所有子节点
            closedChildNode(&count,node: node)
        } else { //如果节点是关着的，打开当前节点即可
            count += node.children.count
            node.setExpand(true)
        }
        
    }
    
    //关闭某个节点和该节点的所有子节点
    func closedChildNode(inout count:Int, node: TreeNode) {
        if node.isLeaf() {
            return
        }
        if node.isExpand {
            node.isExpand = false
            for item in node.children { //关闭子节点
                count++ // 计算子节点数加一
                closedChildNode(&count, node: item)
            }
        }
    }
    
    //    //展开或者关闭某个节点
    //    func expandOrCollapse(position: Int) {
    //        var n: TreeNode? = mNodes![position]
    //        if (n != nil) {
    //            if !n!.isLeaf() {
    //                n!.setExpand(!n!.isExpand)
    //                mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
    //            }
    //        }
    //    }
    
}
