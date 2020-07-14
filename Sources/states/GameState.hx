package states;

import com.soundLib.SoundManager.SM;
import com.loading.basicResources.SoundLoader;
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
import gameObjects.enemyMinions.Boss;
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
	
	var dialogCollision:CollisionGroup;
	var enemiesCollisions:CollisionGroup;
	var bossCollisions:CollisionGroup;
	var endGateCollisions:CollisionGroup;
	var secretGateCollisions:CollisionGroup;
	var torchCollisions:CollisionGroup;
	var enemyProyectilesCollisions:CollisionGroup;
	var level:String;

	public function new(level:String, fromRoom:String = null) {
		super();
		this.level = level;
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader("level"+level+"_tmx"));
		var atlas = new JoinAtlas(4096, 4096);

		atlas.add(new TilesheetLoader("tiles2", 32, 32, 0));
		atlas.add(new FontLoader(Assets.fonts.PixelOperator8_BoldName, 30));
		atlas.add(new FontLoader(Assets.fonts.Kenney_PixelName, 24));
		atlas.add(new ImageLoader("yo"));
		atlas.add(new ImageLoader("skyBackground"));
		atlas.add(new ImageLoader("cave"));
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
		atlas.add(new SpriteSheetLoader("beam", 140, 34, 0, [
			new Sequence("idle", [0])
		]));
		atlas.add(new SpriteSheetLoader("torch", 29, 75, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
		]));
		atlas.add(new SpriteSheetLoader("blueFireball", 23, 17, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7])
		]));
		atlas.add(new SpriteSheetLoader("meteor", 28, 40, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8])
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
		atlas.add(new SpriteSheetLoader("boss", 140, 100, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6]),
			new Sequence("die", [21,22,23,24,25,26,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49]),
			new Sequence("appear", [7,8,9,10,11,12,13,14,15,16,17,18,19,20]),
			new Sequence("disappear", [20,19,18,17,16,15,14,13,12,11,10,9,8,7]),
			new Sequence("hurt", [18]),
			new Sequence("attack2", [80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103]),
			new Sequence("attack", [50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79])
			]));
		resources.add(atlas);
		resources.add(new SoundLoader(Assets.sounds.blueFireName));
		resources.add(new SoundLoader(Assets.sounds.hitName));
		resources.add(new SoundLoader(Assets.sounds.powerUpName));
		resources.add(new SoundLoader(Assets.sounds.oofName));
		if (GGD.level == 3) {
			resources.add(new SoundLoader(Assets.sounds.bossFightName));
		}
	}




	var currentHpBar:RectangleDisplay;
	var hpBarTotal:RectangleDisplay;
	var bossCurrentHpBar:RectangleDisplay;
	var bossHpBarTotal:RectangleDisplay;
	var scoreLevelDisplay:Text;
	override function init() {
		stageColor(0.5, .5, 0.5);
		if (GGD.level == 3) {
			SM.playMusic(Assets.sounds.bossFightName);
		}
		
		dialogCollision = new CollisionGroup();
		secretGateCollisions = new CollisionGroup();
		torchCollisions = new CollisionGroup();
		endGateCollisions = new CollisionGroup();
		GGD.enemyProyectilesCollisions = new CollisionGroup();
		if(GGD.playerProyectilesCollisions == null) GGD.playerProyectilesCollisions = new CollisionGroup();
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		enemiesCollisions = new CollisionGroup();
		bossCollisions = new CollisionGroup();
		GGD.simulationLayer = simulationLayer;
		if (GGD.player != null) {
			player = GGD.player;
			player.respawn(100, 100, simulationLayer);
		} else {
			player = new Player(100, 100, simulationLayer);
			GGD.player = player;
		}
		hudLayer = new StaticLayer();
		
		
		worldMap = new Tilemap("level"+level+"_tmx", 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (tileLayer.properties.exists("damage"))return;
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("tiles2")));
			
			
		}, parseMapObjects);

		damageMap = new Tilemap("level"+level+"_tmx", 1);
		damageMap.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("damage"))return;
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("tiles2")));
			
			
		});
		
		if (GGD.player != null) {
			player = GGD.player;
			player.respawn(100, 100, simulationLayer);
		} else {
			player = new Player(100, 100, simulationLayer);
			GGD.player = player;
		}
		
		
		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 32, worldMap.heightInTiles * 32);
		
		addChild(player);

		createTouchJoystick();

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

		scoreLevelDisplay = new Text(Assets.fonts.PixelOperator8_BoldName);
		scoreLevelDisplay.x = hpBarTotal.x + 35;
		scoreLevelDisplay.y = hpBarTotal.y + hpBarTotal.scaleY + 5;
		scoreLevelDisplay.scaleX = scoreLevelDisplay.scaleY = 1 / 2;
		scoreLevelDisplay.text = 'Score: ' + GGD.score;
		hudLayer.addChild(scoreLevelDisplay);

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
				if (object.type == "boss") {
					bossHpBarTotal = new RectangleDisplay();
					bossHpBarTotal.x = 100;
					bossHpBarTotal.y = GEngine.virtualHeight * 0.95;
					bossHpBarTotal.scaleX = GEngine.virtualWidth - 200;
					bossHpBarTotal.scaleY = 25;
					hudLayer.addChild(bossHpBarTotal);
					bossCurrentHpBar = new RectangleDisplay();
					bossCurrentHpBar.x = 102;
					bossCurrentHpBar.y = GEngine.virtualHeight * 0.95 + 2;
					bossCurrentHpBar.scaleX = bossHpBarTotal.scaleX - 4;
					bossCurrentHpBar.scaleY = 21;
					bossCurrentHpBar.setColor(255, 0, 0);
					hudLayer.addChild(bossCurrentHpBar);
					var boss = new Boss(simulationLayer, bossCollisions, endGateCollisions, bossCurrentHpBar, object.x, object.y, enemyProyectilesCollisions);
					addChild(boss);
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
		if (Input.i.isKeyCodePressed(KeyCode.T)) debugging = !debugging;
		if (GGD.player.currentHp <= 0) {
			changeState(new GameOver("" + GGD.score, "hero", GlobalGameData.level));
		}
		stage.defaultCamera().scale = 2;
		scoreLevelDisplay.text = "Score: " + GGD.score + " - Level: " + GGD.level;
		currentHpBar.scaleX = (player.currentHp * 296) / player.maxHp;
		if (currentHpBar.scaleX <= 0) currentHpBar.scaleX = 0;
		
		CollisionEngine.collide(player.collision, worldMap.collision);
		CollisionEngine.collide(enemiesCollisions, worldMap.collision);
		CollisionEngine.collide(bossCollisions, worldMap.collision);
		CollisionEngine.collide(torchCollisions, worldMap.collision);
		CollisionEngine.overlap(player.collision, damageMap.collision,playerVsDamage);
		if(secretGateCollisions != null) CollisionEngine.collide(secretGateCollisions, worldMap.collision);
		if(endGateCollisions != null) CollisionEngine.collide(endGateCollisions, worldMap.collision);
		CollisionEngine.overlap(player.collision, enemiesCollisions, playerVsEnemy);
		CollisionEngine.overlap(player.collision, bossCollisions, playerVsEnemy);
		secretGateCollisions.overlap(player.collision, playerVsScertGate);
		endGateCollisions.overlap(player.collision, playerVsEndGate);
		torchCollisions.overlap(player.collision, playerVsTorch);
		CollisionEngine.overlap(GGD.enemyProyectilesCollisions, enemiesCollisions);
		CollisionEngine.overlap(GGD.playerProyectilesCollisions, enemiesCollisions, proyectilesVsEnemy);
		CollisionEngine.overlap(GGD.playerProyectilesCollisions, bossCollisions, proyectilesVsEnemy);
		CollisionEngine.overlap(GGD.enemyProyectilesCollisions, player.collision, enemyProyectileVsPlayer);
		//GGD.enemyProyectilesCollisions.overlap(player.collision, enemyProyectileVsPlayer);
		CollisionEngine.overlap(dialogCollision, player.collision, dialogVsPlayer);
		if(player.hitCollision != null){
			CollisionEngine.collide(player.hitCollision, enemiesCollisions, enemyVsPlayerHit);
			CollisionEngine.overlap(player.hitCollision, bossCollisions, enemyVsPlayerHit);
		}
		stage.defaultCamera().setTarget(player.collision.x, player.collision.y);
	}

	function dialogVsPlayer(dialogCollision:ICollider, playerCollision:ICollider) {
		var dialog:Dialog = cast dialogCollision.userData;
		dialog.showText(simulationLayer);
	}

	function playerVsTorch(torchCollision:ICollider, playerCollision:ICollider) {
		player.addEffect(new RangeAttack(player));
		var torch:Torch = cast torchCollision.userData;
		SM.playFx(Assets.sounds.powerUpName);
		torch.die();
	}

	function playerVsEnemy(enemiesCollisions:ICollider, playerCollision:ICollider) {
		var enemy:EnemyMinion = cast enemiesCollisions.userData;
		player.damage(enemy.get_hitDamage());
	}

	function playerVsDamage(enemiesCollisions:ICollider, playerCollision:ICollider) {
		player.damage(100);
	}

	function playerVsScertGate(secretGate:ICollider, playerCollision:ICollider) {
		var secretGate:Gate = cast secretGate.userData;
		player.transport(secretGate.destinyX, secretGate.destinyY);
	}

	function playerVsEndGate(secretGate:ICollider, playerCollision:ICollider) {
		changeState(new SuccessScreen());
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
	}

	#if DEBUGDRAW
	var debugging = false;
	override function draw(framebuffer:kha.Canvas) {
		if (debugging){
			super.draw(framebuffer);
			var camera = stage.defaultCamera();
			CollisionEngine.renderDebug(framebuffer, camera);
		}
	}
	#end

	override function destroy() {
		super.destroy();
		touchJoystick.destroy();
	}
}
