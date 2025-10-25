//
//  FirebaseManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    private init() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
        
        print("✅ FirebaseManager initialized")
    }
    
    // MARK: - Generic Firestore Operations
    
    /// Fetch a single document from Firestore
    func fetchDocument<T: Decodable>(collection: String, 
                                    documentId: String, 
                                    completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collection).document(documentId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data() else {
                completion(.failure(FirebaseError.documentNotFound))
                return
            }
            
            do {
                let object = try Firestore.Decoder().decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Fetch all documents from a collection
    func fetchCollection<T: Decodable>(collection: String, 
                                      completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let objects = snapshot?.documents.compactMap { doc -> T? in
                try? doc.data(as: T.self)
            } ?? []
            
            completion(.success(objects))
        }
    }
    
    /// Add a new document to Firestore
    func addDocument<T: Encodable>(_ object: T, 
                                   to collection: String, 
                                   completion: @escaping (Result<String, Error>) -> Void) {
        do {
            var documentRef: DocumentReference?
            documentRef = try db.collection(collection).addDocument(from: object) { error in
                if let error = error {
                    completion(.failure(error))
                } else if let docRef = documentRef {
                    completion(.success(docRef.documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Update an existing document
    func updateDocument<T: Encodable>(_ object: T, 
                                     in collection: String, 
                                     documentId: String, 
                                     completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection(collection).document(documentId).setData(from: object) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Delete a document
    func deleteDocument(from collection: String, 
                       documentId: String, 
                       completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Storage Operations
    
    /// Upload image to Firebase Storage
    func uploadImage(_ imageData: Data, 
                    path: String, 
                    completion: @escaping (Result<String, Error>) -> Void) {
        let ref = storage.reference().child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                }
            }
        }
    }
}

// MARK: - Firebase Errors
enum FirebaseError: LocalizedError {
    case documentNotFound
    case invalidData
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found in Firestore"
        case .invalidData:
            return "Invalid data format"
        case .uploadFailed:
            return "Failed to upload data"
        }
    }
}
