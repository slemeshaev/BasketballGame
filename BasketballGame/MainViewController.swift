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
    
    // MARK: - Properties
    private let configuration = ARWorldTrackingConfiguration()
    
    private var isHoopAdded = false {
        didSet {
            configuration.planeDetection = []
            sceneView.session.run(configuration, options: .removeExistingAnchors)
        }
    }
    
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
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - IBActions
    @IBAction private func userTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .vertical) else {
            return
        }
        
        let results = sceneView.session.raycast(query)
        
        guard let result = results.first else {
            return
        }
        
        if isHoopAdded {
            // Add basketballs
        } else {
            let hoopNode = hoopNode()
            hoopNode.simdTransform = result.worldTransform
            hoopNode.eulerAngles.x -= .pi / 2
            
            isHoopAdded = true
            sceneView.scene.rootNode.addChildNode(hoopNode)
        }
    }
    
    // MARK: - Private
    private func hoopNode() -> SCNNode {
        guard let scene = SCNScene(named: "Hoop.scn", inDirectory: "art.scnassets") else {
            return SCNNode()
        }
        
        let hoopNode = scene.rootNode.clone()
        
        return hoopNode
    }
    
    private func planeNode(for anchor: ARPlaneAnchor) -> SCNNode {
        let extent = anchor.extent
        
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        plane.firstMaterial?.diffuse.contents = UIColor.green
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x -= .pi / 2
        planeNode.opacity = 0.25
        
        return planeNode
    }
    
    private func updatePlaneNode(_ node: SCNNode, for anchor: ARPlaneAnchor) {
        guard let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else {
            return
        }
        
        planeNode.simdPosition = anchor.center
        
        let extent = anchor.extent
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
    }
}

// MARK: - ARSCNViewDelegate
extension MainViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else {
            return
        }
        
        node.addChildNode(planeNode(for: planeAnchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else {
            return
        }
        
        updatePlaneNode(node, for: planeAnchor)
    }
}
