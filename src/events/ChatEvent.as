package events
{
	import flash.events.Event;
	
	public class ChatEvent extends Event
	{
		public static const STATE_CHANGE:String = "ChatEvent.STATE_CHANGE";
		public static const CANCEL:String = "ChatEvent.CANCEL";
		
		public function ChatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event:ChatEvent = new ChatEvent(type, bubbles, cancelable);
			return event;
		}
	}
}