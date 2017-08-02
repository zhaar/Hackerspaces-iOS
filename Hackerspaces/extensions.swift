//
//  extensions.swift
//  Hackerspaces
//
//  Created by zephyz on 06/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import BrightFutures

func optionalBind<T, U>(_ optional: T?, f: (T) -> U?) -> U?
{
    if let x = optional {
        return f(x)
    }
    else {
        return nil
    }
}

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

func tuplesAsDict<K: Hashable, V, S: Sequence>(seq: S) -> [K : V] where S.Iterator.Element == (K, V) {
    var dict: [K : V] = [:]
    seq.forEach { tuple in
        dict[tuple.0] = tuple.1
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
