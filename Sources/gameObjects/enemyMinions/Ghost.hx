package gameObjects.enemyMinions;

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


class Ghost extends EnemyMinion {
	var hitTimes:Int;
	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float) {
		super(layer, collisions, x, y);
		hitDamage = 10;
		agressionRange = 200;
		scorePoints = currentHp = hpMax = 50;
		display = new Sprite("ghost");
		layer.addChild(display);
		hitTimes = Math.ceil(Math.random() * 3);
		display.timeline.frameRate = 1 / 25;
		display.timeline.playAnimation("idle");
		display.offsetX = -display.width() / 6;
		display.offsetY = -display.height() * 0.25;
		display.pivotX = display.width() * 0.25;
		display.offsetY = -display.height() / 3;
		display.smooth = false;
		collision.width = display.width() / 3;
		collision.height = display.height() / 3;
		if (hitTimes == 1){
			display.colorMultiplication(1,0,1,1);
		} else {
			display.colorMultiplication(1,1,1,1);
		}
	}
	var MAX_SPEED = 200;

	override function get_hitDamage():Int{
		if (!stunned && !target.invulerable && !target.isDead()){
			hitTimes++;
			hitTimes = hitTimes%3;
			if ( hitTimes == 1){
				target.addEffect(new Confusion(target));
			}
		}
		return super.get_hitDamage();
	}

	override function update(dt:Float){
		super.update(dt);
		
		if (hitTimes == 0){
			display.colorMultiplication(1,0,1,1);
		} else {
			display.colorMultiplication(1,1,1,1);
		}
	}

	override function aggresiveStance(dt:Float){
		var dir:FastVector2 = new FastVector2(target.x - (collision.x + collision.width * 0.5), target.y - (collision.y + collision.height * 1.5));
			
			if (Math.abs(dir.x) < 10) {
				dir.x = 0;
			}
			if (Math.abs(dir.y) < 10) {
				dir.y = 0;
			}

			dir.setFrom(dir.normalized());
			dir.setFrom(dir.mult(MAX_SPEED));
			collision.accelerationX = dir.x;
			collision.accelerationY = dir.y;
			collision.maxVelocityX = collision.maxVelocityX = 100;
	}

	override function passiveStance(dt:Float) {
		collision.velocityX = 0;
		collision.velocityY = 0;
	}

	override function render() {
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y;
		if (display.timeline.currentAnimation == "die") return;
		if (stunned) return;
		if (Math.abs(collision.velocityX) > Math.abs(collision.velocityY)) {
			if (collision.accelerationX > 0) {
				if (collision.velocityX < 0){
					display.timeline.playAnimation('slide');
				} else {
					display.scaleX = -1;
					display.timeline.playAnimation('idle');
				}
			} else {
				if (collision.velocityX > 0){
					display.timeline.playAnimation('slide');
				} else {
					display.scaleX = 1;
					display.timeline.playAnimation('idle');
				}
			}
		} 
		super.render();
	}
}
