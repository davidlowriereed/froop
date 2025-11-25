import SwiftUI
import MapKit
import Foundation

struct DateForm {
    static let yyyymmdd = "yyyy-MM-dd"                              // Example: 2023-04-15
    static let ddMMyyyy = "dd-MM-yyyy"                              // Example: 15-04-2023
    static let MMddyyyy = "MM/dd/yyyy"                              // Example: 04/15/2023
    static let ddMMyyyy2 = "dd/MM/yyyy"                             // Example: 15/04/2023
    static let yyyyMMdd = "yyyy/MM/dd"                              // Example: 2023/04/15
    static let yyyyMMMMdd = "yyyy MMMM dd"                          // Example: 2023 April 15
    static let ddMMMMyyyy = "dd MMMM yyyy"                          // Example: 15 April 2023
    static let yyyyMMMMddEEEE = "yyyy MMMM dd, EEEE"                // Example: 2023 April 15, Saturday
    static let EEEEMMMMddyyyy = "EEEE, dd MMMM yyyy"                // Example: Saturday, 15 April 2023
    static let MMddyyyyHHmm = "MM-dd-yyyy HH:mm"                    // Example: 04-15-2023 09:30
    static let MMddyyyyhhmma = "MM/dd/yyyy hh:mm a"                 // Example: 04/15/2023 09:30 AM
    static let yyyyMMddTHHmmss = "yyyy-MM-dd'T'HH:mm:ss"            // Example: 2023-04-15T09:30:45
    static let yyyyMMddTHHmmssSSS = "yyyy-MM-dd'T'HH:mm:ss.SSS"     // Example: 2023-04-15T09:30:45.000
    static let yyyyMMddTHHmmssSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"   // Example: 2023-04-15T09:30:45.000+0000
    static let yyyyMMddTHHmmssZ = "yyyy-MM-dd'T'HH:mm:ssZ"          // Example: 2023-04-15T09:30:45+0000
    static let EddMMMyyyyHHmmss = "E, dd MMM yyyy HH:mm:ss"         // Example: Sat, 15 Apr 2023 09:30:45
    static let EddMMMyyyyHHmmssZ = "E, dd MMM yyyy HH:mm:ss Z"      // Example: Sat, 15 Apr 2023 09:30:45 +0000
    static let MMMdhmma = "MMM d, h:mm a"                           // Example: Apr 15, 9:30 AM
    
    static let froopFlightView = "E, MMM dd"                     // Example: Sat 2023/04/15
    static let card = "MMMM d, h:mm a"                              // Example: April 15, 9:30 AM
    static let detail = "EEEE, MMM d, h:mm a"                       // Example: Saturday, Apr 15, 9:30 AM
    static let inviteCardView = "EEEE, MMMM d, yyyy h:mm a"         // More formats can be added here

    private init() {} // Private initializer to ensure the struct is not instantiated
}
