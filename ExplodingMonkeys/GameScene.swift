//
//  GameScene.swift
//  ExplodingMonkeys
//
//  Created by Huy Bui on 2022-12-14.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var viewController: GameViewController!
    
//    private var buildings: [BuildingNode] = []
    private var buildings = [BuildingNode]()
    
    var player1: SKSpriteNode = { // Anonymous closure!
        let player1 = SKSpriteNode(imageNamed: "player")
        
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = GameObjects.player.rawValue
        player1.physicsBody?.collisionBitMask = GameObjects.banana.rawValue
        player1.physicsBody?.contactTestBitMask = GameObjects.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        player1.name = "player1"
        return player1
    }()
    var player2: SKSpriteNode! = {
        let player2 = SKSpriteNode(imageNamed: "player")
        
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = GameObjects.player.rawValue
        player2.physicsBody?.collisionBitMask = GameObjects.banana.rawValue
        player2.physicsBody?.contactTestBitMask = GameObjects.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        player2.name = "player2"
        return player2
    }()
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    // MARK: Starting point.
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        setupPlayers()
        
        physicsWorld.gravity
        
        physicsWorld.contactDelegate = self
    }
    
    func createBuildings() {
        var x: CGFloat = -15
        
        while x < scene!.size.width {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            x += size.width + 2 // 2: gap between buildings.
            
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: x - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            buildings.append(building)
        }
    }
    
    func setupPlayers() {
        let player1Building = buildings[1] // Second building.
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        let player2Building = buildings[buildings.count - 2] // Second to last building.
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10,
            radians = (Double(angle) * Double.pi) / 180
        
        // If banana exists, remove.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        // New banana.
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        
        // Physics body.
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = GameObjects.banana.rawValue
        banana.physicsBody?.collisionBitMask = GameObjects.building.rawValue
        banana.physicsBody?.contactTestBitMask = GameObjects.building.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(banana)
        
        banana.position =
        currentPlayer == 1
            ? CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            : CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
        
        banana.physicsBody?.angularVelocity =
        currentPlayer == 1
            ? -20
            : 20
        
        // Throwing action.
        let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player\(currentPlayer)Throw")),
            pause = SKAction.wait(forDuration: 0.15),
            lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
        let throwAction = SKAction.sequence([raiseArm, pause, lowerArm])
        currentPlayer == 1
            ? player1.run(throwAction)
            : player2.run(throwAction)
        
        var impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
        impulse.dx *= currentPlayer == 1
            ? 1
            : -1
        banana.physicsBody?.applyImpulse(impulse)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody, // Banana.
            secondBody: SKPhysicsBody // Building/banana.
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node,
              let secondNode = secondBody.node
        else { return }
        
        if firstNode.name == "banana" {
            if secondNode.name == "building" {
                bananaDidHitBuilding(secondNode, atPoint: contact.contactPoint)
            }
            if secondNode.name == "player1" {
                destroy(player: player1)
            }
            if secondNode.name == "player2" {
                destroy(player: player2)
            }
        }
    }
    
    func bananaDidHitBuilding(_ buiding: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = buiding as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = "" // Clear name so banana can't hit buildings twice, i.e. changing the player twic, i.e. reverting to the previous player.
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        if player.name == "player1" {
            viewController.player2Score += 1
        } else if player.name == "player2" {
            viewController.player1Score += 1
        }
        
        let threshold = 3
        if viewController.player1Score == threshold || viewController.player2Score == threshold {
            // Game over.
            viewController.enableNewGameButton()
        } else {
            // MARK: Start new game.
            newGame()
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(currentPlayer)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    @objc func newGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewController.disableNewGameButton()
            
            let newGameScene = GameScene(size: self.size)
            newGameScene.viewController = self.viewController
            self.viewController.gameScene = newGameScene
            
            self.changePlayer()
            newGameScene.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGameScene, transition: transition)
        }
    }
    
}
