package edu.newschool.piim.healthboard.events
{
	import flash.events.Event;
	
	import edu.newschool.piim.healthboard.model.modules.advisories.PublicHealthAdvisory;
	
	public class AdvisoryEvent extends Event
	{
		public static const SHOW_ADVISORY:String = "AdvisoryEvent.SHOW_ADVISORY";
		public static const SHOW_ALL:String = "AdvisoryEvent.SHOW_ALL";
		public static const SHOW_PATIENTS:String = "AdvisoryEvent.SHOW_PATIENTS";
		
		public var data:PublicHealthAdvisory;
		
		public function AdvisoryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,data:PublicHealthAdvisory=null)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
		
		override public function clone():Event
		{
			var event:AdvisoryEvent = new AdvisoryEvent(type, bubbles, cancelable);
			return event;
		}
	}
}