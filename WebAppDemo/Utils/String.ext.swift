//
//  String Convenience Extensions.swift
//  Swift3Project
//
//  Created by Yilei He on 7/11/16.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit

extension String {
    /**
     Migrate the method of NSString.length to String in swift.
     
     It just returns self.characters.count
     */
    public var length:Int {return self.characters.count}
    
    
    
    /**
     Get the character at specific position in the receiver
     
     - parameter i: index of the character
     
     - returns: An instance of Character
     */
    public subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    
    
    /**
     Get the string at specific position in the receiver
     
     - parameter i: index of the string
     
     - returns: A string with only one character
     */
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    
    
    /**
     Get the string in the range
     
     - parameter r: The range used to retrieve string
     
     - returns: The result string
     */
    public subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = characters.index(startIndex, offsetBy: r.upperBound)
        return self[start ..< end]
    }
    
    
    
    public var fullRange: Range<Index> {
        return startIndex ..< endIndex
    }
    
    
    
    public func nsRange(for range: Range<String.Index>) -> NSRange {
        let location = distance(from: startIndex, to: range.lowerBound)
        let length = distance(from: range.lowerBound, to: range.upperBound)
        return NSRange(location: location, length: length)
    }
    
    
    public func range(for nsRange: NSRange) -> Range<String.Index> {
        return index(startIndex, offsetBy: nsRange.location) ..< index(startIndex, offsetBy: nsRange.length)
    }
    
    
    
    public func substring(from offset: String.IndexDistance) -> String {
        return substring(from: index(startIndex, offsetBy: offset))
    }
    
    
    
    public func substring(to offset: String.IndexDistance) -> String {
        return substring(to: index(startIndex, offsetBy: offset))
    }
    
    
    
    public func substring(with aRange:Range<String.IndexDistance>) -> String {
        let start = index(startIndex, offsetBy: aRange.lowerBound)
        let end = index(startIndex, offsetBy: aRange.upperBound)
        let range = start..<end
        return substring(with: range)
    }
    
    
    
    
    public func composedCharacters() -> [String] {
        var results: [String] = []
        enumerateSubstrings(in: fullRange, options: [.byComposedCharacterSequences]) { (substring, substringRange, enclosingRange, _) in
            if let substring = substring {
                results.append(substring)
            }
        }
        return results
    }
    
    
    
    public func words() -> [String] {
        var results: [String] = []
        enumerateSubstrings(in: fullRange, options: [.byWords]) { (substring, substringRange, enclosingRange, _) in
            if let substring = substring {
                results.append(substring)
            }
        }
        return results
    }
    
    
    
    public func lines() -> [String] {
        var results: [String] = []
        enumerateSubstrings(in: fullRange, options: .byLines) { (substring, substringRange, enclosingRange, _) in
            if let substring = substring {
                results.append(substring)
            }
        }
        return results
    }
    
    
    
    /**
     Removing the white space and new line characters at the start and end of the string
     */
    public mutating func trim() {
        self = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    
    /**
     Return a string that the  white space and new line characters at the start and end of the string are removed
     
     - returns: trimmed string
     */
    public func trimmed() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    
    
    // MARK: Attributed
    public func underLinedAttributedString(style:NSUnderlineStyle = .styleSingle, color: UIColor? = nil) -> NSAttributedString {
        return NSAttributedString(string: self).underLinedString(style: style, color: color)
    }
    
    
    
    public func attributed(_ attributes: [String: Any]?) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
    
    
    
    public func toSuperscript(font: UIFont = UIFont.systemFont(ofSize: UIFont.labelFontSize), color: UIColor = UIColor.darkText) -> NSAttributedString {
        return attributed([NSBaselineOffsetAttributeName: (font.pointSize - font.pointSize / 1.5) / 2.0, NSFontAttributeName: font.withSize(font.pointSize/1.5), NSForegroundColorAttributeName: color])
    }
    
    
    
    // MARK: RegularExpression
    public func range(ofRegularExpression regex: String) -> Range<String.Index>? {
        return range(of: regex, options: .regularExpression)
    }
    
    
    
    public func replacing(regularExpression regex: String, with replacement: String) -> String {
        return replacingOccurrences(of: regex, with: replacement, options: .regularExpression)
    }
    
    
    
    public func replacing(regularExpression regex: String, withTemplate template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        return regex.stringByReplacingMatches(in: self, options: [], range: nsRange(for: fullRange), withTemplate: template)
    }
    
    
    
    // MARK: base64
    init?(base64Encoded base64: String) {
        guard let data = Data(base64Encoded: base64) else {return nil}
        self.init(data: data, encoding: .utf8)
    }
    
    
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

}



extension NSAttributedString {
    func underLinedString(style:NSUnderlineStyle = .styleSingle, color: UIColor? = nil) -> NSAttributedString {
        let temp = NSMutableAttributedString(attributedString: self)
        temp.underLine(style: style, color: color)
        return temp
    }
}



extension NSMutableAttributedString {
    func appendText(_ text: String, style: UIFontTextStyle, size: CGFloat = 0, color: UIColor = UIColor.darkText, paragrapthSpacing: CGFloat = 8, lineBreakMode: NSLineBreakMode = .byWordWrapping, alignment: NSTextAlignment = .left) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = paragrapthSpacing
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = alignment
        let font = size == 0 ? UIFont.preferredFont(forTextStyle: style) : UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: style) , size: size)
        self.append(NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle]))
        return self
    }
    
    
    
    func breakLine() -> NSMutableAttributedString {
        self.append(NSAttributedString(string: "\n"))
        return self
    }
    
    
    func highlightSubstring(substring: String, color: UIColor, caseSensitive: Bool = true) {
        let options: NSString.CompareOptions = caseSensitive ? [] : [.caseInsensitive]
        let range = (self.string as NSString).range(of: substring, options: options)
        if range.location == NSNotFound {return}
        addAttribute(NSForegroundColorAttributeName, value: color, range: range)
    }
    
    
    func underLine(style:NSUnderlineStyle = .styleSingle, color: UIColor? = nil) {
        addAttribute(NSUnderlineStyleAttributeName, value: style.rawValue, range: NSRange(location: 0, length: self.string.characters.count))
        if let color = color {
            addAttribute(NSUnderlineColorAttributeName, value: color, range: NSRange(location: 0, length: self.string.characters.count))
        }
    }
}



func +(lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let temp = NSMutableAttributedString(attributedString: lhs)
    temp.append(rhs)
    return temp
}


func +=(lhs:NSMutableAttributedString, rhs: NSAttributedString) {
    lhs.append(rhs)
}
