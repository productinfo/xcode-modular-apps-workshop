import Foundation
import GitHubKit
import Result

public protocol LoginViewModeling: AnyObject {
    func login()
    func shouldLoad(url: URL) -> Bool
}

public protocol LoginViewing: AnyObject {
    func open(url: URL)
    func loginDidComplete(error: Error?)
}

public final class LoginViewModel: LoginViewModeling, GitHubLoginHandlerDelegate {
    
    // MARK: - Attributes
    
    private weak var view: LoginViewing?
    private var loginHandler: GitHubLoginHandling!
    private let sessionController: SessionControlling
    
    public init(view: LoginViewing) {
        self.view = view
        self.sessionController = Services.sessionController
        self.loginHandler = GitHubLoginHandler(clientId: Constants.githubClientId,
                                               clientSecret: Constants.githubClientSecret,
                                               redirectUri: Constants.githubRedirectUri,
                                               scopes: ["repo", "user"],
                                               allowSignup: true,
                                               delegate: self)
    }
    
    init(view: LoginViewing,
         loginHandler: GitHubLoginHandling,
         sessionController: SessionControlling) {
        self.view = view
        self.loginHandler = loginHandler
        self.sessionController = sessionController
    }
    
    public func login() {
        do {
            try loginHandler.start()
        } catch {
            view?.loginDidComplete(error: error)
        }
    }
    
    public func shouldLoad(url: URL) -> Bool {
        return loginHandler.shouldOpen(url: url)
    }
    
    // MARK: - GitHubLoginHandlerDelegate
    
    public func open(url: URL) {
        view?.open(url: url)
    }
    
    public func completed(_ result: Result<String, GitHubLoginError>) {
        if let token = result.value {
            sessionController.authenticated(token: token)
        }
        view?.loginDidComplete(error: result.error)
    }
    
}
