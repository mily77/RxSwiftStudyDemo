//
//  TableEditingCommand.swift
//  RxSwiftStudyDemo
//
//  Created by emily on 2018/11/5.
//  Copyright © 2018 emily. All rights reserved.
//

import Foundation

//定义各种操作命令
enum TableEditingCommand {
    case setItems(items: [String])  //设置表格数据
    case addItem(item: String)  //新增数据
    case moveItem(from: IndexPath, to: IndexPath) //移动数据
    case deleteItem(IndexPath) //删除数据
}
