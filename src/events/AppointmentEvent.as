package events
{
	import flash.events.Event;
	
	public class AppointmentEvent extends Event
	{
		public static const ADD:String = "AppointmentEvent.ADD";
		public static const SAVE:String = "AppointmentEvent.SAVE";
		public static const CANCEL:String = "AppointmentEvent.CANCEL";
		public static const CANCEL_ALL:String = "AppointmentEvent.CANCEL_ALL";
		
		public function AppointmentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new AppointmentEvent(type, bubbles, cancelable);
		}
	}
}