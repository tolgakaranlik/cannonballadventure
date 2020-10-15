package {
	import flash.media.Sound;
	import flash.display.*;
	import flash.utils.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Dynamics.Contacts.*;
    import Box2D.Common.Math.*;
	import soundPlayer;
	import Assets.*;

	class customContactListener extends b2ContactListener {
		private var MAX_IMPULSE:Number=10;
		private var canReplayWallSound:Boolean = true;
		private var canReplayBlockSound:Boolean = true;
		private var soundIntervalWall;
		private var soundIntervalBlock;
		private var itemToRemove;
		private var explosionRadius = 100;
		private var explosionX:Number;
		private var explosionY:Number;
		private var debrisShape:BoxType2;
		private var explosionShape:ExplosionType1;
		private var canPlayOuch:Boolean = true;
		private var soldierShape1:Soldier1;
		private var sndPlayer:soundPlayer = new soundPlayer();

		public var _stage;
		public var _cannonBall:MovieClip;
		public var canAlterRotatorVisibility:Boolean = false;
		public var Points:int = 0;
		public var world;
		public var Following: Boolean = true;
		public var successFunc;
		public var NumAliveWarriors;
		
		public function SetSoundEnabled(isEnabled:Boolean)
		{
			sndPlayer.SetEnabled(isEnabled);
		}

		private function enablePlayOuch()
		{
			canPlayOuch = true;
		}

		private function destroyExplosion()
		{
			explosionShape.visible = false;
		}

		private function destroyItem()
		{
			debrisShape.visible = false;
		}

		private function disableWallSoundTemporarily()
		{
			canReplayWallSound = false;
			soundIntervalWall = setTimeout(enableWallSoundTemporarily, 150);
		}
		
		private function enableWallSoundTemporarily()
		{
			canReplayWallSound = true;
		}
		
		private function disableBlockSoundTemporarily()
		{
			canReplayBlockSound = false;
			soundIntervalBlock = setTimeout(enableBlockSoundTemporarily, 150);
		}
		
		private function enableBlockSoundTemporarily()
		{
			canReplayBlockSound = true;
		}
		
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void {
			var nameA:String=contact.GetFixtureA().GetBody().GetUserData().assetName.toString();
			var nameB:String=contact.GetFixtureB().GetBody().GetUserData().assetName.toString();
			var newMC:LeavesFall;
			var contact_point:b2Vec2;
			var velocity:b2Vec2;

			// Increment points
			var impulseValue = impulse.normalImpulses[0];
			if((nameA == "block" || nameB == "block") && impulseValue> MAX_IMPULSE/ 2)
			{
				Points += 50;
			}
			
			if(nameA=="forest")
			{
				newMC = new LeavesFall();
				newMC.x = _cannonBall.x;
				newMC.y = _cannonBall.y;
				_stage.addChild(newMC);

				sndPlayer.PlaySound((new bushRustle()) as Sound);

				newMC.gotoAndPlay(1);
				contact.GetFixtureB().GetBody().SetLinearVelocity(new b2Vec2(0, 0));
				contact.GetFixtureB().GetBody().GetUserData().remove=true;
				return;
			}
			
			if(nameB=="forest")
			{
				newMC = new LeavesFall();
				newMC.x = _cannonBall.x;
				newMC.y = _cannonBall.y;
				_stage.addChild(newMC);
				newMC.gotoAndPlay(1);
				contact.GetFixtureA().GetBody().SetLinearVelocity(new b2Vec2(0, 0));
				contact.GetFixtureA().GetBody().GetUserData().remove=true;
				return;
			}
			
			if (impulse.normalImpulses[0]>MAX_IMPULSE/ 24) {
				if((nameA == "wall" && nameB == "cannonBall")|| (nameB == "wall" && nameA == "cannonBall"))
				{
					if(canReplayWallSound)
					{
						sndPlayer.PlaySound((new soundHitWall()) as Sound);
					}
				}
	
				if((nameA == "block" && nameB == "cannonBall")|| (nameB == "block" && nameA == "cannonBall"))
				{
					if(canReplayBlockSound)
					{
						disableBlockSoundTemporarily();
						sndPlayer.PlaySound((new soundHitBox()) as Sound);
					}
				}
			}
			
			if (impulse.normalImpulses[0]>MAX_IMPULSE/ 4) {
				if(nameA == "block" || nameB == "block")
				{
					if(canReplayBlockSound)
					{
						disableBlockSoundTemporarily();
						sndPlayer.PlaySound((new soundHitBox()) as Sound);
					}
				}
			}

			if (/*canPlayOuch && */impulse.normalImpulses[0]>MAX_IMPULSE/ 4 && (nameA == "warrior" || nameB == "warrior")) {
				// Kill warrior
				if(nameA == "warrior")
				{
					Following = false;

					soldierShape1 = new Soldier1();
					vecPos = contact.GetFixtureA().GetBody().GetPosition();
					soldierShape1.x = vecPos.x* 30;
					soldierShape1.y = vecPos.y* 30;
					soldierShape1.gotoAndPlay(163);
					soldierShape1.width = 89.5;
					soldierShape1.height = 104.1;
					_stage.addChild(soldierShape1);
					contact.GetFixtureA().GetBody().GetUserData().remove = true;
					contact.GetFixtureA().GetBody().GetUserData().assetName = "warriorDead";
				}

				if(nameB == "warrior")
				{
					Following = false;

					soldierShape1 = new Soldier1();
					vecPos = contact.GetFixtureA().GetBody().GetPosition();
					soldierShape1.x = vecPos.x* 30;
					soldierShape1.y = vecPos.y* 30;
					soldierShape1.width = 89.5;
					soldierShape1.height = 104.1;
					soldierShape1.gotoAndPlay(163);
					_stage.addChild(soldierShape1);
					contact.GetFixtureB().GetBody().GetUserData().remove = true;
					contact.GetFixtureB().GetBody().GetUserData().assetName = "warriorDead";
				}

				NumAliveWarriors--;
				if(successFunc != null && NumAliveWarriors == 0)
				{
					//this.successFunc();
				}
			}
			
			if(canPlayOuch && (nameA == "warrior" || nameB == "warrior"))
			{
				canPlayOuch = false;
				setTimeout(enablePlayOuch, 1000);
				if(nameA == "warrior")
				{
					velocity = contact.GetFixtureA().GetBody().GetLinearVelocity();
					if(Math.abs(velocity.x) > 1)// || Math.abs(velocity.y) > 1)
					{
						sndPlayer.PlaySound((new soundOuch1()) as Sound);
						Points += 100;
						contact.GetFixtureA().GetBody().GetUserData().assetSprite.gotoAndStop(162);
						//trace("A:"+ velocity.x+ ","+ velocity.y);
					}
				}

				if(nameB == "warrior")
				{
					velocity = contact.GetFixtureB().GetBody().GetLinearVelocity();
					if(Math.abs(velocity.x) > 1)// || Math.abs(velocity.y) > 1)
					{
						sndPlayer.PlaySound((new soundOuch1()) as Sound);
						Points += 100;
						contact.GetFixtureB().GetBody().GetUserData().assetSprite.gotoAndStop(162);
						//trace("B:"+ velocity.x+ ","+ velocity.y);
					}
				}
			}
				
			if (impulse.normalImpulses[0]>MAX_IMPULSE) {
				if(nameA == "blockTNT" || nameB == "blockTNT")
				{
					var block = contact.GetFixtureA().GetBody();
					vecPos = contact.GetFixtureA().GetBody().GetPosition();
					if(nameB == "blockTNT")
					{
						block = contact.GetFixtureB().GetBody();
						vecPos = contact.GetFixtureB().GetBody().GetPosition();
					}
					
					explosionShape = new ExplosionType1();
					explosionShape.x = vecPos.x* 30;
					explosionShape.y = vecPos.y* 30;
					_stage.addChild(explosionShape);
					
					explosionShape.gotoAndPlay(1);
					contact.GetFixtureA().GetBody().GetUserData().remove = true;
					setTimeout(destroyExplosion, 1000);

					sndPlayer.PlaySound((new soundBlast()) as Sound);
					Points += 100;
					var p = block.GetPosition();
					for (var b:b2Body = world.GetBodyList(); b; b = b.GetNext()) {
						if(b.GetUserData() != null &&
						   (b.GetUserData().assetName.toString() == "blockTNT" ||
							b.GetUserData().assetName.toString() == "wall"))
						{
							continue;
						}
						
						var v:b2Vec2 = b.GetPosition();
						var distance = Math.sqrt(p.x* p.x+ v.x* v.x);
						if(distance <= explosionRadius)
						{
							b.SetLinearVelocity(new b2Vec2((explosionRadius- (p.x- v.x))/ 10, (explosionRadius- (p.y- v.y))/ 10));
						}
					}
					
					block.GetUserData().remove = true;
				}
				
				var vecPos:b2Vec2;
				if (nameA=="block") {
					Points += 50;
					sndPlayer.PlaySound((new boxBreak()) as Sound);

					//contact.GetFixtureA().GetBody().GetUserData().remove=true;
					vecPos = contact.GetFixtureA().GetBody().GetPosition();
					debrisShape = new BoxType2();
					debrisShape.x = vecPos.x* 30;
					debrisShape.y = vecPos.y* 30;

					_stage.addChild(debrisShape);
					debrisShape.gotoAndPlay(2);
					contact.GetFixtureA().GetBody().GetUserData().remove = true;
					setTimeout(destroyItem, 1000);
				}
				if (nameB=="block") {
					Points += 50;
					sndPlayer.PlaySound((new boxBreak()) as Sound);

					//contact.GetFixtureB().GetBody().GetUserData().remove=true;
					vecPos = contact.GetFixtureA().GetBody().GetPosition();
					var debrisShape:BoxType2 = new BoxType2();
					debrisShape.x = vecPos.x* 30;
					debrisShape.y = vecPos.y* 30;

					_stage.addChild(debrisShape);
					debrisShape.gotoAndPlay(2);
					contact.GetFixtureB().GetBody().GetUserData().remove = true;
					setTimeout(destroyItem, 1000);
				}
			} else {				
				if (nameA=="cannonBall") {
					velocity = contact.GetFixtureA().GetBody().GetLinearVelocity();
					if(velocity.x> 0)
					{
						if(Math.abs(velocity.x-0.01)<0.01)
						{
							canAlterRotatorVisibility = true;
							contact.GetFixtureA().GetBody().SetLinearVelocity(new b2Vec2(0, velocity.y));
						} else {
							contact.GetFixtureA().GetBody().SetLinearVelocity(new b2Vec2(velocity.x-0.01, velocity.y));
						}
					}
					if(velocity.x< 0)
					{
						if(Math.abs(velocity.x+0.01)<0.01)
						{
							canAlterRotatorVisibility = true;
							contact.GetFixtureA().GetBody().SetLinearVelocity(new b2Vec2(0, velocity.y));
						} else {
							contact.GetFixtureA().GetBody().SetLinearVelocity(new b2Vec2(velocity.x+0.01, velocity.y));
						}
					}					
				}
				if (nameB=="cannonBall") {
					velocity = contact.GetFixtureB().GetBody().GetLinearVelocity();
					if(velocity.x> 0)
					{
						if(Math.abs(velocity.x-0.01)<0.01)
						{
							canAlterRotatorVisibility = true;
							contact.GetFixtureB().GetBody().SetLinearVelocity(new b2Vec2(0, velocity.y));
						} else {
							contact.GetFixtureB().GetBody().SetLinearVelocity(new b2Vec2(velocity.x-0.01, velocity.y));
						}
					}
					if(velocity.x< 0)
					{
						if(Math.abs(velocity.x+0.01)<0.01)
						{
							canAlterRotatorVisibility = true;
							contact.GetFixtureB().GetBody().SetLinearVelocity(new b2Vec2(0, velocity.y));
						} else {
							contact.GetFixtureB().GetBody().SetLinearVelocity(new b2Vec2(velocity.x+0.01, velocity.y));
						}
					}					
				}
			}
		}
	}
}