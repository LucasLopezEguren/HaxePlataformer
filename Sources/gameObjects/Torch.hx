package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import GlobalGameData.GGD;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

/* @author Lucas (181830) */
class Torch extends Entity {
	var collisionGroup:CollisionGroup;
	public var collision:CollisionBox;
	public var display:Sprite;

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float) {
		super();
		display = new Sprite("torch");
		display.timeline.playAnimation('idle');
		collision = new CollisionBox();
		collisionGroup = collisions;
		collision.userData = this;
		collision.width = display.width();
		collision.height = display.height();
		collisions.add(collision);
		display.x = collision.x = x;
		display.y = collision.y = y;
		collision.accelerationY = GGD.gravity;
		layer.addChild(display);
	}

	override function update (dt:Float){
		super.update(dt);
		collision.update(dt);
		
		display.x = collision.x;
		display.y = collision.y;
	}

	override function die(){
		super.die();
		collision.removeFromParent();
		display.removeFromParent();
	}

}
