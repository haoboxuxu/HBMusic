//
//  HapticsManger.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit

final class HapticsManger {
    static let shared = HapticsManger()
    
    private init() {}
    
    public func vibrateForSelestion() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
