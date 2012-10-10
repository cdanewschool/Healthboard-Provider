package events
{
	import flash.events.Event;
	
	import models.Appointment;
	import models.ProviderModel;
	import models.UserModel;
	
	public class ProfileEvent extends Event
	{
		public static const VIEW_PROFILE:String = "ProfileEvent.VIEW_PROFILE";
		public static const VIEW_APPOINTMENTS:String = "ProfileEvent.VIEW_APPOINTMENTS";
		public static const SEND_MESSAGE:String = "ProfileEvent.SEND_MESSAGE";
		public static const START_CHAT:String = "ProfileEvent.START_CHAT";
		
		public static const SELECT:String = "ProfileEvent.SELECT";
		public static const SAVE:String = "ProfileEvent.SAVE";
		
		public var user:UserModel;
		
		public function ProfileEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, user:UserModel = null)
		{
			super(type, bubbles, cancelable);
			this.user = user;
		}
		
		override public function clone():Event
		{
			var event:ProfileEvent = new ProfileEvent(type, bubbles, cancelable);
			event.user = user;
			return event;
		}
	}
}