package states;

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
import gameObjects.ChivitoBoy;
import gameObjects.Jason;
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
	var player:ChivitoBoy;
	var simulationLayer:Layer;
	var touchJoystick:VirtualGamepad;
	var tray:helpers.Tray;
	var dialogCollision:CollisionGroup;
	var enemyCollision:CollisionGroup;


	public function new(room:String, fromRoom:String = null) {
		super();
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader(Assets.blobs.testRoom_tmxName));
		var atlas = new JoinAtlas(2048, 2048);

		atlas.add(new TilesheetLoader("tiles2", 32, 32, 0));
		atlas.add(new ImageLoader("salt"));
		atlas.add(new ImageLoader("dummy"));
		atlas.add(new SparrowLoader("jason", "jason_xml"));
		atlas.add(new SpriteSheetLoader("hero", 60, 60, 0, [
			new Sequence("fall", [14, 15]),
			new Sequence("slide", [58]),
			new Sequence("jump", [13]),
			new Sequence("attack1", [32, 33, 34]),
			new Sequence("attack2", [36, 37, 38, 39]),
			new Sequence("attack3", [40, 41, 42, 43, 44]),
			new Sequence("run", [4, 5, 6, 7, 8, 9, 10, 11]),
			new Sequence("idle", [0, 1, 2, 3, 2, 1]),
			new Sequence("rangeAttack", [11])
		]));
		atlas.add(new FontLoader("Kenney_Pixel",24));
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, .5, 0.5);
		dialogCollision = new CollisionGroup();
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		enemyCollision = new CollisionGroup();
		var mayonnaiseMap:TileMapDisplay;
		worldMap = new Tilemap("testRoom_tmx", 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer,new Sprite("tiles2")));
			mayonnaiseMap = layerTilemap.createDisplay(tileLayer,new Sprite("tiles2"));
			simulationLayer.addChild(mayonnaiseMap);
		}, parseMapObjects);
		
		tray = new Tray(mayonnaiseMap);

		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 32 , worldMap.heightInTiles * 32);
		player = new ChivitoBoy(250,200,simulationLayer);
		GGD.player = player;
		addChild(player);

		createTouchJoystick();

		stage.defaultCamera().postProcess=new ShRetro(Blend.blendDefault());
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
		switch (object.objectType){
			case OTTile(gid):
				var sprite = new Sprite("salt");
				sprite.smooth = false;
				sprite.x = object.x;
				sprite.y = object.y - sprite.height();
				sprite.pivotY=sprite.height();
				sprite.scaleX = object.width/sprite.width();
				sprite.scaleY = object.height/sprite.height();
				sprite.rotation = object.rotation*Math.PI/180;
				simulationLayer.addChild(sprite);
			case OTRectangle:
				if(object.type=="dialog"){
					var text=object.properties.get("text");
					var dialog=new Dialog(text,object.x,object.y,object.width,object.height);
					dialogCollision.add(dialog.collider);
					addChild(dialog);
				}
				if(object.type=="enemy"){
					var json = new Jason(simulationLayer,enemyCollision,object.x,object.y);
					addChild(json);
				}
			default:
		}
	}


	override function update(dt:Float) {
		super.update(dt);
		stage.defaultCamera().scale=2;
	
		CollisionEngine.collide(player.collision,worldMap.collision);
		CollisionEngine.collide(enemyCollision,worldMap.collision);
		CollisionEngine.overlap(dialogCollision,player.collision,dialogVsPlayer);
		CollisionEngine.overlap(player.hitCollision, dialogCollision);
		CollisionEngine.collide(player.hitCollision, enemyCollision, enemyVsPlayerHit);
		stage.defaultCamera().setTarget(player.collision.x, player.collision.y);

        tray.setContactPosition(player.collision.x + player.collision.width / 2, player.collision.y + player.collision.height + 1, Sides.BOTTOM);
		tray.setContactPosition(player.collision.x + player.collision.width + 1, player.collision.y + player.collision.height / 2, Sides.RIGHT);
		tray.setContactPosition(player.collision.x-1, player.collision.y+player.collision.height/2, Sides.LEFT);

	}
	function dialogVsPlayer(dialogCollision:ICollider,playerCollision:ICollider) {
		var dialog:Dialog=cast dialogCollision.userData;
		dialog.showText(simulationLayer);
	}

	function enemyVsPlayerHit(enemyCollision:ICollider,hitCollision:ICollider) {
		trace('funcion called');
		var enemy:Jason=cast enemyCollision.userData;
		enemy.damage();
	}
	
	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera=stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer,camera);
	}
	#end
	override function destroy() {
		super.destroy();
		touchJoystick.destroy();
	}

}
