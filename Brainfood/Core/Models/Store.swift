//
//  Store.swift
//  DoorDash
//
//  Created by Marvin Zhan on 2018-09-23.
//  Copyright © 2018 Monster. All rights reserved.
//

import UIKit
import SwiftDate

public enum QuantumValue: Decodable {

    case double(Double)
    case string(String)

    public init(from decoder: Decoder) throws {
        if let double = try? decoder.singleValueContainer().decode(Double.self) {
            self = .double(double)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        throw QuantumError.missingValue
    }

    public enum QuantumError: Error {
        case missingValue
    }

    public var displayValue: Double {
        switch self {
        case .double(let val):
            return val
        case .string(let val):
            return Double(val) ?? 0
        }
    }
}

public struct Store {

    public struct Menu: Codable {

        public enum MenuCodingKeys: String, CodingKey {
            case popularItems = "popular_items"
        }

        public let items: [PopularItem]?

        public struct PopularItem: Codable {

            public enum PopularItemKeys: String, CodingKey {
                case imageURL = "img_url"
            }

            public let url: String?

            public init(url: String?) {
                self.url = url
            }

            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: PopularItemKeys.self)
                let urlString: String? = try values.decodeIfPresent(String.self, forKey: .imageURL)
                self.init(url: urlString)
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: PopularItemKeys.self)
                try container.encode(url, forKey: .imageURL)
            }
        }

        public init(items: [PopularItem]?) {
            self.items = items
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: MenuCodingKeys.self)
            let items: [PopularItem]? = try values.decodeIfPresent([PopularItem].self, forKey: .popularItems)
            self.init(items: items)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: MenuCodingKeys.self)
            try container.encode(items, forKey: .popularItems)
        }
    }

    public enum MoneyFieldCodingKeys: String, CodingKey {
        case currency
        case unitAmount = "unit_amount"
        case displayString = "display_string"
    }

    public enum DeliveryStatus: String, CodingKey {
        case minuteRate = "asap_minutes_range"
    }

    public enum BusinessInfo: String, CodingKey {
        case name
    }

    public enum StoreCodingKeys: String, CodingKey {
        case id
        case numRatings = "num_ratings"
        case averageRating = "average_rating"
        case location
        case storeDescription = "description"
        case priceRange = "price_range"
        case deliveryMoney = "delivery_fee_monetary_fields"
        case name
        case nextCloseTime = "next_close_time"
        case nextOpenTime = "next_open_time"
        case headerImageURL = "header_img_url"
        case menus = "menus"
        case deliveryStatus = "status"
        case isNewlyAdded = "is_newly_added"
        case distanceFromConsumer = "distance_from_consumer"
        case business
        case offersPickup = "offers_pickup"
    }

    public let id: Int64
    public let numRatings: Int64
    public let averageRating: Double
    public let storeDescription: String
    public let priceRange: Int64
    public let deliveryFee: Money
    public let deliveryFeeDisplay: String
    public let deliveryMinutes: Int64
    public let name: String
    public let businessName: String
    public let nextCloseTime: Date
    public let nextOpenTime: Date
    public let headerImageURL: String?
    public let isNewlyAdded: Bool
    public let distanceFromConsumer: QuantumValue?
    public let offersPickup: Bool
    public var location: Location?
    public let menus: [Menu]?

    public init(id: Int64,
                numRatings: Int64,
                averageRating: Double,
                storeDescription: String,
                priceRange: Int64,
                deliveryFee: Money,
                deliveryFeeDisplay: String,
                deliveryMinutes: Int64,
                name: String,
                businessName: String,
                nextCloseTime: Date,
                nextOpenTime: Date,
                headerImageURL: String?,
                isNewlyAdded: Bool,
                distanceFromConsumer: QuantumValue?,
                offersPickup: Bool,
                location: Location?,
                menus: [Menu]?) {
        self.id = id
        self.numRatings = numRatings
        self.averageRating = averageRating
        self.storeDescription = storeDescription
        self.priceRange = priceRange
        self.deliveryFee = deliveryFee
        self.deliveryFeeDisplay = deliveryFeeDisplay
        self.deliveryMinutes = deliveryMinutes
        self.name = name
        self.businessName = businessName
        self.nextCloseTime = nextCloseTime
        self.nextOpenTime = nextOpenTime
        self.headerImageURL = headerImageURL
        self.isNewlyAdded = isNewlyAdded
        self.distanceFromConsumer = distanceFromConsumer
        self.offersPickup = offersPickup
        self.location = location
        self.menus = menus
    }
}

extension Store: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: StoreCodingKeys.self)
        let id: Int64 = try values.decode(Int64.self, forKey: .id)
        let numRatings: Int64 = try values.decodeIfPresent(Int64.self, forKey: .numRatings) ?? 0
        let averageRating: Double = try values.decodeIfPresent(Double.self, forKey: .averageRating) ?? -1
        let storeDescription: String = try values.decodeIfPresent(String.self, forKey: .storeDescription) ?? ""
        let priceRange: Int64 = try values.decodeIfPresent(Int64.self, forKey: .priceRange) ?? 0
        let name: String = try values.decode(String.self, forKey: .name)
        let businessInfo = try? values.nestedContainer(keyedBy: BusinessInfo.self, forKey: .business)
        let businessName: String = try businessInfo?.decodeIfPresent(String.self, forKey: .name) ?? ""
        let nextCloseTimeRaw: String = try values.decodeIfPresent(String.self, forKey: .nextCloseTime) ?? ""
        let nextCloseTime = nextCloseTimeRaw.toISODate()?.date ?? Date()
        let nextOpenTimeRaw: String = try values.decodeIfPresent(String.self, forKey: .nextOpenTime) ?? ""
        let nextOpenTime = nextOpenTimeRaw.toISODate()?.date ?? Date()
        let headerImageURL: String? = try values.decodeIfPresent(String.self, forKey: .headerImageURL)
        let menus: [Store.Menu]? = try values.decodeIfPresent([Menu].self, forKey: .menus)
        let moneyContainer = try values.nestedContainer(keyedBy: MoneyFieldCodingKeys.self, forKey: .deliveryMoney)
        let currency = try moneyContainer.decodeIfPresent(String.self, forKey: .currency) ?? "USD"
        let moneyCents: Int64 = try moneyContainer.decodeIfPresent(Int64.self, forKey: .unitAmount) ?? 0
        let moneyDisplayString: String = try moneyContainer.decodeIfPresent(String.self, forKey: .displayString) ?? "$0.00"
        let deliveryStatusContainer = try values.nestedContainer(keyedBy: DeliveryStatus.self, forKey: .deliveryStatus)
        let distanceFromConsumer = try values.decodeIfPresent(QuantumValue.self, forKey: .distanceFromConsumer)
        let deliveryRange: [Int64] = try deliveryStatusContainer.decodeIfPresent([Int64].self, forKey: .minuteRate) ?? []
        let isNewlyAdded: Bool = try values.decodeIfPresent(Bool.self, forKey: .isNewlyAdded) ?? false
        let offersPickup: Bool = try values.decodeIfPresent(Bool.self, forKey: .offersPickup) ?? false
        let location: Location? = try values.decodeIfPresent(Location.self, forKey: .location)
        self.init(id: id,
                  numRatings: numRatings,
                  averageRating: averageRating,
                  storeDescription: storeDescription,
                  priceRange: priceRange,
                  deliveryFee: Money(cents: moneyCents,
                                     currency: Currency(rawValue: currency) ?? .USD),
                  deliveryFeeDisplay: moneyDisplayString,
                  deliveryMinutes: deliveryRange[safe: 0] ?? 0,
                  name: name,
                  businessName: businessName,
                  nextCloseTime: nextCloseTime,
                  nextOpenTime: nextOpenTime,
                  headerImageURL: headerImageURL,
                  isNewlyAdded: isNewlyAdded,
                  distanceFromConsumer: distanceFromConsumer,
                  offersPickup: offersPickup,
                  location: location,
                  menus: menus)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StoreCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(numRatings, forKey: .numRatings)
        try container.encode(averageRating, forKey: .averageRating)
        try container.encode(priceRange, forKey: .priceRange)
        try container.encode(storeDescription, forKey: .storeDescription)
        try container.encode(name, forKey: .name)
        try container.encode(nextCloseTime, forKey: .nextCloseTime)
        try container.encode(nextOpenTime, forKey: .nextOpenTime)
        try container.encodeIfPresent(menus, forKey: .menus)
        //TODO: Add all fields to encoder if needed.
    }
}
