//
//  GameScene.swift
//  SpriteKitFirst
//
//  Created by Roman on 29.06.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //MARK: - 1. Создаем экземпляр Node
    var dog: SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        //MARK: Размер задника
        let width = UIScreen.main.bounds.width * 2
        let height = UIScreen.main.bounds.height * 2
        
        let undertaleBackground = SKSpriteNode(imageNamed: "Undertale")
        undertaleBackground.position = CGPoint(x: 667, y: 375)
        undertaleBackground.size = CGSize(width: width, height: height)
       
        
        
    //MARK: - 2. Init Node
        dog = SKSpriteNode(imageNamed: "UndertaleDog")
        dog.position = CGPoint(x: 100, y: 350)
        dog.size = CGSize(width: 150, height: 150)

        dog.physicsBody = SKPhysicsBody(circleOfRadius: max(dog.size.width / 2, dog.size.height / 2))
        dog.physicsBody?.isDynamic = false
        
        
        addChild(undertaleBackground)
        addChild(dog)
        
        
        //MARK: - Создание цетков
        
        let flowerCreate = SKAction.run {
            let flower = self.createFlowers
            self.addChild(flower())
        }
        let flowerCreationDelay = SKAction.wait(forDuration: 0.5, withRange: 0.5)
        let flowerSequenceAction = SKAction.sequence([flowerCreate, flowerCreationDelay])
        let flowerRunAction = SKAction.repeatForever(flowerSequenceAction)
        run(flowerRunAction)
    
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
        //MARK: - 3. Определяем точку прикосновения
            let touchLocation = touch.location(in: self)
            
        print(touchLocation)
            
        //MARK: - 4. Создаем действие
            let moveAction = SKAction.move(to: touchLocation, duration: 0.6)
            dog.run(moveAction)
        }
    }
    
    
    func createFlowers() -> SKSpriteNode {
        let flower = SKSpriteNode(imageNamed: "BadFlower")
        flower.xScale = 0.7
        flower.yScale = 0.7
        
        flower.position.y = CGFloat.random(in: 0 ..< 750)
        flower.position.x = frame.size.width + flower.size.width

        flower.physicsBody = SKPhysicsBody(circleOfRadius: max(flower.size.width / 2, flower.size.height / 2))
        
        return flower
    }
    
    override func update(_ currentTime: TimeInterval) {
       

    }
    
}
