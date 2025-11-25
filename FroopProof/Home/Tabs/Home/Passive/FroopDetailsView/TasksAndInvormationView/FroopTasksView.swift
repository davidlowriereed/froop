//
//  FroopTasksView.swift
//  FroopProof
//
//  Created by David Reed on 6/22/23.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import Kingfisher
import FirebaseAuth


struct FroopTasksView: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @State private var editMode = EditMode.inactive
    @State var tasks: [FroopTask] = []
    @Binding var taskOn: Bool
    @State private var isEditing = true
    var uid = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .ignoresSafeArea()
                    .onTapGesture {
                        taskOn = false
                    }
                    .ignoresSafeArea()
                
                List {
                    ForEach(tasks.indices, id: \.self) { index in
                        TaskRow(task: $tasks[index], isEditing: $isEditing, tasks: $tasks, index: index, assignTask: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                tasks[index].isAccepted.toggle()
                                if tasks[index].isAccepted {
                                    tasks[index].assignedUser = uid
                                    tasks[index].imageUrl = myData.profileImageUrl
                                } else {
                                    tasks[index].assignedUser = nil
                                    tasks[index].imageUrl = nil
                                }
                                assignTask(tasks[index])
                            }
                        })
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                }
                .environment(\.editMode, $editMode)
                .navigationBarTitle("Tasks")
                .navigationBarItems(leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        tasks.append(FroopTask(description: "New Task", isAccepted: false, assignedUser: nil, imageUrl: nil))
                    }
                }) {
                    Image(systemName: "plus")
                }, trailing: (uid == froopManager.selectedFroopHistory.host.froopUserID) ? Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isEditing.toggle()
                        if isEditing {
                            editMode = .active
                        } else {
                            editMode = .inactive
                            saveList()
                        }
                    }
                }) {
                    Text(isEditing ? "Save" : "Edit")
                } : nil)
                
                VStack{
                    Spacer()
                    Text("Close")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .onTapGesture {
                            taskOn = false
                        }
                        .padding(.bottom, 100)
                }
                
            }
            
            
            .onAppear {
//                print("----Task OnAppear is called")
//                print("----FroopId = \(froopManager.selectedFroopHistory.froop.froopId)")
                let froopId = froopManager.selectedFroopHistory.froop.froopId
                let tasksRef = db.collection("users").document(uid).collection("myFroops").document(froopId).collection("froopTasks")
                
                tasksRef.getDocuments { (querySnapshot, err) in
                    if let err = err {
//                        print("🚫Error getting documents: \(err)")
                    } else {
                        tasks = querySnapshot?.documents.compactMap { document in
                            let data = document.data()
                            return FroopTask(id: UUID(uuidString: data["id"] as? String ?? "") ?? UUID(),
                                             description: data["description"] as? String ?? "",
                                             isAccepted: data["isAccepted"] as? Bool ?? false,
                                             assignedUser: data["assignedUser"] as? String,
                                             imageUrl: data["imageUrl"] as? String)
                        } ?? []
//                        print("Fetched tasks: \(tasks)")

                    }
                }
                if uid == froopManager.selectedFroopHistory.host.froopUserID && tasks.isEmpty {
                    tasks.append(FroopTask(description: "", isAccepted: false, assignedUser: nil, imageUrl: nil))
                }
            }
        }
    }
    
    func loadTasks() {
        // Assuming froopList is an array of dictionaries
        if let froopList = froopManager.selectedFroopHistory.froop.froopList as? [[String: Any]] {
            tasks = froopList.map { item in
                FroopTask(description: item["description"] as? String ?? "",
                          isAccepted: item["isAccepted"] as? Bool ?? false,
                          assignedUser: item["assignedUser"] as? String,
                          imageUrl: item["imageUrl"] as? String)
            }
//            print("Print Count of Tasks:  \(tasks.count)")
        }
        
    }
    
    private func delete(at offsets: IndexSet) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let froopId = froopManager.selectedFroopHistory.froop.froopId 
        let tasksRef = db.collection("users").document(uid).collection("myFroops").document(froopId).collection("froopTasks")
        
        for index in offsets {
            let task = tasks[index]
            tasksRef.document(task.id.uuidString).delete() { err in
                if let err = err {
                    print("🚫Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            tasks.remove(at: index)
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }
    
    func saveList() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let froopId = froopManager.selectedFroopHistory.froop.froopId 
        let tasksRef = db.collection("users").document(uid).collection("myFroops").document(froopId).collection("froopTasks")
        
        tasks.filter { !$0.description.isEmpty }
             .forEach { task in
                let taskDoc = tasksRef.document(task.id.uuidString)
                let taskData = ["id": task.id.uuidString,
                                "description": task.description,
                                "isAccepted": task.isAccepted,
                                "assignedUser": task.assignedUser ?? "",
                                "imageUrl": task.imageUrl ?? ""]
                
                taskDoc.setData(taskData) { err in
                    if let err = err {
                        print("🚫Error setting document: \(err)")
                    } else {
                        print("Document successfully set")
                    }
                }
        }
    }
    
    func assignTask(_ task: FroopTask) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let froopId = froopManager.selectedFroopHistory.froop.froopId 
        let taskRef = db.collection("users").document(uid).collection("myFroops").document(froopId).collection("froopTasks").document(task.id.uuidString)
        
        let updatedTask = ["description": task.description,
                           "isAccepted": task.isAccepted,
                           "assignedUser": task.assignedUser ?? "",
                           "imageUrl": task.imageUrl ?? ""] as [String : Any]
        
        taskRef.updateData(updatedTask) { err in
            if let err = err {
                print("🚫Error updating task: \(err)")
            } else {
                print("Task successfully updated")
            }
        }
    }
}

struct FroopTask: Identifiable {
    var id: UUID
    var description: String
    var isAccepted: Bool
    var assignedUser: String?
    var imageUrl: String?
    
    init(id: UUID = UUID(), description: String, isAccepted: Bool, assignedUser: String?, imageUrl: String?) {
        self.id = id
        self.description = description
        self.isAccepted = isAccepted
        self.assignedUser = assignedUser
        self.imageUrl = imageUrl
    }
}

struct TaskRow: View {
    @Binding var task: FroopTask
    @Binding var isEditing: Bool
    @Binding var tasks: [FroopTask] // Pass a binding to the tasks array
    var index: Int // Pass the index of the current task
    
    var assignTask: () -> Void // New closure for task assignment
    
    var body: some View {
        HStack {
            TextField("Task description", text: $task.description)
                .disabled(!isEditing)
                .onChange(of: task.description) { newValue, _ in
                    if !newValue.isEmpty && isEditing && index == tasks.count - 1 {
                        // Append a new task to the list if the user starts typing in the last task
                        tasks.append(FroopTask(description: "", isAccepted: false, assignedUser: nil, imageUrl: nil))
                    }
                }
            Spacer()
            if task.isAccepted { // Check if task is accepted
                if let imageUrl = task.imageUrl {
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
            } else {
                Button(action: assignTask) { // Use the new closure
                    Image(systemName: "square")
                }
            }
        }
    }
}
