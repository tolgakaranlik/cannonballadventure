package Assets {
    import flash.display.MovieClip;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

	public class Alphabet5 extends MovieClip
	{
		protected static var data:BitmapData;
		public var clip:Bitmap;
 
		public function Alphabet5(){
			if(!data){
				var sprite:MovieClip = new Alphabet5Asset();
				data = new BitmapData(sprite.width, sprite.height, true, 0x0);
				data.draw(sprite, null, null, null, null, true);
			}
			clip = new Bitmap(data, "auto", true);
			addChild(clip);
			//Optimize mouse children
			mouseChildren = false;
		}
	}
}