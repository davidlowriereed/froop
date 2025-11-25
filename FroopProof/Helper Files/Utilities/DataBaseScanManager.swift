//
//  DataBaseScanManager.swift
//  FroopProof
//
//  Created by David Reed on 5/1/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI
import FirebaseAuth



class FirestoreDataManager: ObservableObject {
    static let shared = FirestoreDataManager()
        private let db = Firestore.firestore()
        
        /// Copies the user document and creates specified collections within it.
        func copyUserDocument(docName: String, completion: @escaping (Error?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(NSError(domain: "FirestoreDataManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Authentication UID not found."]))
                return
            }
            
            let originalDocRef = db.collection("users").document(uid)
            
            Task {
                do {
                    // Fetch the original document
                    let snapshot = try await originalDocRef.getDocument()
                    guard let data = snapshot.data() else {
                        throw NSError(domain: "FirestoreDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Original document data is empty."])
                    }
                    
                    // Create the new document with the specified name
                    let newDocRef = db.collection("users").document(docName)
                    try await newDocRef.setData(data)
                    
                    // Create the collections within the new document
                    await createCollections(for: newDocRef)
                    
                    // Completion with no error
                    completion(nil)
                } catch {
                    // Handle errors
                    completion(error)
                }
            }
        }
        
        /// Creates specified collections in a document.
        private func createCollections(for documentRef: DocumentReference) async {
            let collections = ["friends", "froopDecisions", "myChats", "myFroopChats", "myFroops", "templates"]
            for collection in collections {
                let collectionRef = documentRef.collection(collection)
                // Optionally, add a placeholder document if necessary
                let placeholderDocRef = collectionRef.document("placeholder")
                try? await placeholderDocRef.setData(["initialized": true])
            }
        }
    
    /// Copies all documents from a specified collection of the current user to a new document.
        func copyCollection(fromCurrentUser collectionName: String, toNewDocument newDocName: String, completion: @escaping (Error?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(NSError(domain: "FirestoreDataManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Authentication UID not found."]))
                return
            }
            
            let originalCollectionRef = db.collection("users").document(uid).collection(collectionName)
            let newCollectionRef = db.collection("users").document(newDocName).collection(collectionName)
            
            Task {
                do {
                    // Fetch all documents from the original collection
                    let snapshot = try await originalCollectionRef.getDocuments()
                    for document in snapshot.documents {
                        let data = document.data()
                        let newDocRef = newCollectionRef.document(document.documentID)
                        try await newDocRef.setData(data)
                    }
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    
    }
