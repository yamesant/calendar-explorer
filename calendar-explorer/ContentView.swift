import SwiftUI

struct ContentView: View {
    private let dateInfo = DateInfo()
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("\(dateInfo.dayOfWeekName), \(dateInfo.day)\(dateInfo.ordinalSuffix(of: dateInfo.day)) of \(dateInfo.monthName)")
                Text("Day \(dateInfo.dayOfWeek) of Week \(dateInfo.weekOfYear)")
                Text(String(dateInfo.year))
            }
            .font(.title)
            .padding()
        }
        .padding()
    }
}

struct DateInfo {
    private let date: Date
    private let calendar = Calendar.current
    
    init(date: Date = Date()) {
        self.date = date
    }
    
    var year: Int {
        calendar.component(.year, from: date)
    }
    
    var monthName: String {
        let monthIndex = calendar.component(.month, from: date) - 1
        return calendar.monthSymbols[monthIndex]
    }
    
    var weekOfYear: Int {
        calendar.component(.weekOfYear, from: date)
    }
    
    var day: Int {
        calendar.component(.day, from: date)
    }
    
    var dayOfWeek: Int {
        let weekday = calendar.component(.weekday, from: date)
        return (weekday - calendar.firstWeekday + 7) % 7 + 1
    }
    
    var dayOfWeekName: String {
        let weekdayIndex = calendar.component(.weekday, from: date) - 1
        return calendar.weekdaySymbols[weekdayIndex]
    }
    
    func ordinalSuffix(of number: Int) -> String {
        let suffix: String
        switch number % 10 {
        case 1 where number % 100 != 11: suffix = "st"
        case 2 where number % 100 != 12: suffix = "nd"
        case 3 where number % 100 != 13: suffix = "rd"
        default: suffix = "th"
        }
        return suffix
    }
}

#Preview {
    ContentView()
}
