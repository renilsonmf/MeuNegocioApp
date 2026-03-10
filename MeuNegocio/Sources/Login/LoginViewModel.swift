//
//  LoginViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 18/08/22.
//

import FirebaseAuth
import FirebaseCore
import CoreData

protocol LoginViewModelProtocol: AnyObject {
    func authLogin(_ email: String, _ password: String, resultLogin: @escaping (Bool, String) -> Void)
    func authLoginGoogle(credentials: AuthCredential, resultAuth: @escaping (Bool) -> Void)
    func authLoginApple(credentials: AuthCredential, resultAuth: @escaping (Bool) -> Void)
    func fetchUser(completion: @escaping (UserModelList) -> Void)
    func navigateToHome()
    func navigateToUserOnboarding()
    func navigateToForgotPassword(email: String)
    func navigateToRegister()
    func navigateToCheckYourAccount()
}

class LoginViewModel: LoginViewModelProtocol {
    
    // MARK: - Properties
    private var coordinator: LoginCoordinator?
    
    // MARK: - Init
    init(coordinator: LoginCoordinator?) {
        self.coordinator = coordinator
    }
    
    func authLogin(_ email: String, _ password: String, resultLogin: @escaping (Bool, String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if error != nil {
                guard let typeError = error as? NSError else { return }
                resultLogin(false, self.descriptionError(error: typeError))
            } else {
                MNUserDefaults.set(value: true, forKey: MNKeys.authenticated)
                MNUserDefaults.remove(key: MNKeys.loginWithApple)
                resultLogin(true, .stringEmpty)
            }
        }
    }
    
    func authLoginGoogle(credentials: AuthCredential, resultAuth: @escaping (Bool) -> Void) {
        Auth.auth().signIn(with: credentials) { (result, error) in
            if error != nil {
                resultAuth(false)
            } else {
                resultAuth(true)
                MNUserDefaults.remove(key: MNKeys.loginWithApple)
            }
        }
    }
    
    func authLoginApple(credentials: AuthCredential, resultAuth: @escaping (Bool) -> Void) {
        Auth.auth().signIn(with: credentials) { (result, error) in
            if error != nil {
                resultAuth(false)
            } else {
                resultAuth(true)
                MNUserDefaults.set(value: true, forKey: MNKeys.loginWithApple)
            }
        }
    }
    
    func fetchUser(completion: @escaping (UserModelList) -> Void) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")

        do {
            guard let users = try CoreDataManager.shared.managedObjectContext.fetch(request) as? [NSManagedObject] else {
                completion(UserModelList())
                return
            }

            // Mapear todos os objetos para UserModel
            let result: UserModelList = users.map { user in
                return UserModel(
                    id: user.value(forKey: "id") as? String ?? "",
                    name: user.value(forKey: "name") as? String ?? "",
                    barbershop: user.value(forKey: "barbershop") as? String ?? "",
                    city: user.value(forKey: "city") as? String ?? "",
                    state: user.value(forKey: "state") as? String ?? "",
                    email: user.value(forKey: "email") as? String ?? "",
                    v: 0
                )
            }

            completion(result)
        } catch {
            completion(UserModelList())
        }
    }
    
    private func descriptionError(error: NSError) -> String {
        var description: String = .stringEmpty
        
        switch error.code {
        case AuthErrorCode.userNotFound.rawValue:
            description = "Não existe uma conta com esse email"
        case AuthErrorCode.wrongPassword.rawValue:
            description = "senha incorreta"
        default:
            description = "Ocorreu um erro, tente novamente mais tarde"
        }
        
        return description
    }
    
    // MARK: - Routes
    func navigateToHome() {
        coordinator?.navigateToHome()
    }
    
    func navigateToUserOnboarding() {
        coordinator?.navigateToUserOnboarding()
    }
    
    func navigateToForgotPassword(email: String) {
        coordinator?.navigateToForgotPassword(email: email)
    }
    
    func navigateToRegister() {
        coordinator?.navigateToRegister()
    }

    func navigateToCheckYourAccount() {
        coordinator?.checkYourAccount()
    }
}
