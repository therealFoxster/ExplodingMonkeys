//
//  GameViewController.swift
//  ExplodingMonkeys
//
//  Created by Huy Bui on 2022-12-14.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var gameScene: GameScene!
    
    @IBOutlet var player1Controls: UIStackView!
    @IBOutlet var player1NameLabel: UILabel!
    @IBOutlet var player1AngleSlider: UISlider!
    @IBOutlet var player1AngleLabel: UILabel!
    @IBOutlet var player1VelocitySlider: UISlider!
    @IBOutlet var player1VelocityLabel: UILabel!
    
    @IBOutlet var player2Controls: UIStackView!
    @IBOutlet var player2NameLabel: UILabel!
    @IBOutlet var player2AngleSlider: UISlider!
    @IBOutlet var player2AngleLabel: UILabel!
    @IBOutlet var player2VelocitySlider: UISlider!
    @IBOutlet var player2VelocityLabel: UILabel!
    
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var newGameButton: UIButton!
    
    @IBOutlet var player1WindLabel: UILabel!
    @IBOutlet var player2WindLabel: UILabel!
    
    var player1Score: Int! {
        didSet {
            player1NameLabel.text = "Player 1 (\(player1Score!))"
        }
    }
    var player2Score: Int! {
        didSet {
            player2NameLabel.text = "Player 2 (\(player2Score!))"
        }
    }
    
    var windSpeed: Double! {
        didSet {
            let text = "Wind: \(abs(windSpeed!))\(windSpeed! > 0 ? "E >>" : "W <<")"
            player1WindLabel.text = text
            player2WindLabel.text = text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player1Score = 0; player2Score = 0
        
        angleChanged(player1AngleSlider!)
        angleChanged(player2AngleSlider!)
        velocityChanged(player1VelocitySlider!)
        velocityChanged(player2VelocitySlider!)
        activatePlayer(1)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                gameScene = scene as? GameScene
                gameScene.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
    
    @IBAction func angleChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else { return }
        let text = "Angle: \(Int(slider.value))°"
        
        if slider.tag == 1 {
            player1AngleLabel.text = text
        } else if slider.tag == 2 {
            player2AngleLabel.text = text
        }
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else { return }
        let text = "Velocity: \(Int(slider.value))"
        
        if slider.tag == 1 {
            player1VelocityLabel.text = text
        } else if slider.tag == 2 {
            player2VelocityLabel.text = text
        }
    }
    
    @IBAction func launch(_ sender: Any) {
        // Disable controls & launch button.
        disableControls(forPlayer: 1)
        disableControls(forPlayer: 2)
        launchButton.isUserInteractionEnabled = false
        launchButton.alpha = 0.35
        
        let angle: Int, velocity: Int
        if gameScene.currentPlayer == 1 {
            angle = Int(player1AngleSlider.value)
            velocity = Int(player1VelocitySlider.value)
        } else if gameScene.currentPlayer == 2 {
            angle = Int(player2AngleSlider.value)
            velocity = Int(player2VelocitySlider.value)
        } else { return }
        gameScene.launch(angle: angle, velocity: velocity)
    }
    
    func activatePlayer(_ player: Int) {
        if player == 1 {
            enableControls(forPlayer: 1)
            disableControls(forPlayer: 2)
        } else if player == 2 {
            enableControls(forPlayer: 2)
            disableControls(forPlayer: 1)
        } else { return }
        
        launchButton.isUserInteractionEnabled = true
        launchButton.alpha = 1
        
        gameScene?.currentPlayer = player
        
        // Activate wind randomly.
        activateWind(forPlayer: player)
    }
    
    func enableControls(forPlayer player: Int) {
        if player == 1 {
            player1Controls.isUserInteractionEnabled = true
            player1Controls.alpha = 1
        } else if player == 2 {
            player2Controls.isUserInteractionEnabled = true
            player2Controls.alpha = 1
        }
    }
    
    func disableControls(forPlayer player: Int) {
        if player == 1 {
            player1Controls.isUserInteractionEnabled = false
            player1Controls.alpha = 0.35
        } else if player == 2 {
            player2Controls.isUserInteractionEnabled = false
            player2Controls.alpha = 0.35
        }
    }
    
    @IBAction func newGame(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.player1Score = 0; self.player2Score = 0
        }
        gameScene.newGame()
    }
    
    func enableNewGameButton() {
        launchButton.isHidden = true
        launchButton.isUserInteractionEnabled = false
        newGameButton.isHidden = false
        newGameButton.isUserInteractionEnabled = true
    }
    
    func disableNewGameButton() {
        launchButton.isHidden = false
        launchButton.isUserInteractionEnabled = true
        newGameButton.isHidden = true
        newGameButton.isUserInteractionEnabled = false
    }
    
    func activateWind(forPlayer player: Int) {
        player1WindLabel.isHidden = true
        player2WindLabel.isHidden = true
        
        if Bool.random()
//            && player1Score != 0 || player2Score != 0
        {
            var randomWindSpeed = Double.random(in: 1...10)
            if Bool.random() {
                randomWindSpeed *= -1
            }
            windSpeed = round(randomWindSpeed * 100) / 100
            
            gameScene?.physicsWorld.gravity = CGVector(dx: windSpeed, dy: -9.8)
            
            if player == 1 {
                player1WindLabel.isHidden = false
            } else if player == 2 {
                player2WindLabel.isHidden = false
            }
        } else {
            gameScene?.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        }
    }
    
}
