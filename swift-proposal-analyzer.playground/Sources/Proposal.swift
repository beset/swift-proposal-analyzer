//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  GitHub
//  https://github.com/jessesquires/swift-proposal-analyzer
//
//
//  License
//  Copyright © 2016 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation


public enum SwiftVersion: Double {
    case v2_2 = 2.2
    case v2_3 = 2.3
    case v3_0 = 3.0
    case v3_1 = 3.1
}

extension SwiftVersion: CustomStringConvertible {
    public var description: String {
        return "\(self.rawValue)"
    }
}


public enum Status {
    case inReview
    case awaitingReview
    case accepted
    case implemented(SwiftVersion)
    case deferred
    case rejected
    case withdrawn

    public static let allItems = [
        Status.inReview,
        Status.awaitingReview,
        Status.accepted,
        Status.implemented(.v2_2),
        Status.implemented(.v2_3),
        Status.implemented(.v3_0),
        Status.implemented(.v3_1),
        Status.deferred,
        Status.rejected,
        Status.withdrawn
    ]

    public static let allImplemented = [
        Status.implemented(.v2_2),
        Status.implemented(.v2_3),
        Status.implemented(.v3_0),
        Status.implemented(.v3_1)
    ]

    public static let allAccepted = [
        Status.accepted,
        Status.implemented(.v2_2),
        Status.implemented(.v2_3),
        Status.implemented(.v3_0),
        Status.implemented(.v3_1)
    ]
}

extension Status: Hashable {
    public var hashValue: Int {
        return description.hashValue
    }
}

extension Status: Equatable {
    public static func ==(lhs: Status, rhs: Status) -> Bool {
        switch (lhs, rhs) {
        case (.inReview, .inReview):
            return true
        case (.awaitingReview, .awaitingReview):
            return true
        case (.accepted, .accepted):
            return true
        case (let .implemented(v1), let .implemented(v2)):
            return v1 == v2
        case (.deferred, .deferred):
            return true
        case (.rejected, .rejected):
            return true
        case (.withdrawn, .withdrawn):
            return true
        default:
            return false
        }
    }
}

extension Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .inReview: return "In review"
        case .awaitingReview: return "Awaiting review"
        case .accepted: return "Accepted (awaiting implementation)"
        case .implemented(let v): return "Implemented (\(v))"
        case .deferred: return "Deferred"
        case .rejected: return "Rejected"
        case .withdrawn: return "Withdrawn"
        }
    }
}


public struct Proposal {
    public let title: String
    public let seNumber: String
    public let authors: [String]
    public let status: Status

    public let fileName: String
    public let wordCount: Int

    public init(title: String,
                seNumber: String,
                authors: [String],
                status: Status,
                fileName: String,
                wordCount: Int) {
        self.title = title
        self.seNumber = seNumber
        self.authors = authors
        self.status = status

        self.fileName = fileName
        self.wordCount = wordCount
    }
}

extension Proposal: CustomStringConvertible {
    public var description: String {
        return seNumber + ": " + title
            + "\nAuthor(s): " + authors.joined(separator: ", ")
            + "\nStatus: " + "\(status)"
            + "\nFilename: " + fileName
            + "\nWord count: " + "\(wordCount)"
            + "\n"
    }
}

fileprivate let baseURL: URL = URL(string: "https://github.com/apple/swift-evolution/blob/master/proposals")!
extension Proposal {
    public var githubURL: URL {
        return baseURL.appendingPathComponent(fileName)
    }
}

extension Proposal {
    public var number: Int {
        let start = seNumber.index(seNumber.startIndex, offsetBy: 3)
        let str = seNumber.substring(from: start)
        return Int(str)!
    }
}
