//
//  FirebaseService.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//


import FirebaseFirestore
import CoreImage.CIFilterBuiltins

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    func uploadMenu(_ menu: Menu, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert menu to dictionary
        let docRef = db.collection("menus").document()
        
        do {
            let menuData: [String: Any] = [
                "name": menu.name,
                "sections": try JSONEncoder().encode(menu.sections).base64EncodedString(),
                "timestamp": Timestamp(date: Date())
            ]
            
            docRef.setData(menuData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Generate URL - you can customize this domain
                    let url = "https://menuvision.web.app/menu?id=\(docRef.documentID)"
                    completion(.success(url))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchMenu(id: String, completion: @escaping (Result<Menu, Error>) -> Void) {
        db.collection("menus").document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let name = data["name"] as? String,
                  let sectionsBase64 = data["sections"] as? String,
                  let sectionsData = Data(base64Encoded: sectionsBase64),
                  let sections = try? JSONDecoder().decode([MenuSection].self, from: sectionsData) else {
                completion(.failure(NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid menu data"])))
                return
            }
            
            let menu = Menu(name: name, sections: sections, firebaseId: id)
            completion(.success(menu))
        }
    }
}
