package {
	import Template;
	import nape.geom.Vec2;
	import flash.display.MovieClip;
	
	public class DestructableTerrain extends Template {
		import Terrain;
		public function DestructableTerrain(mc:MovieClip, left:uint, top: uint):void {
			super({
				gravity: Vec2.get(0, 600),
				staticClick: explosion,
				generator: createObject
			});
			
			this.mc = mc;
		}
	
		private var mc:MovieClip;
		private var terrain:Terrain;
		private var bomb:Sprite;
	
		override protected function init():void {
			var w:uint = mc.width; //stage.stageWidth;
			var h:uint = mc.height; //stage.stageHeight;
	
			createBorder();
	
			// Initialise terrain bitmap.
			var bit:BitmapData = new BitmapData(w, h, true, 0);
			//bit.perlinNoise(200, 200, 2, 0x3ed, false, true, BitmapDataChannel.ALPHA, false);
			bit.draw(mc);
	
			// Create initial terrain state, invalidating the whole screen.
			terrain = new Terrain(bit, 30, 5);
			//terrain.invalidate(new AABB(0, 0, w, h), space);
	
			// Create bomb sprite for destruction
			bomb = new Sprite();
			bomb.graphics.beginFill(0xffffff, 1);
			bomb.graphics.drawCircle(0, 0, 40);
		}
	
		private function explosion(pos:Vec2):void {
			// Erase bomb graphic out of terrain.
			terrain.bitmap.draw(bomb, new Matrix(1, 0, 0, 1, pos.x, pos.y), null, BlendMode.ERASE);
	
			// Invalidate region of terrain effected.
			var region:AABB = AABB.fromRect(bomb.getBounds(bomb));
			region.x += pos.x;
			region.y += pos.y;
			terrain.invalidate(region, space);
		}
	
		private function createObject(pos:Vec2):void {
			var body:Body = new Body(BodyType.DYNAMIC, pos);
			if (Math.random() < 0.333) {
				body.shapes.add(new Circle(10 + Math.random()*20));
			}
			else {
				body.shapes.add(new Polygon(Polygon.regular(
						/*radiusX*/ 10 + Math.random()*20,
						/*radiusY*/ 10 + Math.random()*20,
						/*numVerts*/ int(Math.random()*3 + 3)
				)));
			}
			body.space = space;
		}
	}
}