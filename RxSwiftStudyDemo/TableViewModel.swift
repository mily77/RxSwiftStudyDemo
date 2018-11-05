//
//  TableViewModel.swift
//  RxSwiftStudyDemo
//
//  Created by emily on 2018/11/5.
//  Copyright © 2018 emily. All rights reserved.
//

import UIKit

//定义表格对应的ViewModel
struct TableViewModel {
    //表格数据项
//    fileprivate
    var items:[String]
    
    init(items: [String] = []) {
        self.items = items
    }
    
    //执行相应的命令，并返回最终的结果
    func execute(command: TableEditingCommand) -> TableViewModel {
        switch command {
        case .setItems(let items):
            print("设置表格数据。")
            return TableViewModel(items: items)
        case .addItem(let item):
            print("新增数据项。")
            var items = self.items
            items.append(item)
            return TableViewModel(items: items)
        case .moveItem(let from, let to):
            print("移动数据项。")
            var items = self.items
            items.insert(items.remove(at: from.row), at: to.row)
            return TableViewModel(items: items)
        case .deleteItem(let indexPath):
            print("删除数据项。")
            var items = self.items
            items.remove(at: indexPath.row)
            return TableViewModel(items: items)
        }
    }
}
