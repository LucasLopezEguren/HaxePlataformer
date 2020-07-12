package gameObjects.effects;

import com.framework.utils.Input;
import kha.input.KeyCode;
import com.framework.utils.XboxJoystick;
import com.collision.platformer.Sides;

/* @author Lucas (181830) */
class Confusion extends Effect {
	var jumped:Bool = false;
	var durationTime:Float = 4;
	var currentTime:Float = 0;

	public function new(player:Player) {
		super(player);
		effectName = 'Confusion';
	}

	override function effect(dt:Float) {
		currentTime += dt;
		if (currentTime >= durationTime){
			player.removeEffect(this);
		}
		if (Input.i.isKeyCodeDown(KeyCode.Left)) {
			player.collision.accelerationX = 100;
			player.display.scaleX = 1;
		}
		if (Input.i.isKeyCodeDown(KeyCode.Right)){
			player.collision.accelerationX = -100;
			player.display.scaleX = -1;
		}
		if (!Input.i.isKeyCodeDown(KeyCode.Right) && !Input.i.isKeyCodeDown(KeyCode.Left)) {
			player.collision.accelerationX = 0;
			player.collision.velocityX = 0;
		}
	}
}
