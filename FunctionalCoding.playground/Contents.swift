import UIKit

let names = ["John", "Paul", "Georg", "Ringo"]
let namesCount = names.map{$0.count}
print(namesCount)

let scores = [100, 80, 85]
let formatted = scores.map{"Your score is \($0)"}
print(formatted)

let numbers = [4.0, 9.0, 16.0]
let result = numbers.map(sqrt)
print(result)

let input = ["1", "5", "Fish"]
let numbres = input.compactMap{Int($0)}
print(numbres)

let ints = [9, 5, 3, 5]
let counts = ints.map{($0, 1)}
let dict = Dictionary(counts, uniquingKeysWith: +)

let numbersArray = Array(1...100)
let sum = numbersArray.reduce(0, +)

let yes = ["yes", "fuck", "me"]
let reply = "yes of course"
yes.contains(where: reply.contains)
