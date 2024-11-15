import SwiftUI

struct ContentView: View {
    @StateObject private var dateInfo = DateInfo()
    @State private var timeScale: TimeScale = .day
    
    var body: some View {
        NavigationStack {
            VStack() {
                Spacer()
                switch timeScale {
                case .quarter: QuarterView(dateInfo: dateInfo)
                case .week: WeekView(dateInfo: dateInfo)
                case .day: DayView(dateInfo: dateInfo)
                case .timeOfDay: TimeOfDayView(dateInfo: dateInfo)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            if value.translation.width < 0 {
                                dateInfo.moveForward(by: timeScale)
                            } else if value.translation.width > 0 {
                                dateInfo.moveBackward(by: timeScale)
                            }
                        }
                        else {
                            if value.translation.height < 0 {
                                timeScale = timeScale.down
                            } else if value.translation.height > 0 {
                                timeScale = timeScale.up
                            }
                        }
                    }
            )
            .toolbar {
                
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Picker("Time Scale", selection: $timeScale) {
                        Text("Quarter").tag(TimeScale.quarter)
                        Text("Week").tag(TimeScale.week)
                        Text("Day").tag(TimeScale.day)
                        Text("Time of Day").tag(TimeScale.timeOfDay)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(10)
                    .labelsHidden()
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        dateInfo.reset()
                        timeScale = .day
                    }) {
                        Image(systemName: "house")
                            .padding(10)
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}

enum TimeScale {
    case quarter
    case week
    case day
    case timeOfDay
    var up: TimeScale {
        switch self {
        case .quarter: return .quarter
        case .week: return .quarter
        case .day: return .week
        case .timeOfDay: return .day
        }
    }
    var down: TimeScale {
        switch self {
        case .quarter: return .week
        case .week: return .day
        case .day: return .timeOfDay
        case .timeOfDay: return .timeOfDay
        }
    }
}

struct QuarterView: View {
    @ObservedObject var dateInfo: DateInfo
    var body: some View {
        VStack(spacing: 8) {
            Text("Quarter \(dateInfo.quarterOfYear) of Year \(String(dateInfo.year))")
                .font(.title)
        }
        .padding()
    }
}

struct WeekView: View {
    @ObservedObject var dateInfo: DateInfo
    var body: some View {
        VStack(spacing: 8) {
            Text("Week \(dateInfo.weekOfYear) of \(String(dateInfo.year))")
                .font(.title)
            Text("Week \(dateInfo.weekOfQuarter) of Quarter \(dateInfo.quarterOfYear)")
                .font(.title)
            Text(dateInfo.weekDateRangeDescription)
                .font(.title2)
        }
        .padding()
    }
}

struct DayView: View {
    @ObservedObject var dateInfo: DateInfo
    var body: some View {
        VStack(spacing: 8) {
            Text("\(dateInfo.dayOfWeekName), \(dateInfo.day)\(dateInfo.ordinalSuffix(of: dateInfo.day)) of \(dateInfo.monthName)")
            Text("Day \(dateInfo.dayOfWeek) of Week \(dateInfo.weekOfYear)")
            Text(String(dateInfo.year))
        }
        .font(.title)
        .padding()
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
    
    func reset() {
        date = Date()
    }
    
    func moveForward(by timeScale: TimeScale) {
        switch timeScale {
        case .quarter:
            if let newDate = calendar.date(byAdding: .day, value: 91, to: date) {
                date = newDate
            }
        case .week:
            if let newDate = calendar.date(byAdding: .day, value: 7, to: date) {
                date = newDate
            }
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
        case .quarter:
            if let newDate = calendar.date(byAdding: .day, value: -91, to: date) {
                date = newDate
            }
        case .week:
            if let newDate = calendar.date(byAdding: .day, value: -7, to: date) {
                date = newDate
            }
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
    
    var quarterOfYear: Int {
        (weekOfYear - 1) / 13 + 1
    }
    
    var monthName: String {
        let monthIndex = calendar.component(.month, from: date) - 1
        return calendar.monthSymbols[monthIndex]
    }
    
    var weekOfYear: Int {
        calendar.component(.weekOfYear, from: date)
    }
    
    var weekOfQuarter: Int {
        (weekOfYear - 1) % 13 + 1
    }
    
    var weekDateRangeDescription: String {
        let startOfWeek = calendar.date(byAdding: .day, value: 1-dayOfWeek, to: date)!
        let startDay = calendar.component(.day, from: startOfWeek)
        let startMonthName = calendar.monthSymbols[calendar.component(.month, from: startOfWeek)-1]
        
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        let endDay = calendar.component(.day, from: endOfWeek)
        let endMonthName = calendar.monthSymbols[calendar.component(.month, from: endOfWeek)-1]
        
        return "\(startDay)\(ordinalSuffix(of: startDay)) of \(startMonthName) - \(endDay)\(ordinalSuffix(of: endDay)) of \(endMonthName)"
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
