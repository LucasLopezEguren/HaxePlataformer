package gameObjects.enemyMinions;

import GlobalGameData.GGD;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;

/* @author Lucas (181830) */
class Firebeam extends Proyectile {
	var bossWidth:Float;
	var bossHeight:Float;
	public function new() {
		display = new Sprite("beam");
		super();
		speed = 2000;
		lifeTime = 1.7;
		hitDamage = 25;
	}

	public function setBossSize(bossWidth:Float, bossHeight:Float){
		this.bossHeight = bossHeight;
		this.bossWidth = bossWidth;
		
	}

	override function shoot(x:Float, y:Float, dirX:Float, dirY:Float, proyectileCollision:CollisionGroup):Void {
		super.shoot(x,y,dirX,dirY,proyectileCollision);
		GGD.enemyProyectilesCollisions.add(collision);
		collision.velocityX = 0;
		display.offsetX = 0;
		display.pivotX = 0;
		if(dirX > 0){
			collision.x = x - (bossWidth/3 - (dirX * bossWidth/3) - bossWidth/2);
		} else {
			collision.x = x - (bossWidth/3 - (dirX * bossWidth/3) - bossWidth/5);
		}
		collision.y = y - bossHeight * 0.1;
	}

	override function update(dt:Float) {
		currentTime += dt;
		super.update(dt);
		collision.update(dt);
		
		//Manual Overlap because x stays constant and size goes down.
		if (GGD.player.y >= collision.y){
			if (GGD.player.x > (collision.x + collision.width)
			&& GGD.player.x < collision.x)
			GGD.player.damage(hitDamage);
		}
		display.scaleX += dirX * 0.1;
		collision.width = display.width() * display.scaleX;
		display.x = collision.x + dirX * display.offsetX;
		if (currentTime >= lifeTime) {
			die();
		}
	}
}
