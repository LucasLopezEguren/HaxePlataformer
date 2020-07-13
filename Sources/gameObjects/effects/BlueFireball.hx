package gameObjects.effects;

import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

/* @author Lucas (181830) */
class BlueFireball extends Proyectile {

	public function new() {
		display = new Sprite("blueFireball");
		super();
		hitDamage = 30;
		speed = 300;
	}

	override function shoot(x:Float, y:Float, dirX:Float, dirY:Float, proyectileCollision:CollisionGroup):Void {
		display = new Sprite("blueFireball");
		super.shoot(x,y,dirX,dirY,proyectileCollision);
		this.dirX = -dirX;
		display.scaleX = this.dirX;
		currentTime = 0;
		display.offsetX = (display.width()/2) - (display.scaleX * 0.5 * (display.width()/2));
		display.smooth = false;
		GGD.playerProyectilesCollisions.add(collision);
	}

	override function update(dt:Float){
		super.update(dt);
		collision.update(dt);
		super.dissapear(dt);
	}
}
