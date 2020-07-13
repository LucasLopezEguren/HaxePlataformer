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

	var xRange:Int = 300;
	public function stomp(aX:Float, aY:Float, dirX:Float, dirY:Float, times:Int):Void {
		for(i in 0...times){
			var meteor:Meteor = cast recycle(Meteor);
			var randomX = aX - xRange + (Math.ceil(Math.random()*600));
			meteor.shoot(randomX, 0, 0, dirY, proyectilesCollisions);
		}
	}
}
