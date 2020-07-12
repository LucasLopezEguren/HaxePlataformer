package gameObjects;

import com.framework.utils.LERP;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import GlobalGameData.GGD;
import gameObjects.effects.Confusion;
import gameObjects.effects.RangeAttack;

class Player extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var hitCollision:CollisionBox;

	public var invulerable:Bool = false;
	var receiveLowDamage:Bool = false;
	var receiveHeavyDamage:Bool = false;
	var isDying:Bool = false;
	var invulerableTime:Float = 0;
	var timeCounter:Float = 0;
	var effects:List<Effect>;

	public var x(get, null):Float;
	public var y(get, null):Float;
	var destinyX:Float;
	var destinyY:Float;
	var isTransporting:Bool = false;

	public function get_x():Float {
		return collision.x + collision.width * 0.5;
	}

	public function get_y():Float {
		return collision.y + collision.height;
	}

	public function transport(newX:Float, newY:Float) {
		if(!isTransporting){
			isTransporting = true;
			invulerable = true;
			destinyX = newX;
			destinyY = newY;
			invulerableTime = 1;
			timeCounter = 0;
		}
	}

	public function respawn(x:Float, y:Float, layer:Layer) {
		this.x = x;
		this.y = y;
		display = new Sprite("hero");
		display.smooth = false;
		GGD.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width() * 0.5;
		collision.height = display.height() * 0.75;
		display.offsetY = -display.height() * 0.25;
		display.pivotX = display.width() * 0.25;
		display.scaleX = display.scaleY = 1;
		collision.x = x;
		collision.y = y;
		collision.userData = this;

		collision.accelerationY = GGD.gravity;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;

		isDying = false;
		currentHp = maxHp;
	}

	var isReapiring:Bool = false;
	public function reapearing() {
		isReapiring = true;
		isTransporting = false;
		invulerable = true;
		invulerableTime = 1;
		collision.x = destinyX;
		collision.y = destinyY;
		timeCounter = 0;
	}

	var isAtacking:Bool;
	var isAirAtacking:Bool;
	var chainCombo:Bool;
	var chain3rdHit:Bool;
	var keepCombo:Bool;
	var facingRight:Bool;
	var maxSpeed = 200;
	public var currentHp:Int = 200;
	public var maxHp:Int = 200;
	var hitDamage:Int = 0;
	public function get_hitDamage():Int {
		return hitDamage;
	}

	public function new(x:Float, y:Float, layer:Layer) {
		super();
		effects = new List<Effect>();
		display = new Sprite("hero");
		display.smooth = false;
		GGD.simulationLayer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width() * 0.5;
		collision.height = display.height() * 0.75;
		display.offsetY = -display.height() * 0.25;
		display.pivotX = display.width() * 0.25;
		display.scaleX = display.scaleY = 1;
		collision.x = x;
		collision.y = y;
		collision.userData = this;

		collision.accelerationY = GGD.gravity;
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

	public function addEffect(effect:Effect){
		if (!effect.isAcumulative && effects.length > 0) {
			for(actualEffect in effects){
				if(actualEffect.effectName == effect.effectName){
					return;
				}
			}
		}
		effects.add(effect);
	}

	public function removeEffect(effect:Effect){
		effects.remove(effect);
	}

	override function update(dt:Float) {
		if(isDying && !receiveHeavyDamage){
			return;
		}
		super.update(dt);
		if (isTransporting) {
			timeCounter += dt;
			if (invulerableTime > timeCounter) {
				timeCounter += dt;
			} else {
				reapearing();
			}
			display.scaleX = display.scaleY = 1-timeCounter;
			return;
		}
		if (isReapiring) {
			display.scaleX = display.scaleY = 0.1+timeCounter;
			if (invulerableTime > timeCounter) {
				timeCounter += dt;
			} else {
				display.scaleX = display.scaleY = 1;
				invulerable = false;
				isReapiring = false;
				invulerableTime = 0;
				timeCounter = 0;
			}
			return;
		}
		collision.update(dt);
		if (effects.length > 0){
			for(effect in effects){
				effect.effect(dt);
			}
		}
		if (receiveHeavyDamage) {
			receiveHeavyDamage = false;
			collision.velocityX = -display.scaleX * 100;
			collision.velocityY = -150;
		}
		if (hitCollision != null) {
			hitCollision.update(dt);
		}
		if (invulerable) {
			if (invulerableTime > timeCounter) {
				timeCounter += dt;
			} else {
				invulerable = false;
			}
			display.colorMultiplication(1, 1, 1, 0.5);
		} else {
			display.colorMultiplication(1, 1, 1, 1);
		}
		if (hitCollision != null) {
			if (hitCollision.width > 0) {
				hitCollision.x = hitX();
			} else {
				hitCollision.x = collision.x + collision.width * 0.5;
			}
			hitCollision.y = collision.y + 5;
			if (display.timeline.currentAnimation == 'attack1' && !display.timeline.isComplete()) {
				hitCollision.width = 23;
				hitCollision.height = collision.height * 0.5;
				hitDamage = 10;
			}
			if (display.timeline.currentFrame == 13
			&& display.timeline.currentAnimation == 'attack2') {
				collision.velocityX = display.scaleX * 1000;
				hitCollision.width = 30;
				hitCollision.height = collision.height * 0.5;
				hitDamage = 15;
			}
			if (keepCombo && display.timeline.currentFrame == 17
			&& display.timeline.currentAnimation == 'attack3') {
				keepCombo = false;
				collision.velocityY = -200;
				collision.velocityX = display.scaleX * 500;
				hitCollision.width = 28;
				hitCollision.height = collision.height;
				hitDamage = 40;
			}
			if (isAirAtacking
			&& display.timeline.currentFrame == 19 
			&& display.timeline.currentAnimation == 'attack3') {
				isAirAtacking = false;
				hitCollision.width = 28;
				hitCollision.height = collision.height;
				hitDamage = 30;
			}
			if (display.timeline.currentAnimation != "attack1"
				&& display.timeline.currentAnimation != "attack2"
				&& display.timeline.currentAnimation != "attack3") {
				hitCollision.width = hitCollision.height = 0;
				hitCollision.removeFromParent();
				hitDamage = 0;
			}
		}

		if (receiveLowDamage) {
			receiveLowDamage = false;
			collision.velocityX = -display.scaleX * 50;
			collision.velocityY = -150;
		}
	}

	var startedComboX:Float;

	public function damage(damageRecieve:Int) {
		if (isDying) return;
		if (damageRecieve <= 0) return;
		if (!invulerable) {
			if (damageRecieve < maxHp / 4) {
				receiveLowDamage = true;
			} else {
				receiveHeavyDamage = true;
			}
			currentHp -= damageRecieve;
			if (currentHp <= 0) {
				receiveHeavyDamage = true;
				GGD.continues -= 1;
				die();
				return;
			}
			invulerable = true;
			invulerableTime = 1;
			timeCounter = 0;
		}
	}

	override function die() {
		if (isDying) return;
		isDying = true;
		receiveHeavyDamage = true;
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		if (isDying) {
			if (display.timeline.currentAnimation == "heavyDamage") {
				return;
			}
			display.timeline.playAnimation("heavyDamage", false);
			return;
		}
		if (receiveLowDamage) {
			display.timeline.frameRate = 1 / 10;
			display.timeline.playAnimation("damage", false);
		} else if (receiveHeavyDamage) {
			display.timeline.frameRate = 1 / 10;
			display.timeline.playAnimation("heavyDamage", false);
		} else if ((display.timeline.currentAnimation == "damage" || display.timeline.currentAnimation == "heavyDamage")
			&& !display.timeline.isComplete()) {
			return;
		} else {
			if (display.timeline.currentAnimation != "attack1"
				&& display.timeline.currentAnimation != "attack2"
				&& display.timeline.currentAnimation != "attack3") {
				display.timeline.frameRate = (1 / 30) * s + (1 - s) * (1 / 10);
			}
			if (display.timeline.currentAnimation == "rangeAttack" && !display.timeline.isComplete()) {
				return;
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
			if (isAtacking 
				&& display.timeline.currentAnimation != "attack2" 
				&& display.timeline.currentAnimation != "attack3"
				&& display.timeline.currentAnimation != "rangeAttack") {
				display.timeline.frameRate = 1 / 10;
				display.timeline.playAnimation("attack1", false);
				isAtacking = false;
				return;
			} else if (display.timeline.currentAnimation == "attack1" && !display.timeline.isComplete()) {
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
	}

	public function onButtonChange(id:Int, value:Float) {
		if (display.timeline.currentAnimation == "rangeAttack" && !display.timeline.isComplete()) {
			return;
		}
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1 && !isDying) {
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
			hitCollision = new CollisionBox();
			hitCollision.userData = this;
		}
		if (display.timeline.currentAnimation == 'attack1' && !display.timeline.isComplete()) {
			chainCombo = true;
		}
		if (display.timeline.currentAnimation == 'attack2' && !display.timeline.isComplete()) {
			chain3rdHit = true;
		}
	}

	private function airAttack() {
		hitDamage = 20;
		hitCollision = new CollisionBox();
		hitCollision.userData = this;
		isAirAtacking = true;
	}

	public function onAxisChange(id:Int, value:Float) {}
}
