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
import Result

struct FutureUtils {
    
    ///Converts a future that can fail into a future of optional with no failure
    static func futureToOptional<T, E: Error>(_ future: Future<T, E>) -> Future<T?, NoError> {
        return future.map(identity).recover{ _ in nil }
    }
    
    ///Converts a list of futures into a future of list discarding failing futures
    static func successfulFutureList<T, E: Error>(_ list: [Future<T, E>]) -> Future<[T], NoError> {
        return flattenOptionalFuture § list.map(futureToOptional)
    }
    
    ///Converts a list of futures of Option into a future of list of non-nil values
    static func flattenOptionalFuture<T>(_ list: [Future<T?, NoError>]) -> Future<[T], NoError> {
        return list.sequence().map { $0.flatMap(identity)}
    }
}
