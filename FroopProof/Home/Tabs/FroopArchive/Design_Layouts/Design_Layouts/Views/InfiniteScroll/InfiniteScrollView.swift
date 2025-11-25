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
                            Text("\(item.number + 1)")
                                .foregroundColor(.white)
                                .font(.system(size: 72))
                                .fontWeight(.ultraLight)
                        } else {
                            Text("\(item.number)")
                                .foregroundColor(.white)
                                .font(.system(size: 72))
                                .fontWeight(.ultraLight)
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

#Preview {
    ContentView()
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
            print("Current centered item index for scrollViewID \(scrollViewID): \(centeredIndex[scrollViewID] ?? 0)")
            
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
    
    @ObservedObject var scrollTrig = ScrollTrig.shared
    
    let itemHeight: CGFloat = 100
    let itemWidth: CGFloat = 80
    let itemSpacing: CGFloat = 0
    let scrollViewWidth: CGFloat = 90
    let currentTime = Date()
    
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 130)
//                .foregroundColor(Color.offWhite)
                .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            HStack {
                Text("START TIME")
                    .frame(width: 110)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 80/255, green: 80/255, blue: 110/255))
                    .padding(.leading, 10)
                    .offset(y: -75)
                Spacer()
                    
            }
       
            Rectangle()
                .frame(height: 110)
//                .foregroundColor(Color.offWhite)
                .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            
            HStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.firstPositionIndex, targetIndex: $scrollTrig.targetIndexForFirst,
                        items: scrollTrig.firstPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                        },
                        scrollViewID: 1, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.firstPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .onChange(of: scrollTrig.firstPositionIndex) {
                        if scrollTrig.firstPositionIndex == 0 {
                            scrollTrig.secondPositionTime = 1
                        } else {
                            scrollTrig.secondPositionTime = 0
                        }
                        scrollTrig.firstPositionTime = scrollTrig.firstPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                   
                    
                    if scrollTrig.firstPositionIndex == 0 {
                        InfiniteScrollView(
                            currentIndex: $scrollTrig.secondPositionIndexA, targetIndex: $scrollTrig.targetIndexForSecondA,
                            items: scrollTrig.secondPositionNumbersA.map {
                                Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                            },
                            scrollViewID: 2, // Unique ID for each ScrollView
                            height: itemHeight,
                            width: itemWidth,
                            spacing: itemSpacing,
                            itemsCount: scrollTrig.secondPositionNumbersA.count,
                            repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                        )
                        .onAppear {
                            scrollTrig.secondPositionIndexB = 0
                        }
                        .onChange(of: scrollTrig.secondPositionIndexA) {
                            scrollTrig.secondPositionTime = scrollTrig.secondPositionIndexA + 1
                            scrollTrig.updateDateFromIndices()
                        }
                       
                       
                        
                    } else if scrollTrig.firstPositionIndex == 1 {
            
                        InfiniteScrollView(
                            currentIndex: $scrollTrig.secondPositionIndexB, targetIndex: $scrollTrig.targetIndexForSecondB,
                            items: scrollTrig.secondPositionNumbersB.map {
                                Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                            },
                            scrollViewID: 3, // Unique ID for each ScrollView
                            height: itemHeight,
                            width: itemWidth,
                            spacing: itemSpacing,
                            itemsCount: scrollTrig.secondPositionNumbersB.count,
                            repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                        )
                        .onAppear {
                            scrollTrig.secondPositionIndexA = 0
                        }
                        .onChange(of: scrollTrig.secondPositionIndexB) {
                            scrollTrig.secondPositionTime = scrollTrig.secondPositionIndexB
                            scrollTrig.updateDateFromIndices()
                        }
                    }
                }
                
                // Add logic for onChange if needed
                
                
                
                HStack(spacing: 0) {
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.thirdPositionIndex, targetIndex: $scrollTrig.targetIndexForThird,
                        items: scrollTrig.thirdPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                        },
                        scrollViewID: 4, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.thirdPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .onChange(of: scrollTrig.thirdPositionIndex) {
                        scrollTrig.thirdPositionTime = scrollTrig.thirdPositionIndex

                        scrollTrig.updateDateFromIndices()
                    }
                    
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.fourthPositionIndex, targetIndex: $scrollTrig.targetIndexForFourth,
                        items: scrollTrig.fourthPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                        },
                        scrollViewID: 5, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.fourthPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .onChange(of: scrollTrig.fourthPositionIndex) {
                        scrollTrig.fourthPositionTime = scrollTrig.fourthPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                }
                .padding(.leading, 25)
                Spacer()
            }
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            .padding(.trailing, 35)
           
            
//            Text(String(describing: scrollTrig.froopStartTime))
//                .font(.system(size: 24))
//                .fontWeight(.light)
//                .foregroundColor(.black)
//                .offset(y: -150)
//            HStack {
//                Text(String(describing: scrollTrig.firstPositionIndex))
//                    .offset(y: -100)
//                    .font(.system(size: 24))
//                VStack {
//                    Text(String(describing: scrollTrig.secondPositionIndexA))
//                        .offset(y: -100)
//                        .font(.system(size: 24))
//                       
//                    Text(String(describing: scrollTrig.secondPositionIndexB))
//                        .offset(y: -100)
//                        .font(.system(size: 24))
//                }
//                    Text(String(describing: scrollTrig.thirdPositionIndex))
//                        .offset(y: -100)
//                        .font(.system(size: 24))
//                    Text(String(describing: scrollTrig.fourthPositionIndex))
//                        .offset(y: -100)
//                        .font(.system(size: 24))
//                
//            }
//            HStack {
//                Text(String(describing: scrollTrig.firstPositionTime))
//                    .offset(y: 100)
//                    .font(.system(size: 24))
//                Text(String(describing: scrollTrig.secondPositionTime))
//                    .offset(y: 100)
//                    .font(.system(size: 24))
//                Text(String(describing: scrollTrig.thirdPositionTime))
//                    .offset(y: 100)
//                    .font(.system(size: 24))
//                Text(String(describing: scrollTrig.fourthPositionTime))
//                    .offset(y: 100)
//                    .font(.system(size: 24))
//            }
            HStack {
                Spacer()
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(scrollTrig.amPm ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
                            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                        Text("AM")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .fontWeight(scrollTrig.amPm ? .semibold : .light)
                    }
                    .onTapGesture {
                        if scrollTrig.amPm == false {
                            scrollTrig.amPm.toggle()
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(scrollTrig.amPm ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 249/255, green: 0/255, blue: 98/255))                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
                            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                        Text("PM")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .fontWeight(scrollTrig.amPm ? .light : .semibold)
                    }
                    .onTapGesture {
                        if scrollTrig.amPm == true {
                            scrollTrig.amPm.toggle()
                        }
                    }
                }
            }
            .padding(.trailing, 5)
            
            
            Text(":")
                .font(.system(size: 75 ))
                .fontWeight(.light)
                .foregroundColor(.black)
                .offset(x: -16)
                .offset(y: -5)
                .frame(width: 20, height: 110)
                .padding(.leading, 1)
                .padding(.trailing, 1)
                .shadow(color: Color.black.opacity(0.5), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(1), radius: 7, x: -4, y: -4)
                .onTapGesture {
                    scrollTrig.updateDateFromIndices()
                }
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
    
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 180)
//                .foregroundColor(Color.offWhite)
                .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            HStack {
                Text("DURATION")
                    .frame(width: 110)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 80/255, green: 80/255, blue: 110/255))
                    .padding(.leading, 10)
                    .offset(y: -100)
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
            .offset(y: -70)
            .padding(.leading, 30)
            .padding(.trailing, 30)

            Rectangle()
                .frame(height: 110)
//                .foregroundColor(Color.offWhite)
                .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.fifthPositionIndex, 
                        targetIndex: $scrollTrig.targetIndexForFifth,
                        items: scrollTrig.fifthPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255)) },
                        scrollViewID: 5, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.fifthPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .onChange(of: scrollTrig.fifthPositionIndex) {
                        scrollTrig.fifthPositionTime = scrollTrig.fifthPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                   
                    Spacer()
                    InfiniteScrollView(
                        currentIndex: $scrollTrig.sixthPositionIndex, targetIndex: $scrollTrig.targetIndexForSixth,
                        items: scrollTrig.sixthPositionNumbers.map {
                            Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                        },
                        scrollViewID: 6, // Unique ID for each ScrollView
                        height: itemHeight,
                        width: itemWidth,
                        spacing: itemSpacing,
                        itemsCount: scrollTrig.sixthPositionNumbers.count,
                        repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .onChange(of: scrollTrig.sixthPositionIndex) {
                        scrollTrig.sixthPositionTime = scrollTrig.sixthPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                    Spacer()
                    InfiniteScrollView(
                            currentIndex: $scrollTrig.seventhPositionIndex, targetIndex: $scrollTrig.targetIndexForSeventh,
                            items: scrollTrig.seventhPositionNumbers.map {
                                Item(number: $0, color: $0 % 2 == 0 ? Color(red: 25/255, green: 25/255, blue: 85/255) : Color(red: 25/255, green: 25/255, blue: 85/255))
                            },
                            scrollViewID: 7, // Unique ID for each ScrollView
                            height: itemHeight,
                            width: itemWidth,
                            spacing: itemSpacing,
                            itemsCount: scrollTrig.seventhPositionNumbers.count,
                            repeatingCount: calculateRepeatingCount(height: itemHeight, scrollViewWidth: scrollViewWidth)
                    )
                    .onChange(of: scrollTrig.seventhPositionIndex) {
                        scrollTrig.seventhPositionTime = scrollTrig.seventhPositionIndex
                        scrollTrig.updateDateFromIndices()
                    }
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                // Add logic for onChange if needed
            }
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
            .padding(.horizontal)
           
//            Text(String(describing: scrollTrig.froopEndTime))
//                .font(.system(size: 24))
//                .fontWeight(.light)
//                .foregroundColor(.black)
//                .offset(y: -180)
//            HStack {
//                Text(String(describing: scrollTrig.fifthPositionIndex))
//                    .offset(y: -150)
//                    .font(.system(size: 24))
//
//                    Text(String(describing: scrollTrig.sixthPositionIndex))
//                        .offset(y: -150)
//                        .font(.system(size: 24))
//                       
//                    Text(String(describing: scrollTrig.seventhPositionIndex))
//                        .offset(y: -150)
//                        .font(.system(size: 24))
//            }
//            HStack {
//                Text(String(describing: scrollTrig.fifthPositionTime))
//                    .offset(y: 150)
//                    .font(.system(size: 24))
//                Text(String(describing: scrollTrig.sixthPositionTime))
//                    .offset(y: 150)
//                    .font(.system(size: 24))
//                Text(String(describing: scrollTrig.seventhPositionTime))
//                    .offset(y: 150)
//                    .font(.system(size: 24))
//
//            }
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
    @Published var froopEndTime: Date = Date()

    
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
    
    @Published var firstPositionNumbers: [Int] = [0, 1]
    @Published var secondPositionNumbersA: [Int] = Array(0...8)
    @Published var secondPositionNumbersB: [Int] = [0, 1, 2]
    @Published var thirdPositionNumbers: [Int] = Array(0...5)
    @Published var fourthPositionNumbers: [Int] = Array(0...9)
    @Published var fifthPositionNumbers: [Int] = Array(0...30)
    @Published var sixthPositionNumbers: [Int] = Array(0...23)
    @Published var seventhPositionNumbers: [Int] = Array(0...59)

    
    
//    @Published var amPm: Bool = false
    
    
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

//            let firstIndex = hourIndex / 10
//            let secondIndex = hourIndex % 10
//            let thirdIndex = minute / 10
//            let fourthIndex = minute % 10

            return (hourIndex, minute, isAM)
        }
        set {
            let calendar = Calendar.current
            let hourIn24 = newValue.isAM ? newValue.hour : (newValue.hour == 12 ? 12 : newValue.hour + 12)
            let newDate = calendar.date(bySettingHour: hourIn24, minute: newValue.minute, second: 0, of: froopStartTime) ?? froopStartTime

            froopStartTime = newDate
//            firstPositionIndex = newValue.hour / 10
//            secondPositionIndexA = newValue.hour % 10
//            secondPositionIndexB = newValue.hour % 10
//            thirdPositionIndex = newValue.minute / 10
//            fourthPositionIndex = newValue.minute % 10
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
          let minutesToAdd = seventhPositionTime

          if let newEndTime = calendar.date(byAdding: .day, value: daysToAdd, to: froopStartTime) {
              froopEndTime = calendar.date(byAdding: .hour, value: hoursToAdd, to: newEndTime)!
              froopEndTime = calendar.date(byAdding: .minute, value: minutesToAdd, to: froopEndTime)!
          }
      }
    
    func updateDateFromIndices() {
    
       
        var hour: Int
        
        if firstPositionIndex == 0 {
            increment = 1
        } else if firstPositionIndex == 1 {
            increment = 0
        }

        if firstPositionIndex == 0 {
            // When the first digit is 0, directly use the secondPositionIndex.
            // Adjust by 1 because secondPositionIndex array starts from 1 when firstPositionIndex is 0.
            hour = secondPositionIndexA + increment
        } else {
            // When the first digit is not 0, calculate the hour normally.
            hour = firstPositionTime * 10 + secondPositionTime
        }

        let minute = thirdPositionTime * 10 + fourthPositionTime

        // Check and adjust for 12 AM/PM cases
//        if hour == 12 {
//            hour = amPm ? 0 : 12
//        } else if !amPm {
//            hour += 12
//        }

        // Update the froopTime based on the new hour and minute
        self.froopTime = (hour: hour, minute: minute, isAM: amPm)
        print(String(describing: self.froopTime))
        updateFroopEndTime()

    }
    
}


