//
//  CenterCardsCollectionViewFlowLayout.swift
//  DoorDash
//
//  Created by Marvin Zhan on 2018-09-25.
//  Copyright © 2018 Monster. All rights reserved.
//

import UIKit

final class CenterCardsCollectionViewFlowLayout: UICollectionViewFlowLayout {

    var mostRecentOffset = CGPoint.zero

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        if velocity.x == 0 {
            // first scroll, need to add left inset
            if mostRecentOffset == CGPoint.zero {
                return CGPoint(x: mostRecentOffset.x - cv.contentInset.left, y: 0)
            }
            return mostRecentOffset
        }
        let cvBounds = cv.bounds
        let halfWidth = cvBounds.size.width * 0.5
        if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
            var candidateAttributes: UICollectionViewLayoutAttributes?
            for attributes in attributesForVisibleCells {
                // == Skip comparison with non-cell items (headers and footers) == //
                if attributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                    continue
                }
                let scrollInvalid = attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0
                if attributes.center.x == 0 || scrollInvalid {
                    continue
                }
                candidateAttributes = attributes
            }
            if proposedContentOffset.x == -(cv.contentInset.left) {
                return proposedContentOffset
            }

            guard let candidate = candidateAttributes else {
                return mostRecentOffset
            }
            mostRecentOffset = CGPoint(x: floor(candidate.center.x - halfWidth), y: proposedContentOffset.y)
        }
        return mostRecentOffset
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

