//
//  extensions.swift
//  Hackerspaces
//
//  Created by zephyz on 06/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation
import BrightFutures

func optionalBind<T, U>(optional: T?, f: T -> U?) -> U?
{
    if let x = optional {
        return f(x)
    }
    else {
        return nil
    }
}

extension Dictionary {
    func split(discriminationFunction: (Key, Value) -> Bool) -> ([Key: Value],[Key : Value]) {
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

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

extension Array {
    
    func foreach(fn: Element -> Void) {
        for e in self {
            fn(e)
        }
    }
    
    func foldl<S>(initial: S,fn: (acc:S, elem: Element) -> S) -> S {
        var result = initial
        for e in self {
            result = fn(acc: result, elem: e)
        }
        return result
    }
    
    func groupBy<S>(fn: Element -> S) -> [S: [Element]] {
        var dic = [S: [Element]]()
        for e in self {
            let key = fn(e)
            dic[key] = dic[key]?.cons(e) ?? [e]
        }
        return dic
    }
}

extension Dictionary {
    
    func getWithDefault(key: Key, fallback: Value) -> Value {
        return self[key] ?? fallback
    }
    
    func immutableInsert(key: Key, value val: Value) -> [Key : Value] {
        var cpy = self
        cpy[key] = val
        return cpy
    }
}
