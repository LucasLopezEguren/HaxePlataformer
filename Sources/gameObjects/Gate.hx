package gameObjects;

import kha.math.FastVector2;
import kha.math.FastVector2;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import GlobalGameData.GGD;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

/* @author Lucas (181830) */
class Gate extends Entity {
	var collisionGroup:CollisionGroup;
	var endGateCollision:CollisionGroup;
	public var collision:CollisionBox;
	public var display:Sprite;
	public var destinyX:Float;
	public var destinyY:Float;

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float, destinyX:Float, destinyY:Float) {
		super();
		display = new Sprite("gate");
		display.timeline.playAnimation('idle');
		collision = new CollisionBox();
		collisionGroup = collisions;
		collision.userData = this;
		collision.width = display.width() * 0.5;
		collision.height = display.height();
		collisions.add(collision);
		display.x = collision.x = x;
		display.y = collision.y = y;
		display.offsetX = -	display.width() * 0.25;
		this.destinyX = destinyX;
		this.destinyY = destinyY;
		layer.addChild(display);
	}
}
