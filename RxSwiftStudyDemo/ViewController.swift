//
//  ViewController.swift
//  RxSwiftStudyDemo
//
//  Created by emily on 2018/10/21.
//  Copyright © 2018 emily. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inputField = UITextField(frame: CGRect(x: 10, y: 90, width: 200, height: 30))
        inputField.borderStyle = UITextField.BorderStyle.roundedRect
        self.view.addSubview(inputField)

        let outputField = UITextField(frame: CGRect(x: 10, y: 150, width: 300, height: 30))
        outputField.borderStyle = UITextField.BorderStyle.roundedRect
        self.view.addSubview(outputField)
        
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:190, width:300, height:30))
        self.view.addSubview(label)
        
        //创建按钮
        let button:UIButton = UIButton(type:.system)
        button.frame = CGRect(x:20, y:230, width:40, height:30)
        button.setTitle("提交", for:.normal)
        self.view.addSubview(button)
        button.rx.tap.subscribe(onNext: {
        
        }).disposed(by: disposeBag)
        
        let input = inputField.rx.text.orEmpty.asDriver() // 将普通序列转换为 Driver
            .throttle(0.3) //在主线程中操作，0.3秒内值若多次改变，取最后一次
        //内容绑定到另一个输入框中
        input.drive(outputField.rx.text).disposed(by: disposeBag)
        //内容绑定到文本标签中
        input.map {
            "当前字数：\($0.count)"
        }.drive(label.rx.text).disposed(by: disposeBag)
        
        //根据内容字数决定按钮是否可用
        input.map {
            $0.count > 5
        }.drive(button.rx.isEnabled).disposed(by: disposeBag)
        
        // 同时监听多个 textField 内容的变化
//        Observable.combineLatest(inputField.rx.text.orEmpty, outputField.rx.text.orEmpty) {
//            textValue1, textValue2 -> String in
//            return "你输入的号码是：\(textValue1)-\(textValue2)"
//            }
//            .map { $0 }
//            .bind(to: label.rx.text)
//            .disposed(by: disposeBag)
//    }
        
         // rx.controlEvent 可以监听输入框的各种事件
        inputField.rx.controlEvent([.editingDidBegin]) //状态可以组合
            .asObservable()
            .subscribe(onNext: { (_) in
            print("开始编辑内容!")
        }).disposed(by: disposeBag)
        
        //在用户名输入框中按下 return 键
        inputField.rx.controlEvent(.editingDidEndOnExit).subscribe({
            [weak self] (_) in
            outputField.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        //在密码输入框中按下 return 键
        outputField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
            [weak self] (_) in
            outputField.resignFirstResponder()
        }).disposed(by: disposeBag)
        
      
//        let textField = UITextField(frame: CGRect(x: 10, y: 90, width: 200, height: 30))
//        textField.borderStyle = UITextField.BorderStyle.roundedRect
//        self.view.addSubview(textField)
//
//        textField.rx.text.orEmpty.asObservable().subscribe(onNext: {
//            print("您输入的是：\($0)")
//        }).disposed(by: disposeBag)
      
//        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
//        // 将已过去的时间格式化成想要的字符串，并绑定到label上
//        //将已过去的时间格式化成想要的字符串，并绑定到label上
//        timer.map(formatTimeInterval)
//            .bind(to: titleLabel.rx.attributedText)
//            .disposed(by: disposeBag)
        
        
    }

    //将数字转成对应的富文本
    func formatTimeInterval(ms: NSInteger) -> NSMutableAttributedString {
        let string = String(format: "%0.2d:%0.2d.%0.1d",
                            arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
        //富文本设置
        let attributeString = NSMutableAttributedString(string: string)
        //从文本0开始6个字符字体HelveticaNeue-Bold,16号
        attributeString.addAttribute(NSAttributedString.Key.font,
                                     value: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                                     range: NSMakeRange(0, 5))
        //设置字体颜色
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: UIColor.white, range: NSMakeRange(0, 5))
        //设置文字背景颜色
        attributeString.addAttribute(NSAttributedString.Key.backgroundColor,
                                     value: UIColor.orange, range: NSMakeRange(0, 5))
        return attributeString
    }

    func test() {
        // 该方法通过传入一个默认值来初始化。
        let observable1 = Observable.just(2)
        // 该方法可以接受可变数量的参数（必需要是同类型的）
        let observable2 = Observable.of("a","b","c")
        // 该方法需要一个数组参数。
        let observable3 = Observable.from(["A", "B", "C"])
        // 该方法创建一个空内容的 Observable 序列。
        let observable4 = Observable<Any>.empty()
        // 该方法创建一个永远不会发出 Event（也不会终止）的 Observable 序列。
        let observable5 = Observable<Any>.never()
        
        // 该方法通过指定起始和结束数值，创建一个以这个范围内所有值作为初始值的 Observable 序列。
        let observable6 = Observable.range(start: 1, count: 5)
        // 该方法创建一个可以无限发出给定元素的 Event 的 Observable 序列（永不终止）。
        let observable7 = Observable.repeatElement(1)
        // 该方法创建一个只有当提供的所有的判断条件都为 true 的时候，才会给出动作的 Observable 序列。
        let observable8 = Observable.generate(initialState: 0, condition: {
            $0 <= 10
        }, iterate: {$0 + 2})
        
        // 该方法接受一个 block 形式的参数，任务是对每一个过来的订阅进行处理。
        //这个block有一个回调参数observer就是订阅这个Observable对象的订阅者
        //当一个订阅者订阅这个Observable对象的时候，就会将订阅者作为参数传入这个block来执行一些内容
        let observable = Observable<String>.create{observer in
            //对订阅者发出了.next事件，且携带了一个数据"hangge.com"
            observer.onNext("hangge.com")
            //对订阅者发出了.completed事件
            observer.onCompleted()
            //因为一个订阅行为会有一个Disposable类型的返回值，所以在结尾一定要returen一个Disposable
            return Disposables.create()
        }
        
        observable.subscribe {
            print($0)
        }
        // 这个方法创建的 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。而且它会一直发送下去
        let observable9 = Observable<Int>.interval(2, scheduler: MainScheduler.instance)
        observable9.subscribe { (event) in
            print(event)
        }
        //5秒种后发出唯一的一个元素0
        let observable10 = Observable<Int>.timer(5, scheduler: MainScheduler.instance)
        observable10.subscribe { event in
            print(event)
        }
        
        //延时5秒种后，每隔1秒钟发出一个元素
        let observable11 = Observable<Int>.timer(5, period: 1, scheduler: MainScheduler.instance)
        observable11.subscribe { event in
            print(event)
        }
    }
}

