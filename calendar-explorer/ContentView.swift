import SwiftUI

struct ContentView: View {
    @StateObject private var dateInfo = DateInfo()
    @State private var timeScale: TimeScale = .timeOfDay
    
    var body: some View {
        VStack() {
            Spacer()
            switch timeScale {
            case .day: DayView(dateInfo: dateInfo)
            case .timeOfDay: TimeOfDayView(dateInfo: dateInfo)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < 0 {
                        dateInfo.moveForward(by: timeScale)
                    } else {
                        dateInfo.moveBackward(by: timeScale)
                    }
                }
        )
    }
}

enum TimeScale {
    case day
    case timeOfDay
}

struct DayView: View {
    @ObservedObject var dateInfo: DateInfo
    var body: some View {
        VStack(spacing: 8) {
            Text("\(dateInfo.dayOfWeekName), \(dateInfo.day)\(dateInfo.ordinalSuffix(of: dateInfo.day)) of \(dateInfo.monthName)")
            Text("Day \(dateInfo.dayOfWeek) of Week \(dateInfo.weekOfYear)")
            Text(String(dateInfo.year))
        }
    }
}

struct TimeOfDayView: View {
    @ObservedObject var dateInfo: DateInfo
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: dateInfo.timeOfDay.imageName)
                .resizable()
                .scaledToFit()
                .padding()
            Text(dateInfo.timeOfDay.description)
            Text("\(dateInfo.dayOfWeekName), \(dateInfo.day)\(dateInfo.ordinalSuffix(of: dateInfo.day)) of \(dateInfo.monthName)")
            Text("Day \(dateInfo.dayOfWeek) of Week \(dateInfo.weekOfYear)")
            Text(String(dateInfo.year))
        }
        .font(.title)
        .padding()
    }
}

enum TimeOfDay {
    case night
    case morning
    case afternoon
    case evening
    var description: String {
        switch self {
        case .night: return "Night (12am - 6am)"
        case .morning: return "Morning (6am - 12pm)"
        case .afternoon: return "Afternoon (12pm - 6pm)"
        case .evening: return "Evening (6pm - 12am)"
        }
    }
    var imageName: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }
}

class DateInfo: ObservableObject {
    @Published private var date: Date
    private let calendar = Calendar.current
    
    init(date: Date = Date()) {
        self.date = date
    }
    
    func moveForward(by timeScale: TimeScale) {
        switch timeScale {
        case .day:
            if let newDate = calendar.date(byAdding: .day, value: 1, to: date) {
                date = newDate
            }
        case .timeOfDay:
            if let newDate = calendar.date(byAdding: .hour, value: 6, to: date) {
                date = newDate
            }
        }
    }
    
    func moveBackward(by timeScale: TimeScale) {
        switch timeScale {
        case .day:
            if let newDate = calendar.date(byAdding: .day, value: -1, to: date) {
                date = newDate
            }
        case .timeOfDay:
            if let newDate = calendar.date(byAdding: .hour, value: -6, to: date) {
                date = newDate
            }
        }
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
    
    var timeOfDay: TimeOfDay {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 0..<6: return .night
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        default: return .evening
        }
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
