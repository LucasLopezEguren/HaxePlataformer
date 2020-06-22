package gameObjects;

import com.framework.utils.Random;
import com.collision.platformer.Sides;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import com.gEngine.display.Layer;

/**
 * ...
 * @author Joaquin
 */
class Jason extends Entity {
	var display:Sprite;
	var collision:CollisionBox;
	var collisionGroup:CollisionGroup;

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float) {
		super();
		collisionGroup = collisions;
		display = new Sprite("dummy");
		layer.addChild(display);
		collision = new CollisionBox();
		collision.userData = this;
		collisions.add(collision);
		display.offsetX = -display.width()/6;

		display.scaleX = 1/3;
		display.scaleY = 1/3;
		collision.width = display.width()/3;
		collision.height = display.height()/3;
		display.timeline.frameRate = 1 / 10;
		display.smooth = false;
		collision.x = x;
		collision.y = y;
		collision.accelerationY = 2000;
	}

	override public function update(dt:Float):Void {
		super.update(dt);
		collision.update(dt);
	}

	private function randomPos() {
		var target:ChivitoBoy = GGD.player;
		var dirX = 1 - Math.random() * 2;
		var dirY = 1 - Math.random() * 2;
		if (dirX == 0 && dirY == 0) {
			dirX += 1;
		}
		var length = Math.sqrt(dirX * dirX + dirY * dirY);
		collision.x = target.x + 500 * dirX / length;
		collision.y = target.y + 300 * dirY / length;
	}

	public function damage():Void {
		trace('should be dead');
		display.offsetY = -35;
		collision.removeFromParent();
	}

	override function render() {
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y;
		if (display.timeline.currentAnimation == "die_")
			return;
		if (Math.abs(collision.velocityX) > Math.abs(collision.velocityY)) {
			if (collision.velocityX > 0) {
				display.scaleX = 1;
			} else {
				display.scaleX = -1;
			}
		} else {
			if (collision.velocityY > 0) {
			} else {
			}
		}
		super.render();
	}
}
