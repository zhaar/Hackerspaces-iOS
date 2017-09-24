//
//  extensions.swift
//  Hackerspaces
//
//  Created by zephyz on 06/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import BrightFutures
import Result

extension Dictionary {
    func split(_ discriminationFunction: (Key, Value) -> Bool) -> ([Key: Value],[Key : Value]) {
        var target = [Key: Value]()
        var rest = [Key : Value]()
        for (k, v) in self {
            if discriminationFunction(k,v) {
                target[k] = v
            } else {
                rest[k] = v
            }
        }
        return (target, rest)
    }
    
}

func tuplesAsDict<K: Hashable, V, S: Sequence>(_ seq: S) -> [K : V] where S.Iterator.Element == (K, V) {
    var dict: [K : V] = [:]
    for (k, v) in seq {
        dict[k] = v
    }
    return dict
}

extension Dictionary {
    init(pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

func get<A: Equatable, B>(_ array: [(A, B)], key: A) -> B? {
    return array.first(where: { p in p.0 == key })?.1
}

func update<A: Equatable, B>(key: A, value: B, _ array: [(A, B)]) -> [(A, B)] {
    if let idx = array.index(where: { $0.0 == key }) {
        var cpy: [(A, B)] = array
        cpy[idx] = (key, value)
        return cpy
    } else {
        return array
    }
}

func addOrpdate<A: Equatable, B>(key: A, value: B, _ array: [(A, B)]) -> [(A, B)] {
    var cpy: [(A, B)] = array
    if let idx = array.index(where: { $0.0 == key }) {
        cpy[idx] = (key, value)
    } else {
        cpy.append((key, value))
    }
    return cpy
}

func remove<A: Equatable, B>(from array: [(A, B)], key: A) -> [(A, B)] {
    if let idx = array.index(where: { $0.0 == key }) {
        var cpy = array
        cpy.remove(at: idx)
        return cpy
    } else {
        return array
    }
}

extension Array {
    
    func foreach(_ fn: (Element) -> Void) {
        for e in self {
            fn(e)
        }
    }
    
    func foldl<S>(_ initial: S,fn: (_ acc:S, _ elem: Element) -> S) -> S {
        var result = initial
        for e in self {
            result = fn(result, e)
        }
        return result
    }
    
    func groupBy<S>(_ fn: (Element) -> S) -> [S: [Element]] {
        var dic = [S: [Element]]()
        for e in self {
            let key = fn(e)
            dic[key] = dic[key]?.cons(e) ?? [e]
        }
        return dic
    }

}

extension Dictionary {
    
    func getWithDefault(_ key: Key, fallback: Value) -> Value {
        return self[key] ?? fallback
    }
    
    func immutableInsert(_ key: Key, value val: Value) -> [Key : Value] {
        var cpy = self
        cpy[key] = val
        return cpy
    }
}

prefix operator ==
prefix func == <T: Equatable>(rhs: T) -> (T) -> Bool {
    return { lhs in lhs == rhs }
}

prefix operator ?>
prefix func ?> <T: Comparable>(rhs: T) -> (T) -> Bool {
    return { lhs in lhs > rhs }
}

prefix operator ?<
prefix func ?< <T: Comparable>(rhs: T) -> (T) -> Bool {
    return { lhs in lhs < rhs }
}

prefix operator ?>=
prefix func ?>= <T: Comparable>(rhs: T) -> (T) -> Bool {
    return { lhs in lhs >= rhs }
}

prefix operator ?<=
prefix func ?<= <T: Comparable>(rhs: T) -> (T) -> Bool {
    return { lhs in lhs <= rhs }
}

infix operator |=> : NilCoalescingPrecedence
func |=> <T, E: Error>(lhs: T?, rhs: E) -> Result<T, E> {
    return lhs.map({ .success($0) }) ?? .failure(rhs)
}
