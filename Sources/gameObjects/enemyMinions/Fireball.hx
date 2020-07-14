package gameObjects.enemyMinions;

import com.soundLib.SoundManager.SM;
import kha.Assets;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

/* @author Lucas (181830) */
class Fireball extends Proyectile {
	public function new() {
		display = new Sprite("fireball");
		super();
		speed = 100;
	}

	override function update(dt:Float){
		super.update(dt);
		collision.update(dt);
		super.dissapear(dt);
	}

	override function shoot(x:Float, y:Float, dirX:Float, dirY:Float, proyectileCollision:CollisionGroup):Void {
		super.shoot(x,y,dirX,dirY,proyectileCollision);	
		GGD.enemyProyectilesCollisions.add(collision);
		SM.playFx(Assets.sounds.blueFireName, false);
	}
}
