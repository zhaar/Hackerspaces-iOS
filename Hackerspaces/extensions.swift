//
//  extensions.swift
//  Hackerspaces
//
//  Created by zephyz on 06/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import Foundation


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

extension Dictionary {
    func map<OutKey: Hashable, OutValue>(transform: Element -> (OutKey, OutValue)) -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(Swift.map(self, transform))
    }
    
    func filter(includeElement: Element -> Bool) -> [Key: Value] {
        return Dictionary(Swift.filter(self, includeElement))
    }
}

func toDict<T,S>(arr: [(T,S)]) -> [T : S] {
    return arr.foldl([T : S]()) { (var acc, tuple) in
        acc[tuple.0] = tuple.1
        return acc
    }
}

extension Array {
    
    func foreach(fn: T -> Void) {
        for e in self {
            fn(e)
        }
    }
    
    func foldl<S>(initial: S,fn: (acc:S, elem: T) -> S) -> S {
        var result = initial
        for e in self {
            result = fn(acc: result, elem: e)
        }
        return result
    }
    
    ///add element at the end of the array, returns a copy
    func cons(e: Element) -> [Element] {
        var cpy = self
        cpy.append(e)
        return cpy
    }
    
    func groupBy<S>(fn: T -> S) -> [S: [T]] {
        var dic = [S: [T]]()
        for e in self {
            let key = fn(e)
            dic[key] = dic[key]?.cons(e) ?? [e]
        }
        return dic
    }
    
    func immutableSort(isOrderedBefore: (T, T) -> Bool) -> [Element] {
        var cpy = self
        cpy.sort(isOrderedBefore)
        return cpy
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

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}