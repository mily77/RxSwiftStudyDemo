//
//  MainViewController.swift
//  RxSwiftStudyDemo
//
//  Created by emily on 2018/10/24.
//  Copyright © 2018 emily. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class MainViewController: UIViewController {

    var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.view.frame)
        //创建一个重用的单元格
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
        //初始化数据
        let items = Observable.just([
            "文本输入框的用法",
            "开关按钮的用法",
            "进度条的用法",
            "文本标签的用法",
            ])

         //设置单元格数据（其实就是对 cellForRowAt 的封装）
        items.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = "\(row)：\(element)"
            return cell
        }.disposed(by: disposeBag)
        
        // 业务代码直接放在响应方法内部，可以这么写
        //获取选中项的索引
//        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
//            print("选中项的indexPath为：\(indexPath)")
//        }).disposed(by: disposeBag)
//
//        //获取选中项的内容
//        tableView.rx.modelSelected(String.self).subscribe(onNext: { item in
//            print("选中项的标题为：\(item)")
//        }).disposed(by: disposeBag)
        
        // 同时获取选中项的索引及内容也是可以的
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .bind { [weak self] indexPath, item in
                self?.showMessage("选中项的indexPath为：\(indexPath)")
                self?.showMessage("选中项的标题为：\(item)")
            }
            .disposed(by: disposeBag)
        
        //获取被取消选中项的索引
        tableView.rx.itemDeselected.subscribe(onNext: { [weak self] indexPath in
            self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        //获取被取消选中项的内容
        tableView.rx.modelDeselected(String.self).subscribe(onNext: {[weak self] item in
            self?.showMessage("被取消选中项的的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        // 获取删除项的索引
        tableView.rx.itemDeleted.subscribe(onNext:{[weak self] indexPath in
            self?.showMessage("删除项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        //获取删除项的内容
        tableView.rx.modelDeleted(String.self).subscribe(onNext: {[weak self] item in
            self?.showMessage("删除项的的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        //获取移动项的索引
        tableView.rx.itemMoved.subscribe(onNext: { [weak self]
            sourceIndexPath, destinationIndexPath in
            self?.showMessage("移动项原来的indexPath为：\(sourceIndexPath)")
            self?.showMessage("移动项现在的indexPath为：\(destinationIndexPath)")
        }).disposed(by: disposeBag)
        
        //获取点击的尾部图标的索引
        tableView.rx.itemAccessoryButtonTapped.subscribe(onNext: { [weak self] indexPath in
            self?.showMessage("尾部项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
    }
    //显示消息提示框
    func showMessage(_ text: String) {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
