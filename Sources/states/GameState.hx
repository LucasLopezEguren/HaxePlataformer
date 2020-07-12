package states;

import gameObjects.effects.RangeAttack;
import com.gEngine.display.Text;
import com.gEngine.display.StaticLayer;
import com.gEngine.GEngine;
import com.gEngine.helper.RectangleDisplay;
import kha.FastFloat;
import gameObjects.EnemyMinion;
import gameObjects.enemyMinions.Fireball;
import gameObjects.effects.BlueFireball;
import gameObjects.Gate;
import gameObjects.EndGate;
import gameObjects.Torch;
import GlobalGameData.GGD;
import com.loading.basicResources.SparrowLoader;
import com.loading.basicResources.FontLoader;
import com.collision.platformer.ICollider;
import com.collision.platformer.CollisionBox;
import com.collision.platformer.CollisionGroup;
import com.loading.basicResources.ImageLoader;
import format.tmx.Data.TmxObjectType;
import com.gEngine.display.Sprite;
import com.gEngine.shaders.ShRetro;
import com.gEngine.display.Blend;
import com.gEngine.shaders.ShRgbSplit;
import com.gEngine.display.Camera;
import kha.Assets;
import helpers.Tray;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.Player;
import gameObjects.enemyMinions.Ghost;
import gameObjects.enemyMinions.Salamander;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import cinematic.Dialog;

class GameState extends State {
	var worldMap:Tilemap;
	var damageMap:Tilemap;
	var player:Player;
	var simulationLayer:Layer;
	var hudLayer:StaticLayer;
	var touchJoystick:VirtualGamepad;
	var tray:helpers.Tray;
	var dialogCollision:CollisionGroup;
	var enemiesCollisions:CollisionGroup;
	var endGateCollisions:CollisionGroup;
	var secretGateCollisions:CollisionGroup;
	var torchCollisions:CollisionGroup;
	var enemyProyectilesCollisions:CollisionGroup;

	public function new(room:String, fromRoom:String = null) {
		super();
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader(Assets.blobs.testRoom_tmxName));
		var atlas = new JoinAtlas(2048, 2048);

		atlas.add(new TilesheetLoader("tiles2", 32, 32, 0));
		atlas.add(new FontLoader(Assets.fonts.PixelOperator8_BoldName, 30));
		atlas.add(new ImageLoader("salt"));
		atlas.add(new ImageLoader("yo"));
		atlas.add(new ImageLoader("avatar"));
		atlas.add(new SpriteSheetLoader("ghost", 60, 60, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]),
			new Sequence("die", [24, 25, 26, 27, 28, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40]),
			new Sequence("slide", [61, 61]),
			new Sequence("hurt", [60])
		]));
		atlas.add(new SpriteSheetLoader("gate", 50, 85, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8])
		]));
		atlas.add(new SpriteSheetLoader("torch", 29, 75, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
		]));
		atlas.add(new SpriteSheetLoader("blueFireball", 34, 25, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7])
		]));
		atlas.add(new SpriteSheetLoader("salamander", 60, 40, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5]),
			new Sequence("walk", [6, 7, 8, 9, 10, 11, 12, 13]),
			new Sequence("attack", [17, 18, 19, 20, 21, 22, 23, 24, 25, 26]),
			new Sequence("die", [14, 15, 16]),
			new Sequence("hurt", [14, 15])
		]));
		atlas.add(new SpriteSheetLoader("fireball", 33, 25, 0, [
			new Sequence("idle", [0, 1])
		]));
		atlas.add(new SpriteSheetLoader("hero", 60, 60, 0, [
			new Sequence("fall", [14, 15]),
			new Sequence("slide", [58]),
			new Sequence("jump", [13]), 
			new Sequence("rangeAttack", [49, 50, 51, 52, 49]),
			new Sequence("attack1", [32, 33, 34]),
			new Sequence("attack2", [36, 37, 38, 39]), 
			new Sequence("attack3", [40, 41, 42, 43, 44]), 
			new Sequence("run", [4, 5, 6, 7, 8, 9, 10, 11]),
			new Sequence("idle", [0, 1, 2, 3, 2, 1]), 
			new Sequence("heavyDamage", [19, 20, 21, 22, 23]), 
			new Sequence("damage", [25, 26, 27]), 
			new Sequence("rangeAttack", [11])]));
		atlas.add(new FontLoader("Kenney_Pixel", 24));
		resources.add(atlas);
	}

	var currentHpBar:RectangleDisplay;
	var hpBarTotal:RectangleDisplay;
	var scoreDisplay:Text;
	override function init() {
		stageColor(0.5, .5, 0.5);
		
		dialogCollision = new CollisionGroup();
		secretGateCollisions = new CollisionGroup();
		torchCollisions = new CollisionGroup();
		endGateCollisions = new CollisionGroup();
		GGD.enemyProyectilesCollisions = new CollisionGroup();
		if(GGD.playerProyectilesCollisions == null) GGD.playerProyectilesCollisions = new CollisionGroup();
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		enemiesCollisions = new CollisionGroup();
		GGD.simulationLayer = simulationLayer;
		if (GGD.player != null) {
			player = GGD.player;
			player.respawn(250, 200, simulationLayer);
		} else {
			player = new Player(250, 200, simulationLayer);
			GGD.player = player;
		}
		var mayonnaiseMap:TileMapDisplay;
		worldMap = new Tilemap("testRoom_tmx", 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (tileLayer.properties.exists("damage"))return;
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("tiles2")));
			mayonnaiseMap = layerTilemap.createDisplay(tileLayer, new Sprite("tiles2"));
			simulationLayer.addChild(mayonnaiseMap);
		}, parseMapObjects);

		damageMap = new Tilemap("testRoom_tmx", 1);
		damageMap.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("tiles2")));
			mayonnaiseMap = layerTilemap.createDisplay(tileLayer, new Sprite("tiles2"));
			simulationLayer.addChild(mayonnaiseMap);
		});

		tray = new Tray(mayonnaiseMap);
		
		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 32, worldMap.heightInTiles * 32);
		
		addChild(player);

		createTouchJoystick();

		stage.defaultCamera().postProcess = new ShRetro(Blend.blendDefault());

		hudLayer = new StaticLayer();
		stage.addChild(hudLayer);
		hpBarTotal = new RectangleDisplay();
		hpBarTotal.x = 100;
		hpBarTotal.y = GEngine.virtualHeight * 0.05;
		hpBarTotal.scaleX = 300;
		hpBarTotal.scaleY = 25;
		hudLayer.addChild(hpBarTotal);
		currentHpBar = new RectangleDisplay();
		currentHpBar.x = 102;
		currentHpBar.y = GEngine.virtualHeight * 0.05 + 2;
		currentHpBar.scaleX = 296;
		currentHpBar.scaleY = 21;
		currentHpBar.setColor(255, 0, 0);
		hudLayer.addChild(currentHpBar);
		
		var avatar = new Sprite("avatar");
		avatar.smooth = true;
		avatar.x = hpBarTotal.x - avatar.width() * 3;
		avatar.y = hpBarTotal.y - avatar.height();
		avatar.scaleX = avatar.scaleY = 3;
		hudLayer.addChild(avatar);

		scoreDisplay = new Text(Assets.fonts.PixelOperator8_BoldName);
		scoreDisplay.x = hpBarTotal.x + 35;
		scoreDisplay.y = hpBarTotal.y + hpBarTotal.scaleY + 5;
		scoreDisplay.scaleX = scoreDisplay.scaleY = 1 / 2;
		scoreDisplay.text = 'Score: ' + GGD.score;
		hudLayer.addChild(scoreDisplay);

		var continues = new Text(Assets.fonts.PixelOperator8_BoldName);
		continues.x = hpBarTotal.x - 10;
		continues.y = hpBarTotal.y + hpBarTotal.scaleY + 5;
		continues.scaleX = continues.scaleY = 1 / 2;
		continues.text = 'x' + GGD.continues;
		hudLayer.addChild(continues);
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);
		touchJoystick.notify(player.onAxisChange, player.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(player.onAxisChange, player.onButtonChange);
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		switch (object.objectType) {
			case OTTile(gid):
				var sprite = new Sprite(object.properties.get("spriteName"));
				sprite.smooth = false;
				sprite.x = object.x;
				sprite.y = object.y - sprite.height();
				sprite.pivotY = sprite.height();
				sprite.scaleX = object.width / sprite.width();
				sprite.scaleY = object.height / sprite.height();
				sprite.rotation = object.rotation * Math.PI / 180;
				if (object.flippedHorizontally) sprite.scaleX = -sprite.scaleX;
				simulationLayer.addChild(sprite);
			case OTRectangle:
				if (object.type == "dialog") {
					var text = object.properties.get("text");
					var dialog = new Dialog(text, object.x, object.y, object.width, object.height);
					dialogCollision.add(dialog.collider);
					addChild(dialog);
				}
				if (object.type == "ghost") {
					var ghost = new Ghost(simulationLayer, enemiesCollisions, object.x, object.y);
					addChild(ghost);
				}
				if (object.type == "salamander") {
					var salamander = new Salamander(simulationLayer, enemiesCollisions, object.x, object.y, GGD.enemyProyectilesCollisions);
					addChild(salamander);
				}
				if (object.type == "endGate") {
					var endGate = new EndGate(simulationLayer, endGateCollisions, object.x, object.y);
					addChild(endGate);
				}
				if (object.type == "gate") {
					var gate = new Gate(simulationLayer, secretGateCollisions, object.x, object.y, Std.parseFloat(object.properties.get("destinyX")), Std.parseFloat(object.properties.get("destinyY")));
					addChild(gate);
				}
				if (object.type == "torch") {
					var torch = new Torch(simulationLayer, torchCollisions, object.x, object.y);
					addChild(torch);
				}
			default:
		}
	}

	override function update(dt:Float) {
		super.update(dt);
		stage.defaultCamera().scale = 2;
		scoreDisplay.text = "Score: " + GGD.score;
		currentHpBar.scaleX = (player.currentHp * 296) / player.maxHp;
		if (currentHpBar.scaleX <= 0) currentHpBar.scaleX = 0;
		CollisionEngine.collide(player.collision, worldMap.collision);
		CollisionEngine.collide(enemiesCollisions, worldMap.collision);
		CollisionEngine.collide(torchCollisions, worldMap.collision);
		CollisionEngine.overlap(player.collision, damageMap.collision,playerVsDamage);
		if(secretGateCollisions != null) CollisionEngine.collide(secretGateCollisions, worldMap.collision);
		if(endGateCollisions != null) CollisionEngine.collide(endGateCollisions, worldMap.collision);
		CollisionEngine.overlap(player.collision, enemiesCollisions, playerVsEnemy);
		secretGateCollisions.overlap(player.collision, playerVsScertGate);
		torchCollisions.overlap(player.collision, playerVsTorch);
		CollisionEngine.overlap(GGD.enemyProyectilesCollisions, enemiesCollisions);
		CollisionEngine.overlap(GGD.playerProyectilesCollisions, enemiesCollisions, proyectilesVsEnemy);
		GGD.enemyProyectilesCollisions.overlap(player.collision, enemyProyectileVsPlayer);
		CollisionEngine.overlap(dialogCollision, player.collision, dialogVsPlayer);
		if(player.hitCollision != null){
			CollisionEngine.collide(player.hitCollision, enemiesCollisions, enemyVsPlayerHit);
		}
		stage.defaultCamera().setTarget(player.collision.x, player.collision.y);

		tray.setContactPosition(player.collision.x + player.collision.width / 2, player.collision.y + player.collision.height + 1, Sides.BOTTOM);
		tray.setContactPosition(player.collision.x + player.collision.width + 1, player.collision.y + player.collision.height / 2, Sides.RIGHT);
		tray.setContactPosition(player.collision.x - 1, player.collision.y + player.collision.height / 2, Sides.LEFT);
	}

	function dialogVsPlayer(dialogCollision:ICollider, playerCollision:ICollider) {
		var dialog:Dialog = cast dialogCollision.userData;
		dialog.showText(simulationLayer);
	}

	function playerVsTorch(torchCollision:ICollider, playerCollision:ICollider) {
		player.addEffect(new RangeAttack(player));
		var torch:Torch = cast torchCollision.userData;
		torch.die();
	}

	function playerVsEnemy(enemiesCollisions:ICollider, playerCollision:ICollider) {
		var enemy:EnemyMinion = cast enemiesCollisions.userData;
		player.damage(enemy.get_hitDamage());
		if (player.currentHp <= 0) {
			changeState(new GameOver("" + GGD.score, "0", "hero", GlobalGameData.level));
		}
	}

	function playerVsDamage(enemiesCollisions:ICollider, playerCollision:ICollider) {
		player.damage(player.maxHp);
		if (player.currentHp <= 0) {
			changeState(new GameOver("" + GGD.score, "0", "hero", GlobalGameData.level));
		}
	}

	function playerVsScertGate(secretGate:ICollider, playerCollision:ICollider) {
		var secretGate:Gate = cast secretGate.userData;
		player.transport(secretGate.destinyX, secretGate.destinyY);
	}

	function enemyVsPlayerHit(enemiesCollisions:ICollider, hitCollision:ICollider) {
		var enemy:EnemyMinion = cast enemiesCollisions.userData;
		enemy.damage(player.get_hitDamage());
	}

	function proyectilesVsEnemy(proyectileCollision:ICollider, enemiesCollisions:ICollider) {
		var proyectile:BlueFireball = cast proyectileCollision.userData;
		var enemy:EnemyMinion = cast enemiesCollisions.userData;
		enemy.damage(proyectile.get_hitDamage());
	}

	function enemyProyectileVsPlayer(aProyectile:ICollider, aPlayer:ICollider){
		var proyectile:Fireball = cast aProyectile.userData;
		player.damage(proyectile.get_hitDamage());
		if (player.currentHp <= 0) {
			changeState(new GameOver("" + GGD.score, "0", "hero", GlobalGameData.level));
		}
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end

	override function destroy() {
		super.destroy();
		touchJoystick.destroy();
	}
}
