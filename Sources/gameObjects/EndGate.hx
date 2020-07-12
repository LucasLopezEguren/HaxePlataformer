package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import GlobalGameData.GGD;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

/* @author Lucas (181830) */
class EndGate extends Entity {
	var collisionGroup:CollisionGroup;
	public var collision:CollisionBox;
	public var display:Sprite;

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float) {
		super();
		display = new Sprite("gate");
		display.timeline.playAnimation('idle');
		display.colorAdd(0.75,0,0,0);
		display.colorMultiplication(0,0.6,0.6,1);
		collision = new CollisionBox();
		collisionGroup = collisions;
		collision.userData = this;
		collision.width = display.width() * 0.5;
		collision.height = display.height();
		collisions.add(collision);
		display.x = collision.x = x;
		display.y = collision.y = y;
		display.offsetX = -	display.width() * 0.25;
		layer.addChild(display);
	}

}
