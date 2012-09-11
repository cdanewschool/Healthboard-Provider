package events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class AutoCompleteEvent extends Event
	{
		public static const SHOW:String = "showAutocomplete";
		public static const HIDE:String = "hideAutocomplete";
		
		public var dataProvider:ArrayCollection;
		public var targetElement:DisplayObject;
		
		public var callbackFunction:Function;
		public var labelFunction:Function;
		
		public function AutoCompleteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}