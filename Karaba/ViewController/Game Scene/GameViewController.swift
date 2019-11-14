//
//  GameViewController.swift
//  Karaba
//
//  Created by Rem Remy on 14/10/19.
//  Copyright © 2019 Rem Remy. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
class GameViewController: UIViewController, SKViewDelegate{
    
    var whichScene = 0
    // 0 game scene
    // 1 compound
    @IBOutlet weak var lbGuide: UILabel!{
        didSet{
            lbGuide.textAlignment = .center
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skView: SKView!
    
    let polygon = [CGPoint(x: 0, y: 0), CGPoint(x: 50, y: 0),CGPoint(x: 50, y: 50), CGPoint(x: 0, y: 0)]
    
    var compoundScene : CompoundScene?
    var gameScene : GameScene?
    var cornerScene : CornerScene?
    var surroundScene : SurroundScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        ShapeBentuk.getAllShape()
        configCollection()
//        gameScene = scene as? gameScene
//        self.view = SKView()
        lbGuide.text = "I am square and\n I've been alone all my life"
        if let view = skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                gameScene = scene as? GameScene
                gameScene!.gameVC = self
                whichScene = 0
                collectionView.isHidden = false
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
            view.setNeedsDisplay()
        }
    }
    
    func getShapeScale(points: [CGPoint]) -> Float{
        return 0
    }

    func configCollection(){
        collectionView.register(UINib(nibName: "DragNDropItemCell", bundle: nil), forCellWithReuseIdentifier: "dragNDropItemCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func changeScene(sceneNo : Int){
        whichScene = sceneNo
        print("SCN:", "Change to scene", sceneNo)
        
        UIView.animate(withDuration: 5.0, animations: {
            self.lbGuide.alpha = 0.0
        })
        
        if sceneNo == 0{

        } else if sceneNo == 1 {
            self.lbGuide.text = "I dream big even\nthough I feel empty"
            collectionView.isHidden = false
        } else if sceneNo == 2 {
            self.lbGuide.text = "I feel so empty and alone, sometimes\nI just want to curl up in the corner"
            collectionView.isHidden = true
        } else if sceneNo == 3 {
            self.lbGuide.text = "Even though I am surrounded,\nI still feel alone"
            collectionView.isHidden = false
        }
        UIView.animate(withDuration: 5.0, animations: {
            self.lbGuide.alpha = 1.0
        })
    }
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    var itemColor = ["#FF0000"]
    var viewInVC = [UIView]()
    func selectedItem(itemIndex:Int, frame : CGRect){
        let xZero = -200
        let yZero = 200
        let polygons = [
            [
                CGPoint(x: xZero, y: yZero),
                CGPoint(x: xZero - 80, y: yZero),
                CGPoint(x: xZero - 80, y: yZero + 80),
                CGPoint(x: xZero, y: yZero + 80),
            ]
        ]
        
        let path = CGMutablePath()
        for points in polygons {
            path.addLines(between: points)
            path.closeSubpath()
        }
        let child1 = SKShapeNode(path: path)
        child1.fillColor = UIColor(hexString: itemColor[itemIndex])!
        child1.name = "anakanak"
        if whichScene == 0{
            gameScene?.addChildFunc(shape: child1)
        } else if whichScene == 1{
            compoundScene?.addChildFunc(shape: child1)
        } else if whichScene == 2{
            cornerScene?.addChildFunc(shape: child1)
        } else if whichScene == 3{
            surroundScene?.addChildFunc(shape: child1)
        }
    }
    @objc func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let translation = gestureRecognizer.translation(in: self.view)
            print(gestureRecognizer.view!.center.y)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self.view)
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended && (gestureRecognizer.view!.center.x < skView.frame.minX  || gestureRecognizer.view!.center.x > skView.frame.maxX || gestureRecognizer.view!.center.y < skView.frame.minY  || gestureRecognizer.view!.center.y > skView.frame.maxY){
            gestureRecognizer.view!.removeFromSuperview()
        }
    }
}
extension GameViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //ganti jadi count dari shape data yg disimpen
        return itemColor.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dragNDropItemCell", for: indexPath) as! DragNDropItemCell
//        cell.testView.backgroundColor = UIColor(hexString: itemColor[indexPath.row])
        cell.drawShape(points: polygon, scale: 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem(itemIndex: indexPath.row, frame : collectionView.layoutAttributesForItem(at: indexPath)!.frame)
    }
    
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    
}
