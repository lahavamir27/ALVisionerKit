//
//  Stack.swift
//  DisplayLiveSamples
//
//  Created by amir.lahav on 04/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation


struct ALStack<Element> {
    
    fileprivate var array: [Element] = []
    
    mutating func push(_ element: Element) {
        array.append(element)
    }
    
    mutating func pop() -> Element? {
        return array.popLast()
    }
    
    func peek() -> Element? {
        return array.last
    }
    
    func isEmpty() -> Bool {
        return array.isEmpty
    }
}


