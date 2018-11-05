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
import RxDataSources

class MainViewController: UIViewController {

    var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    //搜索栏
    var searchBar:UISearchBar!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
//        rxBindDataSource()
//        tableRxDelegate()
//
        let initialVM = TableViewModel()

        //刷新数据
        let refreshCommand = refreshButton.rx.tap.asObservable()
            .startWith(())
            .flatMapLatest(getRandomResult2)
            .map(TableEditingCommand.setItems)
//
        //新增条目命令
        let addCommand = addButton.rx.tap.asObservable()
            .map{ "\(arc4random())" }
            .map(TableEditingCommand.addItem)
//
        //移动位置命令
        let movedCommand = tableView.rx.itemMoved
            .map(TableEditingCommand.moveItem)

        //删除条目命令
        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableEditingCommand.deleteItem)

        //绑定单元格数据
        Observable.of(refreshCommand, addCommand, movedCommand, deleteCommand)
            .merge()
            .scan(initialVM) { (vm: TableViewModel, command: TableEditingCommand)
                -> TableViewModel in
                return vm.execute(command: command)
            }
            .startWith(initialVM)
            .map {
                [AnimatableSectionModel(model: "", items: $0.items)]
            }
            .share(replay: 1)
            .bind(to: tableView.rx.items(dataSource: MainViewController.dataSource2()))
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
    

    //获取随机数据
    func getRandomResult2() -> Observable<[String]> {
        print("生成随机数据。")
        let items = (0 ..< 5).map {_ in
            "\(arc4random())"
        }
        return Observable.just(items)
    }
}


extension MainViewController {
    //创建表格数据源
    static func dataSource2() -> RxTableViewSectionedAnimatedDataSource
        <AnimatableSectionModel<String, String>> {
            return RxTableViewSectionedAnimatedDataSource(
                //设置插入、删除、移动单元格的动画效果
                animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                               reloadAnimation: .fade,
                                                               deleteAnimation: .left),
                configureCell: {
                    (dataSource, tv, indexPath, element) in
                    let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
                    cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                    return cell
            },
                canEditRowAtIndexPath: { _, _ in
                    return true //单元格可删除
            },
                canMoveRowAtIndexPath: { _, _ in
                    return true //单元格可移动
            }
            )
    }
}


extension MainViewController {
    func initTableView() {
        self.tableView = UITableView(frame: self.view.frame)
        //创建一个重用的单元格
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
        //创建表头的搜索栏
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0,
                                                   width: self.view.bounds.size.width, height: 56))
        self.tableView.tableHeaderView =  self.searchBar
    }
}



extension MainViewController {
    func rxBindDataSource() {
        //随机的表格数据
        let randomResult = refreshButton.rx.tap.asObservable()
            .throttle(1, scheduler: MainScheduler.instance) //在主线程中操作，1秒内值若多次改变，取最后一次
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            .flatMapLatest{ //当 takeUntil 中的 Observable 发送一个值时，便会结束对应的 Observable。
                self.getRandomResult().takeUntil(self.cancelButton.rx.tap)
            }
            .flatMap(filterResult) //筛选数据
            .share(replay: 1)
        
        //创建数据源
        let dataSource = RxTableViewSectionedReloadDataSource
            <SectionModel<String, Int>>(configureCell: {
                (dataSource, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
                cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                return cell
            })
        
        //绑定单元格数据
        randomResult
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        //初始化数据
//        let sections = Observable.just([
//            MySection(header: "基本控件", items: [
//                "UILable的用法",
//                "UIText的用法",
//                "UIButton的用法"
//                ]),
//            MySection(header: "高级控件", items: [
//                "UITableView的用法",
//                "UICollectionViews的用法"
//                ])
//            ])
//
//        //创建数据源
//        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
//            //设置单元格
//            configureCell: { ds, tv, ip, item in
//                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
//                    ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
//                cell.textLabel?.text = "\(ip.row)：\(item)"
//
//                return cell
//        },
//            //设置分区头标题
//            titleForHeaderInSection: { ds, index in
//                return ds.sectionModels[index].header
//        }
//        )
//
//        //绑定单元格数据
//        sections
//            .bind(to: tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
        //初始化数据
//        let items = Observable.just([
//            SectionModel(model: "基本控件", items: [
//                "UILable的用法",
//                "UIText的用法",
//                "UIButton的用法"
//                ]),
//            SectionModel(model: "高级控件", items: [
//                "UITableView的用法",
//                "UICollectionViews的用法"
//                ])
//            ])
//
//        //创建数据源
//        let dataSource = RxTableViewSectionedReloadDataSource
//            <SectionModel<String, String>>(configureCell: {
//                (dataSource, tv, indexPath, element) in
//                let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
//                cell.textLabel?.text = "\(indexPath.row)：\(element)"
//                return cell
//            })
//
//        //设置分区头标题
//        dataSource.titleForHeaderInSection = { ds, index in
//            return ds.sectionModels[index].model
//        }
//        //绑定单元格数据
//        items
//            .bind(to: tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        // 使用自定义section
        //初始化数据
//        let sections = Observable.just([
//            MySection(header: "", items: [
//                "UILable的用法",
//                "UIText的用法",
//                "UIButton的用法"
//                ])
//            ])
        //创建数据源
//        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
//            //设置单元格
//            configureCell: { ds, tv, ip, item in
//                let cell = tv.dequeueReusableCell(withIdentifier: "cell")
//                    ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
//                cell.textLabel?.text = "\(ip.row)：\(item)"
//
//                return cell
//        })
        
        //绑定单元格数据
//        sections
//            .bind(to: tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
//
        
        //创建数据源
//        let dataSource = RxTableViewSectionedReloadDataSource
//            <SectionModel<String, String>>(configureCell: {
//                (dataSource, tv, indexPath, element) in
//                let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
//                cell.textLabel?.text = "\(indexPath.row)：\(element)"
//                return cell
//            })
//
//        //绑定单元格数据
//        items
//            .bind(to: tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)

        //设置单元格数据（其实就是对 cellForRowAt 的封装）
//        items.bind(to: tableView.rx.items) { (tableView, row, element) in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
//            cell.textLabel?.text = "\(row)：\(element)"
//            return cell
//        }.disposed(by: disposeBag)
        
    }
}

extension MainViewController {
    func tableRxDelegate() {
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
    
}

extension MainViewController {
    //显示消息提示框
    func showMessage(_ text: String) {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //获取随机数据
    func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("正在请求数据......")
        let items = (0 ..< 5).map {_ in
            Int(arc4random())
        }
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(2, scheduler: MainScheduler.instance)
    }
    //过滤数据
    func filterResult(data:[SectionModel<String, Int>])
        -> Observable<[SectionModel<String, Int>]> {
            return self.searchBar.rx.text.orEmpty
                //.debounce(0.5, scheduler: MainScheduler.instance) //只有间隔超过0.5秒才发送
                .flatMapLatest{
                    query -> Observable<[SectionModel<String, Int>]> in
                    print("正在筛选数据（条件为：\(query)）")
                    //输入条件为空，则直接返回原始数据
                    if query.isEmpty{
                        return Observable.just(data)
                    }
                        //输入条件为不空，则只返回包含有该文字的数据
                    else{
                        var newData:[SectionModel<String, Int>] = []
                        for sectionModel in data {
                            let items = sectionModel.items.filter{ "\($0)".contains(query) }
                            newData.append(SectionModel(model: sectionModel.model, items: items))
                        }
                        return Observable.just(newData)
                    }
            }
    }
}

//自定义Section
struct MySection {
    var header: String
    var items: [Item]
}

extension MySection : AnimatableSectionModelType {
    typealias Item = String
    
    var identity: String {
        return header
    }
    
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}


