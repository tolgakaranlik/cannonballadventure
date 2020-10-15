package {
    import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
    import flash.utils.*;
    import Assets.*;

	class BallInformation
	{
		private var ballType;
		private var mc:MovieClip;
		private var myTweenX;
		private var myTweenY;
		private var myTweenStep;

		public var _stage;
		
		public static const BALLTYPE_SIMPLE:int = 0;

		private function killMovieClip()
		{
			mc.visible = false;
		}

		public function GetMovieClip()
		{
			return mc;
		}

		public function Die()
		{
			myTweenStep = new Tween(mc, "y", Strong.easeOut, mc.y, mc.y- 50, 1, true);
			
			setTimeout(killMovieClip, 1000);
		}

		public function Step(shouldFocus:Boolean)
		{
			myTweenStep = new Tween(mc, "x", Strong.easeOut, mc.x, mc.x- (shouldFocus?33:27), 1, true);
			
			if(shouldFocus)
			{
				Focus();
			}
		}

		public function Focus()
		{
			if(mc == null)
			{
				return;
			}
			
			mc.parent.setChildIndex(mc,mc.parent.numChildren - 1);
			myTweenX = new Tween(mc, "width", Strong.easeOut, 25, 25* 1.5, 1, true);
			myTweenY = new Tween(mc, "height", Strong.easeOut, 25, 25* 1.5, 1, true);
		}

		public function BallInformation(ballType:int)
		{
			this.ballType = ballType;
			mc = null;
			
			switch(ballType)
			{
				case BALLTYPE_SIMPLE:
					mc = new CannonSimple();
					break;
			}
			
			if(mc != null)
			{
				mc.width=25;
				mc.height=25;
			}
		}
	}
}