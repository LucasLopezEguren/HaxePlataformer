package gameObjects.enemyMinions;

import com.gEngine.GEngine;
import com.gEngine.helper.RectangleDisplay;
import gameObjects.effects.Confusion;
import kha.math.FastVector2;
import com.framework.utils.Random;
import com.collision.platformer.Sides;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import com.gEngine.display.Layer;
import gameObjects.EnemyMinion;


class Boss extends EnemyMinion {
	var endGateCollision:CollisionGroup;
	var simulationlayer:Layer;
	var hpBarMaxSize:Float;
	var bossCurrentHpBar:RectangleDisplay;
	var armGun:ArmGun;
	var stompAttack:StompAttack;
	public function new(layer:Layer, collisions:CollisionGroup, endGateCollision:CollisionGroup, bossCurrentHpBar:RectangleDisplay, x:Float, y:Float, enemyProyectilesCollisions:CollisionGroup) {
		super(layer, collisions, x, y);
		hitDamage = 0;
		this.endGateCollision = endGateCollision;
		hpBarMaxSize = bossCurrentHpBar.scaleX;
		this.bossCurrentHpBar = bossCurrentHpBar;
		simulationlayer = layer;
		scorePoints = currentHp = hpMax = 1000;
		display = new Sprite("boss");
		agressionRange = 20000;
		armGun = new ArmGun(enemyProyectilesCollisions, display.width(), display.height());
		stompAttack = new StompAttack(enemyProyectilesCollisions);
		addChild(armGun);
		addChild(stompAttack);
		layer.addChild(display);
		display.timeline.frameRate = 1 / 10;
		display.timeline.playAnimation("idle");
		display.offsetY = -20;
		display.offsetX = -40;
		display.pivotX = display.width() * 0.27;
		display.smooth = true;
		collision.width = display.width()/2;
		collision.height = display.height() - 20;
		collision.accelerationY = GGD.gravity;
	}

	
	var timeBetweenAtacks:Float = 0.3;
	var timeBetweenAtacksCounter:Float = 0;

	var timeToAct:Float = 1;
	var timeToActCounter:Float = 0.5;
	var timeInvulnerable:Float;
	var acting:Bool = false;
	override public function update(dt:Float):Void {
		collision.update(dt);
		super.update(dt);
		stunnedTime = (currentHp * 0.5) / hpMax;
		timeInvulnerable = timeToAct - stunnedTime;
		timeBetweenAtacks = 0.3 + (currentHp * 2) / hpMax;
		if (stunned && timeCounter >= stunnedTime) {
			timeToActCounter = 0;
		}
		if (timeInvulnerable >= timeToActCounter) {
			invulerable = true;
			hitDamage = 0;
			timeToActCounter += dt;
		} else {
			hitDamage = 0;
			invulerable = false;
		}
		if (bossCurrentHpBar != null) {
			bossCurrentHpBar.scaleX = (currentHp * hpBarMaxSize) / hpMax;
			if (bossCurrentHpBar.scaleX <= 0) bossCurrentHpBar.scaleX = 0;
		}
		if (display.timeline.currentFrame == 102 && !attacked) {
			armGun.shoot(x,y-display.height()/2,display.scaleX,0);
			attacked = true;
		}
		if (display.timeline.currentFrame == 89 && !attacked) {
			var meteors = Math.ceil((11 - (currentHp * 10) / hpMax));
			trace('meteor' + meteors);
			stompAttack.stomp(target.x,y-display.height()/2,display.scaleX,0,meteors);
			attacked = true;
		}
		if (isTransporting) {
			timeCounter += dt;
			if (invulerableTime > timeCounter) {
				timeCounter += dt;
			} else {
				reapearing();
			}
			return;
		}
		if (isReapiring) {
			if (invulerableTime > timeCounter) {
				timeCounter += dt;
			} else {
				display.scaleX = display.scaleY = 1;
				invulerable = false;
				isReapiring = false;
				invulerableTime = 0;
				timeCounter = 0;
			}
			return;
		}
		if(display.timeline.currentAnimation != 'idle' 
			&& display.timeline.currentAnimation != 'hurt' ){
			acting = true;
			hitDamage = 20;
		} else {
			acting = false;
			hitDamage = 0;
		}
	}

	override function damage(damageReceived:Int):Void {
		if (invulerable) return;
		if (damageReceived == 0) return;
		if (lastDamageReceived != damageReceived){
			currentHp -= damageReceived;
			if(currentHp <= 0){
				addPoints();
				display.timeline.playAnimation('die', false);
				collision.velocityX = collision.velocityY = 0;
				collision.accelerationY = collision.accelerationX = 0;
				collision.removeFromParent();
			} else {
				stunned = true;
				timeCounter = 0;
				if (display.timeline.currentAnimation != 'idle'){
				} else {
					display.timeline.playAnimation('hurt', false);
				}
			}
			lastDamageReceived = damageReceived;
		}
	}

	override function aggresiveStance(dt:Float){
		collision.velocityX = 0;
		if(target.x - collision.x > 0) {
			display.scaleX = 1;
		} else {
			display.scaleX = -1;
		}
		if (timeBetweenAtacks <= timeBetweenAtacksCounter){
			attack();
			timeBetweenAtacksCounter = 0;
		} else {
			timeBetweenAtacksCounter += dt;
		}
	}

	var worldWidth:Float = 1650;
	var attacked:Bool = false;
	function attack(){
		var action = Math.ceil(Math.random() * 13);
		if(display.timeline.currentAnimation != 'attack' 
			&& display.timeline.currentAnimation != 'attack2'
			&& display.timeline.currentAnimation != 'appear'
			&& display.timeline.currentAnimation != 'dissappear' ){
			if(action >= 12) {
				transport(200+(Math.random()*(worldWidth-400)), collision.y);
			} else if (action == 11) {
				//dead time to receive attacks
			} else if (action <= 5){
				display.timeline.frameRate = 1/20;
				display.timeline.playAnimation('attack2',false);
				attacked = false;
			} else {
				display.timeline.frameRate = 1/10;
				display.timeline.playAnimation('attack',false);
				attacked = false;
			}

		}
			
	}

	var isTransporting:Bool = false;
	var invulerable:Bool = false;
	var destinyX:Float;
	var destinyY:Float;
	var invulerableTime:Float;
	var invulerableTimeCounter:Float;
	public function transport(newX:Float, newY:Float) {
		if(!isTransporting){
			invulerable = true;
			display.timeline.frameRate = 1/10;
			display.timeline.playAnimation("disappear", false);
			isTransporting = true;
			destinyX = newX;
			destinyY = newY;
			invulerableTime = 2.5;
			invulerableTimeCounter = 0;
		}
	}

	var isReapiring:Bool = false;
	public function reapearing() {
		display.timeline.playAnimation("appear", false);
		isReapiring = true;
		isTransporting = false;
		invulerable = true;
		invulerableTime = 1;
		collision.x = destinyX;
		collision.y = destinyY;
		timeCounter = 0;
	}

	override function passiveStance(dt:Float){
		timeBetweenAtacksCounter = timeBetweenAtacks;
	}

	static var gateOutX:Float = 300;
	static var gateOutY:Float = 600;
	override function die(){
		super.die();
		var endGate = new EndGate(simulationlayer, endGateCollision, gateOutX, gateOutY);
		addChild(endGate);
	}

	override function render() {
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y;
		if (display.timeline.currentAnimation == "die") return;
		if ((display.timeline.currentAnimation == 'attack' 
		|| display.timeline.currentAnimation == 'attack2'
		|| display.timeline.currentAnimation == 'appear'
		|| display.timeline.currentAnimation == 'disappear') 
		&& !display.timeline.isComplete() ) {
			return;
		} 
		if (stunned) {
			if(timeCounter <= stunnedTime) {
				var colorMod = timeCounter/stunnedTime;
				display.colorMultiplication(colorMod,colorMod,colorMod,1);
			} else if (timeCounter >= stunnedTime) {
				display.colorMultiplication(1,1,1,1);
			}
			return;
		}
		if ((display.timeline.currentAnimation == 'attack' 
		|| display.timeline.currentAnimation == 'attack2'
		|| display.timeline.currentAnimation == 'appear'
		|| display.timeline.currentAnimation == 'disappear') 
		&& !display.timeline.isComplete() ) {
			return;
		} else {
			display.timeline.frameRate = 1/10;
			display.timeline.playAnimation('idle');
			if (acting) return;
			if (target.x - collision.x > 0) {
				display.scaleX = 1;
			} else {
				display.scaleX = -1;
			}
		}
		super.render();
	}
}
