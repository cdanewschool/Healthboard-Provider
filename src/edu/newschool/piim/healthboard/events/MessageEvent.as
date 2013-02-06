package edu.newschool.piim.healthboard.events
{
	import flash.events.Event;
	
	public class MessageEvent extends Event
	{
		public static const ADD:String = "MessageEvent.ADD";
		public static const MESSAGE_ALL:String = "MessageEvent.MESSAGE_ALL";
		
		public function MessageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new MessageEvent(type, bubbles, cancelable);
		}
	}
}