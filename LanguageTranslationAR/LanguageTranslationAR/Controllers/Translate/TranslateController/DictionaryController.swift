 //
//  File.swift
//  WWDC-App
//
//  Created by Cesare de Cal on 16/03/2018.
//  Copyright © 2018 Cesare Gianfilippo Astianatte de Cal. All rights reserved.
//

import UIKit
import AVKit
import Vision
import ARKit
import AVFoundation

@available(iOS 11.0, *) 
public class DictionaryController: UIViewController {

    internal var items: [Translation] = []

    var myView: UIView?
    var detectedDataAnchor: ARAnchor?

    //--------------------
    //MARK: - AR Variables
    //--------------------
    
    lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.delegate = self
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        return sceneView
    }()
    
    let augmentedRealitySession = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    
    var focusSquare = FocusSquare()
    var canDisplayFocusSquare = true
    var screenCenter: CGPoint {
        let bounds = self.sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    let updateQueue = DispatchQueue(label: "cesaredecal")

    //--------------------
    //MARK: - CoreML Vision
    //--------------------

    var visionRequests = [VNRequest]()
    var mlPrediction: String?
    
    var player: AVAudioPlayer?

    var identifier: String? {
        didSet {
            if identifier == oldValue {
                return
            }            
        }
    }
    
    lazy var addButton: AddButtonView = {
        let view = AddButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    public override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
        checkCameraPermissions()
        
        myView = Bundle.main.loadNibNamed("ARView", owner: nil, options: nil)?.first as? UIView
	}
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldPresentWelcomeController() {
            present(WelcomeController(), animated: true, completion: nil)
        }
    }
    
    @objc internal func shouldPresentWelcomeController() -> Bool {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus {
        case .denied:
            return true
        case .authorized:
            return false
        case .restricted:
            return true
        case .notDetermined:
            return true
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
    }
 }