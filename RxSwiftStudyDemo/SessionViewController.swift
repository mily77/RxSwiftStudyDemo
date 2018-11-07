//
//  SessionViewController.swift
//  RxSwiftStudyDemo
//
//  Created by emily on 2018/11/6.
//  Copyright © 2018 emily. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class SessionViewController: UIViewController {

    let disposeBag = DisposeBag()
    var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
        self.view.backgroundColor = .white
        
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL.init(string: urlString)
        
        let request = URLRequest(url: url!)
        
//        URLSession.shared.rx.data(request: request).subscribe(onNext: { (data) in
//            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
//            print("--- 请求成功！返回的如下数据 ---")
//            print(json!)
//        }).disposed(by: disposeBag)
        
        //创建并发起请求
//        URLSession.shared.rx.data(request: request)
//            .map {
//                try JSONSerialization.jsonObject(with: $0, options: .allowFragments)
//                    as! [String: Any]
//            }
//            .subscribe(onNext: {
//                data in
//                print("--- 请求成功！返回的如下数据 ---")
//                print(data)
//            }).disposed(by: disposeBag)
        
        //创建并发起请求
        URLSession.shared.rx.json(request: request).subscribe(onNext: {
            data in
            let json = data as! [String: Any]
            print("--- 请求成功！返回的如下数据 ---")
            print(json )
        }).disposed(by: disposeBag)
        
        //获取列表数据
        let data = URLSession.shared.rx.json(request: request).map { (result) -> [[String: Any]] in
            if let data = result as? [String: Any],let channels = data["channels"] as? [[String: Any]]{
                return channels
            
            }else{
                return []
            }
        }
        
        //将数据绑定到表格
//        data.bind(to: tableView.rx.items) { (tableView, row, element) in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
//            cell.textLabel?.text = "\(row)：\(element["name"]!)"
//            return cell
//            }.disposed(by: disposeBag)
        
        data.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(row)：\(element["name"]!)"
            return cell
        }.disposed(by: disposeBag)
    }
    

}
