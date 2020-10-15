package Assets {
	import flash.geom.Matrix;
    import flash.display.MovieClip;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

	public class Hill2 extends MovieClip
	{
		protected static var data:BitmapData;
		public var clip:Bitmap;
 
		public function Hill2(){
			if(!data){
				var sprite:MovieClip = new Hill2Asset();
				data = new BitmapData(sprite.width, sprite.height+ 145.35, true, 0x0);
				data.draw(sprite, new Matrix(1, 0, 0, 1, 0, 145.35), null, null, null, true);
			}
			clip = new Bitmap(data, "auto", true);
			addChild(clip);
			//Optimize mouse children
			mouseChildren = false;
		}
	}
}