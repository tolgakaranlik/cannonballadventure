package Assets {
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class CachedMovieClip extends MovieClip
	{
		//Declare a static data cache
		protected static var cachedData:Object = {};
		public var clip:Bitmap;
		 
		public function MovieClip(asset:Object, scale:int = 2){
			//Check the cache to see if we've already cached this asset
			var data:BitmapData = cachedData[getQualifiedClassName(asset)];
			if(!data){
				var instance:MovieClip = new asset();
				var bounds:Rectangle = instance.getBounds(this);
						//Optionally, use a matrix to up-scale the vector asset,
				//this way you can increase scale later and it still looks good.
				var m:Matrix = new Matrix();
				m.translate(-bounds.x, -bounds.y);
				m.scale(scale, scale);
						data = new BitmapData(bounds.width * scale, bounds.height * scale, true, 0×0);
				data = new BitmapData(instance.width, instance.height, true, 0x0);
				data.draw(instance, m, null, null, null, true);
				cachedData[getQualifiedClassName(asset)] = data;
			}
		 
			clip = new Bitmap(data, "auto", true);
			//Use the bitmap class to inversely scale, so the asset still
			//appear to be it's normal size
			clip.scaleX = clip.scaleY = 1/scale;
			addChild(clip);
			//Optimize mouse children
			mouseChildren = false;
		}
	}
}