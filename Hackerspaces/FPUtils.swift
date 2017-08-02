//
//  FPUtils.swift
//  Hackerspaces
//
//  Created by zephyz on 28.03.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import Foundation
import Swiftz

func map<A, B, F: Functor>(_ fn: @escaping (A) -> B) -> (F) -> F.FB where F.A == A, F.B == B {
    return { f in f.fmap(fn) }
}

