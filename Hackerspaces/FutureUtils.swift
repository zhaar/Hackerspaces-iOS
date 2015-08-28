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
        return future.map { identity($0) }.recover{ _ in nil }
    }
    
    ///Converts a future with failures to a future of Result with no failure
    static func futureToResult<T, E: ErrorType>(future: Future<T, E>) -> Future<Result<T>, NoError> {
        return future.map { Result.value($0) }.recover { Result.error($0.nsError) }
    }
    
    ///Converts a list of futures into a future of list discarding failing futures
    static func successfulFutureList<T, E: ErrorType>(list: [Future<T, E>]) -> Future<[T], NoError> {
        return flattenOptionalFuture(list.map(futureToOptional))
    }
    
    ///Converts a list of futures of Option into a future of list of non-nil values
    static func flattenOptionalFuture<T>(list: [Future<T?, NoError>]) -> Future<[T], NoError> {
        return BrightFutures.sequence(list).map { (arr: [T?]) -> [T] in arr.filter({ $0 != nil }).map {$0!}}
    }
    
    ///Converts a tuple of futures into a future of tuples
    static func unwrapTuple<S,T>(tuple: (Future<S, ErrorType>, Future<T, ErrorType>)) -> Future<(S,T), ErrorType> {
        return tuple.0.zip(tuple.1)
    }
    
//    ///Converts a list of tuple of futures into a future of list of tuple discating tuples containing a failing future
//    static func upwrapListSuccessTuples<S,T>(list: [(Future<S, ErrorType>, Future<T, ErrorType>)]) -> Future<[(S,T)], NoError> {
//        return successfulFutureList(list.map(unwrapTuple))
//    }
}
