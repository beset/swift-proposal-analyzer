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


public func parseProposals(inDirectory directory: URL) -> [Proposal] {
    let files = proposalFiles(inDirectory: directory)

    var allProposals = [Proposal]()
    for (url, fileContents) in files {
        let proposal = proposalFrom(fileContents: fileContents, fileName: url.lastPathComponent)
        allProposals.append(proposal)
    }

    return allProposals.sorted { p1, p2 -> Bool in
        p1.seNumber < p2.seNumber
    }
}


func proposalFiles(inDirectory directory: URL) -> [URL : String] {
    let fm = FileManager.default
    let proposalNames = try! fm.contentsOfDirectory(atPath: directory.path)
    var proposals = [URL : String]()

    for eachName in proposalNames {
        let url = directory.appendingPathComponent(eachName)
        let fileContents = try! String(contentsOf: url, encoding: String.Encoding.utf8)
        proposals[url] = fileContents
    }
    return proposals
}


func proposalFrom(fileContents: String, fileName: String) -> Proposal {
    let lines = proposalLines(10, fromFile: fileContents)

    let titleLine = lines[0].trimmingWhitespace()
    var seNumberLine: String!
    var singleAuthorLine: String?
    var multipleAuthorLine: String?
    var statusLine: String!

    for eachLine in lines {
        if eachLine.hasPrefix("* Proposal:") {
            seNumberLine = eachLine
        }

        if eachLine.hasPrefix("* Author:") {
            singleAuthorLine = eachLine
        }

        if eachLine.hasPrefix("* Authors:") {
            multipleAuthorLine = eachLine
        }

        if eachLine.hasPrefix("* Status: ") {
            statusLine = eachLine
        }
    }

    let title = nameFromLine(titleLine)
    let seNumber = seNumberFromLine(seNumberLine)

    let authorLine: String! = singleAuthorLine ?? multipleAuthorLine
    let authors = authorsFromLine(authorLine, multiple: (singleAuthorLine == nil))

    let status = statusFromLine(statusLine)
    let words = wordCount(fromFile: fileContents)

    return Proposal(title: title,
                    seNumber: seNumber,
                    authors: authors,
                    status: status,
                    fileName: fileName,
                    fileContents: fileContents,
                    wordCount: words)
}

extension String {
    func trimmingWhitespace() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


func wordCount(fromFile file: String) -> Int {
    // yes, this is extremely naive and not very precise
    // but good enough to get a basic idea of word count
    // also, i'm lazy
    let trimmedChars = CharacterSet.punctuationCharacters.union(.symbols)

    return file.components(separatedBy: .whitespacesAndNewlines)
        .map { $0.trimmingCharacters(in: trimmedChars) }
        .filter { $0 != "" }.count
}

func proposalLines(_ numberOfLines: Int, fromFile file: String) -> [String] {
    var lines = [String]()
    var count = 0
    file.enumerateLines { line, stop in
        lines.append(line)
        count += 1

        if count >= numberOfLines {
            stop = true
        }
    }
    return lines
}


func nameFromLine(_ line: String) -> String {
    return line.trimmingCharacters(in: CharacterSet(["#", " "])).trimmingWhitespace()
}


func seNumberFromLine(_ line: String) -> String {
    let start = line.index(line.startIndex, offsetBy: 13)
    let range = start..<line.index(start, offsetBy: 7)
    return line.substring(with: range).trimmingWhitespace()
}


func authorsFromLine(_ line: String, multiple: Bool) -> [Author] {
    let range = line.index(line.startIndex, offsetBy: multiple ? 11 : 10)
    let authorString = line.substring(from: range)
    let authorComponents = authorString.components(separatedBy: ",")

    var authors = [Author]()
    for eachAuthor in authorComponents {
        let components = eachAuthor.components(separatedBy: CharacterSet(["[", "]"]))
        if components.count > 1 {
            let name = components[1].trimmingWhitespace()
            authors.append(Author(name: name))
        } else {
            let name = components[0].trimmingWhitespace()
            authors.append(Author(name: name))
        }
    }

    return authors
}


func statusFromLine(_ line: String) -> Status {
    let range = line.index(line.startIndex, offsetBy: 10)
    let string = line.substring(from: range)
    let characters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(["*"]))
    let statusString = string.trimmingCharacters(in: characters)

    switch statusString {
    case _ where statusString.localizedCaseInsensitiveContains("Active Review"):
        return .inReview
    case _ where statusString.localizedCaseInsensitiveContains("Awaiting Review"):
        return .awaitingReview
    case _ where statusString.localizedCaseInsensitiveContains("Accepted"):
        return .accepted
    case _ where statusString.localizedCaseInsensitiveContains("Implemented"):
        let version = versionFromString(statusString)
        return .implemented(version)
    case _ where statusString.localizedCaseInsensitiveContains("Deferred"):
        return .deferred
    case _ where statusString.localizedCaseInsensitiveContains("Rejected"):
        return .rejected
    case _ where statusString.localizedCaseInsensitiveContains("Withdrawn"):
        return .withdrawn
    default:
        fatalError("** Error: unknown status found in line: " + line)
    }
}


func versionFromString(_ versionString: String) -> SwiftVersion {
    switch versionString {
    case _ where versionString.localizedCaseInsensitiveContains("Swift 2.2"):
        return .v2_2
    case _ where versionString.localizedCaseInsensitiveContains("Swift 2.3"):
        return .v2_3
    case _ where versionString.localizedCaseInsensitiveContains("Swift 3.1"):
        return .v3_1
    case _ where versionString.localizedCaseInsensitiveContains("Swift 3.0.1"):
        return .v3_0_1
    case _ where versionString.localizedCaseInsensitiveContains("Swift 3.0"): fallthrough
    case _ where versionString.localizedCaseInsensitiveContains("Swift 3"):
        return .v3_0
    default:
        fatalError("** Error: unknown version number found: " + versionString)
    }
}

