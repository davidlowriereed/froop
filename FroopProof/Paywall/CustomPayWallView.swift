//
//  CustomPayWallView.swift
//  FroopProof
//
//  Created by David Reed on 1/25/24.
//

import SwiftUI
import RevenueCatUI
import SDWebImageSwiftUI

struct CustomPayWallView: View {
    @ObservedObject var manager = PayWallManager.shared
    @Binding var model: PaywallModel?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            VStack {
                if let  model, !manager.showDefaultView {
                    // Custom PaywallView
                    CustomView(model: model, size: size, safeArea: safeArea)
                        .offset(y: -20)
                } else {
                    if model == nil && !manager.showDefaultView {
                        // Loading State
                        ProgressView()
                            .frame(width: size.width, height: size.height)
                    }
                    
                    // Ignoring Custom Paywall View and presenting RC default Paywall View
                    if manager.showDefaultView {
                        PaywallView()
                    }
                }
                
                    
            }
            .background(Color.white) // Here you can set the background color
            .frame(width: size.width, height: size.height)
            .edgesIgnoringSafeArea(.all)
            
        }
    }
    /// Custom View
    @ViewBuilder
    func CustomView(model: PaywallModel, size: CGSize, safeArea: EdgeInsets) -> some View {
        ScrollView {
            VStack {
                GeometryReader {
                    let size = $0.size
                    let isSticky = model.stickyHeader
                    let stretchyHeader = model.stretchyHeader
                    let minY = $0.frame(in: .global).minY
                    //Limited Header
                    let limitedHeaderHeight = size.height - (160 + safeArea.top)
                    // Progress
                    let progress = min(max((-minY / size.height), 0), 1)
                    let limitedMinY = -minY > limitedHeaderHeight ? -(minY + limitedHeaderHeight) : 0
                    let stickyHeaderTitle = model.stickyHeaderTitle
                    
                    
                    
                    WebImage(url: URL(string: model.headerImage))
                        .resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .frame(width: size.width, height: size.height + (stretchyHeader ? (minY > 0 ? minY : 0) : 0))
                        .offset(y: 100)
                        .overlay {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .opacity(progress)
                                .overlay(alignment: .bottom) {
                                    Text(stickyHeaderTitle)
                                        .font(.title3.bold())
                                        .foregroundStyle(Color.primary)
                                        .offset(y: 90 - (100 * progress))
                                }
                        }
                        .clipped()
                        .offset(y: isSticky ? (minY > 0 ? -minY : (isSticky ? limitedMinY : 0)) : 0)
                        .overlay(alignment: .center) {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("Save The Memories")
                                        .font(Font.custom("Bradley Hand", size: 42))
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .offset(y: 50)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .frame(width: size.width, height: size.height + (stretchyHeader ? (minY > 0 ? minY : 0) : 0))
                        }
                        .overlay(alignment: .topTrailing) {
                            Button(action: { manager.showIAPView = false/*dismiss()*/ }, label: {
                                Image(systemName: "xmark")
                                    .font(.callout)
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(Color.primary)
                                    .background(.ultraThinMaterial, in: .circle)
                                    .contentShape(.circle)
                                
                            })
                            .padding(.top, safeArea.top + 120)
                            .padding(.trailing, 15)
                            .offset(y: -minY)
                        }
                }
                .frame(height: size.height - (140 + 420 - safeArea.top))
                .zIndex(1000)
                
                VStack(alignment: .leading, spacing: 12, content: {
                    Text(model.title)
                        .font(.largeTitle)
                    
                    Text(model.subTitle)
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    // Ponts View
                    VStack(spacing: 15) {
                        ForEach(model.points) { point in
                            PointView(
                                point: point,
                                allPoints: model.points,
                                size: size
                            )
                        }
                    }
                    .padding(.top, 12)
                    
                    VStack(spacing: 15) {
                        ForEach(model.reviews) { review in
                                ReviewView(
                                    review: review,
                                    allReviews: model.reviews,
                                    size: size
                                )
                        }
                    }
                    .padding(.top, 15)
                })
                .frame(maxWidth: UIScreen.screenWidth, alignment: .leading)
                .padding(15)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .scrollIndicators(.hidden)
        .paywallFooter(condensed: true) { info in
            // completed
        } restoreCompleted: { info in
           // Restored
        }
    }
}

// Point View
fileprivate struct PointView: View {
    @ObservedObject var manager = PayWallManager.shared

    var point: PaywallModel.Point
    // For Calculating Delay with the help index
    var allPoints: [PaywallModel.Point]
    var size: CGSize
    // View Properties
    @State var animateSymbol: Bool = false
    @State var animateContent: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                if animateSymbol {
                    Image(systemName: point.symbol)
                        .font(.title)
                        .foregroundStyle(point.colorValue.gradient)
                        .transition(.scale)
                }
            }
            .frame(width: 35, height: 35)
            
            Text(point.content)
                .font(.callout)
                .foregroundStyle(Color.primary)
                .offset(x: !animateContent ? -size.width : 0)
                .clipped()
                .padding(.leading, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task {
            guard !animateSymbol else { return }
            
            // De;ay
            try? await Task.sleep(for: .seconds(initialDelay))
            withAnimation(.snappy(duration: 0.3)) {
                animateSymbol = true
            }
            
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.easeInOut(duration: 0.25)) {
                animateContent = true
            }
        }
    }
    
    var initialDelay: Double {
        return Double(allPoints.firstIndex(where: { $0.id == point.id }) ?? 0) * 0.4
    }
}

// Review View
fileprivate struct ReviewView: View {
    @ObservedObject var manager = PayWallManager.shared

    var review: PaywallModel.Review
    var allReviews: [PaywallModel.Review]
    var size: CGSize
    // View Properties
    @State var animateReview: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 6, content: {
            Text(review.name)
                .font(.caption)
                .foregroundStyle(.gray)
            
            // Rating View
            RatingView(review.rating)
            
            Text(review.content)
                .font(.callout)
                .textScale(.secondary)
                .foregroundStyle(Color.primary)
            
        })
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        .padding(positionEdge, 35)
        .frame(maxWidth: .infinity, alignment: positionEdge == .leading ? .trailing : .leading)
        .offset(x: animateReview ? 0 : (positionEdge == .leading ? size.width : -size.width))
        .overlay {
            GeometryReader {
                let minY = $0.frame(in: .global).minY
                
                Color.clear
                    .onChange(of: minY) { oldValue, newValue in
                        if newValue < (size.height - 140) && !animateReview {
                            withAnimation(.smooth(duration: 0.45)) {
                                animateReview = true
                            }
                        }
                    }
            }
        }
        .onAppear {
            if isFirstReview {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.smooth(duration: 0.45)) {
                        animateReview = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func RatingView(_ rating: Int) -> some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundStyle(rating >= index ? .yellow : .gray)
            }
        }
    }
    
    var positionEdge: Edge.Set {
        let index = allReviews.firstIndex(where: { $0.id == review.id }) ?? 0
        
        return index % 2 == 0 ? .leading : .trailing
    }
    
    var delay: Double {
        // Set the delay duration here. For example, 2 seconds.
        return 2.0
    }
    
    var isFirstReview: Bool {
        return allReviews.firstIndex(where: { $0.id == review.id }) == 0
    }
}

