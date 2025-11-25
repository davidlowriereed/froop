


import SwiftUI

struct FroopHistoryView: View {
    
    @State private var searchText = ""
    @State private var isMine = true
    
    var body: some View {
        
        VStack{
            ZStack {
                Rectangle()
                    .ignoresSafeArea()
                    .frame(height: 125)
                    .background(.ultraThinMaterial)
                    .foregroundColor(.black)
                    .opacity(0.8)
                VStack {
                    TextField("Search...", text: $searchText)
                        .padding(7)
                        .background(Color(.white))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .offset(y: -20)
                    HStack {
                        Toggle(isOn: $isMine) {
                            Text(isMine ? "My Froops" : "All")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .toggleStyle(CustomToggleStyle())
                        .padding(.trailing, 25)
                        
                    }
                }
            }
            
            ScrollView {
                ForEach(Month.preview) { month in
                    if !month.listItems.isEmpty {
                        Section(header: Text(month.name)
                            .font(.system(size: 36)) // set the font
                            .fontWeight(.thin)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            .frame(maxWidth: .infinity, alignment: .leading) // align text to the leading
                            .padding(.leading, 5)
                                
                        ) {
                            ForEach(month.listItems) { _ in
                                FroopHistoryCardView()
                                
                            }
                        }
                    }
                }
            }
        }
    }
}


struct FroopHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        FroopHistoryView()
    }
}
