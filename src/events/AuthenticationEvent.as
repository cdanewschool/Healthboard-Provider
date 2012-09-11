package events
{
	import flash.events.Event;
	
	public class AuthenticationEvent extends Event
	{
		public static const SUCCESS:String = "success";
		public static const ERROR:String = "error";
		
		public function AuthenticationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}