//
//  DictionaryController+Views.swift
//  WWDC-App
//
//  Created by Cesare de Cal on 16/03/2018.
//  Copyright © 2018 Cesare Gianfilippo Astianatte de Cal. All rights reserved.
//

import UIKit

extension TranslateController: AddButtonProtocol {
    
	internal func setupViews() {
        view.backgroundColor = .black
        
        if Testing.isTesting {
            view.addSubview(testImageView)
            testImageView.fillToSuperview(includeNotch: true)            
        } else {
            setupSceneView()
            setupCustomView()
        }
        setupAddButton()
        setupFeedbackView()
        setupScanningView()
        changeScanningState(planesDetected: false)
        setupClearButton()
    }
            
    private func setupFeedbackView() {
        view.addSubview(recognizedObjectFeedbackView)
        recognizedObjectFeedbackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 66).isActive = true
        recognizedObjectFeedbackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupScanningView() {
        view.addSubview(moveDeviceToScanView)
        moveDeviceToScanView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        moveDeviceToScanView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func changeScanningState(planesDetected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.plusButton.isHidden = !planesDetected
            self.recognizedObjectFeedbackView.isHidden = !planesDetected
            self.clearButtonView.isHidden = !planesDetected
            self.tipView.isHidden = !planesDetected
            self.moveDeviceToScanView.isHidden = planesDetected
        }
        
        if planesDetected {
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.updateLabel), userInfo: nil, repeats: true).fire()
        }
    }
    
    private func setupCustomView() {
        view.addSubview(customARView)
        customARView.topAnchor.constraint(equalTo: view.topAnchor, constant: -300).isActive = true
        
        if Testing.isTesting {
            self.recognizedObjectFeedbackView.textLabel.text = "TEST_LABEL".localized
        }
    }

    func setupClearButton() {
        view.addSubview(clearButtonView)
        clearButtonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        clearButtonView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -7).isActive = true        
    }
    
    internal func setupAddButton() {
        view.addSubview(plusButton)        
        plusButton.widthAnchor.constraint(equalToConstant: 73).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 73).isActive = true
        plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -39).isActive = true
        
        presentTipView()
        
        plusButton.delegate = self
    }
    
	private func setupSceneView() {
		view.addSubview(sceneView)
        sceneView.fillToSuperview(includeNotch: true)
	}
}
