//
//  AboutViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/22/21.
//

import Cocoa
import SnapKit

internal final class AboutViewController: NSViewController {
    internal weak var abountWindow: AboutWindow? = nil
    private weak var visualEffectView: NSVisualEffectView? = nil
    private weak var containerView: NSView? = nil
    private weak var containetViewTopConstraint: Constraint? = nil
    private weak var mainStackView: NSStackView? = nil
    private weak var logoImageView: NSImageView? = nil
    private weak var appNameTextField: NSTextField? = nil
    private weak var appVersionTextField: NSTextField? = nil
    private weak var openDeveloperGitHubButton: NSButton? = nil
    private weak var sendFeedbackEmailButton: NSButton? = nil
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureVisualEffectView()
        configureContainerView()
        configureMainStackView()
        configureLogoImageView()
        configureAppNameTextField()
        configureAppVersionTextField()
        configureOpenDeveloperGitHubButton()
        configureSendFeedbackEmailButton()
    }
    
    internal override func viewDidLayout() {
        super.viewDidLayout()
        containetViewTopConstraint?.update(offset: abountWindow?.topBarHeight ?? 28)
    }
    
    private func configureVisualEffectView() {
        let visualEffectView: NSVisualEffectView = .init()
        self.visualEffectView = visualEffectView
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        visualEffectView.snp.remakeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func configureContainerView() {
        guard let visualEffectView: NSVisualEffectView = visualEffectView else {
            return
        }
        
        let containerView: NSView = .init()
        self.containerView = containerView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(containerView)
        containerView.snp.remakeConstraints { [weak self] make in
            let top: ConstraintMakerEditable = make.top.equalToSuperview().offset(28)
            self?.containetViewTopConstraint = top.constraint
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureMainStackView() {
        guard let containerView: NSView = containerView else {
            return
        }
        
        let mainStackView: NSStackView = .init()
        self.mainStackView = mainStackView
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mainStackView)
        mainStackView.snp.remakeConstraints { $0.center.equalToSuperview() }
        
        mainStackView.orientation = .vertical
        mainStackView.distribution = .fillProportionally
        mainStackView.alignment = .centerX
    }
    
    private func configureLogoImageView() {
        guard let mainStackView: NSStackView = mainStackView else {
            return
        }
        
        guard let logoImage: NSImage = NSImage(named: "logo") else {
            return
        }
        
        let logoImageView: NSImageView = .init(image: logoImage)
        self.logoImageView = logoImageView
        mainStackView.addArrangedSubview(logoImageView)
        logoImageView.snp.remakeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
        }
    }
    
    private func configureAppNameTextField() {
        guard let mainStackView: NSStackView = mainStackView else {
            return
        }
        
        let appNameTextField: NSTextField = .init()
        self.appNameTextField = appNameTextField
        mainStackView.addArrangedSubview(appNameTextField)
        
        appNameTextField.setLabelStyle()
        appNameTextField.stringValue = Localizable.DORODORO.string
        appNameTextField.font = .systemFont(ofSize: 25, weight: .bold)
    }
    
    private func configureAppVersionTextField() {
        guard let mainStackView: NSStackView = mainStackView else {
            return
        }
        
        let appVersionTextField: NSTextField = .init()
        self.appVersionTextField = appVersionTextField
        mainStackView.addArrangedSubview(appVersionTextField)
        
        appVersionTextField.setLabelStyle()
        appVersionTextField.stringValue = "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))"
        appVersionTextField.font = .systemFont(ofSize: 15, weight: .light)
    }
    
    private func configureOpenDeveloperGitHubButton() {
        guard let mainStackView: NSStackView = mainStackView else {
            return
        }
        
        let openDeveloperGitHubButton: NSButton = .init()
        self.openDeveloperGitHubButton = openDeveloperGitHubButton
        mainStackView.addArrangedSubview(openDeveloperGitHubButton)
        openDeveloperGitHubButton.snp.remakeConstraints {
            $0.width.equalTo(200)
        }
        
        openDeveloperGitHubButton.bezelStyle = .regularSquare
        openDeveloperGitHubButton.title = Localizable.MAC_OPEN_DEVELOPER_GITHUB.string
        openDeveloperGitHubButton.action = #selector(clickedOpenDeveloperGitHubButton(_:))
        openDeveloperGitHubButton.target = self
    }
    
    private func configureSendFeedbackEmailButton() {
        guard let mainStackView: NSStackView = mainStackView else {
            return
        }
        
        let sendFeedbackEmailButton: NSButton = .init()
        self.sendFeedbackEmailButton = sendFeedbackEmailButton
        mainStackView.addArrangedSubview(sendFeedbackEmailButton)
        sendFeedbackEmailButton.snp.remakeConstraints {
            $0.width.equalTo(200)
        }
        
        sendFeedbackEmailButton.bezelStyle = .regularSquare
        sendFeedbackEmailButton.title = Localizable.MAC_SEND_FEEDBACK_TO_DEVELOPER.string
        sendFeedbackEmailButton.action = #selector(clickedSendFeedbackEmailButton(_:))
        sendFeedbackEmailButton.target = self
    }
    
    @objc private func clickedOpenDeveloperGitHubButton(_ sender: NSButton) {
        openDeveloperGitHub()
    }
    
    @objc private func clickedSendFeedbackEmailButton(_ sender: NSButton) {
        sendFeedbackEmail()
    }
    
    private func openDeveloperGitHub() {
        guard let url: URL = URL(string: "https://github.com/pookjw") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    private func sendFeedbackEmail() {
        guard let emailService: NSSharingService = NSSharingService(named: .composeEmail) else {
            return
        }
        emailService.recipients = ["kidjinwoo@me.com"]
        emailService.subject = Localizable.MAC_EMAIL_TITLE.string
        
        let body: String = """
        
        \(Localizable.EMAIL_APP_INFO.string)
        \(Localizable.EMAIL_SYSTEM_INFO.string)
        """
        let formattedBody: String = String(format: body,
                                           "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))",
                                           "\(HardwareService.shared.modelName ?? "(Unknown)")_\(ProcessInfo.processInfo.operatingSystemVersionString)")
        
        guard emailService.canPerform(withItems: [formattedBody]) else {
            showErrorAlert(message: Localizable.EMAIL_ERROR_NO_REGISTERED_EMAILS_ON_DEVICE.string)
            return
        }
        
        emailService.perform(withItems: [formattedBody])
    }
}
