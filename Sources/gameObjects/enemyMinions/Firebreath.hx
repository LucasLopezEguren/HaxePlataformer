package gameObjects.enemyMinions;

import GlobalGameData.GGD;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

/* @author Lucas (181830) */
class Firebreath extends Entity {
	public var proyectilesCollisions:CollisionGroup;

	public function new(enemyProyectilesCollisions:CollisionGroup) {
		super();
		pool = true;
		proyectilesCollisions = enemyProyectilesCollisions;
	}

	public function shoot(aX:Float, aY:Float, dirX:Float, dirY:Float):Void {
		var fireball:Fireball = cast recycle(Fireball);
		fireball.shoot(aX, aY, dirX, dirY, proyectilesCollisions);
	}
}
