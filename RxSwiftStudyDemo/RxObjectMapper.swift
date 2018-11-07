//
//  RxObjectMapper.swift
//  RxSwiftStudyDemo
//
//  Created by emily on 2018/11/7.
//  Copyright © 2018 emily. All rights reserved.
//

import ObjectMapper
import RxSwift

//数据映射错误
public enum RxObjectMapperError: Error {
    case parsingError
}

//扩展Observable：增加模型映射方法
public extension Observable where Element:Any {
    
    //将JSON数据转成对象
    public func mapObject< T>(type:T.Type) -> Observable<T> where T:Mappable {
        let mapper = Mapper<T>()
        
        return self.map { (element) -> T in
            guard let parsedElement = mapper.map(JSONObject: element) else {
                throw RxObjectMapperError.parsingError
            }
            
            return parsedElement
        }
    }
    
    //将JSON数据转成数组
    public func mapArray< T>(type:T.Type) -> Observable<[T]> where T:Mappable {
        let mapper = Mapper<T>()
        
        return self.map { (element) -> [T] in
            guard let parsedArray = mapper.mapArray(JSONObject: element) else {
                throw RxObjectMapperError.parsingError
            }
            
            return parsedArray
        }
    }
}
