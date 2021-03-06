//
//  UICollectionView+IWReusable.swift
//  haoduobaduo
//
//  Created by iWe on 2017/9/6.
//  Copyright © 2017年 iWe. All rights reserved.
//

import UIKit

extension UICollectionReusableView: IWNibReusable {
    
}

extension UICollectionView {
    
    // MARK: Regist reusable cell
    final func registReusable<T: UICollectionViewCell>(_ cellType: T.Type) {
        let name = String(describing: cellType)
        let xibPath = Bundle.main.path(forResource: name, ofType: "nib")
        if let path = xibPath {
            let exists = FileManager.default.fileExists(atPath: path)
            if exists {
                register(cellType.nib, forCellWithReuseIdentifier: cellType.identifier)
                return
            }
        }
        register(cellType.self, forCellWithReuseIdentifier: cellType.identifier)
    }
    
    final func reuseCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellType.identifier)")
        }
        return cell
    }
}

extension UICollectionView {
    
    final func registReusableView<T: UICollectionReusableView>(supplementaryViewType: T.Type = T.self, ofKind elementKind: String) {
        self.register(supplementaryViewType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: supplementaryViewType.identifier)
    }
    
    final func reuseReusableView<T: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T {
        let view = self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewType.identifier, for: indexPath)
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.identifier) "
                    + "matching type \(viewType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the supplementary view beforehand"
            )
        }
        return typedView
    }
}
