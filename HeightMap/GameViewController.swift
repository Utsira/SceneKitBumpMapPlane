//
//  GameViewController.swift
//  HeightMap
//
//  Created by Oliver Dew on 25/04/2016.
//  Copyright (c) 2016 Salt Pig. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SceneKit.ModelIO

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene() //SCNScene(named: "art.scnassets/ship.scn")!
        
        // Add a cube to test physics
        let cubeNode = SCNNode()
        cubeNode.position = SCNVector3(x:0, y: 10, z:0)
        cubeNode.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        let plastic = SCNMaterial()
        plastic.diffuse.contents = UIColor.cyanColor()
        plastic.shininess = 2
        cubeNode.geometry?.materials = [plastic]
        cubeNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        cubeNode.physicsBody!.friction = 1
        scene.rootNode.addChildNode(cubeNode)
        
        let lookAtCube = SCNLookAtConstraint(target: cubeNode)
        lookAtCube.gimbalLockEnabled = true
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        let light = SCNLight()
        //light.type = SCNLightTypeDirectional
        light.type = SCNLightTypeOmni
        light.attenuationFalloffExponent = 0
//        light.type = SCNLightTypeSpot
//        light.castsShadow = true
//        light.spotInnerAngle = 40
//        light.spotOuterAngle = 60
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 6, z: 40)
        //lightNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0 )
        //lightNode.constraints = [lookAtCube]
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        //add a skybox
        let skyBox = MDLSkyCubeTexture(name: nil, channelEncoding: MDLTextureChannelEncoding.UInt8,
                                       textureDimensions: [Int32(160), Int32(160)], turbidity: 0.8, sunElevation: 0.55, upperAtmosphereScattering: 0.2, groundAlbedo: 2)
        scene.background.contents = skyBox.imageFromTexture()?.takeUnretainedValue()
        scene.fogColor = UIColor(red: 0.55, green: 0.6, blue: 0.35, alpha: 1)
        scene.fogStartDistance = 10
        scene.fogEndDistance = 120
        scene.fogDensityExponent = 1.5
        // retrieve the ship node
        //let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        //ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
        //create heightmap ground
        let groundNode = SCNNode()
        groundNode.position = SCNVector3(x: 0, y: 0, z: 0)
        let groundGeometry = bumpyPlane()
        groundNode.geometry = groundGeometry
       // groundNode.geometry?.firstMaterial?.diffuse.contents = UIImage(contentsOfFile: "art.scnassets/Barren Reds.jpg")
        groundNode.physicsBody = SCNPhysicsBody(type: .Static, shape: SCNPhysicsShape(geometry: groundGeometry, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron]))
        groundNode.physicsBody!.friction = 1
        groundNode.geometry!.subdivisionLevel = 1 //if you subdivide ground geometry, the physics body is also subdivided
        scene.rootNode.addChildNode(groundNode)
        //groundNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.debugOptions = SCNDebugOptions.ShowPhysicsShapes
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
