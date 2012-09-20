package events
{
	import flash.events.Event;
	
	public class AuthenticationEvent extends Event
	{
		public static const SUCCESS:String = "AuthenticationEvent.SUCCESS";
		public static const ERROR:String = "AuthenticationEvent.ERROR";
		
		public function AuthenticationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new AuthenticationEvent(type, bubbles, cancelable);
		}
	}
}