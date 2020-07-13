package gameObjects.enemyMinions;

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
	var hitTimes:Int;
	var endGateCollision:CollisionGroup;
	var simulationlayer:Layer;
	var hpBarMaxSize:Float;
	var bossCurrentHpBar:RectangleDisplay;
	var armGun:ArmGun;
	public function new(layer:Layer, collisions:CollisionGroup, endGateCollision:CollisionGroup, bossCurrentHpBar:RectangleDisplay, x:Float, y:Float, enemyProyectilesCollisions:CollisionGroup) {
		super(layer, collisions, x, y);
		hitDamage = 10;
		this.endGateCollision = endGateCollision;
		hpBarMaxSize = bossCurrentHpBar.scaleX;
		this.bossCurrentHpBar = bossCurrentHpBar;
		simulationlayer = layer;
		scorePoints = currentHp = hpMax = 1000;
		display = new Sprite("boss");
		agressionRange = 20000;
		armGun = new ArmGun(enemyProyectilesCollisions, display.width(), display.height());
		addChild(armGun);
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

	override function get_hitDamage():Int{
		if (!stunned && !target.invulerable && !target.isDead()){
			
		}
		return super.get_hitDamage();
	}

	
	var timeBetweenAtacks:Float = 2;
	var timeBetweenAtacksCounter:Float = 0;
	var walkTime:Float = 2;
	var walkTimeCounter:Float = 2;
	var standTimeCounter:Float = 0;
	var walkLeft:Bool = false;
	override public function update(dt:Float):Void {
		collision.update(dt);
		super.update(dt);
		if (bossCurrentHpBar != null) {
			bossCurrentHpBar.scaleX = (currentHp * hpBarMaxSize) / hpMax;
			if (bossCurrentHpBar.scaleX <= 0) bossCurrentHpBar.scaleX = 0;
		}
		if (display.timeline.currentAnimation == 'attack2'){
			trace(display.timeline.currentFrame);
		}
		if (display.timeline.currentFrame == 102 && !shoot) {
			armGun.shoot(x,y-display.height()/2,display.scaleX,0);
			shoot = true;
		}
		if (display.timeline.currentFrame == 89 && !shoot) {
			armGun.stomp(target.x,y-display.height()/2,display.scaleX,0,6);
			shoot = true;
		}
	}

	override function damage(damageReceived:Int):Void {
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
				display.timeline.playAnimation('hurt', false);
				stunned = true;
				timeCounter = 0;
			}
			lastDamageReceived = damageReceived;
		}
	}

	override function aggresiveStance(dt:Float){
		var dir:FastVector2 = new FastVector2(target.x - (collision.x + collision.width * 0.5), target.y - (collision.y + collision.height * 1.5));
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

	var shoot:Bool = false;
	function attack(){
		if(display.timeline.currentAnimation != 'attack'){
			display.timeline.frameRate = 1/20;
			display.timeline.playAnimation('attack2',false);
			shoot = false;
		}
	}

	override function passiveStance(dt:Float){
		timeBetweenAtacksCounter = timeBetweenAtacks;
		if (standTimeCounter < walkTime){
			collision.velocityX = 0;
			standTimeCounter += dt;
			if (standTimeCounter > walkTime){
				walkTimeCounter = 0;
				walkLeft = !walkLeft;
			}
		} 
		if (walkTimeCounter < walkTime){
			if (walkLeft) {
				collision.velocityX = -50;
			} else {
				collision.velocityX = 50;
			}
			walkTimeCounter += dt;
			if (walkTimeCounter > walkTime){
				standTimeCounter = 0;
			}
		}
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
		if (stunned) {
			display.colorMultiplication(1,1,1,1);
			return;
		}
		if ((display.timeline.currentAnimation == 'attack' 
		|| display.timeline.currentAnimation == 'attack2') 
		&& !display.timeline.isComplete() ) return;
		display.timeline.frameRate = 1/10;
		if (target.x - collision.x > 0) {
			display.scaleX = 1;
			display.timeline.playAnimation('idle');
		} else {
			display.scaleX = -1;
			display.timeline.playAnimation('idle');
		}
		super.render();
	}
}
