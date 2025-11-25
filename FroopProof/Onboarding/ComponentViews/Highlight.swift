// Highlight.swift
// FroopProof
//
// Created by David Reed on 5/21/24.

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum OnboardingViewType {
    case home
    case friends
    case profile
    case createFroopType
    case createFroopLocation
    case createFroopDate
    case createFroopTime
    case createFroopSummary
    case manageFroop
    case froopOpenCard
    case froopDetails
    case froopGlobalChat
    case none
}

/// Highlight View Properties
struct Highlight: Identifiable, Equatable {
    var id: UUID = .init()
    var order: Int
    var anchor: Anchor<CGRect>
    var title: String
    var subTitle: String
    var cornerRadius: CGFloat
    var style: RoundedCornerStyle = .continuous
    var scale: CGFloat = 1

    static func ==(lhs: Highlight, rhs: Highlight) -> Bool {
        return lhs.id == rhs.id &&
               lhs.order == rhs.order &&
               lhs.title == rhs.title &&
               lhs.subTitle == rhs.subTitle &&
               lhs.cornerRadius == rhs.cornerRadius &&
               lhs.style == rhs.style &&
               lhs.scale == rhs.scale
    }
}


/// Custom Show Case View Extensions
extension View {
    @ViewBuilder
    func showCase(order: Int, title: String, subTitle: String, cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous, scale: CGFloat = 1) -> some View {
        self
            .anchorPreference(key: HighlightAnchorKey.self, value: .bounds) { anchor in
                let highlight = Highlight(order: order, anchor: anchor, title: title, subTitle: subTitle, cornerRadius: cornerRadius, style: style, scale: scale)
                print("🔍 Storing highlight with order \(order): \(title)")
                return [order: highlight]
            }
            .onAppear {
                print("🔍 View with showCase order \(order) appeared")
            }
    }
}

struct ActiveShowCaseRootKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var activeShowCaseRoot: String? {
        get { self[ActiveShowCaseRootKey.self] }
        set { self[ActiveShowCaseRootKey.self] = newValue }
    }
}

/// ShowCase Root View Modifier

struct ShowCaseRoot: ViewModifier {
    @ObservedObject var appStateManager = AppStateManager.shared
    var showHighlights: Bool
    var onFinished: () -> ()
    @State var firstTime: Bool = true
    @State private var isAnimating: Bool = false
    @ObservedObject var onboardingData = OnboardingData.shared
    @State private var highlightOrder: [Int] = []
    @State private var currentHighlight: Int = 0
    @State private var showView: Bool = true
    @State private var showTitle: Bool = false
    @Namespace private var animation
    @Environment(\.activeShowCaseRoot) private var activeShowCaseRoot: String?
    var identifier: String

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(HighlightAnchorKey.self) { value in
                highlightOrder = Array(value.keys).sorted()
                print("🥎 Highlight Order after preference change: \(highlightOrder)")
            }
            .overlayPreferenceValue(HighlightAnchorKey.self) { preferences in
                if activeShowCaseRoot == identifier,
                   highlightOrder.indices.contains(currentHighlight),
                   showHighlights, showView {
                    if let highlight = preferences[highlightOrder[currentHighlight]] {
                        HighlightView(highlight)
                            .onAppear {
                                print("🥎💿 1 Evaluating overlayPreferenceValue")
                                print("🥎💿 activeShowCaseRoot: \(String(describing: activeShowCaseRoot)), identifier: \(identifier)")
                                print("🥎💿 Displaying Highlight: \(highlight)")
                            }
                    } else {
                        EmptyView()
                            .onAppear {
                                print("🥎💿 2 Evaluating overlayPreferenceValue")
                                print("🥎💿 activeShowCaseRoot: \(String(describing: activeShowCaseRoot)), identifier: \(identifier)")
                                print("🥎💿 No Highlight Found for current index")
                            }
                    }
                } else {
                    EmptyView()
                        .onAppear {
                            print("🥎💿 3 Evaluating overlayPreferenceValue")
                            print("🥎💿 activeShowCaseRoot: \(String(describing: activeShowCaseRoot)), identifier: \(identifier)")
                            print("🥎💿 Conditions not met for displaying highlight")
                        }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    currentHighlight = 0
                    showTitle = true
                }
                print("🥎 Conditions not met for displaying highlight")
                print("🥎 activeShowCaseRoot: \(String(describing: activeShowCaseRoot))")
                print("🥎 identifier: \(identifier)")
                print("🥎 showHighlights: \(showHighlights)")
                print("🥎 showView: \(showView)")
                print("🥎 currentHighlight: \(currentHighlight)")
                print("🥎 highlightOrder: \(highlightOrder)")

            }
    }
    
    @ViewBuilder
    func HighlightView(_ highlight: Highlight) -> some View {
        GeometryReader { proxy in
            let highlightRect = proxy[highlight.anchor]
            
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .opacity(0.8)
                    .ignoresSafeArea()
                    .onAppear {
                        print("🎯 HighlightView ShowCaseRoot Dark overlay appeared")
                    }
                
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showView = false
                        }
                        appStateManager.showFace = false
                        appStateManager.showFaceText = false
                        Task {
                            await onboardingData.updateOnboarding(for: appStateManager.currentViewID, to: true)
                        }
                        onFinished()
                    }) {
                        VStack (spacing: 15) {
                            Text("Remaining Insights: \(String(describing: highlightOrder.count - currentHighlight))")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .fontWeight(.thin)
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .opacity(0.85)
                                    .frame(width: 200, height: 40)
                                Text("Skip Overview")
                                    .font(.system(size: 24))
                                    .fontWeight(.thin)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            }
                            .padding(.bottom, 100)
                        }
                    }
                    .opacity(currentHighlight == (highlightOrder.count - 1) ? 0 : 1)
                    .onChange(of: appStateManager.currentViewID) { oldValue, newValue in
                        print("🥎🥎 Old Value: \(oldValue)")
                        print("🥎🥎 New Value: \(newValue)")
                    }
                    
                }
            }
            .reverseMask {
                Rectangle()
                    .matchedGeometryEffect(id: "HIGHLIGHTSHAPE", in: animation)
                    .frame(width: highlightRect.width, height: highlightRect.height)
                    .clipShape(RoundedRectangle(cornerRadius: highlight.cornerRadius, style: highlight.style))
                    .scaleEffect(highlight.scale)
                    .offset(x: highlightRect.minX - 2.5, y: highlightRect.minY - 2.5)
            }
            .onTapGesture {
                
                if currentHighlight == highlightOrder.count - 2 {
//                    appStateManager.showFace = true
                    appStateManager.showFaceText = false
                } else {
//                    appStateManager.showFace = false
                    appStateManager.showFaceText = false
                }
                
                if !isAnimating {
                    isAnimating = true
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showTitle = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        if currentHighlight >= highlightOrder.count - 1 {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showView = false
                                appStateManager.showFace = false
                                appStateManager.showFaceText = false
                            }
                            Task {
                                await onboardingData.updateOnboarding(for: appStateManager.currentViewID, to: true)
                            }
                            onFinished()
                        } else {
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.7)) {
                                currentHighlight += 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showTitle = true
                                isAnimating = false
                            }
                        }
                    }
                }
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: highlightRect.width + 20, height: highlightRect.height + 20)
                .clipShape(RoundedRectangle(cornerRadius: highlight.cornerRadius, style: highlight.style))
                .popover(isPresented: $showTitle) {
                    Text(highlight.title)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                        .padding(.horizontal, 10)
                        .foregroundColor(.black)
                        .presentationCompactAdaptation(.popover)
                        .interactiveDismissDisabled()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showTitle = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                if currentHighlight >= highlightOrder.count - 1 {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showView = false
                                    }
                                    Task {
                                        await onboardingData.updateOnboarding(for: appStateManager.currentViewID, to: true)
                                    }
                                    onFinished()
                                } else {
                                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.7)) {
                                        currentHighlight += 1
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        showTitle = true
                                    }
                                }
                            }
                        }
                }
                .scaleEffect(highlight.scale)
                .offset(x: highlightRect.minX - 10, y: highlightRect.minY - 10)
        }
    }
}

/// Anchor Key
fileprivate struct HighlightAnchorKey: PreferenceKey {
    static var defaultValue: [Int: Highlight] = [:]

    static func reduce(value: inout [Int : Highlight], nextValue: () -> [Int : Highlight]) {
        value.merge(nextValue()) { $1 }
//        print("Reducing preferences with value: \(value)")
    }
}

/// Custom View Modifier for Inner/Reverse Mask
extension View {
    @ViewBuilder
    func reverseMask<Content: View>(alignment: Alignment = .topLeading, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .mask {
                Rectangle()
                    .overlay(alignment: .topLeading) {
                        content()
                            .blendMode(.destinationOut)
                    }
            }
    }
}
