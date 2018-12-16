//
//  DictionaryController+ARKit.swift
//  WWDC-App
//
//  Created by Cesare de Cal on 16/03/2018.
//  Copyright © 2018 Cesare Gianfilippo Astianatte de Cal. All rights reserved.
//

import UIKit
import ARKit

@available(iOS 11.0, *)
extension DictionaryController: ARSCNViewDelegate {

    @objc internal func setupAR() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.session = augmentedRealitySession        
    }
    
    func createNode() -> SCNNode? {
        guard let theView = myView else {
            print("ERROR: failed to load AR detail view")
            return nil
        }
        
        let box = SCNPlane(width: 0.1, height: 0.1)
        let imageMaterial = SCNMaterial()
        imageMaterial.isDoubleSided = true
        imageMaterial.diffuse.contents = theView.asImage()
        box.materials = [imageMaterial]
        
        let cube = SCNNode(geometry: box)
        return cube
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("did add!")
        DispatchQueue.main.async {
//            self.attachCustomNode(to: node)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { self.updateFocusSquare() }
    }
    
    func updateFocusSquare() {
        if let camera = self.augmentedRealitySession.currentFrame?.camera,
            case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                if self.canDisplayFocusSquare {
                    self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                    self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
                }
            }
            
        } else {
            updateQueue.async {
                if self.canDisplayFocusSquare {
                    self.focusSquare.state = .initializing
                    self.sceneView.pointOfView?.addChildNode(self.focusSquare)
                }
            }
        }
    }
    
    internal func detectWorldCoordinates() -> SCNVector3? {
        let screenCentre = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        let arHitTestResults = sceneView.hitTest(screenCentre, types: [.featurePoint])
        if let closestResult = arHitTestResults.first {
            let transform = closestResult.worldTransform
            return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        } else {
            return nil
        }
    }
    
    func didTapSceneView(coords: SCNVector3) {
        print("didTapSceneView(coords: SCNVector3)")
        guard let latestPrediction = mlPrediction else { return }
        if !latestPrediction.isEmpty {
            getTranslation(text: latestPrediction) { (translation) in
                DispatchQueue.main.async {
                    if let translation = translation {
                        //self.addNode(title: latestPrediction, subtitle: translation.translatedText, coords: coords)
                        self.handleIncomingTranslation(translation: translation)
                        TranslationItems.shared.array.append(translation)
                    }
                }
            }
        }
    }
    
    func handleIncomingTranslation(translation: Translation) {
        //self.animateDictionaryView(item: translation)
        TextToSpeech.speak(item: translation)
    }
    
    @objc func didTapAddButton() {
        // HIT TEST : REAL WORLD
        // Get Screen Centre
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Create 3D Text
            if let node = createNode() {
                sceneView.scene.rootNode.addChildNode(node)
                node.position = worldCoord
                print("should have added text to scene")
            } else {
                print("ERROR! Something wrong here.")
            }
        }
    }
    
    @objc internal func didTapClearScene() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if node is FocusSquare {
                node.removeFromParentNode()
            }
        }
        
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
    }
    
    @objc func updateLabel() {
        identifier = mlPrediction
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerAlignmentMode(_ input: CATextLayerAlignmentMode) -> String {
	return input.rawValue
}

// this would be outside your controller class, i.e. the top-level of a swift file
extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
