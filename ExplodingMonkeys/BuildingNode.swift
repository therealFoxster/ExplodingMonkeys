//
//  BuildingNode.swift
//  ExplodingMonkeys
//
//  Created by Huy Bui on 2022-12-14.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!
    
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = GameObjects.building.rawValue
        physicsBody?.contactTestBitMask = GameObjects.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let output = renderer.image { context in
            let color: UIColor
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            case 2:
                fallthrough
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            color.setFill()
            
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fill)
            
            let lightOffColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1),
                lightOnColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                    Bool.random() ? lightOffColor.setFill() : lightOnColor.setFill()
                    context.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        
        return output
    }
    
    func hit(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - size.height / 2))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let output = renderer.image { context in
            currentImage.draw(at: .zero)
            
            context.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            context.cgContext.setBlendMode(.clear)
            context.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: output)
        currentImage = output
        
        configurePhysics()
    }
    
}
