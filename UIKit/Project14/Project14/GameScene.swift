import SpriteKit

class GameScene: SKScene {
    
    var numRound = 0
    var popupTime = 0.85
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupScoreLabel()
        addSlots()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupScoreLabel() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.fontSize = 48
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        addChild(gameScore)
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func addSlots() {
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
    }
    
    func createEnemy() {
        numRound += 1
        if numRound >= 30 {
            gameOver()
            return
        }
        popupTime *= 0.991
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4  { slots[1].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 8  { slots[2].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)}
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
    
    func gameOver() {
        for slot in slots {
            slot.hide()
        }
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
        run(SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: true))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        for node in nodes {
            guard let slot = node.parent?.parent as? WhackSlot else { continue }
            if !slot.isVisible { continue }
            if slot.isHit { continue }
            slot.hit()
            if node.name == "friendChar" {
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                score -= score > 4 ? 5 : 0
            } else if node.name == "enemyChar" {
                score += 1
                node.xScale = 0.85
                node.yScale = 0.85
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
}
