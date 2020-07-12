package gameObjects.enemyMinions;

import kha.math.FastVector2;
import com.framework.utils.Random;
import com.collision.platformer.Sides;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import com.gEngine.display.Layer;


class Salamander extends EnemyMinion {
	
	var gravity:Int = GGD.gravity;
	var firebreath:Firebreath;

	static var MAX_SPEED = 100;

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float, enemyProyectilesCollisions:CollisionGroup) {
		super(layer, collisions, x, y);
		hitDamage = 10;
		scorePoints = currentHp = hpMax = 100;
		firebreath = new Firebreath(enemyProyectilesCollisions);
		addChild(firebreath);
		agressionRange = 200;
		display = new Sprite("salamander");
		display.timeline.playAnimation("idle");
		display.timeline.frameRate = 1 / 10	;
		display.smooth = false;
		display.offsetX = -display.width()/2 + 5;
		display.offsetY = -display.height()/2;
		display.pivotX = display.width() * 0.4;
		collision.width = display.width()/2;
		collision.height = display.height()/2;
		layer.addChild(display);
		collision.accelerationY = GGD.gravity;
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
		if (display.timeline.currentFrame == 19 && !shoot) {
			firebreath.shoot(x,y-display.height()/2,display.scaleX,0);
			shoot = true;
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

	var shoot:Bool = false;
	function attack(){
		if(display.timeline.currentAnimation != 'attack'){
			display.timeline.playAnimation('attack',false);
			shoot = false;
		}
	}

	override function render() {
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y;
		if (display.timeline.currentAnimation == "die") return;
		if (stunned) return;
		if(display.timeline.currentAnimation == 'attack' 
		&& !display.timeline.isComplete()){
			return;
		}
		super.render();
		if (walkTimeCounter < walkTime) {
			display.timeline.playAnimation('walk');
			if (!walkLeft) {
				display.scaleX = 1;
			} else {
				display.scaleX = -1;
			}
		} else {
			display.timeline.playAnimation('idle');
		}
	}
}
