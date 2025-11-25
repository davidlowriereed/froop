//
//  InfiniteScrollView.swift
//  Design_Layouts
//
//  Created by David Reed on 11/28/23.
//

import SwiftUI

struct InfiniteScrollView: View {
    @ObservedObject var scrollTrig = ScrollTrig.shared
    @Binding var currentIndex: Int
    @Binding var targetIndex: Int?

    let items: [Item] // Use this items array passed as a parameter
    let scrollViewID: Int
    
    var height: CGFloat
    var width: CGFloat
    var spacing: CGFloat
    var itemsCount: Int
    var repeatingCount: Int
    
    var body: some View {
        // Calculate height, spacing, itemsCount, and repeatingCount based on your items and design
        let height: CGFloat = 100 // Example value, adjust as needed
        let spacing: CGFloat = 0 // Example value, adjust as needed
        let size = UIScreen.main.bounds.size // Use the screen size to calculate repeatingCount
        let repeatingCount = height > 0 ? Int((size.height / height).rounded()) + 1 : 1
        
        
        HStack (alignment: .center){
            GeometryReader {
                let size = $0.size
                LoopingScrollView(height: size.height, spacing: 0, items: items, scrollViewID: scrollViewID, targetIndex: $targetIndex, currentIndex: $currentIndex) { item in
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(item.color.gradient)
                            .frame(height: 100)
                            .frame(width: width)
                        if scrollTrig.firstPositionIndex == 0 && scrollViewID == 2 {
                            Text("\(item.number)")
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 72))
                                .fontWeight(.ultraLight)
                                .rotationEffect(.degrees(180), anchor: .center) // This will flip the text upside down

                        } else {
                            Text("\(item.number)")
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 72))
                                .fontWeight(.ultraLight)
                                .rotationEffect(.degrees(180), anchor: .center) // This will flip the text upside down

                        }
                    }
                }
                .contentMargins(.vertical, 0, for: .scrollContent)
                .scrollTargetBehavior(.paging)
                
            }
            .frame(width: width + 10)
            
            
            
        }
        .padding(.horizontal, 15)
        .frame(height: 110)
        .frame(width: width + 5)
        
        .scrollIndicators(.hidden)
        .background {
            ScrollViewHelper(height: height,
                             spacing: spacing,
                             itemsCount: items.count,
                             repeatingCount: repeatingCount, scrollViewID: scrollViewID, targetIndex: $targetIndex, currentIndex: $currentIndex)
        }
    }
}



struct Item: Identifiable {
    var id: UUID = .init()
    var number: Int
    var color: Color
}


struct LoopingScrollView<Content: View, Item: RandomAccessCollection>: View where Item.Element: Identifiable {
    
    var height: CGFloat
    var spacing: CGFloat = 0
    var items: Item
    var scrollViewID: Int
    @Binding var targetIndex: Int?
    @Binding var currentIndex: Int

    
    @ViewBuilder var content: (Item.Element) -> Content
    
    var filteredItems: [Item.Element] {
        switch scrollViewID {
            case 1:
                // Apply specific filter for the first scroll view
                return Array(items)
//                return items.filter { _ in ScrollTrig.shared.secondPositionIndex <= 2 }
                // Add cases for other scroll views if needed
            default:
                return Array(items)
        }
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let repeatingCount = height > 0 ? Int((size.height / height).rounded()) + 1 : 1
            
            ScrollView(.vertical) {
                LazyVStack(spacing: spacing) {
                    ForEach(filteredItems, id: \.id) { item in
                        content(item)
                            .frame(height: height)
                    }
                    ForEach(0..<repeatingCount, id: \.self) { index in
                        let item = Array(items)[index % items.count]
                        content(item)
                            .frame(height: height)
                    }
                }
                .background {
                    ScrollViewHelper(height: height,
                                     spacing: spacing,
                                     itemsCount: items.count,
                                     repeatingCount: repeatingCount,
                                     scrollViewID: scrollViewID, targetIndex: $targetIndex, currentIndex: $currentIndex)
                }
            }
        }
    }
}



fileprivate struct ScrollViewHelper: UIViewRepresentable {
    @ObservedObject var scrollTrig = ScrollTrig.shared
    var height: CGFloat
    var spacing: CGFloat
    var itemsCount: Int
    var repeatingCount: Int
    var scrollViewID: Int
    @Binding var targetIndex: Int?
    @Binding var currentIndex: Int
    
    func makeCoordinator() -> ISCoordinator {
        return ISCoordinator(height: height,
                             spacing: spacing,
                             itemsCount: itemsCount,
                             repeatingCount: repeatingCount,
                             scrollViewID: scrollViewID, currentIndex: $currentIndex)
    }
    
    func makeUIView(context: Context) -> UIView {
        return .init()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
//        print("updateUIView Firing")
        DispatchQueue.main.async {
            if let targetIndex = targetIndex {
                // Make sure the view is of type UIScrollView
                guard let scrollView = uiView as? UIScrollView else { return }
                
                let yOffset = CGFloat(targetIndex) * (height + spacing)
                scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
                self.targetIndex = nil // Reset the targetIndex after scrolling
            }
            
            // Check if the scrollView delegate is already set
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView,
                !context.coordinator.isAdded {
                scrollView.delegate = context.coordinator
                context.coordinator.isAdded = true
            }
        }

        // Update coordinator properties
        context.coordinator.height = height
        context.coordinator.spacing = spacing
        context.coordinator.itemsCount = itemsCount
        context.coordinator.repeatingCount = repeatingCount
    }
        
    class ISCoordinator: NSObject, UIScrollViewDelegate {
        var height: CGFloat
        var spacing: CGFloat
        var itemsCount: Int
        var repeatingCount: Int
        var scrollViewID: Int
        var centeredIndex: [Int: Int] = [:] // Dictionary to track index for each scroll view
        var lastContentOffset: CGPoint = .zero // To track the last content offset
        @Binding var currentIndex: Int // Binding to the current index
        var isScrolling = false

        
        init(height: CGFloat, spacing: CGFloat, itemsCount: Int, repeatingCount: Int, scrollViewID: Int, currentIndex: Binding<Int>) {
              self.height = height
              self.spacing = spacing
              self.itemsCount = itemsCount
              self.repeatingCount = repeatingCount
              self.scrollViewID = scrollViewID
              self._currentIndex = currentIndex // Note the underscore
          }
        
        var isAdded: Bool = false
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard itemsCount > 0 else { return }
            
            let minY = scrollView.contentOffset.y
            let mainContentSize = CGFloat(itemsCount) * height
            let spacingSize = CGFloat(itemsCount - 1) * spacing
            
            // Adjust minY to get the index of the centered item
            let adjustedMinY = minY + (scrollView.frame.height / 2) - (height / 2)
            
            // Calculate the index of the current centered item
            let index = Int((adjustedMinY / (height + spacing)).rounded())
            centeredIndex[scrollViewID] = index % itemsCount // Update the index for this scroll view
            
            // Print or use the index as needed
//            print("Current centered item index for scrollViewID \(scrollViewID): \(centeredIndex[scrollViewID] ?? 0)")
            
            // Loop the scroll view content
            if minY > (mainContentSize + spacingSize) {
                scrollView.contentOffset.y -= (mainContentSize + spacingSize)
            } else if minY < -spacingSize {
                scrollView.contentOffset.y += (mainContentSize + spacingSize)
            }
            
            // Update the last content offset
            lastContentOffset = scrollView.contentOffset
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//            lastContentOffset = scrollView.contentOffset
            isScrolling = true
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isScrolling = false
            updateCurrentIndex(scrollView)
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                isScrolling = false
                updateCurrentIndex(scrollView)
            }
        }
        
        private func updateCurrentIndex(_ scrollView: UIScrollView) {
            let minY = scrollView.contentOffset.y
            let adjustedMinY = minY + (scrollView.frame.height / 2) - (height / 2)
            let newIndex = Int((adjustedMinY / (height + spacing)).rounded()) % self.itemsCount

            // Check if the new index is different from the current one
            if !isScrolling {
                if newIndex != self.currentIndex {
                    DispatchQueue.main.async {
                        self.currentIndex = newIndex
                        
                        // Update the corresponding index in ScrollTrig
                        switch self.scrollViewID {
                            case 1:
                                if ScrollTrig.shared.firstPositionIndex != newIndex {
                                    ScrollTrig.shared.firstPositionIndex = newIndex
                                }
                            case 2:
                                if ScrollTrig.shared.secondPositionIndexA != newIndex {
                                    ScrollTrig.shared.secondPositionIndexA = newIndex
                                }
                            case 3:
                                if ScrollTrig.shared.secondPositionIndexB != newIndex {
                                    ScrollTrig.shared.secondPositionIndexB = newIndex
                                }
                                // Add cases for other scroll views
                            default:
                                break
                        }
                    }
                }
            }
        }
    }
}


struct ClockView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var scrollTrig = ScrollTrig.shared
    
    let itemHeight: CGFloat = 90
    let itemWidth: CGFloat = UIScreen.screenWidth / 5.5
    let itemSpacing: CGFloat = 0
    let scrollViewWidth: CGFloat = 80
    let currentTime = Date()
    @ObservedObject var froopData = FroopData.shared

    
    
    
    var body: some View {
        ZStack {
            HStack {
                Text("START TIME")
                    .frame(width: 110)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 80/255, green: 80/255, blue: 110/255))
                    .padding(.leading, 10)
                    .offset(y: -75)
                Spacer()
            }
       
            HStack {
                Spacer()
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(scrollTrig.amPm ? Color(red: 249/255, green: 0/255, blue: 98/255) : .white)
                            .frame(width: 40, height: 40)
                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                        Text("AM")
                            .font(.system(size: 16))
                            .foregroundColor(scrollTrig.amPm ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(scrollTrig.amPm ? .semibold : .light)
                    }
                    .onTapGesture {
                        if scrollTrig.amPm == false {
                            scrollTrig.amPm.toggle()
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(scrollTrig.amPm ? .white : Color(red: 249/255, green: 0/255, blue: 98/255))
                            .frame(width: 40, height: 40)
                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                        Text("PM")
                            .font(.system(size: 16))
                            .foregroundColor(scrollTrig.amPm ? Color(red: 50/255, green: 46/255, blue: 62/255) : .white)
                            .fontWeight(scrollTrig.amPm ? .light : .semibold)
                    }
                    .onTapGesture {
                        if scrollTrig.amPm == true {
                            scrollTrig.amPm.toggle()
                        }
                    }
                }
            }
            .padding(.trailing, UIScreen.screenWidth * 0.1)
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    if scrollTrig.firstPositionIndex == 0 {
                        ZStack {
                            InfiniteScrollView(
                                currentIndex: $scrollTrig.secondPositionIndexA, targetIndex: $scrollTrig.targetIndexForSecondA,
                                items: scrollTrig.secondPositionNumbersA.map {
                                    Item(number: $0, color: $0 % 2 == 0 ? .white : .white)
                                },
                                scrollViewID: 2, // Unique ID for each ScrollView
                                height: itemHeight,
                                width: itemWidth + 30,
                                spacing: itemSpacing,
                                itemsCount: scrollTrig.secondPositionNumbersA.count,
                                repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                            )
                            .rotationEffect(.degrees(180), anchor: .center)
                            
                            .onAppear {
                                scrollTrig.secondPositionIndexB = 0
                            }
                            .onChange(of: scrollTrig.secondPositionIndexA) {
                                scrollTrig.secondPositionTime = scrollTrig.secondPositionIndexA + 1
                                scrollTrig.updateDateFromIndices()
                            }
                            
                            Text(":")
                                .font(.system(size: 75 ))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .offset(y: -5)
                                .frame(width: 20, height: 110)
                                .padding(.leading, 1)
                                .padding(.trailing, 1)
                                .shadow(color: Color.white.opacity(1), radius: 7, x: -4, y: -4)
                                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), radius: 7, x: 7, y: 7)
                                .offset(x: itemWidth / 2 + 28)
                            
                                
                        }
                       
                        
                    } else if scrollTrig.firstPositionIndex == 1 {
            
                        InfiniteScrollView(
                            currentIndex: $scrollTrig.secondPositionIndexB, targetIndex: $scrollTrig.targetIndexForSecondB,
                            items: scrollTrig.secondPositionNumbersB.map {
                                Item(number: $0, color: $0 % 2 == 0 ? .white : .white)
                            },
                            scrollViewID: 3, // Unique ID for each ScrollView
                            height: itemHeight,
                            width: itemWidth,
                            spacing: itemSpacing,
                            itemsCount: scrollTrig.secondPositionNumbersB.count,
                            repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                        )
                        .rotationEffect(.degrees(180), anchor: .center)

                        .onAppear {
                            
                            scrollTrig.secondPositionIndexA = 0
                        }
                        .onChange(of: scrollTrig.secondPositionIndexB) {
                            scrollTrig.secondPositionTime = scrollTrig.secondPositionIndexB
                            scrollTrig.updateDateFromIndices()
                        }
                    }
                }
                
                
                
                
                HStack(spacing: 0) {
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.thirdPositionIndex, targetIndex: $scrollTrig.targetIndexForThird,
                        items: scrollTrig.thirdPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? .white : .white)
                        },
                        scrollViewID: 4, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.thirdPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .rotationEffect(.degrees(180), anchor: .center)

                    .onChange(of: scrollTrig.thirdPositionIndex) {
                        scrollTrig.thirdPositionTime = scrollTrig.thirdPositionIndex

                        scrollTrig.updateDateFromIndices()
                    }
                    
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.fourthPositionIndex, targetIndex: $scrollTrig.targetIndexForFourth,
                        items: scrollTrig.fourthPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? .white : .white)
                        },
                        scrollViewID: 5, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.fourthPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .rotationEffect(.degrees(180), anchor: .center)

                    .onChange(of: scrollTrig.fourthPositionIndex) {
                        scrollTrig.fourthPositionTime = scrollTrig.fourthPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                }
                .padding(.leading, UIScreen.screenWidth / 20)
                Spacer()
            }
            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            .padding(.leading, UIScreen.screenWidth * 0.05)
            .padding(.trailing, UIScreen.screenWidth * 0.17)
            .frame(maxWidth: UIScreen.screenWidth - 40)
        }
    }
    
    func resetFirstPosition() {
        scrollTrig.targetIndexForFirst = 0
    }
    
    private func calculateRepeatingCount(height: CGFloat, scrollViewWidth: CGFloat) -> Int {
        // Calculate the repeating count based on the height and width
        let count = Int((scrollViewWidth / height).rounded()) + 1
        return max(count, 1) // Ensure it's at least 1
    }
}

struct DurationView: View {
    
    @ObservedObject var scrollTrig = ScrollTrig.shared
    
    let itemHeight: CGFloat = 100
    let itemWidth: CGFloat = 100
    let itemSpacing: CGFloat = 0
    let scrollViewWidth: CGFloat = 110
    let currentTime = Date()
    @ObservedObject var froopData = FroopData.shared

    
    
    var body: some View {
        ZStack {

            HStack {
                Text("DURATION")
                    .frame(width: 110)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 80/255, green: 80/255, blue: 110/255))
                    .padding(.leading, 10)
                    .offset(y: -75)
                Spacer()
                    
            }
            HStack (spacing: 0){
                Text("DAYS")
                    .frame(width: 110)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 180/255, green: 180/255, blue: 210/255))
                Spacer()
                Text("HOURS")
                    .frame(width: 110)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 180/255, green: 180/255, blue: 210/255))

                Spacer()
                Text("MINUTES")
                    .frame(width: 110)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 180/255, green: 180/255, blue: 210/255))

            }
            .offset(y: 70)
            .padding(.leading, 30)
            .padding(.trailing, 30)
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.fifthPositionIndex,
                        targetIndex: $scrollTrig.targetIndexForFifth,
                        items: scrollTrig.fifthPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? .white : .white) },
                        scrollViewID: 5, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.fifthPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .rotationEffect(.degrees(180), anchor: .center)

                    .onChange(of: scrollTrig.fifthPositionIndex) {
                        scrollTrig.fifthPositionTime = scrollTrig.fifthPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                   
                    Spacer()
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.sixthPositionIndex, targetIndex: $scrollTrig.targetIndexForSixth,
                        items: scrollTrig.sixthPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? .white : .white) },
                        scrollViewID: 6, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.sixthPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .rotationEffect(.degrees(180), anchor: .center)

                    .onChange(of: scrollTrig.sixthPositionIndex) {
                        scrollTrig.sixthPositionTime = scrollTrig.sixthPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                    Spacer()
                    InfiniteScrollView(
                            currentIndex: $scrollTrig.seventhPositionIndex, targetIndex: $scrollTrig.targetIndexForSeventh,
                            items: scrollTrig.seventhPositionNumbers.map {
                                Item(number: $0, color: $0 % 2 == 0 ? .white : .white) },
                            scrollViewID: 7, // Unique ID for each ScrollView
                            height: itemHeight,
                            width: itemWidth,
                            spacing: itemSpacing,
                            itemsCount: scrollTrig.seventhPositionNumbers.count,
                            repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .rotationEffect(.degrees(180), anchor: .center)

                    .onChange(of: scrollTrig.seventhPositionIndex) {
                        scrollTrig.seventhPositionTime = scrollTrig.seventhPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                // Add logic for onChange if needed
            }
            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            .padding(.horizontal)

        }
    }
    
    func resetFirstPosition() {
        scrollTrig.targetIndexForFirst = 0
    }
    
    private func calculateRepeatingCount(height: CGFloat, scrollViewWidth: CGFloat) -> Int {
        // Calculate the repeating count based on the height and width
        let count = Int((scrollViewWidth / height).rounded()) + 1
        return max(count, 1) // Ensure it's at least 1
    }
}


class ScrollTrig: ObservableObject {
    static let shared = ScrollTrig()
    var increment: Int = 0
        
    @Published var froopStartTime: Date = Date()
    @Published var froopEndTime: Date = ChangeView.shared.froopData.froopStartTime
    @Published var froopDuration: Int = 0
    
    @Published var firstPositionIndex: Int = 0
    @Published var secondPositionIndexA: Int = 0
    @Published var secondPositionIndexB: Int = 0
    @Published var thirdPositionIndex: Int = 0
    @Published var fourthPositionIndex: Int = 0
    @Published var fifthPositionIndex: Int = 0
    @Published var sixthPositionIndex: Int = 0
    @Published var seventhPositionIndex: Int = 0
    
    @Published var firstPositionTime: Int = 0
    @Published var secondPositionTime: Int = 0
    @Published var thirdPositionTime: Int = 0
    @Published var fourthPositionTime: Int = 0
    @Published var fifthPositionTime: Int = 0
    @Published var sixthPositionTime: Int = 0
    @Published var seventhPositionTime: Int = 0
    
    @Published var targetIndexForFirst: Int?
    @Published var targetIndexForSecondA: Int?
    @Published var targetIndexForSecondB: Int?
    @Published var targetIndexForThird: Int?
    @Published var targetIndexForFourth: Int?
    @Published var targetIndexForFifth: Int?
    @Published var targetIndexForSixth: Int?
    @Published var targetIndexForSeventh: Int?
    
    @Published var firstPositionNumbers: [Int] = [0]
    @Published var secondPositionNumbersA: [Int] = Array(0...11)
    @Published var secondPositionNumbersB: [Int] = [0, 1, 2]
    @Published var thirdPositionNumbers: [Int] = Array(0...5)
    @Published var fourthPositionNumbers: [Int] = Array(0...9)
    @Published var fifthPositionNumbers: [Int] = Array(0...30)
    @Published var sixthPositionNumbers: [Int] = Array(0...23)
    @Published var seventhPositionNumbers: [Int] = [0, 15, 30, 45]
    
    init() {
        updateArraysForCurrentTime()
    }

    func updateArraysForCurrentTime() {
        let calendar = Calendar.current
        let now = Date()

        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)

        // Convert 24-hour format to 12-hour format for display
        let hourIn12HourFormat = (currentHour % 12 == 0) ? 12 : currentHour % 12

        // Time pickers: Hours (1 to 12)
        secondPositionNumbersA = manuallySeedHoursFor12HourFormat(startingHour: hourIn12HourFormat)

        // Time pickers: Minutes (split into tens and ones place)
        let tensPlace = currentMinute / 10
        let onesPlace = currentMinute % 10
        thirdPositionNumbers = manuallySeedMinutesArray(tens: true, startingValue: tensPlace)
        fourthPositionNumbers = manuallySeedMinutesArray(tens: false, startingValue: onesPlace)

        // Duration pickers: Start from 1 hour up to 24
        sixthPositionNumbers = manuallySeedHoursForDuration(startingHour: 1)
    }

    private func manuallySeedHoursFor12HourFormat(startingHour: Int) -> [Int] {
        var array = [Int]()
        for hour in startingHour...12 {
            array.append(hour)
        }
        if startingHour > 1 {
            for hour in 1..<startingHour {
                array.append(hour)
            }
        }
        return array
    }

    private func manuallySeedHoursForDuration(startingHour: Int) -> [Int] {
        var array = [Int]()
        for hour in (startingHour - 1)...23 {
            array.append(hour)
        }
        return array
    }

    private func manuallySeedMinutesArray(tens: Bool, startingValue: Int) -> [Int] {
        var array = [Int]()
        let range = tens ? 0...5 : 0...9
        for value in startingValue...range.upperBound {
            array.append(value)
        }
        for value in range.lowerBound..<startingValue {
            array.append(value)
        }
        return array
    }
}

extension ScrollTrig {
    var amPm: Bool {
        get {
            let hour = Calendar.current.component(.hour, from: froopStartTime)
            return hour < 12
        }
        set {
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: froopStartTime)
            let currentMinute = calendar.component(.minute, from: froopStartTime)
            let hourIn24 = newValue ? (currentHour % 12) : (currentHour == 0 ? 12 : currentHour + 12)
            froopStartTime = calendar.date(bySettingHour: hourIn24, minute: currentMinute, second: 0, of: froopStartTime) ?? froopStartTime
        }
    }
    
    var froopTime: (hour: Int, minute: Int, isAM: Bool) {
        get {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: froopStartTime)
            let minute = calendar.component(.minute, from: froopStartTime)

            let isAM = hour < 12
            let hour12 = hour % 12
            let hourIndex = hour12 == 0 ? 12 : hour12 // Convert 0 (12 AM) to 12



            return (hourIndex, minute, isAM)
        }
        set {
            let calendar = Calendar.current
            let hourIn24 = newValue.isAM ? newValue.hour : (newValue.hour == 12 ? 12 : newValue.hour + 12)
            let newDate = calendar.date(bySettingHour: hourIn24, minute: newValue.minute, second: 0, of: froopStartTime) ?? froopStartTime

            froopStartTime = ChangeView.shared.froopData.froopStartTime
            amPm = newValue.isAM
        }
    }
    
 
    func calculateTimeFromIndex(_ index: Int, for scrollViewID: Int) -> Int {
        // Depending on the scrollViewID, the index might represent different values
        switch scrollViewID {
            case 1: // For first position (hours first digit)
                return index // Assuming 0 and 1 are the only values
            case 2: // For second position (hours second digit)
                    // If firstPositionIndex is 0, the values range from 1-9, else 0-9
                return index + 1
            case 3: // For third position (minutes first digit)
                return index // Assuming values 0-5
            case 4: // For fourth position (minutes second digit)
                return index // Assuming values 0-9
            default:
                return index
        }
    }
    
    func updateFroopEndTime() {
        let calendar = Calendar.current
        
        let daysToAdd = fifthPositionTime
        let hoursToAdd = sixthPositionTime
        // Use the index to access the corresponding minute from the new array
        let minutesToAdd = seventhPositionNumbers[seventhPositionIndex]
        
        var froopDuration: Int = 0
        
        // Assuming froopStartTime is already set and is the starting point
        guard let newEndTime = calendar.date(byAdding: .day, value: daysToAdd, to: ChangeView.shared.froopData.froopStartTime) else { return }
        ChangeView.shared.froopData.froopEndTime = calendar.date(byAdding: .hour, value: hoursToAdd, to: newEndTime)!
        ChangeView.shared.froopData.froopEndTime = calendar.date(byAdding: .minute, value: minutesToAdd, to: ChangeView.shared.froopData.froopEndTime)!

        // Calculate duration in seconds
        froopDuration = Int(ChangeView.shared.froopData.froopEndTime.timeIntervalSince(ChangeView.shared.froopData.froopStartTime))
        self.froopDuration = froopDuration
    }

    func updateDateFromIndices() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: ChangeView.shared.froopData.froopStartTime)

        // Use the actual value from the array for hours
        let hour = secondPositionNumbersA[secondPositionIndexA]
        let tensPlace = thirdPositionNumbers[thirdPositionIndex]
        let onesPlace = fourthPositionNumbers[fourthPositionIndex]
        let minutes = tensPlace * 10 + onesPlace

        // Adjust hour for AM/PM
        components.hour = hour == 12 ? (amPm ? 0 : 12) : (amPm ? hour : hour + 12)
        components.minute = minutes

        // Update froopStartTime
        if let newStartTime = calendar.date(from: components) {
            ChangeView.shared.froopData.froopStartTime = newStartTime
        }

        // For duration, use actual values for days, hours, and custom minutes
        let daysToAdd = fifthPositionNumbers[fifthPositionIndex]
        let hoursToAdd = sixthPositionNumbers[sixthPositionIndex]
        let minutesToAdd = seventhPositionNumbers[seventhPositionIndex]

        // Calculate duration in seconds
        let durationInSeconds = (daysToAdd * 24 * 60 + hoursToAdd * 60 + minutesToAdd) * 60
        if let newEndTime = calendar.date(byAdding: .second, value: durationInSeconds, to: ChangeView.shared.froopData.froopStartTime) {
            ChangeView.shared.froopData.froopEndTime = newEndTime
        }

        ChangeView.shared.froopData.froopDuration = durationInSeconds
        
    }

}


extension ScrollTrig {
    var froopStartTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles") // PDT timezone
        return formatter.string(from: ChangeView.shared.froopData.froopStartTime)
    }
}


extension ScrollTrig {
    func setInitialScrollPositions() {
        let currentTime = Date()
        let calendar = Calendar.current

        // Extracting hour and minute components
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)

        // For the 12-hour format
        let hour12 = hour % 12 == 0 ? 12 : hour % 12 // Convert 0 hour to 12 for 12-hour format
        firstPositionIndex = hour12 / 10 // First digit of the hour (1 or 0, if the time is in 12-hour format)
        secondPositionIndexA = hour12 % 10 // Second digit of the hour

        thirdPositionIndex = minute / 10 // First digit of the minute
        fourthPositionIndex = minute % 10 // Second digit of the minute

        // AM/PM indicator
        amPm = hour < 12

        // Assuming you also have scroll views for duration days, hours, and minutes
        // Setting them to zero initially or to any default value you prefer
        fifthPositionIndex = 0 // Days
        sixthPositionIndex = 0 // Hours
        seventhPositionIndex = 0 // Index for the specific minute value in the duration

        // Update the scrollTrig properties for the duration
        updateFroopDuration()
    }

    func updateFroopDuration() {
        // Example of how you might calculate duration based on the fifth, sixth, and seventh positions
        // Assuming you use these to represent days, hours, and specific minutes (e.g., 15, 30, 45)
        let daysToAdd = fifthPositionIndex
        let hoursToAdd = sixthPositionIndex
        let minutesToAdd = seventhPositionNumbers[seventhPositionIndex] // Assuming seventhPositionNumbers is an array like [0, 15, 30, 45]

        let totalDurationInSeconds = (daysToAdd * 24 * 60 * 60) + (hoursToAdd * 60 * 60) + (minutesToAdd * 60)
        froopDuration = totalDurationInSeconds
    }
}
