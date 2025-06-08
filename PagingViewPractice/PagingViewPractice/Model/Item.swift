//
//  Item.swift
//  PagingViewPractice
//
//  Created by 김진웅 on 6/8/25.
//

import UIKit

struct Item: Hashable, Identifiable {
    let id: UUID = UUID()
    let title: String
    let color: UIColor
    
    static let mockItems: [Item] = [
        Item(title: "첫 번째", color: .systemRed),
        Item(title: "두 번째", color: .systemBlue),
        Item(title: "세 번째", color: .systemGreen),
        Item(title: "네 번째", color: .systemOrange),
        Item(title: "다섯 번째", color: .systemPurple)
    ]
}
