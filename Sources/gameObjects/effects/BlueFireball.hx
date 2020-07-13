package gameObjects.effects;

import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

/* @author Lucas (181830) */
class BlueFireball extends Entity {
	public var collision:CollisionBox;

	var display:Sprite;
	var lifeTime:Float = 4;
	var currentTime:Float = 0;
	var dirX:Float;
	public var hitDamage(get, null):Int = 30;
	public function get_hitDamage():Int {
		return hitDamage;
	}

	public function new() {
		super();
		collision = new CollisionBox();
		display = new Sprite("blueFireball");
		collision.width = display.width()/2;
		collision.height = display.height()/2;
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
		if (lifeTime - currentTime < 1) {
			display.scaleX = dirX * (lifeTime - currentTime);
			display.scaleY = lifeTime - currentTime;
			
			collision.width = display.width() * Math.abs(display.scaleX);
			collision.height = display.height() * display.scaleY;
		}
		if (currentTime >= lifeTime) {
			die();
		}
	}

	public function shoot(x:Float, y:Float, dirX:Float, dirY:Float, proyectileCollision:CollisionGroup):Void {
		display = new Sprite("blueFireball");
		display.scaleX = dirX * -(1/3) * 2;
		display.scaleY = 1/3 * 2;
		collision.width = display.width() * 2 / 3;
		collision.height = display.height() * 2 / 3 + 5;
		this.dirX = dirX;
		currentTime = 0;
		collision.x = x;
		collision.y = y;
		display.offsetX = (display.width()/3) - (display.scaleX * 3 / 2 * (display.width()/3));
		display.smooth = false;
		collision.velocityX = 300 * dirX;
		collision.velocityY = 0;
		GGD.playerProyectilesCollisions.add(collision);
		GGD.simulationLayer.addChild(display);
		display.timeline.playAnimation('idle');
		display.timeline.frameRate = 1/10;
	}
}
