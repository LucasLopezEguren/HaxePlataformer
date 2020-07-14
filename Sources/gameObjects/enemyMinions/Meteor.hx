package gameObjects.enemyMinions;

import gameObjects.effects.Confusion;
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
		speed = 200;
	}

	override function get_hitDamage():Int {
		if (confuse){ 
			GGD.player.addEffect(new Confusion(GGD.player)); 
		}
		return hitDamage;
	}

	override function update(dt:Float){
		super.update(dt);
		collision.update(dt);
		super.dissapear(dt);
	}

	var confuse:Bool = false;
	override function shoot(x:Float, y:Float, dirX:Float, dirY:Float, proyectileCollision:CollisionGroup):Void {
		hitDamage=15;
		this.dirX = 0;
		super.shoot(x,y,dirX,dirY,proyectileCollision);	
		var confuseChance:Int = Math.ceil(Math.random()*10);
		if (confuseChance > 7) {
			confuse = true;
			display.colorMultiplication (1,0,1,1);
		} else {
			confuse = false;
			display.colorMultiplication (1,1,1,1);
		}
		collision.y = y;
		GGD.enemyProyectilesCollisions.add(collision);
		collision.velocityX = 0;
		collision.velocityY = speed;
	}
}
