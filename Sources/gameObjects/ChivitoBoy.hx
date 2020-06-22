package gameObjects;

import com.framework.utils.LERP;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class ChivitoBoy extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var hitCollision:CollisionBox;
	public var x(get, null):Float;
	public var y(get, null):Float;

	public function get_x():Float {
		return collision.x + collision.width * 0.5;
	}

	public function get_y():Float {
		return collision.y + collision.height;
	}

	var isAtacking:Bool;
	var isAirAtacking:Bool;
	var chainCombo:Bool;
	var chain3rdHit:Bool;
	var keepCombo:Bool;
	var facingRight:Bool;
	var maxSpeed = 200;

	public function new(x:Float, y:Float, layer:Layer) {
		super();
		display = new Sprite("hero");
		display.smooth = false;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width() * 0.5;
		collision.height = display.height() * 0.75;
		display.offsetY = -display.height() * 0.25;
		display.pivotX = display.width() * 0.25;
		hitCollision = new CollisionBox();
		display.scaleX = display.scaleY = 1;
		collision.x = x;
		collision.y = y;
		collision.userData = this;

		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;
	}

	inline function hitX():Float {
		return collision.x
			+ display.scaleX * collision.width * 0.5
			+ collision.width * 0.5
			+ (display.scaleX * hitCollision.width * 0.5 - hitCollision.width * 0.5);
	}

	override function update(dt:Float) {
		super.update(dt);
		collision.update(dt);
		hitCollision.update(dt);
		if (hitCollision.width > 0) {
			hitCollision.x = hitX();
		} else {
			hitCollision.x = collision.x 
			+ collision.width * 0.5;
		}
		hitCollision.y = collision.y + 5;
		if (display.timeline.currentAnimation == 'attack1' && !display.timeline.isComplete()) {
			hitCollision.width = 23;
			hitCollision.height = collision.height * 0.5;
		}
		if (display.timeline.currentFrame == 8) {
			collision.velocityX = display.scaleX * 1000;
			hitCollision.width = 30;
			hitCollision.height = collision.height * 0.5;
		}
		if (keepCombo && display.timeline.currentFrame == 13) {
			keepCombo = false;
			collision.velocityY = -200;
			collision.velocityX = display.scaleX * 500;
			hitCollision.width = 28;
			hitCollision.height = collision.height;
		}
		if (isAirAtacking && display.timeline.currentFrame == 13) {
			isAirAtacking = false;
			hitCollision.width = 28;
			hitCollision.height = collision.height;
		}
		if (display.timeline.currentAnimation != "attack1"
			&& display.timeline.currentAnimation != "attack2"
			&& display.timeline.currentAnimation != "attack3") {
			hitCollision.width = hitCollision.height = 0;
			hitCollision.removeFromParent();
		}
	}

	var startedComboX:Float;

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		if (display.timeline.currentAnimation != "attack1"
			&& display.timeline.currentAnimation != "attack2"
			&& display.timeline.currentAnimation != "attack3") {
			display.timeline.frameRate = (1 / 30) * s + (1 - s) * (1 / 10);
		}
		if (isAirAtacking) {
			display.timeline.frameRate = 1 / 10;
			display.timeline.playAnimation("attack3", false);
			return;
		} else if (display.timeline.currentAnimation == "attack3"
			&& !display.timeline.isComplete()
			&& !collision.isTouching(Sides.BOTTOM)) {
			return;
		}
		if (isAtacking && display.timeline.currentAnimation != "attack2" && display.timeline.currentAnimation != "attack3") {
			display.timeline.frameRate = 1 / 10;
			display.timeline.playAnimation("attack1", false);
			isAtacking = false;
			return;
		}
		if (display.timeline.currentAnimation == "attack1" && !display.timeline.isComplete()) {
			return;
		} else if (chainCombo) {
			startedComboX = collision.x;
			display.timeline.frameRate = 1 / 10;
			display.timeline.playAnimation("attack2", false);
			chainCombo = false;
			return;
		} else if (display.timeline.currentAnimation == "attack2" && !display.timeline.isComplete()) {
			return;
		} else if (chain3rdHit && Math.abs(startedComboX - collision.x) > 50) {
			display.timeline.frameRate = 1 / 10;
			display.timeline.playAnimation("attack3", false);
			keepCombo = true;
			chain3rdHit = false;
			return;
		} else if (display.timeline.currentAnimation == "attack3" && !display.timeline.isComplete()) {
			return;
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX * collision.accelerationX < 0) {
			display.timeline.playAnimation("slide");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
		} else if (collision.isTouching(Sides.BOTTOM)
			&& collision.velocityX != 0
			&& display.timeline.currentAnimation != "attack2"
			&& ((display.timeline.currentAnimation == "attack3" && display.timeline.isComplete())
				|| display.timeline.currentAnimation != "attack3")) {
			display.timeline.playAnimation("run");
		} else if (!collision.isTouching(Sides.BOTTOM)
			&& collision.velocityY > 0
			&& ((display.timeline.currentAnimation == "attack3" && display.timeline.isComplete())
				|| display.timeline.currentAnimation != "attack3")) {
			display.timeline.frameRate = 1 / 5;
			display.timeline.playAnimation("fall");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0 && display.timeline.currentAnimation != "attack3") {
			display.timeline.playAnimation("jump");
		}
	}

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				collision.accelerationX = -maxSpeed * 4;
				display.scaleX = -Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if (value == 1) {
				collision.accelerationX = maxSpeed * 4;
				display.scaleX = Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.A) {
			if (value == 1) {
				if (collision.isTouching(Sides.BOTTOM)
					&& ((display.timeline.currentAnimation != 'attack1'
						&& display.timeline.currentAnimation != 'attack2'
						&& display.timeline.currentAnimation != 'attack3')
						&& !display.timeline.isComplete())) {
					collision.velocityY = -1000;
				}
			}
		}
		if (id == XboxJoystick.X) {
			if (value == 1) {
				if (collision.isTouching(Sides.BOTTOM)) {
					collision.accelerationX = 0;
					attack();
				}
				if (!collision.isTouching(Sides.BOTTOM)) {
					airAttack();
				}
			}
		}
	}

	private function attack() {
		if (display.timeline.currentAnimation != 'attack1'
			&& display.timeline.currentAnimation != 'attack2'
			&& display.timeline.currentAnimation != 'attack3') {
			isAtacking = true;
		}
		if (display.timeline.currentAnimation == 'attack1' && !display.timeline.isComplete()) {
			chainCombo = true;
		}
		if (display.timeline.currentAnimation == 'attack2' && !display.timeline.isComplete()) {
			chain3rdHit = true;
		}
	}

	private function airAttack() {
		isAirAtacking = true;
	}

	public function onAxisChange(id:Int, value:Float) {}
}
