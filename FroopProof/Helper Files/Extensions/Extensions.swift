//
//  Extensions+View.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import UIKit
import Foundation
import MapKit
import Combine


extension LocationManager {
    func getCurrentAddress(completion: @escaping (CLPlacemark?) -> Void) {
        guard let currentLocation = self.currentLocation else {
            completion(nil)
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error)")
                completion(nil)
                return
            }
            
            completion(placemarks?.first)
        }
    }
}

public extension Int {
    func daySuffix() -> String {
        switch self {
        case 11...13: return "th"
        default:
            switch self % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
}

extension String {
    
    var formattedPhoneNumber: String {
        let cleanedPhoneNumber = self.filter { "0"..."9" ~= $0 }
        let formattedPhoneNumber: String
        
        if cleanedPhoneNumber.count == 10 {
            let startIndex1 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 3)
            let endIndex1 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 5)
            let startIndex2 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 6)
            let endIndex2 = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 9)
            
            let part1 = cleanedPhoneNumber.prefix(3)
            let part2 = cleanedPhoneNumber[startIndex1...endIndex1]
            let part3 = cleanedPhoneNumber[startIndex2...endIndex2]
            
            formattedPhoneNumber = "(\(part1)) \(part2)-\(part3)"
        } else {
            formattedPhoneNumber = self
        }
        
        return formattedPhoneNumber
    }
    
    var formattedPhoneNumberC: String {
        let cleanedPhoneNumber = self.filter { "0"..."9" ~= $0 }
        
        // Assuming that the country code is only 1 digit. Adjust the `countryCodeLength` as needed.
        let countryCodeLength = 1
        let startIndex = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: countryCodeLength)
        let phoneNumberWithoutCountryCode = String(cleanedPhoneNumber[startIndex...])
        
        let formattedPhoneNumber: String
        
        if phoneNumberWithoutCountryCode.count == 10 {
            let startIndex1 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 3)
            let endIndex1 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 5)
            let startIndex2 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 6)
            let endIndex2 = phoneNumberWithoutCountryCode.index(phoneNumberWithoutCountryCode.startIndex, offsetBy: 9)
            
            let part1 = phoneNumberWithoutCountryCode.prefix(3)
            let part2 = phoneNumberWithoutCountryCode[startIndex1...endIndex1]
            let part3 = phoneNumberWithoutCountryCode[startIndex2...endIndex2]
            
            formattedPhoneNumber = "(\(part1)) \(part2)-\(part3)"
        } else {
            formattedPhoneNumber = self
        }
        
        return formattedPhoneNumber
    }
}
extension Date {
    
    func diff(numDays: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: numDays, to: self)!
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
extension Double {
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    func toCurrency() -> String {
        return currencyFormatter.string(for: self) ?? ""
    }
    
}

extension Array {
    subscript(safe index: Int, file: String = #file, function: String = #function, line: Int = #line) -> Element? {
        if index >= 0 && index < count {
            return self[index]
        } else {
            // Log the details of the failed access attempt
            print("Attempted to access index \(index) of array, but index is out of range. Array count: \(count). Access was attempted from file: \(file), function: \(function), line: \(line).")
            return nil
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow})
            .first?.endEditing(force)
    }
}
extension UIApplication{
    func closeKeyboard(){
        PrintControl.shared.printExtensions("-Application_utility: Function: closeKeyboard firing")
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Root Controller
    func rootController()->UIViewController{
        PrintControl.shared.printExtensions("-Application_utility: Function: rootController firing")
        guard let window = connectedScenes.first as? UIWindowScene else{
            fatalError("Unable to get UIWindowScene")
        }
        guard let viewcontroller = window.windows.last?.rootViewController else{
            fatalError("Unable to get rootViewController")
        }
        
        return viewcontroller
    }
}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UIApplication {
    func inAppNotification<Content: View>(adaptForDynamicIsland: Bool = false, timeout: CGFloat = 5, swipeToClose: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: {
            $0.tag == 0320 }) {
            /// Frame and SafeArea Values
            let frame = activeWindow.frame
            let safeArea = activeWindow.safeAreaInsets
            
            var tag: Int = 1009
            let checkForDynamicIsland = adaptForDynamicIsland && safeArea.top >= 51
            
            if let previousTag = UserDefaults.standard.value(forKey: "in_app_notification_tag") as? Int {
                tag = previousTag + 1
            }
            
            UserDefaults.standard.setValue(tag, forKey: "in_app_notification_tag")
            
            /// Changing Status into Black to blend with Dynamic Island
            if checkForDynamicIsland {
                if let controller = activeWindow.rootViewController as?
                    StatusBarBasedController {
                    controller.statusBarStyle = .darkContent
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
            
            /// Creating UIView from SwiftUIView using UIHosting Configuration
            let config = UIHostingConfiguration {
                AnimatedNotificationView(
                    content: content(),
                    safeArea: safeArea,
                    tag: tag,
                    adaptForDynamicIsland: adaptForDynamicIsland,
                    timeout: timeout,
                    swipeToClose: swipeToClose
                )
                /// Maximum Notification Height will be 120
                .frame(width: frame.width - (checkForDynamicIsland ? 20 : 30), height: 120, alignment: .top)
                .contentShape(.rect)
            }
            /// Creating UIView
            let view = config.makeContentView()
            view.tag = tag
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if let rootView = activeWindow.rootViewController?.view {
                /// Adding View to the Window
                rootView.addSubview(view)
                
                /// Layout Constraints
                view.centerXAnchor.constraint(equalTo: activeWindow.centerXAnchor).isActive = true
                view.centerYAnchor.constraint(equalTo: activeWindow.centerYAnchor, constant: (-(frame.height - safeArea.top) / 2) + (checkForDynamicIsland ? 11 : safeArea.top)).isActive = true
                
            }
        }
    }
}

extension UIDevice {
    func checkIfHasDynamicIsland() -> Bool {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            let nameSimulator = simulatorModelIdentifier
            return nameSimulator == "iPhone15,2" || nameSimulator == "iPhone15,3" ? true : false
        }
        
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let name =  String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return name == "iPhone15,2" || name == "iPhone15,3" ? true : false
    }
}

fileprivate struct AnimatedNotificationView<Content: View>: View {
    var content: Content
    var safeArea: UIEdgeInsets
    var tag: Int
    var adaptForDynamicIsland: Bool
    var timeout: CGFloat
    var swipeToClose: Bool
    /// View Properties
    @State private var animateNotification: Bool = false
    
    var body: some View {
        content
            .blur(radius: animateNotification ? 0 : 10)
            .disabled(!animateNotification)
            .mask {
                
                if adaptForDynamicIsland {
                    /// Size Based Bapsule
                    GeometryReader(content: { geometry in
                        let size = geometry.size
                        let radius = size.height / 2
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                    })
                } else {
                    Rectangle()
                }
            }
            /// Scaling Animation only for Dynamic Island Notification
            .scaleEffect(adaptForDynamicIsland ? (animateNotification ? 1 : 0.01) : 1, anchor: .init(x: 0.5, y: 0.01))
        
            /// Offset Animation for Non Dynamic Island Notifications
            .offset(y: offsetY)
            .gesture(
            DragGesture()
                .onEnded({ value in
                    if -value.translation.height > 50 && swipeToClose {
                        withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                            animateNotification = false
                        } completion: {
                            removerNotificationViewFromWindow()
                        }
                    }
                })
            )
            .onAppear(perform: {
                Task {
                    guard !animateNotification else { return }
                    withAnimation(.smooth) {
                        animateNotification = true
                    }
                    /// Timeout for Notificaiton
                    try await Task.sleep(for: .seconds(timeout < 1 ? 1 : timeout))
                    
                    guard animateNotification else { return }
                    
                    withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                        animateNotification = false
                    } completion: {
                        removerNotificationViewFromWindow()
                    }
                }
                
            })
    }
    
    var offsetY: CGFloat {
        if adaptForDynamicIsland {
            return 0
        }
        
        return animateNotification ? 10 : -(safeArea.top + 130)
    }
    
    func removerNotificationViewFromWindow() {
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
            if let view = activeWindow.viewWithTag(tag) {
                PrintControl.shared.printExtensions("Removed View with \(tag)")
                view.removeFromSuperview()
                
                /// Resetting Once All the notifications are removed
                if let controller = activeWindow.rootViewController as?
                    StatusBarBasedController, controller.view.subviews.isEmpty {
                    controller.statusBarStyle = .default
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
    
}


extension Map {

    func metersPerPixel(at latitude: Double, altitude: Double) -> Double {
        // Earth's radius at given latitude
        let earthRadiusMeters = 6378137.0 * cos(latitude * .pi / 180.0)
        
        // The width of each pixel in meters at the given latitude and altitude
        let metersPerPixel = cos(latitude * .pi / 180.0) * 2 * .pi * earthRadiusMeters / (256 * pow(2, altitude))
        
        return metersPerPixel
    }

    func convertPointToCoordinate(from point: CGPoint, in region: MKCoordinateRegion, withAltitude altitude: Double, screenSize: CGSize) -> CLLocationCoordinate2D {
        let metersPerPixel = self.metersPerPixel(at: region.center.latitude, altitude: altitude)
        
        let centerScreenX = screenSize.width / 2
        let centerScreenY = screenSize.height / 2
        
        let offsetX = Double(point.x - centerScreenX) * metersPerPixel
        let offsetY = Double(point.y - centerScreenY) * metersPerPixel
        
        // Earth's circumference in meters at given latitude
        let earthCircumference = 2 * .pi * 6378137.0 * cos(region.center.latitude * .pi / 180.0)
        
        let offsetLongitude = (offsetX / earthCircumference) * 360.0
        let offsetLatitude = (offsetY / 111000) // Approximate meters per degree latitude
        
        return CLLocationCoordinate2D(
            latitude: region.center.latitude + offsetLatitude,
            longitude: region.center.longitude + offsetLongitude
        )
    }

}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

extension View{
    //MARK: Custom View Modifier
    func blurredSheet<Content: View>(_ style: AnyShapeStyle, show: Binding<Bool>, onDismiss: @escaping ()->(), @ViewBuilder content: @escaping ()->Content)-> some View{
        self
            .fullScreenCover(isPresented: show, onDismiss: onDismiss) {
                content()
                    .background(RemovebackgroundColor())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Rectangle()
                            .fill(style)
                            .ignoresSafeArea(.container, edges: .all)
                    }
            }
    }
}

extension View {
    
    func myMoveText(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    //let minX = rect.minX
                    let midY = rect.midY
                    // let midTarget = 0
                    // let delta = rect.width - 125
                    // let adjustededX = rect.width - delta
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 0.85) / 2
                    // let halfScaledTextWidth = (rect.width * 0.85) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
                    //                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    //let scaledImageWidth = profileImageWidth * 0.3
                    // let halfScaledImageHeight = scaledImageHeight / 2
                    // let halfScaledImageWidth = scaledImageWidth / 2
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - ((minimumHeaderHeight / 3) - (halfScaledTextHeight * 2) - vStackSpacing - scaledImageHeight))
                    //let resizedOffsetX = (minX - 10)
                    
                    self
                        .scaleEffect(1 - (progress * 0.15))
                        .offset(y: -resizedOffsetY * progress)
                    //.offset(x: -resizedOffsetX * progress)
                        .onAppear {
                            printProperties(midY: midY,
                                            minimumHeaderHeight: minimumHeaderHeight,
                                            halfScaledTextHeight: halfScaledTextHeight,
                                            vStackSpacing: vStackSpacing,
                                            scaledImageHeight: scaledImageHeight,
                                            resizedOffsetY: resizedOffsetY)
                        }
                }
                
            }
        
    }
    
    private func printProperties(midY: CGFloat, minimumHeaderHeight: CGFloat, halfScaledTextHeight: CGFloat, vStackSpacing: CGFloat, scaledImageHeight: CGFloat, resizedOffsetY: CGFloat) {
        PrintControl.shared.printExtensions("midY: \(midY)")
        PrintControl.shared.printExtensions("minimumHeaderHeight: \(minimumHeaderHeight)")
        PrintControl.shared.printExtensions("halfScaledTextHeight: \(halfScaledTextHeight)")
        PrintControl.shared.printExtensions("vStackSpacing: \(vStackSpacing)")
        PrintControl.shared.printExtensions("scaledImageHeight: \(scaledImageHeight)")
        PrintControl.shared.printExtensions("resizedOffsetY: \(resizedOffsetY)")
    }
    
    func myMoveSymbols(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    let minX = rect.minX
                    let midY = rect.midY
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 1) / 2
                    // let halfScaledTextWidth = (rect.width * 1) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
                    //                let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    //let scaledImageWidth = profileImageWidth * 0.3
                    // let halfScaledImageHeight = scaledImageHeight / 2
                    // let halfScaledImageWidth = scaledImageWidth / 2
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - ((minimumHeaderHeight / 2) - halfScaledTextHeight - vStackSpacing - scaledImageHeight))
                    let resizedOffsetX = (minX)
                    
                    self
                        .scaleEffect(1 - (progress * 1))
                        .offset(y: -resizedOffsetY * progress / 2)
                        .offset(x: -resizedOffsetX * progress)
                        .opacity(1 - progress)
                        .onAppear {
                            printProperties(midY: midY,
                                            minimumHeaderHeight: minimumHeaderHeight,
                                            halfScaledTextHeight: halfScaledTextHeight,
                                            vStackSpacing: vStackSpacing,
                                            scaledImageHeight: scaledImageHeight,
                                            resizedOffsetY: resizedOffsetY)
                        }
                }
            }
    }
    
    func myMoveMenu(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    //let minX = rect.minX
                    //                    let midX = rect.midX
                    let midY = rect.midY
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 1) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
                    //                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    //                     let scaledImageWidth = profileImageWidth * 0.3
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - ((minimumHeaderHeight / 2) - (halfScaledTextHeight * 2) - vStackSpacing - scaledImageHeight + 65))
                    //let resizedOffsetX = (minX - 80)
                    
                    self
                        .scaleEffect(1)
                        .offset(y: -resizedOffsetY * progress / 2)
                    //.offset(x: -resizedOffsetX * progress)
                        .onAppear {
                            printProperties(midY: midY,
                                            minimumHeaderHeight: minimumHeaderHeight,
                                            halfScaledTextHeight: halfScaledTextHeight,
                                            vStackSpacing: vStackSpacing,
                                            scaledImageHeight: scaledImageHeight,
                                            resizedOffsetY: resizedOffsetY)
                        }
                }
            }
    }
    
    func myMoveCounter(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    let minX = rect.minX
                    //                    let midX = rect.midX
                    let midY = rect.midY
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 1) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
                    //                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    //                     let scaledImageWidth = profileImageWidth * 0.3
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - ((minimumHeaderHeight / 2) - (halfScaledTextHeight * 2) - vStackSpacing - scaledImageHeight + 32))
                    let resizedOffsetX = (minX - 150)
                    
                    self
                        .scaleEffect(1)
                        .offset(y: -resizedOffsetY * progress / 2)
                        .offset(x: -resizedOffsetX * progress)
                        .onAppear {
                            printProperties(midY: midY,
                                            minimumHeaderHeight: minimumHeaderHeight,
                                            halfScaledTextHeight: halfScaledTextHeight,
                                            vStackSpacing: vStackSpacing,
                                            scaledImageHeight: scaledImageHeight,
                                            resizedOffsetY: resizedOffsetY)
                        }
                }
            }
    }
    
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

extension UIView {
    func makeFirstResponder(_ view: UIView) {
        for subview in subviews {
            if subview.isFirstResponder {
                subview.resignFirstResponder()
            }
            subview.makeFirstResponder(view)
        }
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        } else if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? navigationController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? tabBarController
        } else {
            return self
        }
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
}

extension Text {
    func customTitleText() -> Text {
        PrintControl.shared.printProfile("-TitleView2: Function: customTitleText firing")
        return self
            .foregroundColor(.primary)
            .fontWeight(.light)
            .font(.system(size: 36))
    }
}
extension Text {
    func CcustomTitleText() -> Text {
        self
            .fontWeight(.light)
            .font(.system(size: 36))
    }
}

//extension Color {
//    init(uiColor: UIColor) {
//        self.init(red: Double(uiColor.cgColor.components?[0] ?? 0),
//                  green: Double(uiColor.cgColor.components?[1] ?? 0),
//                  blue: Double(uiColor.cgColor.components?[2] ?? 0),
//                  opacity: Double(uiColor.cgColor.components?[3] ?? 1))
//    }
//}

extension Color {
    static var mainColor = Color(UIColor.systemIndigo)
}
extension Color {
    static let theme = ColorTheme()
}
extension Color {
    static var CmainColor = Color(UIColor.systemIndigo)
}
extension Color {
    
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255 )
    
    func luminosity(_ value: Double) -> Color {
        let uiColor = UIColor(self)
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(UIColor(hue: hue, saturation: saturation, brightness: CGFloat(value), alpha: alpha))
    }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}




extension FroopTypeView {

    // Function to check if a froop type has associated topics or subcategories.
    func hasAssociatedTopics(for froopType: FroopType) -> Bool {
        return froopTypeStore.froopTypes.contains(where: { $0.category.contains(froopType.name) })
    }

}

extension FroopHistory {
    func determineFroopStatus() {
        let froopId = self.froop.froopId
        
        if FroopDataListener.shared.myArchivedList.contains(where: { $0.froopId == froopId }) {
            if self.froop.froopCreationTime > self.froop.froopStartTime || self.froop.froopImages.count >= 1 {
                self.froopStatus = .memory
            } else {
                self.froopStatus = .archived
                
            }
        } else if FroopDataListener.shared.myInvitesList.contains(where: { $0.froopId == froopId }) {
            self.froopStatus = .invited
        } else if FroopDataListener.shared.myConfirmedList.contains(where: { $0.froopId == froopId }) {
            self.froopStatus = .confirmed
        } else {
            self.froopStatus = .none
        }
    }

    func textForStatus() -> String {
        switch self.froopStatus {
            case .invited:
                return "Invite Pending"
            case .confirmed:
                return "Confirmed"
            case .declined:
                return "Declined"
            case .archived:
                return "Archived"
            case .memory:
                return "Memory"
            case .none:
                return "Error"
        }
    }
    
    func cardForStatus(openFroop: Binding<Bool>, invitedFriends: [UserData]) -> some View {
        FroopHistoryWrapper(froopHistory: self).cardForStatus(openFroop: openFroop, invitedFriends: invitedFriends)
    }
    
    func colorForStatus() -> Color {
        switch self.froopStatus {
            case .invited:
                return Color(red: 249/255, green: 0/255, blue: 98/255)
            case .confirmed:
                return Color.blue
            case .declined:
                return Color.gray
            case .archived:
                return Color(red: 50/255, green: 46/255, blue: 62/255)
            case .memory:
                return Color(red: 183/255, green: 29/255, blue: 84/255)
            case .none:
                return Color.red
        }
    }
    
}

extension FroopHistoryWrapper {
    func cardForStatus(openFroop: Binding<Bool>, invitedFriends: [UserData]) -> some View {
        switch self.froopStatus {
            case .invited:
                return AnyView(FroopInvitesCardView(openFroop: openFroop, froopHistoryWrapper: self))
            
            case .confirmed:
                return AnyView(FroopConfirmedCardView(openFroop: openFroop, froopHistoryWrapper: self))
            
            case .declined, .archived, .memory:
                return AnyView(FroopArchivedCardView(openFroop: openFroop, froopHistoryWrapper: self))
            
            case .none:
            return AnyView(EmptyView())
        }
    }
}


extension Message: Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(froopId)
        hasher.combine(senderId)
        hasher.combine(receiverId)
        hasher.combine(timestamp)
        hasher.combine(conversationId)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.text == rhs.text &&
        lhs.froopId == rhs.froopId &&
        lhs.senderId == rhs.senderId &&
        lhs.receiverId == rhs.receiverId &&
        lhs.timestamp == rhs.timestamp &&
        lhs.conversationId == rhs.conversationId
    }
}

extension FriendRequest {
    enum CodingKeys: String, CodingKey {
        case fromUserID
        case toUserInfo
        case toUserID
        case status
        case documentID
        case firstName
        case lastName
        case profileImageUrl
        case phoneNumber
        case friendsInCommon // Add profile image URLs to CodingKeys
    }
}

extension FriendListData: Encodable {
    func encode(to encoder: Encoder) throws {
        PrintControl.shared.printInviteFriends("-FriendListData: Function: encode firing")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(froopUserID, forKey: .froopUserID)
        try container.encode(timeZone, forKey: .timeZone)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(profileImageUrl, forKey: .profileImageUrl)
    }
}

extension MKMapRect {
    func reducedRect(_ fraction: CGFloat = 0.35) -> MKMapRect {
        var regionRect = self

        let wPadding = regionRect.size.width * fraction
        let hPadding = regionRect.size.height * fraction
                    
        regionRect.size.width += wPadding
        regionRect.size.height += hPadding
                    
        regionRect.origin.x -= wPadding / 2
        regionRect.origin.y -= hPadding / 2
        
        return regionRect
    }
}

extension NotificationCenter {
    static var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return Publishers.Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

// Publisher to track keyboard height changes
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension MKCoordinateRegion {
    static func defaultRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 29.7, longitude: -95.39), latitudinalMeters: 100, longitudinalMeters: 100)
    }
    
    static var myRegion: MKCoordinateRegion {
        return .init(center: .myLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
    static var myNowRegion: MKCoordinateRegion {
        return .init(center: CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129), latitudinalMeters: 10000000, longitudinalMeters: 10000000)
    }
    
}

extension CLLocationCoordinate2D {
    static var myLocation: CLLocationCoordinate2D {
        return .init(latitude: LocationManager.shared.userLocation?.coordinate.latitude ?? 0.0, longitude: LocationManager.shared.userLocation?.coordinate.longitude ?? 0.0
        )
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D {
    /// Returns the bearing between two coordinates in degrees.
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.radians
        let lon1 = self.longitude.radians
        let lat2 = destination.latitude.radians
        let lon2 = destination.longitude.radians

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let initialBearing = atan2(y, x).toDegrees
        let bearing = (initialBearing + 360).truncatingRemainder(dividingBy: 360)
        return bearing
    }
}

extension View {
    func getRect()-> CGRect {
        return UIScreen.main.bounds
    }
    func safeArea()->UIEdgeInsets {
        let null = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return null
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return null
        }
        return safeArea
    }
}

extension Double {
    var radians: Double {
        return self * .pi / 180.0
    }

    var toDegrees: Double {
        return self * 180.0 / .pi
    }
}

extension FroopMapViewRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        @ObservedObject var froopData = FroopData.shared
        let mapView = MKMapView()
        @ObservedObject var locationManager = LocationManager.shared
        @ObservedObject var navLocationServices = NavLocationServices.shared // @Binding var mapState: MapViewState
        @EnvironmentObject var locationViewModel: LocationSearchViewModel
        
        // MARK: - Properties
        let mapUpdateState: MapUpdateState
        let parent: FroopMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        //var froopLocation: CLLocationCoordinate2D?
        
        //print("updating userLocation FOURTEEN")
        // MARK: - Lifecycle
        
        init(parent: FroopMapViewRepresentable, mapUpdateState: MapUpdateState, froopData: FroopData) {
            self.parent = parent
            self.mapUpdateState = mapUpdateState
            self.froopData = froopData
            
            super.init()
        }
        
        
        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if NavLocationServices.shared.trackUserLocation == false {
                return
            }
            let newCoordinate = userLocation.coordinate
            guard let previousCoordinate = self.userLocationCoordinate else {
                // This is the first location update, so we don't have a previous location to compare with
                self.userLocationCoordinate = newCoordinate
                return
            }
            
            let distance = sqrt(pow(newCoordinate.latitude - previousCoordinate.latitude, 2) + pow(newCoordinate.longitude - previousCoordinate.longitude, 2))
            if distance < 0.00001 { // Adjust this threshold as needed
                // The location hasn't changed significantly, so we ignore this update
                return
            }
            
            // The location has changed significantly, so we process this update
            self.userLocationCoordinate = newCoordinate
            
            PrintControl.shared.printNavLocationServices("Previous Location: \(String(describing: previousCoordinate.latitude)), \(String(describing: previousCoordinate.longitude))")
            PrintControl.shared.printNavLocationServices("New Location: \(newCoordinate.latitude), \(newCoordinate.longitude)")
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            
            PrintControl.shared.printNavLocationServices("updating userLocation TOMMY")
            PrintControl.shared.printNavLocationServices(mapUpdateState.isFunctionEnabled.description)
            self.currentRegion = region
            
            parent.mapView.setRegion(region, animated: false)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            PrintControl.shared.printNavLocationServices("-FroopMapViewRepresentable: Function: mapView2 is firing!")
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        // MARK: - Helpers
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            PrintControl.shared.printNavLocationServices("-FroopMapViewRepresentable: Function: addAndSelectAnnotation is firing!")
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            
            let anno = MKPointAnnotation()
            anno.coordinate = coordinate
            parent.mapView.addAnnotation(anno)
            parent.mapView.selectAnnotation(anno, animated: true)
        }
        
        func calculateDistance(to location: FroopData) -> Double {
            PrintControl.shared.printNavLocationServices("-FroopMapViewRepresentable: Function: calculateDistance is firing!")
            guard let userLocation = locationManager.userLocation else { return 0 }
            let froopData = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            return userLocation.distance(from: froopData)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            PrintControl.shared.printMap("-FroopMapViewRepresentable: Function: configurePolyline is firing!")
            PrintControl.shared.printMap("DAVID - CONFIGURE POLY LINE STARTED")
            
            guard let userCoordinate = LocationManager.shared.userLocation?.coordinate else {
                return
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                guard let route = response?.routes.first else {
                    return
                }
                
                self?.parent.mapView.addOverlay(route.polyline)
                self?.parent.mapState = .polylineAdded
                
                let rect = self?.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
                                                                edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32))
                
                if let rect = rect {
                    self?.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                }
            }
        }
        
        func clearMapViewAndRecenterOnUserLocation() {
            PrintControl.shared.printMap("FroopMapViewRepresentable: Function: clearMapViewAndRecenterOnUserLocation is firing!")
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            PrintControl.shared.printNavLocationServices("updating userLocation NINETEEN")
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: false)
            }
        }
    }
}


extension UserData {
    static func convert(from myData: MyData) -> UserData {
        let userData = UserData()
        userData.data = myData.data
        userData.froopUserID = myData.froopUserID
        userData.timeZone = myData.timeZone
        userData.firstName = myData.firstName
        userData.lastName = myData.lastName
        userData.phoneNumber = myData.phoneNumber
        userData.addressNumber = myData.addressNumber
        userData.addressStreet = myData.addressStreet
        userData.unitName = myData.unitName
        userData.addressCity = myData.addressCity
        userData.addressState = myData.addressState
        userData.addressZip = myData.addressZip
        userData.addressCountry = myData.addressCountry
        userData.profileImageUrl = myData.profileImageUrl
        userData.fcmToken = myData.fcmToken
        userData.badgeCount = myData.badgeCount
        userData.coordinate = myData.coordinate
        return userData
    }
}

extension MyData: CustomStringConvertible {
    var description: String {
        return """
        MyData:
        - firstName: \(firstName)
        - lastName: \(lastName)
        - phoneNumber: \(phoneNumber)
        - addressNumber: \(addressNumber)
        - addressStreet: \(addressStreet)
        - unitName: \(unitName)
        - addressCity: \(addressCity)
        - addressState: \(addressState)
        - addressZip: \(addressZip)
        - addressCountry: \(addressCountry)
        - profileImageUrl: \(profileImageUrl)
        - coordinate: \(coordinate)
        - geoPoint: \(geoPoint)
        """
    }
    
    // Asynchronously fetches the address title and subtitle for the current coordinate
    func fetchAddressTitleAndSubtitle() async -> (title: String?, subtitle: String?) {
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            return (nil, nil)
        }
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            let placemark = placemarks.first
            
            let title = placemark?.name
            let subtitleComponents = [placemark?.locality, placemark?.administrativeArea]
                .compactMap { $0 }
                .joined(separator: ", ")
            
            return (title, subtitleComponents.isEmpty ? nil : subtitleComponents)
        } catch {
            print("Failed to fetch address: \(error)")
            return (nil, nil)
        }
    }
}


// MARK: HelperView
fileprivate struct RemovebackgroundColor: UIViewRepresentable{
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}

extension FroopHistory: CustomStringConvertible {
    var description: String {
        """
        FroopHistory:
        - Froop: \(froop)
        - Host: \(host)
        - Invited Friends: \(invitedFriends)
        - Confirmed Friends: \(confirmedFriends)
        - Declined Friends: \(declinedFriends)
        - Images: \(images)
        - Videos: \(videos)
        """
    }
    
    func updateFlightDetails(with newFlightDetails: [ScheduledFlightAPI.FlightDetail]) {
        // Assuming you want to update the flight details if there's at least one detail
        if let detail = newFlightDetails.first {
            self.flightData = detail
            print("Flight details updated for FroopHistory ID \(self.id)")
        }
    }
    
}


extension UserData: CustomStringConvertible {
    var description: String {
        """
        UserData:
        - firstName: \(firstName)
        - lastName: \(lastName)
        - ... other properties ...
        """
    }
}

extension FroopFlightDataManager {
    // Method to fetch and update flight details in a specific FroopHistory
    func fetchAndUpdateFlightDetails(for flightNumber: String, date: String, in froopHistory: FroopHistory) async {
        do {
            let flightDetails = try await fetchSingleFlightDetails(for: flightNumber, date: date)
            await MainActor.run {
                froopHistory.updateFlightDetails(with: flightDetails)
            }
        } catch {
            print("An error occurred while updating flight details: \(error.localizedDescription)")
        }
    }
    
    func fetchSingleFlightDetails(for flightNumber: String, date: String) async throws -> [ScheduledFlightAPI.FlightDetail] {
        let urlString = "https://aerodatabox.p.rapidapi.com/flights/number/\(flightNumber)/\(date)?withAircraftImage=true&withLocation=true"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1001, userInfo: nil)
        }
        print(urlString)
        print(date)
        print(flightNumber)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Secrets.rapidAPI, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("aerodatabox.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "Received non-200 HTTP response", code: -1002, userInfo: nil)
        }
        
        let decodedFlights = try JSONDecoder().decode([ScheduledFlightAPI.FlightDetail].self, from: data)
        print(decodedFlights)
        return decodedFlights
    }
}












