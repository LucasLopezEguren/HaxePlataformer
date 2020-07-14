package gameObjects.enemyMinions;

import GlobalGameData.GGD;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

/* @author Lucas (181830) */
class StompAttack extends Entity {
	public var proyectilesCollisions:CollisionGroup;
	var bossWidth:Float;
	var bossHeight:Float;

	public function new(enemyProyectilesCollisions:CollisionGroup) {
		super();
		pool = true;
		proyectilesCollisions = enemyProyectilesCollisions;
	}

	var xRange:Int = 300;
	var yRange:Int = 100;
	public function stomp(aX:Float, aY:Float, dirX:Float, dirY:Float, times:Int):Void {
		for(i in 0...times){
			var meteor:Meteor = cast recycle(Meteor);
			var randomX = aX - xRange + (Math.ceil(Math.random()*600));
			var randomY = (Math.ceil(Math.random()*yRange));
			meteor.shoot(randomX, randomY, dirX, dirY, proyectilesCollisions);
		}
	}
}
