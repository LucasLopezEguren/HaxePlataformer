package gameObjects.enemyMinions;

import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

/* @author Lucas (181830) */
class Meteor extends Proyectile {
	public function new() {
		display = new Sprite("meteor");
		super();
	}

	override function shoot(x:Float, y:Float, dirX:Float, dirY:Float, proyectileCollision:CollisionGroup):Void {
		super.shoot(x,y,dirX,dirY,proyectileCollision);	
		GGD.enemyProyectilesCollisions.add(collision);
		collision.velocityX = 0;
		collision.accelerationY = GGD.gravity/4;
	}
}
