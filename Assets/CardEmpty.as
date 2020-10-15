﻿package Assets {
	import flash.geom.Matrix;
    import flash.display.MovieClip;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

	public class CardEmpty extends MovieClip
	{
		protected static var data:BitmapData;
		public var clip:Bitmap;
 
		public function CardEmpty(){
			if(!data){
				var sprite:MovieClip = new CardEmptyAsset();
				data = new BitmapData(sprite.width, sprite.height, true, 0x0);
				data.draw(sprite, new Matrix(1, 0, 0, 1, 0, 0), null, null, null, true);
			}
			clip = new Bitmap(data, "auto", true);
			addChild(clip);
			//Optimize mouse children
			mouseChildren = false;
		}
	}
}