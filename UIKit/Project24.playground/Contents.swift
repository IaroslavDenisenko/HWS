import UIKit

let string = "Taylor"
//for letter in string {
//    print(letter)
//}
print(string[string.index(string.startIndex, offsetBy: 3)])

extension String {
    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deleteSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

print(string.deletePrefix("Tay"))
print(string.deleteSuffix("lor"))


extension String {
    var capitalizeFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

let weather = "it's going to rain"
weather.capitalizeFirst

let languages = ["Python", "Ruby", "Swift"]
let input = "Swift is like Objective-C without the C"

extension String {
    func containsAny(of array: [String]) -> Bool {
        for string in array {
            if self.contains(string) {
                return true
            }
        }
        return false
    }
}

input.containsAny(of: languages)
languages.contains(where: input.contains)

let testString = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .backgroundColor: UIColor.red,
    .foregroundColor: UIColor.black,
    .font: UIFont.boldSystemFont(ofSize: 36)
]
let testAttributedString = NSAttributedString(string: testString, attributes: attributes)

let attributedString = NSMutableAttributedString(string: testString)
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString.addAttribute(.font, value:UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

// Challenge

// 1
extension String {
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return self
        }
        return prefix + self
    }
}

"pet".withPrefix("car")
let carpet = "carpet"
carpet.withPrefix("car")

// 2
extension String {
    var isNumeric: Bool {
        if Double(self) != nil {
            return true
        }
        return false
    }
}
"12342340345..".isNumeric

extension String {
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}

"this\nis\na\ntest".lines
