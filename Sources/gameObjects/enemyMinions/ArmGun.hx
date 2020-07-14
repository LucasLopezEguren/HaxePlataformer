package gameObjects.enemyMinions;

import GlobalGameData.GGD;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

/* @author Lucas (181830) */
class ArmGun extends Entity {
	public var proyectilesCollisions:CollisionGroup;
	var bossWidth:Float;
	var bossHeight:Float;

	public function new(enemyProyectilesCollisions:CollisionGroup, bossWidth:Float, bossHeight:Float) {
		super();
		pool = true;
		proyectilesCollisions = enemyProyectilesCollisions;
		this.bossWidth = bossWidth;
		this.bossHeight = bossHeight;
	}

	public function shoot(aX:Float, aY:Float, dirX:Float, dirY:Float):Void {
		var firebeam:Firebeam = cast recycle(Firebeam);
		firebeam.setBossSize(bossWidth, bossHeight);
		firebeam.shoot(aX, aY, dirX, dirY, proyectilesCollisions);
	}
}
