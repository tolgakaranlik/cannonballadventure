package {
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.MovieClip;
	import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.*;
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
	import Box2D.Dynamics.Joints.*;
	import Box2DSeparator.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import Assets.*;

	class CBALevel extends MovieClip {
		public var STAGE_BORDER = 0;
		public var HIGHLIGHT_PHYSICS = 0;
		public var mainMenuFunc;
		public var nextMenuFunc;

		public var world;
		public var debugMode:int = 0;
		public var circleColor:uint = 0xFFFF00;
		public var currIndex:uint = 1;
		public var firingInterval:uint = 0;
		public var MAX_INTERVAL:uint = 125;
		public var isFiring:uint = 0;
		public var initialSpeed:Number = 0;
		public var initialSpeedX:Number = 0;
		public var initialSpeedY:Number = 0;
		public var cannonTime:Number = 0;
		public var cannonAngle:Number = 0;
		public var cannonBallLeft:Number = 0;
		public var cannonBallTop:Number = 0;
		public var cannonBall:CannonSimple = null; 
		public var cannonBallAppearInterval:uint = 0;
		public var cannonBallMoveInterval:uint = 0;
		public var cannonAngleSin:Number = 0;
		public var friction:Number = 0.8;
		public var coordAngle:Number = 13;
		public var i_x, i_y:Number;
		public var BallInfo = new Array(MAX_BALLS);
		public var cannonBallSphere:b2Body;
        public var worldDebugDraw:b2DebugDraw;
		public var MAX_BALLS = 0;
		public var mcSettingBox:MovieClip;
		public var mcCannon:MovieClip;
		public var mcRotator:MovieClip;
		public var mcSlider:MovieClip;
		public var introMode:int = 0;
		public var mcOpener:MovieClip;
		public var mcBallBox:MovieClip;
		public var customContact;
		public var tutorialObject:MovieClip;

		private var pointsAlpha1:MovieClip = null;
		private var pointsAlpha2:MovieClip = null;
		private var pointsAlpha3:MovieClip = null;
		private var pointsAlpha4:MovieClip = null;
		private var pointsAlpha5:MovieClip = null;
		private var pointsAlpha6:MovieClip = null;

		private var soundChannel:SoundChannel = new SoundChannel();
		private var musicEnabled:Boolean = true;
		private var soundEnabled:Boolean = true;
		private var myChannel:SoundChannel = new SoundChannel();
		private var sndPlayer:soundPlayer = new soundPlayer();
		private var musicPlayer:soundPlayer = new soundPlayer();
		private var menuToggler:int = 0;
		private var myTweenStep;
		private var worldScale:int=30;
		private var mcCannonWheel;
		private var firstTime:Boolean = true;

		public var mcTitleDefeated;
		public var mcTitleVictorious;

		public function postInitialize()
		{
			mcOpener.mainMenuFunc = mainMenuFunc;
		}

		public function initialize()
		{
			if(!firstTime)
			{
				return;
			}
			
			firstTime = false;
			
			mcSettingBox = new SettingBox();
			mcSettingBox.x = 657; //- x;
			mcSettingBox.y = 16;
			mcSettingBox.width = 380;
			mcSettingBox.height = 120;
			addChild(mcSettingBox);
			
			mcCannon = new Cannon();
			mcCannon.x = 56.7;
			mcCannon.y = 528.2;
			mcCannon.width = 168.2;
			mcCannon.height = 74;
			mcCannon.brightness = 0.2;
			addChild(mcCannon);
			
			mcRotator = new Rotator();
			mcRotator.x = 15.6;
			mcRotator.y = 260;
			mcRotator.width = 357.1;
			mcRotator.height = 372;
			mcRotator.alpha = 0.5;
			addChild(mcRotator);
			
			mcSlider = new Slider();
			mcSlider.x = -757;
			mcSlider.y = -0.1;
			mcSlider.width = 3171.1;
			mcSlider.height = 566.9;
			mcSlider.alpha = 0;
			addChild(mcSlider);
			
			bringToFront(mcRotator);
			bringToFront(mcCannon);
			mcOpener = new OpeningMenu();
			mcOpener.x = -12;
			mcOpener.y = -8;
			
			if(tutorialObject != null)
			{
				tutorialObject.skipFunction = skipTutorial;
				addChild(tutorialObject);
			} else {
				addChild(mcOpener);
			}
			
			mcBallBox = new BallBox();
			mcBallBox.x = 0;
			mcBallBox.y = 0;
			mcBallBox.width = 319;
			mcBallBox.height = 37.8;
			addChild(mcBallBox);
			
			mcCannonWheel = new CannonWheel();
			mcCannonWheel.x = 28.9;
			mcCannonWheel.y = 504.9;
			mcCannonWheel.width = 78.8;
			mcCannonWheel.height = 78.8;
			addChild(mcCannonWheel);
			bringToFront(mcSettingBox);
			if(tutorialObject == null)
			{
				bringToFront(mcOpener);
			} else {
				bringToFront(tutorialObject);
			}
			
			mcSettingBox.mcSoundOff.visible = false;
			mcSettingBox.mcMusicOff.visible = false;
			
			mcSettingBox.btnSetting.addEventListener(MouseEvent.MOUSE_DOWN, toggleMenuOpen);
			mcSettingBox.btnSpeaker.addEventListener(MouseEvent.MOUSE_DOWN, toggleMusic);
			mcSettingBox.btnNote.addEventListener(MouseEvent.MOUSE_DOWN, toggleSound);

			mcCannon.addEventListener(MouseEvent.MOUSE_DOWN, fireCannon);
			mcCannon.addEventListener(MouseEvent.MOUSE_UP, stopFiring);

			mcSlider.addEventListener(MouseEvent.MOUSE_MOVE, sliderMove);
			mcSlider.addEventListener(MouseEvent.MOUSE_DOWN, sliderBegin);
			mcSlider.addEventListener(MouseEvent.MOUSE_UP, sliderEnd);

			mcRotator.addEventListener(MouseEvent.MOUSE_MOVE, rotatorMove);
			mcRotator.addEventListener(MouseEvent.MOUSE_DOWN, rotatorBegin);
			mcRotator.addEventListener(MouseEvent.MOUSE_UP, rotatorEnd);

			world = new b2World(new b2Vec2(0,10),true);
			mcRotator.visible = MAX_BALLS> 0 && introMode == -1;
			addEventListener(Event.ENTER_FRAME,updateWorld);

			mcOpener.introFunc = startIntro;
			customContact.successFunc = succeedStage;
			debugDraw();
		}

		public function skipTutorial()
		{
			tutorialObject.visible = false;			
			removeChild(tutorialObject);
			tutorialObject = null;

			addChild(mcOpener);
			bringToFront(mcOpener);
		}

		public function startIntro()
		{
		}

		public function SetWorldScale(scale:int)
		{
			worldScale = scale;
		}

		public function GetSoundEnabled()
		{
			return soundEnabled;
		}

		public function GetMusicEnabled()
		{
			return musicEnabled;
		}

		public function PlayMusic(param1, param2)
		{
			soundChannel = musicPlayer.PlaySound(param1, param2);
		}

		public function GetWorldScale()
		{
			return worldScale;
		}

		private function toggleMusic(event:MouseEvent)
		{
			mcSettingBox.mcMusicOff.visible = !mcSettingBox.mcMusicOff.visible;
			musicEnabled = !mcSettingBox.mcMusicOff.visible;

			musicPlayer.SetEnabled(musicEnabled);
			if(musicEnabled)
			{
				musicPlayer.PlaySound((new natureSound()) as Sound, true);
			}
		}

		public function toggleSound(event:MouseEvent)
		{
			mcSettingBox.mcSoundOff.visible = !mcSettingBox.mcSoundOff.visible;
			soundEnabled = !mcSettingBox.mcSoundOff.visible;

			sndPlayer.SetEnabled(soundEnabled);
			customContact.SetSoundEnabled(soundEnabled);
		}

		private function toggleMenuOpen(evet:MouseEvent)
		{
			menuToggler = (menuToggler == 0?60:0);
		}

		private function succeedStage()
		{
			customContact.successFunc = null;
			setTimeout(congratPlayer, 1000);
			sndPlayer.PlaySound((new soundApplause()) as Sound);
		}
		
		public function congratPlayer()
		{
			mcTitleVictorious = new TitleVictory();
			mcTitleVictorious.visible = true;
			mcTitleVictorious.alpha = 0;
			mcTitleVictorious.nextFunc = nextMenuFunc;
			mcTitleVictorious.mainMenuFunc = mainMenuFunc;
			mcTitleVictorious.x = -x;
			mcTitleVictorious.numBalls = MAX_BALLS;
			mcTitleVictorious.sndPlayer = sndPlayer;
			mcTitleVictorious.currPoints = customContact.Points;
			addChild(mcTitleVictorious);

			bringToFront(mcTitleVictorious);
			myTweenStep = new Tween(mcTitleVictorious, "alpha", Strong.easeOut, 0, 1, 1, true);
		}

		public function bringToFront(param)
		{
			param.parent.setChildIndex(param,param.parent.numChildren - 1);
		}

		private function nextStage()
		{
		}

		private function failStage()
		{
			if(mcTitleDefeated != null)
			{
				removeChild(mcTitleDefeated);
				mcTitleDefeated = null;
			}
			
			mcTitleDefeated = new TitleDefeat();
			mcTitleDefeated.visible = true;
			mcTitleDefeated.alpha = 0;
			mcTitleDefeated.introFunc = RestartLevel;
			mcTitleDefeated.x = -x;
			addChild(mcTitleDefeated);
			
			mcTitleDefeated.parent.setChildIndex(mcTitleDefeated,mcTitleDefeated.parent.numChildren - 1);
			myTweenStep = new Tween(mcTitleDefeated, "alpha", Strong.easeOut, 0, 1, 1, true);
		}

		public function initBalls()
		{
			var offsetX:int = 175;
			for(var i:int = 0; i< MAX_BALLS; i++)
			{
				BallInfo[i] = new BallInformation(BallInformation.BALLTYPE_SIMPLE);
				var mc:MovieClip = BallInfo[i].GetMovieClip();
				
				mc.x = offsetX;
				mc.y = 23+ (i==0?0:-4);
				addChild(mc);
				
				if(i == 0)
				{
					offsetX += 33;
					BallInfo[i].Focus();
				} else {
					offsetX += 27;
				}
			}
		}

		public function displayPoints()
		{
			if(introMode == 0)
			{
				return;
			}
			
			var pts = customContact.Points.toString();
			for(var r:int = 0; r< 6- customContact.Points.toString().length; r++)
			{
				pts = "0" + pts;
			}
			
			if(pointsAlpha1 != null)
			{
				removeChild(pointsAlpha1);
			}
			
			if(pointsAlpha2 != null)
			{
				removeChild(pointsAlpha2);
			}
			
			if(pointsAlpha3 != null)
			{
				removeChild(pointsAlpha3);
			}
			
			if(pointsAlpha4 != null)
			{
				removeChild(pointsAlpha4);
			}
			
			if(pointsAlpha5 != null)
			{
				removeChild(pointsAlpha5);
			}
			
			if(pointsAlpha6 != null)
			{
				removeChild(pointsAlpha6);
			}
			
			mcBallBox.x = -1* x;
			mcSettingBox.x = 657- x;
			mcSettingBox.y = 16+ menuToggler;
			mcSettingBox.parent.setChildIndex(mcSettingBox,mcSettingBox.parent.numChildren - 1);
			placeBalls();
			
			pointsAlpha1 = getSpriteFromAlphabetLettr(pts.charAt(0)); //new Alphabet0();
			pointsAlpha1.x = mcBallBox.x+ 4;
			pointsAlpha1.y = 6;
			addChild(pointsAlpha1);
			pointsAlpha2 = getSpriteFromAlphabetLettr(pts.charAt(1)); //
			pointsAlpha2.x = pointsAlpha1.x + pointsAlpha1.width+ 1;
			pointsAlpha2.y = 6;
			addChild(pointsAlpha2);
			pointsAlpha3 = getSpriteFromAlphabetLettr(pts.charAt(2)); //new Alphabet2();
			pointsAlpha3.x = pointsAlpha2.x + pointsAlpha2.width+ 1;
			pointsAlpha3.y = 6;
			addChild(pointsAlpha3);
			pointsAlpha4 = getSpriteFromAlphabetLettr(pts.charAt(3)); //new Alphabet5();
			pointsAlpha4.x = pointsAlpha3.x + pointsAlpha3.width+ 1;
			pointsAlpha4.y = 6;
			addChild(pointsAlpha4);
			pointsAlpha5 = getSpriteFromAlphabetLettr(pts.charAt(4)); //new Alphabet0();
			pointsAlpha5.x = pointsAlpha4.x + pointsAlpha4.width+ 1;
			pointsAlpha5.y = 6;
			addChild(pointsAlpha5);
			pointsAlpha6 = getSpriteFromAlphabetLettr(pts.charAt(5)); //new Alphabet0();
			pointsAlpha6.x = pointsAlpha5.x + pointsAlpha5.width+ 1;
			pointsAlpha6.y = 6;
			addChild(pointsAlpha6);
		}

		private function getSpriteFromAlphabetLettr(letter)
		{
			switch(letter)
			{
				case "0":
					return new Alphabet0();
				case "1":
					return new Alphabet1();
				case "2":
					return new Alphabet2();
				case "3":
					return new Alphabet3();
				case "4":
					return new Alphabet4();
				case "5":
					return new Alphabet5();
				case "6":
					return new Alphabet6();
				case "7":
					return new Alphabet7();
				case "8":
					return new Alphabet8();
				case "9":
					return new Alphabet9();
			}
			
			return null;
		}

		// Cannonball Stuff
		public var temp:int = 0;
		public function placeCannonBallNow()
		{
			cannonAngle = mcCannon.rotation* Math.PI / 180;
			//cannonAngle = coordAngle* Math.PI / 180;
			cannonAngleSin = Math.sin(cannonAngle);
			cannonBall = new CannonSimple();
			cannonBall.x = mcCannon.x - 15 + 120* Math.cos(coordAngle);
			cannonBall.y = mcCannon.y - 150* Math.sin(coordAngle);
			cannonBallLeft = cannonBall.x;
			cannonBallTop = cannonBall.y;
			addChild(cannonBall);
			customContact._cannonBall = cannonBall;
		
			cannonTime = 0;
			clearInterval(cannonBallAppearInterval);
			//cannonBallMoveInterval = setInterval(moveCannonBallNow, 20);
			startCannonBallPhysics();
		}
		
		public function placeCannonBall()
		{
			cannonBallAppearInterval = setInterval(placeCannonBallNow, 150);
		}
		
		public function proceedNextCircle():void
		{
			var color:uint = circleColor - currIndex << 8;
			var radius:uint = 7 + (8/ MAX_INTERVAL)* currIndex;
			var circle:Shape = new Shape();
			circle.graphics.beginFill(color);
			circle.graphics.drawCircle(radius- 49/ 4, radius, radius);
			circle.graphics.endFill();
			circle.x = 100 + currIndex/ 2- 49/ 4;
			circle.y = 3 - (8/ (MAX_INTERVAL / 3))* currIndex- 67/ 2;
			mcCannon.addChild(circle);
			
			currIndex += 2;
			if(currIndex >= MAX_INTERVAL)
			{
				stopFiring(null);
				isFiring = 0;
			}
		}
		
		public function fireCannon(event:MouseEvent)
		{
			if(introMode != -1)
			{
				return;
			}
			
			if(MAX_BALLS> 0)
			{
				introMode = 99;
				BallInfo[0].Die();
				for(var i:int = 1; i< MAX_BALLS; i++)
				{
					BallInfo[i- 1] = BallInfo[i];
					BallInfo.Length--;

					BallInfo[i].Step(i == 1);
				}
				
				MAX_BALLS--;
			} else {
				return;
			}
			
			customContact.Points++;
			customContact.Following = true;
			currIndex = 1;
			isFiring = 1;
			myChannel = sndPlayer.PlaySound((new soundRising()) as Sound);

			firingInterval = setInterval(proceedNextCircle, 1000 / MAX_INTERVAL);
			mcRotator.visible = false;
		}
		
		public function stopFiring(event:MouseEvent)
		{
			if(isFiring == 0)
			{
				return;
			}
			
			if(myChannel != null)
			{
				myChannel.stop();
			}

			clearInterval(firingInterval);
			
			var i:int = 0;
			while (mcCannon.numChildren > 1)
			{
				mcCannon.removeChild(mcCannon.getChildAt(1));
			}
			
			initialSpeed = currIndex;
			initialSpeedX = Math.abs(initialSpeed* Math.cos(coordAngle));
			initialSpeedY = Math.abs(initialSpeed* Math.sin(coordAngle));
			mcCannon.gotoAndPlay(1);
			placeCannonBall();
			isFiring = 0;
			
			sndPlayer.PlaySound((new soundKaboom()) as Sound);
		}
		
		private function startCannonBallPhysics()
		{
			customContact.Following = true;
			var sphereShape:b2CircleShape=new b2CircleShape((25/ 2)/worldScale);
			var sphereFixture:b2FixtureDef = new b2FixtureDef();
			sphereFixture.density=1;
			sphereFixture.friction=0.3;
			sphereFixture.restitution=0.1;
			sphereFixture.shape=sphereShape;
			var sphereBodyDef:b2BodyDef = new b2BodyDef();
			sphereBodyDef.type=b2Body.b2_dynamicBody;
			sphereBodyDef.userData={assetName:"cannonBall",assetSprite:cannonBall,remove:false};
			sphereBodyDef.position.Set(cannonBall.x/worldScale,cannonBall.y/worldScale);
			cannonBallSphere=world.CreateBody(sphereBodyDef);
			cannonBallSphere.CreateFixture(sphereFixture);
			cannonBallSphere.SetLinearVelocity(new b2Vec2(initialSpeed*Math.cos(coordAngle)/4,-initialSpeed*Math.sin(coordAngle)/4));
		}
		
		// Slider stuff
		public var sliderBeginLeft:int = 0;
		public var sliderBeginTop:int = 0;
		public var sliderEndLeft:int = 0;
		public var sliderEndTop:int = 0;
		public var sliderSpeed:Number = 0;
		public var sliderMoving:uint = 0;
		public var sliderInterval:uint = 0;
		public var rotatorMoving:uint = 0;
		
		public function sliderBegin(event:MouseEvent)
		{
			if(introMode != -1)
			{
				return;
			}

			sliderBeginLeft = stage.mouseX;
			sliderBeginTop = stage.mouseY;
			
			sliderMoving = 1;
		}
		
		public function sliderEnd(event:MouseEvent)
		{
			//sliderMove(event);
			rotatorMoving = 0;
			sliderMoving = 0;
			sliderInterval = setInterval(keepSliding, 50);
		}
		
		public function keepSliding()
		{
			if(Math.abs(sliderSpeed) <= 1)
			{
				clearInterval(sliderInterval);
				return;
			}
			
			sliderSpeed /= 1.25;
			moveAllChildren(sliderSpeed);
		}
		
		public function sliderMove(event:MouseEvent)
		{
			var speed = 0;
			if(cannonBall != null)
			{
				var vec = cannonBallSphere.GetLinearVelocity();
				speed = vec.x;
			}
			
			if(cannonBall != null && cannonBall.x > 512 && speed >= 0.2)
			{
				sliderMoving = 0;
			}

			if(sliderMoving == 0 || introMode != -1)
			{
				return;
			}
			
			sliderEndLeft = stage.mouseX;
			sliderEndTop = stage.mouseY;
			
			sliderSpeed = sliderBeginLeft - sliderEndLeft
			moveAllChildren(sliderSpeed);
			
			sliderBeginLeft = sliderEndLeft;
			sliderBeginTop = sliderEndTop;
		}
		
		private function removeAllBlocks()
		{
			if(world == null)
			{
				return;
			}
			
            for (var currentBody:b2Body=world.GetBodyList(); currentBody; currentBody=currentBody.GetNext()) {
				if(currentBody.GetUserData() && currentBody.GetUserData().assetSprite != null)
				{
					removeChild(currentBody.GetUserData().assetSprite);
				}

				world.DestroyBody(currentBody);
			}
		}
		
		public function moveAllChildren(delta:int)
		{
			if(x - delta< -STAGE_BORDER)
			{
				x = -STAGE_BORDER;
				//mcLogo.x = STAGE_BORDER+ 669;
			} else if(x - delta> 0)
			{
				x = 0;
				//mcLogo.x = 669;
			} else {
				x -= delta;
				//mcLogo.x += delta;
			}

			displayPoints();
			placeBalls();
		}
		
		// Rotator
		public function rotatorBegin(event:MouseEvent)
		{
			if(introMode != -1)
			{
				return;
			}

			rotatorMoving = 1;
		}
		
		public function rotatorEnd(event:MouseEvent)
		{
			sliderMoving = 0;
			rotatorMoving = 0;
		}
		
		public function rotatorMove(event:MouseEvent)
		{
			if(rotatorMoving == 0)
			{
				return;
			}
			
			var coordLeft = stage.mouseX;
			var coordTop = 600- stage.mouseY;
			var coordHyp = Math.sqrt(coordTop* coordTop + coordLeft* coordLeft);
			coordAngle = Math.asin(coordTop / coordHyp);
			
			mcCannon.rotation = -coordAngle* 180 / Math.PI + 40 / Math.PI;
			//rotateAroundCenter(mcCannon, coordAngle* 180 / Math.PI + 20 / Math.PI, mcCannon.x, mcCannon.y);
		}

        public function addBlock(w,h,px,py):void {
			var physicObject = new Vector.<b2Vec2>();
			physicObject.push(new b2Vec2(-5.2-25, 52.3-25));
			physicObject.push(new b2Vec2(-4.1-25, -5.9-25));
			physicObject.push(new b2Vec2(17.3-25, -5.9-25));
			physicObject.push(new b2Vec2(16.2-25, 1.9-25));
			physicObject.push(new b2Vec2(22.9-25, 8.5-25));
			physicObject.push(new b2Vec2(32.3-25, -5.9-25));
			physicObject.push(new b2Vec2(50.9-25, -5.9-25));
			physicObject.push(new b2Vec2(52.7-25, 52.3-25));
			physicObject.push(new b2Vec2(37.4-25, 52.3-25));
			physicObject.push(new b2Vec2(36.5-25, 43.4-25));
			physicObject.push(new b2Vec2(25.4-25, 35.2-25));
			physicObject.push(new b2Vec2(10.6-25, 52.3-25));

			for(var r:int = 0; r< physicObject.length; r++)
			{
				physicObject[r].x /= worldScale;
				physicObject[r].y /= worldScale;
			}

            var blockFixture:b2FixtureDef = new b2FixtureDef();
            blockFixture.density=0.15;
            blockFixture.friction=2;
            blockFixture.restitution=0.22;
            var blockBodyDef:b2BodyDef = new b2BodyDef();
            blockBodyDef.position.Set(px/worldScale,py/worldScale);

			var sprite:MovieClip;
			if(Math.random()* 100%2 == 0)
			{
				sprite = new BoxType1();
			} else {
				sprite = new BoxType2();
			}
            addChild(sprite);
			
            blockBodyDef.userData={assetName:"block",assetSprite:sprite,remove:false};
            blockBodyDef.type=b2Body.b2_dynamicBody;
            var block:b2Body=world.CreateBody(blockBodyDef);
			
			var sep:b2Separator = new b2Separator();
			if (sep.Validate(physicObject)==0) {
				sep.Separate(block, blockFixture, physicObject);
			} else {
				trace(":( "+ sep.Validate(physicObject));
			}
        }		
		
        public function addWarrior(w,h,px,py):void {
			var physicObject = new Vector.<b2Vec2>();
			physicObject.push(new b2Vec2(0*0.275, 198.5*0.275));
			physicObject.push(new b2Vec2(-17*0.275, -55*0.275));
			physicObject.push(new b2Vec2(56*0.275, -155.5*0.275));
			physicObject.push(new b2Vec2(128.5*0.275, -155.5*0.275));
			physicObject.push(new b2Vec2(233.9*0.275, -60.5*0.275));
			physicObject.push(new b2Vec2(209.9*0.275, 198.5*0.275));

			for(var r:int = 0; r< physicObject.length; r++)
			{
				physicObject[r].x /= worldScale;
				physicObject[r].y /= worldScale;
			}

            var blockFixture:b2FixtureDef = new b2FixtureDef();
            blockFixture.density=0.15;
            blockFixture.friction=2;
            blockFixture.restitution=0.8;
            var blockBodyDef:b2BodyDef = new b2BodyDef();
            blockBodyDef.position.Set(px/worldScale,py/worldScale);

			var sprite:MovieClip;
			sprite = new Soldier1();
			sprite.width = 89.5;
			sprite.height = 104.1;
            addChild(sprite);
			
            blockBodyDef.userData={assetName:"warrior",assetSprite:sprite,remove:false};
            blockBodyDef.type=b2Body.b2_dynamicBody;
            var block:b2Body=world.CreateBody(blockBodyDef);
			
			var sep:b2Separator = new b2Separator();
			if (sep.Validate(physicObject)==0) {
				sep.Separate(block, blockFixture, physicObject);
			} else {
				trace(":( "+ sep.Validate(physicObject));
			}
        }		
		
        public function addBlockTNT(w,h,px,py):void {
            var blockShape:b2PolygonShape = new b2PolygonShape();
            blockShape.SetAsBox(w*0.5/worldScale,h*0.5/worldScale);
			
			var blockFixture:b2FixtureDef = new b2FixtureDef();
            blockFixture.density=0.15;
            blockFixture.friction=2;
            blockFixture.restitution=0.22;
            blockFixture.shape=blockShape;
            var blockBodyDef:b2BodyDef = new b2BodyDef();
            blockBodyDef.position.Set(px/worldScale,py/worldScale);

			var sprite:MovieClip;
			sprite = new BoxTNT();
            addChild(sprite);
			
            blockBodyDef.userData={assetName:"blockTNT",assetSprite:sprite,remove:false};
            blockBodyDef.type=b2Body.b2_dynamicBody;
            var block:b2Body=world.CreateBody(blockBodyDef);
			block.CreateFixture(blockFixture);
        }
		
        public function addPlank(w,h,px,py):void {
            var blockShape:b2PolygonShape = new b2PolygonShape();
            blockShape.SetAsBox(w*0.5/worldScale,h*0.5/worldScale);
			
			var blockFixture:b2FixtureDef = new b2FixtureDef();
            blockFixture.density=0.15;
            blockFixture.friction=2;
            blockFixture.restitution=0.22;
            blockFixture.shape=blockShape;
            var blockBodyDef:b2BodyDef = new b2BodyDef();
            blockBodyDef.position.Set(px/worldScale,py/worldScale);

			var sprite:MovieClip;
			sprite = new BoxPlank();
            addChild(sprite);
			
            blockBodyDef.userData={assetName:"block",assetSprite:sprite,remove:false};
            blockBodyDef.type=b2Body.b2_dynamicBody;
            var block:b2Body=world.CreateBody(blockBodyDef);
			block.CreateFixture(blockFixture);
        }
		
		public function addWall(w,h,px,py):void {
			var floorShape:b2PolygonShape = new b2PolygonShape();
            floorShape.SetAsBox(w/worldScale,h/worldScale);
			
            var floorFixture:b2FixtureDef = new b2FixtureDef();
            floorFixture.density=0;
            floorFixture.friction=100;
            floorFixture.restitution=0.5;
            floorFixture.shape=floorShape;
            
			var floorBodyDef:b2BodyDef = new b2BodyDef();
            floorBodyDef.position.Set(px/worldScale,py/worldScale);
            floorBodyDef.userData={assetName:"wall",assetSprite:null,remove:false};
            
			var floor:b2Body=world.CreateBody(floorBodyDef);
            floor.CreateFixture(floorFixture);
        }
		
        private function debugDraw():void {
            worldDebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
            addChild(debugSprite);
			
            worldDebugDraw.SetSprite(debugSprite);
            worldDebugDraw.SetDrawScale(worldScale);
			if(HIGHLIGHT_PHYSICS == 1)
			{
				worldDebugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
				worldDebugDraw.SetFillAlpha(0.5);
			}
            world.SetDebugDraw(worldDebugDraw);
        }
		
       public function updateWorld(e:Event):void {
			world.Step(1/30,10,10);
            for (var currentBody:b2Body=world.GetBodyList(); currentBody; currentBody=currentBody.GetNext()) {
                if (currentBody.GetUserData()) {
                    if (currentBody.GetUserData().assetSprite!=null) {
                        currentBody.GetUserData().assetSprite.x=currentBody.GetPosition().x*worldScale;
                        currentBody.GetUserData().assetSprite.y=currentBody.GetPosition().y*worldScale;
                        currentBody.GetUserData().assetSprite.rotation=currentBody.GetAngle()*(180/Math.PI);
                    }
					
                    if (currentBody.GetUserData().remove) {
                        if (currentBody.GetUserData().assetSprite!=null) {
                            removeChild(currentBody.GetUserData().assetSprite);
                        }

						world.DestroyBody(currentBody);
                    }

					if(currentBody.GetUserData().assetName == "cannonBall")
					{
						mcRotator.visible = false;
						if(currentBody.GetPosition().x* GetWorldScale() < -10 || currentBody.GetPosition().x* GetWorldScale() > STAGE_BORDER+ 1100)
						{
							currentBody.SetLinearVelocity(new b2Vec2(0,0));
							world.DestroyBody(currentBody);
						}

						var v2:b2Vec2 = currentBody.GetLinearVelocity();
						if(v2.x == 0 && !isFiring)
						{
							currentBody.GetUserData().assetName = "cannonBallDied";
							if(customContact.NumAliveWarriors <= 0)
							{
								succeedStage();
							} else {							
								if(MAX_BALLS> 0)
								{
									introMode = 99; // prevent user to slide screen before it automatically does
									setTimeout(introStep2, 1000);
								} else {
									failStage();
								}
							}
						}
					}
				}
            }
			
            world.ClearForces();
            world.DrawDebugData();

			//displayPoints();
			//placeBalls();
        }
		
		public function setRotatorVisible()
		{
			mcRotator.visible = MAX_BALLS> 0;
		}

		public function placeBalls()
		{
			if(MAX_BALLS == 0 || BallInfo == null || BallInfo.Length == 0 || BallInfo[0] == null)
			{
				return;
			}
			
			var offsetX:int = 160- x;
			for(var i:int=0; i< MAX_BALLS; i++)
			{
				BallInfo[i].GetMovieClip().x = offsetX;
				if(i == 0)
				{
					offsetX += 33;
				} else {
					offsetX += 27;
				}
			}
		}

		public function introStep2()
		{
		}
		
		public function RestartLevel()
		{
			if(mcTitleDefeated != null)
			{
				mcTitleDefeated.visible = false;
				//removeChild(mcTitleDefeated);
			}
			
			removeAllBlocks();
			initialize();
			startIntro();
		}
	}
}