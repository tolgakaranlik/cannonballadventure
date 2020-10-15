package Assets {
	import flash.geom.Matrix;
    import flash.display.MovieClip;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

	public class FrontSome extends MovieClip
	{
		protected static var data:BitmapData;
		public var clip:Bitmap;
 
		public function FrontSome(){
			if(!data){
				var sprite:MovieClip = new FrontSomeAsset();
				data = new BitmapData(sprite.width+ 1214/ 2, sprite.height+ 386.7/ 2, true, 0x0);
				data.draw(sprite, new Matrix(1, 0, 0, 1, 1214/ 2, 386.7/ 2), null, null, null, true);
			}
			clip = new Bitmap(data, "auto", true);
			addChild(clip);
			//Optimize mouse children
			mouseChildren = false;
		}
	}
}