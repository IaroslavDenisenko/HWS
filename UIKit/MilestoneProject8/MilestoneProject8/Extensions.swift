//
//  Extensions.swift
//  MilestoneProject8
//
//  Created by Iaroslav Denisenko on 18.12.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import Foundation
import UIKit

extension Collection where Element: BinaryInteger {
    func countOddEven() {
        var odd = 0
        var even = 0
        for val in self {
            if val.isMultiple(of: 2) {
                even += 1
            } else {
                odd += 1
            }
            
        }
        print("Odd = \(odd), even = \(even)")
    }
}

extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform.init(scaleX: 0.0001 , y: 0.0001 )
        }
    }
}

extension Int {
    func times(_ closure: () -> Void) {
        for _ in 0..<abs(self) {
            closure()
        }
    }
}

extension Array where Element: Comparable {
   mutating func remove(item: Element) {
        if self.filter({$0 == item}).count > 1 {
            if let index = self.firstIndex(of: item) {
                self.remove(at: index)
            }
        }
    }
}
