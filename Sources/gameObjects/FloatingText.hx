package gameObjects;

import com.gEngine.display.Text;
import kha.Assets;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

/* @author Lucas (181830) */
class FloatingText extends Entity {
	var display:Text;
	var lifeTime:Float = 1;
	var currentTime:Float = 0;
	var collision:CollisionBox;
	var layer:Layer;

	public function new(text:String, x:Float, y:Float, layer:Layer) {
		super();
		display = new Text(Assets.fonts.PixelOperator8_BoldName);
		display.text = text;
		collision = new CollisionBox();
		collision.x = x;
		collision.y = y;
		display.x = x;
		display.y = y;
		this.layer = layer;
		this.layer.addChild(display);
	}

	override function update(dt:Float) {
		collision.update(dt);
		super.update(dt);
		currentTime += dt;
		trace(currentTime);
		if (currentTime >= lifeTime) {
			die();
		}
	}

	override function die() {
		super.die();
		display.removeFromParent();
	}

	override function render() {
		super.render();
		trace("Esta si se llama");
		display.x = collision.x;
		display.y = collision.y;
	}
}
