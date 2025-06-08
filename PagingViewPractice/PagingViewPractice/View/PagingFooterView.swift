//
//  PagingFooterView.swift
//  PagingViewPractice
//
//  Created by 김진웅 on 6/8/25.
//

import UIKit

final class PagingFooterView: UICollectionReusableView {
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = .black
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    var onPageControlValueChanged: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
    }
    
    func configure(numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }
    
    func updateCurrentPage(_ page: Int) {
        pageControl.currentPage = page
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        onPageControlValueChanged?(sender.currentPage)
    }
}
