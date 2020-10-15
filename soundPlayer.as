package {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;

	class soundPlayer {
		private var isEnabled:Boolean = true;
		private var soundChannel;
		private var sound;
		
		public function PlaySound(sound:Sound, shouldRepeat:Boolean = false)
		{
			if(!isEnabled)
			{
				return null;
			}
			
			this.sound = sound;
			soundChannel = sound.play();
			if(shouldRepeat)
			{
				soundChannel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			}

			return soundChannel;
		}
		
		public function SetEnabled(isEnabled:Boolean)
		{
			this.isEnabled = isEnabled;
			
			if(!isEnabled)
			{
				if(soundChannel != null)
				{
					soundChannel.stop();
				}
			}
		}
		
		public function GetEnabled()
		{
			return isEnabled;
		}
		
		private function soundComplete(event:Event)
		{
			soundChannel = sound.play();
		}
	}
}