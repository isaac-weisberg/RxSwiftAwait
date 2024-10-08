//
//  SwiftSupport.swift
//  RxSwift
//
//  Created by Volodymyr  Gorbenko on 3/6/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

typealias IntMax = Int64
public typealias RxAbstractInteger = FixedWidthInteger & Sendable

extension SignedInteger {
    func toIntMax() -> IntMax {
        IntMax(self)
    }
}
