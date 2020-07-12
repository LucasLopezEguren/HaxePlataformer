package gameObjects;

import kha.math.FastVector2;
import com.framework.utils.Random;
import com.collision.platformer.Sides;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import com.gEngine.display.Layer;


class EnemyMinion extends Entity {
	var display:Sprite;
	var collision:CollisionBox;
	var collisionGroup:CollisionGroup;
	var agressionRange:Float = 200;
	var target:Player;
	var hpMax:Int;
	var currentHp:Int;
	var scorePoints:Int = 0;
	public var x(get, null):Float;
	public var y(get, null):Float;
	public var hitDamage(get, null):Int;
	var stunned:Bool=false;

	public function get_x():Float {
		return collision.x + collision.width * 0.5;
	}

	public function get_y():Float {
		return collision.y + collision.height;
	}

	public function get_hitDamage():Int {
		return hitDamage;
	}

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float) {
		super();
		collision = new CollisionBox();
		collision.userData = this;
		collisionGroup = collisions;
		collision.x = x;
		collision.y = y;
		collisions.add(collision);
		target = GGD.player;
	}

	function addPoints() {
		GGD.score += scorePoints;
	}

	var stunnedTime:Float = 0.5;
	var timeCounter:Float = 0;
	
	var dyingTime:Float = 0;
	var disapearTime:Float = 2;
	override public function update(dt:Float):Void {
		super.update(dt);
		collision.update(dt);
		if (display.timeline.currentAnimation == 'die'){
			dyingTime += dt;
			if (dyingTime <= disapearTime){
				display.colorMultiplication(1,1,1,1-(dyingTime/disapearTime));
			} else {
				display.removeFromParent();
				die();
			}
			return;	
		} 
		if(stunned && timeCounter <= stunnedTime) {
			display.colorMultiplication(1,1,1,0.5);
			hitDamage = 0;
			timeCounter += dt;
			return;
		} else if (stunned && timeCounter >= stunnedTime) {
			stunned = false;
			lastDamageReceived = 0;
			hitDamage = 10;
			display.colorMultiplication(1,1,1,1);
			timeCounter = 0;
		}
		
		if (Math.abs(target.x - collision.x) < agressionRange 
		&& Math.abs(target.y - collision.y) < agressionRange) {
			aggresiveStance(dt);
		} else {
			passiveStance(dt);
		}
	}

	function aggresiveStance (dt:Float) {}
	function passiveStance (dt:Float) {}

	var lastDamageReceived:Int=0;
	public function damage(damageReceived:Int):Void {
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

}
