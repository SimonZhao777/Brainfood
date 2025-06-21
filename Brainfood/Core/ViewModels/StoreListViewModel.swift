//
//  StoreListViewModel.swift
//  DoorDash
//
//  Created by Marvin Zhan on 2018-09-27.
//  Copyright © 2018 Monster. All rights reserved.
//

import MapKit

final class StoreListViewModel {

    var allStores: [StoreViewModel] = []
    var isLoadingMoreStores = false
    var numStores: Int = 0
    
    private var serverPageOffset: Int? = 0
    private var serverFetchLimit: Int = 50
    private var localPageOffset: Int = 0
    private var localFetchLimit: Int = 10

    private let service: BrowseFoodAPIService
    private let query: String?
    private let curatedCateogryID: String?
    private var filterOptions: [StoreFilterRequestModel] = []
    private var layout: MenuCollectionViewLayoutKind = .centerOneItem

    init(service: BrowseFoodAPIService,
         serverFetchLimit: Int = 60,
         query: String? = nil,
         curatedCateogryID: String? = nil) {
        self.service = service
        self.query = query
        self.curatedCateogryID = curatedCateogryID
    }

    func setFilterOptions(models: [StoreFilterRequestModel]) {
        reset()
        self.filterOptions = models
    }

    func reset() {
        self.serverFetchLimit = 60
        self.serverPageOffset = 0
        self.localPageOffset = 0
        self.localFetchLimit = 10
        self.allStores.removeAll()
        self.numStores = 0
        self.isLoadingMoreStores = false
    }

    func loadMoreStores(completion: @escaping ([BrowseFoodAllStoreItem], Bool) -> ()) {
        if !isLoadingMoreStores {
            isLoadingMoreStores = true
            self.generatePresentingStores { (stores) in
                self.isLoadingMoreStores = false
                completion(self.generateDataForAllStores(stores: stores), stores.count > 0)
            }
        } else {
            completion([], false)
        }
    }

    func fetchFirstList(addTopInset: Bool = true,
                        completion: @escaping ([BrowseFoodAllStoreItem], String?) -> ()) {
        fetchStores { (errorMsg) in
            if let error = errorMsg {
                completion([], error)
                return
            }
            self.generatePresentingStores { (stores) in
                let items = self.generateDataForAllStores(
                    stores: stores, addTopInset: addTopInset
                )
                completion(items, nil)
            }
        }
    }

    func fetchStores(location: Location? = nil,
                     completion: @escaping (String?) -> ()) {
        guard let user = ApplicationEnvironment.current.currentUser else {
            fatalError("WTF? NO USER?")
        }
        let latitude: CLLocationDegrees? = location?.latitude ?? user.defaultAddress?.latitude
        let longitude: CLLocationDegrees? = location?.longitude ?? user.defaultAddress?.longitude
        guard let lat = latitude, let lng = longitude else {
            fatalError("User MUST have an address at this point")
        }
        guard let pageOffset = serverPageOffset else {
            completion("No more data")
            return
        }
        let request = FetchAllStoresRequestModel(
            limit: serverFetchLimit, offset: pageOffset, latitude: lat, longitude: lng,
            sortOption: .asap, query: query, curatedCateogryID: curatedCateogryID, filters: filterOptions
        )
        service.fetchAllStores(request: request, isFiltered: !filterOptions.isEmpty) { (response, error) in
            if let error = error as? BrowseFoodAPIServiceError {
                completion(error.errorMessage)
                return
            }
            if let response = response {
                self.serverPageOffset = response.nextOffset
                self.numStores = response.numStores
                self.allStores.append(contentsOf: response.stores.map { store in
                    StoreViewModel(store: store)
                })
            }
            completion(nil)
        }
    }

    func generateDataForAllStores(stores: [StoreViewModel],
                                  addTopInset: Bool = true) -> [BrowseFoodAllStoreItem] {
        var items: [BrowseFoodAllStoreItem] = []
        for (i, store) in stores.enumerated() {
            var shouldAddInset = true
            if !addTopInset && i == 0 {
                shouldAddInset = false
            }
            let item = store.convertToPresenterItem(topInset: shouldAddInset ? nil : 0, layout: self.layout)
            items.append(item)
        }
        return items
    }
}

extension StoreListViewModel {

    func generatePresentingStores(completion: @escaping ([StoreViewModel]) -> ()) {
        // not enough data left at local, go fetch from server
        if allStores.count - localPageOffset < localFetchLimit {
            guard serverPageOffset != nil else {
                if allStores.count == localPageOffset {
                    print("No more data from server.")
                    completion([])
                    return
                }
                completion(fetchStoresFromLocal())
                return
            }
            fetchStores { (errorMsg) in
                if let msg = errorMsg {
                    log.error(msg)
                    completion([])
                    return
                }
                completion(self.fetchStoresFromLocal())
            }
        } else {
            completion(fetchStoresFromLocal())
        }
    }

    private func fetchStoresFromLocal() -> [StoreViewModel] {
        var stores: [StoreViewModel] = []
        var currCount = 0
        for i in localPageOffset..<allStores.count {
            if currCount == localFetchLimit {
                break
            }
            stores.append(allStores[i])
            currCount += 1
        }
        localPageOffset += currCount
        return stores
    }
}
