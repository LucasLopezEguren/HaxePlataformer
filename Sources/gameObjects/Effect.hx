package gameObjects;

import com.framework.utils.Entity;

/* @author Lucas (181830) */
class Effect extends Entity {
	var player:Player;
	public var isAcumulative:Bool = true;
	public var effectName:String;

	public function new(player:Player) {
		super();
		this.player = player;
		player.addEffect(this);
	}

	public function effect(dt:Float) {

	}
}
