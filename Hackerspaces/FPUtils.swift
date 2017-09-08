//
//  FPUtils.swift
//  Hackerspaces
//
//  Created by zephyz on 28.03.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import Foundation
import Swiftz

extension Optional: Functor {
    
}

func map<A, B, F: Functor>(_ fn: @escaping (A) -> B) -> (F) -> F.FB where F.A == A, F.B == B {
    return { f in f.fmap(fn) }
}

func bind<A, B, M: Monad>(_ fn: @escaping (A) -> M.FB) -> (M) -> M.FB where M.A == A, M.B == B {
    return { f in f.bind(fn) }
}


func const<A, B>(_ value: A) -> (B) -> A {
    return { _ in value }
}

func constFn<A, B>(_ f: @escaping () -> A) -> (B) -> A {
    return { _ in f() }
}
