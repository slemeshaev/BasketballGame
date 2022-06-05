//
//  MainViewController.swift
//  BasketballGame
//
//  Created by Stanislav Lemeshaev on 31.05.2022.
//  Copyright © 2022 slemeshaev. All rights reserved.
//

import ARKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var sceneView: ARSCNView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Private
    private func hoopNode() -> SCNNode {
        guard let scene = SCNScene(named: "Hoop.scn", inDirectory: "art.scnassets") else {
            return SCNNode()
        }
        
        let hoopNode = scene.rootNode.clone()
        hoopNode.eulerAngles.x -= .pi / 2
        
        return hoopNode
    }
}

// MARK: - ARSCNViewDelegate
extension MainViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else {
            return
        }
        
        node.addChildNode(hoopNode())
    }
}
