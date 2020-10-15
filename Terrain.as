package {
	import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.BlendMode;
    import flash.display.Sprite;
	import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.BlendMode;
    import flash.display.Sprite;
	import nape.geom.AABB;
	import nape.geom.IsoFunction;
	import nape.geom.MarchingSquares;
	import nape.geom.Vec2;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	public class Terrain {
		public var bitmap:BitmapData;
		private var subSize:Number;
	 
		private var width:int;
		private var height:int;
	 
		public function Terrain(bitmap:BitmapData, subSize:Number):void {
			this.bitmap = bitmap;
			this.subSize = subSize;
	 
			width = bitmap.width;
			height = bitmap.height;
		}
	}
}