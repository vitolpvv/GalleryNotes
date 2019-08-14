//
//  LoginViewController.swift
//  Notes
//
//  Created by VitalyP on 06/08/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import CoreData


// Контроллер авторизации и генерации токена.
// Используется Basic-метод авторизации - https://developer.github.com/v3/auth/#basic-authentication
// Поддерживает двуступенчатую авторизацию.
// Отправляет запрос на генерацию токена с правами для работы с гистами.
class LoginViewController: UIViewController {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var tokenNoteTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var firstStepView: UIView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var secondStepView: UIView!
    
    var persistentContainer: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextField.becomeFirstResponder()
    }
    
    @IBAction func generateTokenDidTapped(_ sender: Any) {
        guard !(loginTextField.text?.isEmpty ?? true) else {
            loginTextField.becomeFirstResponder()
            return
        }
        guard !(passwordTextField.text?.isEmpty ?? true) else {
            passwordTextField.becomeFirstResponder()
            return
        }
        guard !(tokenNoteTextField.text?.isEmpty ?? true) else {
            tokenNoteTextField.becomeFirstResponder()
            return
        }
        guard let url = URL(string: "https://api.github.com/authorizations") else {
            return
        }
        guard let requestBody = try? JSONEncoder().encode(TokenRequest(note: tokenNoteTextField.text!)) else {
            showMessage("Unable to create request")
            return
        }
        processing(true)
        var cridential = "\(loginTextField.text!):\(passwordTextField.text!)"
        cridential = Data(cridential.utf8).base64EncodedString()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(cridential)", forHTTPHeaderField: "Authorization")
        if firstStepView.isHidden {
            guard let otp = otpTextField.text else {
                otpTextField.becomeFirstResponder()
                return
            }
            request.setValue(otp, forHTTPHeaderField: "x-github-otp")
        }
        request.httpBody = requestBody
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let this = self else { return }
            guard error == nil else {
                this.processing(false)
                this.showMessage(error?.localizedDescription)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                this.processing(false)
                this.showMessage("No response")
                return
            }
            guard (200..<300).contains(response.statusCode) else {
                switch response.statusCode {
                case 401:
                    switch response.allHeaderFields["X-GitHub-OTP"] {
                    case .none:
                        this.processing(false)
                        this.showMessage("Invalid login or password")
                    default:
                        DispatchQueue.main.async {
                            if this.firstStepView.isHidden {
                                this.showMessage("Invalid 'One Time Password'")
                            }
                        }
                        this.showSecondStepView(true)
                    }
                case 422:
                    this.showSecondStepView(false)
                    this.showMessage("Token already exists")
                default:
                    this.showSecondStepView(false)
                    this.showMessage(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
                }
                return
            }
            if response.statusCode == 201 {
                guard let token = try? JSONDecoder().decode(Token.self, from: data!) else {
                    this.showSecondStepView(false)
                    this.showMessage("Unable to encode token")
                    return
                }
                UserDefaults().setValue(token.token, forKeyPath: "token")
                this.showMainView()
            }
        }.resume()
    }
    
    @IBAction func offlineDidTapped(_ sender: Any) {
        showMainView()
    }
    // Показывает процесс обработки запроса
    private func processing(_ start: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.activityView.isHidden = !start
        }
    }
    
    // Показывает сообщение на экране
    private func showMessage(_ message: String?) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Error", message: "\(message ?? "unknown")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    // Переход в основное окно приложения
    private func showMainView() {
        DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "MainViewSegue", sender: nil)
        }
    }
    
    // Показывает второй шаг при двуступенчатой аутентификации
    private func showSecondStepView(_ show: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.firstStepView.isHidden = show
            self?.secondStepView.isHidden = !show
            self?.activityView.isHidden = true
            if show {
                self?.otpTextField.text = nil
                self?.otpTextField.becomeFirstResponder()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainViewSegue" {
            let tbc = segue.destination as? UITabBarController
            let nc = tbc?.viewControllers?.first as? UINavigationController
            let vc = nc?.topViewController as? NotesTableViewController
            vc?.persistentContainer = persistentContainer
        }
    }
}
