//
//  ProfileViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 02/09/22.
//
import FirebaseAuth
import FirebaseFirestore

protocol ProfileViewModelProtocol {
    func signOut(resultSignOut: (Bool) -> Void)
    func deleteUserAccount(completion: @escaping (Bool) -> Void)
    func logout()
}

class ProfileViewModel: ProfileViewModelProtocol {
    
    // MARK: - Properties
    private var coordinator: ProfileCoordinator?
    
    // MARK: - Init
    init(coordinator: ProfileCoordinator?) {
        self.coordinator = coordinator
    }
    
    func deleteUserAccount(completion: @escaping (Bool) -> Void) {
        
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let uid = user.uid
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uid)
            .collection("procedures")
            .getDocuments { snapshot, _ in
                
                let batch = db.batch()
                
                snapshot?.documents.forEach {
                    batch.deleteDocument($0.reference)
                }
                
                batch.commit { _ in
                    db.collection("users").document(uid).delete { _ in
                        user.delete { error in
                            if let error = error {
                                print("Erro ao deletar auth:", error)
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
                }
            }
    }
    
    
    func signOut(resultSignOut: (Bool) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            resultSignOut(true)
        } catch {
            resultSignOut(false)
        }
    }
    
    // MARK: - Routes
    func logout() {
        KeychainService.deleteCredentials()
        coordinator?.closed()
    }
}
