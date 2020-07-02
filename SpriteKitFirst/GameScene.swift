//
//  GameScene.swift
//  SpriteKitFirst
//
//  Created by Roman on 29.06.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    //nodes
    var gameNode: SKNode!
    var groundNode: SKNode!
    var flowerNode: SKNode!
    var dogNode: SKNode!
    
    //score
    var scoreNode: SKLabelNode!
    var resetInstructions: SKLabelNode!
    var score = 0 as Int
       
    //sprites
    var dogSprite: SKSpriteNode!
       
    //spawning vars
    var spawnRate = 1.5 as Double
    var timeSinceLastSpawn = 0.0 as Double
       
    //generic vars
    var groundHeight: CGFloat?
    var dogYPosition: CGFloat?
    var groundSpeed = 500 as CGFloat
       
    //consts
    let dogHopForce = 900 as Int
    let background = 0 as CGFloat
    let foreground = 1 as CGFloat
       
    //collision categories
    let groundCategory = 1 << 0 as UInt32
    let dogCategory = 1 << 1 as UInt32
    let flowerCategory = 1 << 2 as UInt32
    
    
    //MARK: - 1. Создаем экземпляр Node
    
    override func didMove(to view: SKView) {

        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        
        //MARK: Размер задника
        //background elements
        let width = UIScreen.main.bounds.width * 2.5
        let height = UIScreen.main.bounds.height * 2.5
  
        let undertaleBackground = SKSpriteNode(imageNamed: "Undertale")
        undertaleBackground.position.x = 667
        undertaleBackground.position.y = 375
        undertaleBackground.zPosition = background
        undertaleBackground.size = CGSize(width: width, height: height)
        addChild(undertaleBackground)
  
        //ground
        groundNode = SKNode()
        groundNode.zPosition = background
        createAndMoveGround()
        addCollisionToGround()
             
        //dog
        dogNode = SKNode()
        dogNode.zPosition = foreground
        createDog()
             
        //flower
        flowerNode = SKNode()
        flowerNode.zPosition = foreground
             
        //score
        score = 0
        scoreNode = SKLabelNode(fontNamed: "Arial")
        scoreNode.fontSize = 30
        scoreNode.zPosition = foreground
        scoreNode.text = "Score: 0"
        scoreNode.fontColor = SKColor.gray
        scoreNode.position = CGPoint(x: 150, y: 80)
             
        //reset instructions
        resetInstructions = SKLabelNode(fontNamed: "Arial")
        resetInstructions.fontSize = 50
        resetInstructions.text = "Tap to Restart"
        resetInstructions.fontColor = SKColor.white
        resetInstructions.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        resetInstructions.isHidden = true
             
        //parent game node
        gameNode = SKNode()
        gameNode.addChild(groundNode)
        gameNode.addChild(dogNode)
        gameNode.addChild(flowerNode)
        gameNode.addChild(scoreNode)
        gameNode.addChild(resetInstructions)
        self.addChild(gameNode)
    }
    
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
   
    if(gameNode.speed < 1.0){
        resetGame()
        return
        }
        
    for _ in touches {
        if let groundPosition = dogYPosition {
            if dogSprite.position.y <= groundPosition && gameNode.speed > 0 {
                dogSprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: dogHopForce))
                   
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        if(gameNode.speed > 0){
            groundSpeed += 0.2
            
            score += 1
            scoreNode.text = "Score: \(score/5)"
            
            if(currentTime - timeSinceLastSpawn > spawnRate){
                timeSinceLastSpawn = currentTime
                spawnRate = Double.random(in: 1.0 ..< 3.5)
                spawnFlowers()
            }
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if hitFlower(contact){
            gameOver()
        }
    }
    
    
    func hitFlower(_ contact: SKPhysicsContact) -> Bool {
        return contact.bodyA.categoryBitMask & flowerCategory == flowerCategory ||
            contact.bodyB.categoryBitMask & flowerCategory == flowerCategory
    }
    
 
    func resetGame() {
        gameOver()
        gameNode.speed = 1.0
        timeSinceLastSpawn = 0.0
        groundSpeed = 500
        score = 0

        flowerNode.removeAllChildren()
      
        resetInstructions.isHidden = true
        
        let dogTexture1 = SKTexture(imageNamed: "UndertaleDog")
        let dogTexture2 = SKTexture(imageNamed: "UndertaleDogRun")
        dogTexture1.filteringMode = .nearest
        dogTexture2.filteringMode = .nearest
        
        let runningAnimation = SKAction.animate(with: [dogTexture1, dogTexture2], timePerFrame: 0.12)
        
        dogSprite.position = CGPoint(x: self.frame.size.width * 0.15, y: dogYPosition!)
        dogSprite.run(SKAction.repeatForever(runningAnimation))
    }
    
    
    func gameOver() {
        gameNode.speed = 0.0
        resetInstructions.isHidden = false
        resetInstructions.fontColor = SKColor.white
        let deadDogTexture = SKTexture(imageNamed: "UndertaleDogDead")
        deadDogTexture.filteringMode = .nearest
        
        dogSprite.removeAllActions()
        dogSprite.texture = deadDogTexture
    
    }
    
    
    //MARK: - createAndMoveGround
    func createAndMoveGround() {
        let screenWidth = self.frame.size.width
        
        //ground texture
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        let homeButtonPadding = 50.0 as CGFloat
        groundHeight = groundTexture.size().height + homeButtonPadding
        
        //ground actions
        let moveGroundLeft = SKAction.moveBy(x: -groundTexture.size().width,
                                             y: 0.0, duration: TimeInterval(screenWidth / groundSpeed))
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0.0, duration: 0.0)
        let groundLoop = SKAction.sequence([moveGroundLeft, resetGround])
        
        //ground nodes
        let numberOfGroundNodes = 1 + Int(ceil(screenWidth / groundTexture.size().width))
        
        for i in 0 ..< numberOfGroundNodes {
            let node = SKSpriteNode(texture: groundTexture)
            node.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            node.position = CGPoint(x: CGFloat(i) * groundTexture.size().width, y: groundHeight!)
            groundNode.addChild(node)
            node.run(SKAction.repeatForever(groundLoop))
        }
    }
    
    //MARK: - addCollisionToGround
    func addCollisionToGround() {
        let groundContactNode = SKNode()
        groundContactNode.position = CGPoint(x: 0, y: groundHeight! - 30)
        groundContactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width * 3,
                                                                          height: groundHeight!))
        groundContactNode.physicsBody?.friction = 0.0
        groundContactNode.physicsBody?.isDynamic = false
        groundContactNode.physicsBody?.categoryBitMask = groundCategory
        
        groundNode.addChild(groundContactNode)
    }
  
  
    
    
    
    
    
    
    
    
    func createDog() {
        let screenWidth = self.frame.size.width
        let dogScale = 0.5 as CGFloat
        
        //textures
        let dogTexture1 = SKTexture(imageNamed: "UndertaleDog")
        let dogTexture2 = SKTexture(imageNamed: "UndertaleDogRun")
        dogTexture1.filteringMode = .nearest
        dogTexture2.filteringMode = .nearest
        
        let runningAnimation = SKAction.animate(with: [dogTexture1, dogTexture2], timePerFrame: 0.2)
        
        dogSprite = SKSpriteNode()
        dogSprite.size = dogTexture1.size()
        dogSprite.setScale(dogScale)
        dogNode.addChild(dogSprite)
        
        let physicsBox = CGSize(width: dogTexture1.size().width * dogScale/2,
                                height: dogTexture1.size().height * dogScale/2)
        
        dogSprite.physicsBody = SKPhysicsBody(rectangleOf: physicsBox)
        dogSprite.physicsBody?.isDynamic = true
        dogSprite.physicsBody?.mass = 1.0
        dogSprite.physicsBody?.categoryBitMask = dogCategory
        dogSprite.physicsBody?.contactTestBitMask = flowerCategory
        dogSprite.physicsBody?.collisionBitMask = groundCategory
        
        dogYPosition = getGroundHeight() + dogTexture1.size().height * dogScale
        dogSprite.position = CGPoint(x: screenWidth * 0.15, y: dogYPosition!)
        dogSprite.run(SKAction.repeatForever(runningAnimation))
    }
    
    func spawnFlowers() {
        let flowerTextures = ["BadFlower", "EvilFlower", "PrettyFlower"]
        let flowerScale = 1.0 as CGFloat
        
        //texture
        let flowerTexture = SKTexture(imageNamed: flowerTextures.randomElement()!)
        flowerTexture.filteringMode = .nearest
        
        //sprite
        let flowerSprite = SKSpriteNode(texture: flowerTexture)
        flowerSprite.setScale(flowerScale)
        
        //physics
        let contactBox = CGSize(width: flowerTexture.size().width * flowerScale,
                                height: flowerTexture.size().height * flowerScale)
        flowerSprite.physicsBody = SKPhysicsBody(rectangleOf: contactBox)
        flowerSprite.physicsBody?.isDynamic = true
        flowerSprite.physicsBody?.mass = 1.0
        flowerSprite.physicsBody?.categoryBitMask = flowerCategory
        flowerSprite.physicsBody?.contactTestBitMask = dogCategory
        flowerSprite.physicsBody?.collisionBitMask = groundCategory
        
        //add to scene
        flowerNode.addChild(flowerSprite)
        //animate
        animateFlower(sprite: flowerSprite, texture: flowerTexture)
    }
    
    func animateFlower(sprite: SKSpriteNode, texture: SKTexture) {
        let screenWidth = self.frame.size.width
        let distanceOffscreen = 50.0 as CGFloat
        let distanceToMove = screenWidth + distanceOffscreen + texture.size().width
        
        //actions
        let moveFlower = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(screenWidth / groundSpeed))
        let removeFlower = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveFlower, removeFlower])
        
        sprite.position = CGPoint(x: distanceToMove, y: getGroundHeight() + texture.size().height)
        sprite.run(moveAndRemove)
    }
  
    
    func getGroundHeight() -> CGFloat {
        if let gHeight = groundHeight {
            return gHeight
        } else {
            print("Ground size wasn't previously calculated")
            exit(0)
        }
    }

    
}
