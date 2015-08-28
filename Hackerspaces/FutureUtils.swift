//
//  FutureUtils.swift
//  Hackerspaces
//
//  Created by zephyz on 27/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import BrightFutures
import Swiftz

struct FutureUtils {
    
    ///Converts a future that can fail into a future of optional with no failure
    static func futureToOptional<T, E: ErrorType>(future: Future<T, E>) -> Future<T?, NoError> {
        return future.map { t in return t }.recover{ error in return  nil }
    }
    
    static func futureToResult<T, E: ErrorType>(future: Future<T, E>) -> Future<Result<T>, NoError> {
        return future.map { t in return Result.value(t) }.recover { err in Result.error(err.nsError) }
    }
    
    ///Converts a list of futures into a future of list discarding failing futures
    static func successfulFutureList<T, E: ErrorType>(list: [Future<T, E>]) -> Future<[T], NoError> {
        let results = list.map { (future: Future<T, E>) in self.futureToOptional(future)}
        return flattenOptionalFuture(results)
    }
    
    static func flattenOptionalFuture<T>(list: [Future<T?, NoError>]) -> Future<[T], NoError> {
        return BrightFutures.sequence(list).map { (arr: [T?]) -> [T] in arr.filter({ elem in elem != nil }).map { $0!}}
    }
    
    static func flatten
    ///Converts a tuple of futures into a future of tuples
    static func unwrapTuple<S,T>(tuple: (Future<S, ErrorType>, Future<T, ErrorType>)) -> Future<(S,T), ErrorType> {
        return tuple.0.zip(tuple.1)
    }
    
    ///Converts a list of tuple of futures into a future of list of tuple discating tuples containing a failing future
    static func upwrapListSuccessTuples<S,T>(list: [(Future<S, ErrorType>, Future<T, ErrorType>)]) -> Future<[(S,T)], NoError> {
        let ls = list.map(unwrapTuple)
        return successfulFutureList(ls)
    }
}

//extension Future<T> {
//    func wrapError() -> Future<Result<T>, NoError> {
//        return
//    }
//}