//
//  UIView+Animation.swift
//  KeyprTestTask
//
//  Created by User on 11.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit

enum Direction {
    case Left
    case Right
}

extension UIView {
    func rotateInfinity(duration: CFTimeInterval = 0.5, direction: Direction) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        var startValue:CGFloat = 0.0
        var endValue = CGFloat(Double.pi * 2)
        if direction == .Left {
            startValue = endValue
            endValue = 0
        }
        rotateAnimation.fromValue = startValue
        rotateAnimation.toValue = endValue
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
