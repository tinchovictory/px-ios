//
//  PXAnimator.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/10/18.
//

import UIKit

typealias PXAnimation = (animation: () -> Void, delay: CGFloat)

struct PXAnimator {

    private var animations: [PXAnimation] = []
    private var completions: [() -> Void] = []
    private let duration: Double
    private let dampingRatio: CGFloat
    var animator: UIViewPropertyAnimator
    var isRunning: Bool {
        get {
            return animator.isRunning
        }
    }

    init(duration: Double, dampingRatio: CGFloat) {
        self.duration = duration
        self.dampingRatio = dampingRatio
        self.animator = UIViewPropertyAnimator(duration: self.duration, dampingRatio: self.dampingRatio, animations: nil)
    }

    mutating func addAnimation(animation: @escaping () -> Void, delay: CGFloat = 0) {
        let pxAnimation = PXAnimation(animation, delay)
        animations.append(pxAnimation)
    }

    mutating func addCompletion(completion: @escaping () -> Void) {
        completions.append(completion)
    }

    func animate() {
        for animation in animations {
            animator.addAnimations(animation.animation, delayFactor: animation.delay)
        }

        for completion in completions {
            animator.addCompletion { (_) in
                completion()
            }
        }
        
        animator.startAnimation()
    }

}
