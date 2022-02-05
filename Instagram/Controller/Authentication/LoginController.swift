//
//  LoginController.swift
//  Instagram
//
//  Created by Владимир Юшков on 10.01.2022.
//

import UIKit

protocol AuthenticationDelegate: AnyObject { // Проблема: После того как первый пользователь вышел из аккаунта, у последующего пользователя зашедшего в свой аккаунт отображаются данные предыдущего пользователя. Этот протокол поможет MainTabController refetch user
    func authenticationDidComplete()
}

class LoginController: UIViewController {
    
    // MARK: Properties
    private var viewModel = LoginViewModel()
    weak var delegate: AuthenticationDelegate? // weak чтобы избежать retain cycle. Эта переменная хранит reference, weak нужен чтобы сделать weak reference вместо strong reference. / В нашем случае она будет хранить reference к MainTabController
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailTextField: UITextField = {
       let tf = CustomTextField(placeholder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
       let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.authButtonTitle("Log In")
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Forgot your password?", secondPart: "Get help signing in.")
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Don't have an account?", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: Actions
    @objc func handleShowResetPassword() {
        let controller = ResetPasswordController()
        controller.delegate = self
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.logUserIn(with: email, password: password) { result, error in
            if let error = error {
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                print("DEBUG: Failed to log user in \(error.localizedDescription)")
                return // Выйдет полностью из функции
            }
            
            self.delegate?.authenticationDidComplete()
        }
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate // Назначает RegistrationController.delegate своего делегата который лежит в его свойстве delegat (LoginController.delegate) / Мы нигде кроме этого места не имеем доступ к RegistrationController поэтому назначили здесь / LoginController гарантированно будет иметь делегата поэтому назначение делегата of RegistrationController безопасно /
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        updateForm()
    }
    
    // MARK: Helpers
    func configureUI() {
        configureGradientLayer()
        
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
}

// MARK: - FormViewModel
extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}

// MARK: - ResetPasswordControllerDelegate
extension LoginController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Success", message: "We sent a link to your email to reset your password.")
    }
}
