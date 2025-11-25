import SwiftUI

struct OnboardingView: View {
    @State private var currentView: Int = 0
    @State private var direction: Int = 0
    @State private var isKeyboardShown: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @Binding var ProfileCompletionCurrentPage: Int

    var body: some View {
        ZStack {
            Color.clear
            
            currentOnboardingView
                .transition(.asymmetric(
                    insertion: .move(edge: direction > 0 ? .trailing : .leading),
                    removal: .move(edge: direction > 0 ? .leading : .trailing)
                ))
                .animation(.easeInOut, value: currentView)
        }
    }
    
    @ViewBuilder
    var currentOnboardingView: some View {
        switch currentView {
        case 0:
            OnboardOne(moveToNext: moveToNext)
        case 1:
            OnboardTwo(moveToNext: moveToNext, moveToPrevious: moveToPrevious)

        case 2:
            OnboardThree(moveToNext: moveToNext, moveToPrevious: moveToPrevious)

        case 3:
            OnboardFour(moveToNext: moveToNext, moveToPrevious: moveToPrevious)

        case 4:
            OnboardFive(moveToNext: moveToNext, moveToPrevious: moveToPrevious)

        case 5:
            OnboardSix(moveToPrevious: moveToPrevious, ProfileCompletionCurrentPage: $ProfileCompletionCurrentPage)

        default:
            EmptyView()
        }
    }
    
    func moveToNext() {
        withAnimation {
            direction = 1
            currentView = min(currentView + 1, 5)
        }
    }
    
    func moveToPrevious() {
        withAnimation {
            direction = -1
            currentView = max(currentView - 1, 0)
        }
    }
}

extension AnyTransition {
    static func slideFromEdge(_ edge: Edge, _ direction: Int) -> AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: direction > 0 ? .trailing : .leading),
            removal: .move(edge: direction > 0 ? .leading : .trailing)
        )
    }
}
