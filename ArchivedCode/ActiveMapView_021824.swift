
//FirestoreDataManager.shared.copyUserDocument(docName: "newDocName") { error in
//    if let error = error {
//        print("Failed to copy document: \(error.localizedDescription)")
//    } else {
//        print("Document and collections copied successfully.")
//        FirestoreDataManager.shared.copyCollection(fromCurrentUser: "friends", toNewDocument: "newDocName") { error in
//            if let error = error {
//                print("Failed to copy collection: \(error.localizedDescription)")
//            } else {
//                print("Collection copied successfully.")
//                FirestoreDataManager.shared.copyCollection(fromCurrentUser: "froopDecisions", toNewDocument: "newDocName") { error in
//                    if let error = error {
//                        print("Failed to copy collection: \(error.localizedDescription)")
//                    } else {
//                        print("Collection copied successfully.")
//                        FirestoreDataManager.shared.copyCollection(fromCurrentUser: "myChats", toNewDocument: "newDocName") { error in
//                            if let error = error {
//                                print("Failed to copy collection: \(error.localizedDescription)")
//                            } else {
//                                print("Collection copied successfully.")
//                                FirestoreDataManager.shared.copyCollection(fromCurrentUser: "myFroopChats", toNewDocument: "newDocName") { error in
//                                    if let error = error {
//                                        print("Failed to copy collection: \(error.localizedDescription)")
//                                    } else {
//                                        print("Collection copied successfully.")
//                                        FirestoreDataManager.shared.copyCollection(fromCurrentUser: "myFroops", toNewDocument: "newDocName") { error in
//                                            if let error = error {
//                                                print("Failed to copy collection: \(error.localizedDescription)")
//                                            } else {
//                                                print("Collection copied successfully.")
//                                                FirestoreDataManager.shared.copyCollection(fromCurrentUser: "templates", toNewDocument: "newDocName") { error in
//                                                    if let error = error {
//                                                        print("Failed to copy collection: \(error.localizedDescription)")
//                                                    } else {
//                                                        print("Collection copied successfully.")
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
