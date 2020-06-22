import com.gEngine.display.Camera;
import com.gEngine.display.Layer;
import gameObjects.ChivitoBoy;

typedef GGD = GlobalGameData; 
class GlobalGameData {

    public static var player:ChivitoBoy;
    public static var simulationLayer:Layer;
    public static var camera:Camera;

    public static function destroy() {
        player=null;
        simulationLayer=null;
        camera=null;
    }
}