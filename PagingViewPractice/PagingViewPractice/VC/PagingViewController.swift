//
//  PagingViewController.swift
//  PagingViewPractice
//
//  Created by 김진웅 on 6/8/25.
//

import Combine
import UIKit

final class PagingViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private var dataSource: DataSource?
    private var onPageChanged: ((Int) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    private let items: [Item] = Item.mockItems
    private let currentPageSubject = CurrentValueSubject<Int, Never>(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupCollectionViewLayout()
        setupDataSource()
        setupBinding()
        
        applySnapshot(items)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func setupCollectionViewLayout() {
        let layout = createCompositionalLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 20
        section.visibleItemsInvalidationHandler = { [weak self] _, point, environment in
            let pageIndex = self?.calculateCurrentPage(from: point, environment: environment) ?? 0
            self?.currentPageSubject.send(pageIndex)
        }
        
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [footer]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func calculateCurrentPage(from point: CGPoint, environment: NSCollectionLayoutEnvironment) -> Int {
        let pageIndex = Int((point.x / environment.container.contentSize.width).rounded(.up))
        return max(0, min(pageIndex, items.count - 1))
    }
    
    private func setupDataSource() {
        let cellRegistration = createCellRegistration()
        let footerRegistration = createFooterRegistration()
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
        }
    }
    
    private func createCellRegistration() -> UICollectionView.CellRegistration<PagingCell, Item> {
        return UICollectionView.CellRegistration<PagingCell, Item> { cell, indexPath, item in
            cell.configure(with: item)
        }
    }
    
    private func createFooterRegistration() -> UICollectionView.SupplementaryRegistration<PagingFooterView> {
        return UICollectionView.SupplementaryRegistration<PagingFooterView>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] footerView, _, _ in
            footerView.configure(numberOfPages: self?.items.count ?? .zero)
            footerView.onPageControlValueChanged = { selectedPage in
                self?.scrollToPage(selectedPage)
            }
            self?.onPageChanged = footerView.updateCurrentPage(_:)
        }
    }
    
    func setupBinding() {
        currentPageSubject
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] page in
                self?.onPageChanged?(page)
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot(_ items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot)
    }
    
    private func scrollToPage(_ page: Int) {
        guard page >= 0 && page < items.count else { return }
        
        let indexPath = IndexPath(item: page, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
