package events
{
	import flash.events.Event;
	
	import models.Appointment;
	
	public class AppointmentEvent extends Event
	{
		public static const ADD:String = "AppointmentEvent.ADD";
		public static const SAVE:String = "AppointmentEvent.SAVE";
		public static const CANCEL:String = "AppointmentEvent.CANCEL";
		public static const CANCEL_ALL:String = "AppointmentEvent.CANCEL_ALL";
		
		public static const VIEW:String = "AppointmentEvent.VIEW";
		public static const ACCEPT:String = "AppointmentEvent.ACCEPT";
		public static const DECLINE:String = "AppointmentEvent.DECLINE";
		
		public var appointment:Appointment;
		
		public function AppointmentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event:AppointmentEvent = new AppointmentEvent(type, bubbles, cancelable);
			event.appointment = appointment;
			return event;
		}
	}
}