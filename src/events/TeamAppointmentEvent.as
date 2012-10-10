package events
{
	import flash.events.Event;
	
	import models.Appointment;
	import models.ProviderModel;
	
	public class TeamAppointmentEvent extends Event
	{
		public static const ADD:String = "TeamAppointmentEvent.ADD";
		public static const SAVE:String = "TeamAppointmentEvent.SAVE";
		public static const CANCEL:String = "TeamAppointmentEvent.CANCEL";
		public static const CANCEL_ALL:String = "TeamAppointmentEvent.CANCEL_ALL";
		
		public static const VIEW:String = "TeamAppointmentEvent.VIEW";
		public static const ACCEPT:String = "TeamAppointmentEvent.ACCEPT";
		public static const DECLINE:String = "TeamAppointmentEvent.DECLINE";
		
		public static const VIEW_PROVIDER:String = "TeamAppointmentEvent.VIEW_PROVIDER";
		
		public var appointment:Appointment;
		public var data:*;
		
		public function TeamAppointmentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event:TeamAppointmentEvent = new TeamAppointmentEvent(type, bubbles, cancelable);
			event.appointment = appointment;
			return event;
		}
	}
}