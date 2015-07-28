//
//  GameScene.swift
//  Heros
//
//  Created by Cal Leung on 3/13/15.
//  Copyright (c) 2015 calprojects. All rights reserved.
//

import SpriteKit

enum BodyType : UInt32 {
    case hero = 1
    case kryptonite = 2
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero = SKSpriteNode()
    var moveAndRemoveClouds = SKAction()
    var randomCloudTime = (arc4random() % 5) + 1
    var moveClouds = SKAction()
    var removeClouds = SKAction()
    var distanceToMoveClouds = CGFloat()
    var delayCloudSpawn = SKAction()
    var healthBar = SKSpriteNode()
    var rock = SKSpriteNode()
    var healthPoints = 300
    
    override func didMoveToView(view: SKView) {
        
        //Initializes the background
        
        physicsWorld.contactDelegate = self
        self.scene?.backgroundColor = UIColor(red: 196/255, green: 228/255, blue: 1.0, alpha: 1.0)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        
        //Creates the hero
        let heroPic = SKTexture(imageNamed: "superman")
        heroPic.filteringMode = SKTextureFilteringMode.Nearest
        hero = SKSpriteNode(texture: heroPic, size: heroPic.size())
        hero.position = CGPointMake(self.frame.size.width / 3, self.frame.size.height / 2)
        hero.setScale(0.5)
        hero.zPosition = 5
        hero.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: heroPic.size().width * 0.5, height: heroPic.size().height * 0.5))
        hero.physicsBody?.dynamic = false
        hero.physicsBody?.categoryBitMask = BodyType.hero.rawValue
        hero.physicsBody?.contactTestBitMask = BodyType.kryptonite.rawValue
        //hero.physicsBody?.collisionBitMask = 0
        self.addChild(hero)
        
        //Creates the health bar
        var healthBarBox = SKNode()
        healthBarBox.position = CGPointMake(self.frame.size.width / 2, 152)
        var healthBarOutline = SKShapeNode(rectOfSize: CGSize(width: 303, height: 33))
        healthBarOutline.strokeColor = UIColor.blackColor()
        healthBar = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 300, height: 30))
        healthBarBox.zPosition = 10
        healthBarBox.addChild(healthBarOutline)
        healthBarBox.addChild(healthBar)
        self.addChild(healthBarBox)
        
        //Spawns and moves the clouds
        let spawnCloudFunc = SKAction.runBlock({() in self.spawnClouds()})
        delayCloudSpawn = SKAction.waitForDuration(NSTimeInterval(0.75))
        let spawnAndDelayClouds = SKAction.sequence([spawnCloudFunc,delayCloudSpawn])
        let spawnCloudsForever = SKAction.repeatActionForever(spawnAndDelayClouds)
        self.runAction(spawnCloudsForever)
        
        distanceToMoveClouds = CGFloat(self.frame.size.width * 3)
        moveClouds = SKAction.moveByX(-distanceToMoveClouds, y: 0, duration: NSTimeInterval(7))
        removeClouds = SKAction.removeFromParent()
        moveAndRemoveClouds = SKAction.sequence([moveClouds,removeClouds])
        
        //Spawns kryptonite
        let spawnKryptoniteFunc = SKAction.runBlock({() in self.spawnKryptonite()})
        let delayKryptoniteSpawn = SKAction.waitForDuration(NSTimeInterval(2))
        let spawnAndDelayKryptonite = SKAction.sequence([spawnKryptoniteFunc,delayKryptoniteSpawn])
        let spawnKryptoniteForever = SKAction.repeatActionForever(spawnAndDelayKryptonite)
        self.runAction(spawnKryptoniteForever)
    }
    
    func spawnKryptonite() {
        var randomNum = arc4random() % UInt32(self.frame.size.width)
        //rock = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: 50, height: 50))
        let civilians = ["person1","person2","person3","person4","person5"]
        var randomNumCivilian = arc4random() % 5
        var randomPerson = civilians[Int(randomNumCivilian)]
        let civilianTexture = SKTexture(imageNamed: randomPerson)
        rock = SKSpriteNode(texture: civilianTexture)
        rock.setScale(0.8)
        rock.position = CGPointMake(CGFloat(randomNum), self.frame.size.height)
        rock.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        rock.physicsBody?.categoryBitMask = BodyType.kryptonite.rawValue
        rock.physicsBody?.collisionBitMask = 0
        self.addChild(rock)
    }
    
    func spawnClouds() {
        //Randomizes cloud pictures
        var cloudList = ["cloud1", "cloud2", "cloud3", "cloud4", "cloud5","cloud6"]
        var randomNum = arc4random() % 6
        var randomCloud = cloudList[Int(randomNum)]
        let cloudTexture = SKTexture(imageNamed: randomCloud)
        var cloud = SKSpriteNode(texture: cloudTexture)
        //Sets transparency depending on zPosition
        var randomT = arc4random() % 10
        if (randomT > UInt32(hero.zPosition)) {
            cloud.zPosition = CGFloat(randomT)
            cloud.alpha = 0.6
        }
        //Sets cloud size and randomizes position
        cloud.setScale(2.7)
        var randomPositionX = arc4random() % UInt32(self.frame.size.width)
        var randomPositionY = arc4random() % UInt32(self.frame.size.height)
        cloud.position = CGPointMake(CGFloat(randomPositionX) + self.frame.size.width * 1.5, CGFloat(randomPositionY))
        //Moves cloud across
        cloud.runAction(moveAndRemoveClouds)
        self.addChild(cloud)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contact = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contact) {
        case BodyType.hero.rawValue | BodyType.kryptonite.rawValue:
            NSLog("Superman is hurt!")
            if (healthPoints > 0) {
                healthPoints -= 20
                healthBar.size = CGSize(width: healthPoints, height: 30)
                let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 0.2)
                let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.2)
                let hurtFade = SKAction.sequence([fadeOut,fadeIn])
                hero.runAction(hurtFade)
            }
            break
        default:
            break
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let moveHero = SKAction.moveTo(location, duration: NSTimeInterval(0.3))
            hero.runAction(moveHero)
            //hero.physicsBody?.dynamic = true
            hero.physicsBody?.mass = 0.3
            hero.physicsBody?.velocity = CGVectorMake(0, 0)
            hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

    }
}
