//
//  CuisineItemSectonController.swift
//  DoorDash
//
//  Created by Marvin Zhan on 2018-09-25.
//  Copyright © 2018 Monster. All rights reserved.
//

import IGListKit
import UIKit

final class CuisineItem: NSObject, ListDiffable {

    let imageURL: URL
    let title: String
    let cuisine: BrowseFoodCuisineCategory
    var selected: Bool

    init(imageURL: URL, title: String, cuisine: BrowseFoodCuisineCategory) {
        self.imageURL = imageURL
        self.title = title
        self.cuisine = cuisine
        self.selected = false
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

final class CuisinePage: NSObject, ListDiffable {
    let items: [CuisineItem]

    init(items: [CuisineItem]) {
        self.items = items
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

final class CuisinePages: NSObject, ListDiffable {

    let pages: [CuisinePage]

    init(pages: [CuisinePage]) {
        self.pages = pages
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

final class CuisineItemSectonController: ListSectionController {

    private var cuisineItem: CuisineItem?
    static var heightWithoutImage: CGFloat = 2 + 10 + 20
    var didSelectCuisine: ((BrowseFoodCuisineCategory) -> ())?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let itemWidth: CGFloat = BrowseFoodViewModel.UIConfigure.getCuisineItemSize(collectionViewWidth: width)
        return CGSize(width: itemWidth,
                      height: collectionContext?.containerSize.height ?? 0)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CuisineItemCell.self, for: self, at: index) as? CuisineItemCell, let item = cuisineItem else {
            fatalError()
        }
        cell.setupCell(imageURL: item.imageURL, title: item.title)
        return cell
    }

    override func didUpdate(to object: Any) {
        cuisineItem = object as? CuisineItem
    }

    override func didSelectItem(at index: Int) {
        guard let cuisine = self.cuisineItem?.cuisine else {
            return
        }
        self.didSelectCuisine?(cuisine)
    }
}

