package gameObjects;

import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

/* @author Lucas (181830) */
class Proyectile extends Entity {
	public var collision:CollisionBox;

	var display:Sprite;
	var lifeTime:Float = 4;
	var currentTime:Float = 0;
	var dirX:Float;
	var speed:Float = 150;
	public var hitDamage(get, null):Int = 15;
	public function get_hitDamage():Int {
		return hitDamage;
	}

	public function new() {
		super();
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.userData = this;
	}

	override function die() {
		super.die();
		limboStart();
	}

	override function limboStart() {
		display.removeFromParent();
		collision.removeFromParent();
	}

	override function update(dt:Float) {
		super.update(dt);
		currentTime += dt;
		collision.update(dt);
		display.x = collision.x;
		display.y = collision.y;
		if (currentTime >= lifeTime) {
			die();
		}
	}

	function dissapear(dt:Float){
		if (lifeTime - currentTime < 1) {
			display.scaleX = dirX * (lifeTime - currentTime);
			display.scaleY = lifeTime - currentTime;
			
			collision.width = display.width() * Math.abs(display.scaleX);
			collision.height = display.height() * display.scaleY;
		}
	}

	public function shoot(x:Float, y:Float, dirX:Float, dirY:Float, proyectileCollision:CollisionGroup):Void {
		display.scaleX = dirX;
		display.scaleY = 1;
		collision.width = display.width();
		collision.height = display.height();
		this.dirX = dirX;
		currentTime = 0;
		collision.x = x;
		collision.y = y;
		display.offsetX = (display.width() / 4) - (dirX * display.width()/4);
		display.pivotX = display.width() * 0.25;
		display.smooth = false;
		collision.velocityX = speed * display.scaleX;
		collision.velocityY = 0;
		GGD.simulationLayer.addChild(display);
		display.timeline.playAnimation('idle');
		display.timeline.frameRate = 1/10;
	}
}
