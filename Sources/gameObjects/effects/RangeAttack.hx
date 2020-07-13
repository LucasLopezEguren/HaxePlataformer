package gameObjects.effects;

import GlobalGameData.GGD;
import com.collision.platformer.CollisionGroup;
import com.framework.utils.Input;
import kha.input.KeyCode;
import com.framework.utils.XboxJoystick;
import com.collision.platformer.Sides;

/* @author Lucas (181830) */
class RangeAttack extends Effect {
	var inCooldown:Bool = false;
	var shooted:Bool = false;
	var cooldown:Float = 1;
	var currentTime:Float = 0;

	public var proyectilesCollisions:CollisionGroup;

	public function new(player:Player) {
		super(player);
		pool = true;
		isAcumulative = false;
		effectName = 'RangeAttack';
		proyectilesCollisions = GGD.playerProyectilesCollisions;
		player.addChild(this);
	}

	override function effect(dt:Float) {
		currentTime += dt;
		if (currentTime >= cooldown) {
			inCooldown = false;
		}
		if (Input.i.isKeyCodePressed(KeyCode.A) && !inCooldown) {
			inCooldown = true;
			currentTime = 0;
			shooted = false;
			player.collision.accelerationX = 0;
			player.display.timeline.frameRate = 1 / 10;
			player.display.timeline.playAnimation('rangeAttack', false);
		}
		if (inCooldown && !shooted
		&& player.display.timeline.currentAnimation == 'rangeAttack' 
		&& player.display.timeline.currentFrame == 7) {
			shooted = true;
			shoot(player.x, player.y - player.display.height() + 20, player.display.scaleX, 0);
		}
	}

	public function shoot(aX:Float, aY:Float, dirX:Float, dirY:Float):Void {
		var fireball:BlueFireball = cast recycle(BlueFireball);
		fireball.shoot(aX, aY, dirX, dirY, proyectilesCollisions);
	}
}
