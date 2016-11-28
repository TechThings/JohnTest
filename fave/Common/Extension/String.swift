//
//  String.swift
//
//  Created by Nazih Shoura on 19/03/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import CoreLocation

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).uppercaseString
        let other = String(characters.dropFirst())
        return first + other
    }
    func insert(string: String, atIndex index: Int) -> String {
        return  String(self.characters.prefix(index)) + string + String(self.characters.suffix(self.characters.count-index))
    }
    func split(regex pattern: String) -> [String] {

        guard let re = try? NSRegularExpression(pattern: pattern, options: [])
            else { return [] }

        let nsString = self as NSString // needed for range compatibility
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatchesInString(
            self,
            options: [],
            range: NSRange(location: 0, length: nsString.length),
            withTemplate: stop)
        return modifiedString.componentsSeparatedByString(stop)
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)

        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)

        return boundingBox.height + 2
    }

    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)

        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)

        return boundingBox.width + 2
    }
}

extension String {
    var location: CLLocation? {
        let locationString = self.stringByReplacingOccurrencesOfString(" ", withString:"")
        let components = locationString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
        guard let latitudeString = components[safe: 0] else { return nil }
        guard let longitudeString = components[safe: 1] else { return nil }
        guard let latitude = Double(latitudeString) else { return nil }
        guard let longitude = Double(longitudeString) else { return nil }
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return location
    }
}

// MARK: Fave
extension String {
    static func participantsString(fromNames names: [String]) -> String {
        var result = ""
        let namesString = names.joinWithSeparator(", ")
        if let rangeOfLastSeperator = namesString.rangeOfString(", ", options:NSStringCompareOptions.BackwardsSearch) {
            result = result + namesString.stringByReplacingCharactersInRange(rangeOfLastSeperator, withString: " & ")
        } else {
            result = result + namesString
        }
        return result
    }
    /**
     Splits a string with a given regular expression and returns all matches in an array of separate strings.
     
     - parameter string: The string that is to be split.
     - parameter regex: The regular expression that is used to search for matches in `string`.
     
     - returns: An array of all matches found in string for `regex`.
     */
    private static func splitString(string: String, withRegex regex: NSRegularExpression) -> [String] {
        let matches = regex.matchesInString(string, options: NSMatchingOptions(), range: NSMakeRange(0, string.characters.count))
        var result = [String]()

        matches.forEach {
            for i in 1..<$0.numberOfRanges {
                let range = $0.rangeAtIndex(i)

                if range.length > 0 {
                    result.append(NSString(string: string).substringWithRange(range))
                }
            }
        }

        return result
    }

    /**
     Formats the given card number string based on the detected card type.
     
     - parameter cardNumberString: The card number's unformatted string representation.
     
     - returns: Formatted card number string.
     */
    func formattedCardNumber() -> String {
        let regex: NSRegularExpression

        do {
            let groups = [4, 4, 4, 4]
            var pattern = ""
            var first = true
            for group in groups {
                pattern += "(\\d{1,\(group)})"
                if !first {
                    pattern += "?"
                }
                first = false
            }
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
        } catch {
            fatalError("Error when creating regular expression: \(error)")
        }

        let stringGroups = String.splitString(self, withRegex: regex)
        let result = stringGroups.joinWithSeparator(" ")
        return result
    }
}

protocol OptionalString {}
extension String: OptionalString {}

extension Optional where Wrapped: OptionalString {
    func emptyOnNil() -> String {
        guard let string = self as? String else {return "" }
        return string
    }
}
