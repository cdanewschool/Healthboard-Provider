package edu.newschool.piim.healthboard.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.TextInput;
	
	public class AutoCompleteEvent extends Event
	{
		public static const SHOW:String = "AutoCompleteEvent.SHOW";
		public static const HIDE:String = "AutoCompleteEvent.HIDE";
		
		public var dataProvider:ArrayCollection;
		public var targetField:TextInput;
		public var desiredWidth:int;
		
		public var callbackFunction:Function;
		public var labelFunction:Function;
		
		public var backgroundColor:uint;
		
		public function AutoCompleteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event:AutoCompleteEvent = new AutoCompleteEvent(type, bubbles, cancelable);
			event.dataProvider = dataProvider;
			event.targetField = targetField;
			event.desiredWidth = desiredWidth;
			event.callbackFunction = callbackFunction;
			event.labelFunction = labelFunction;
			event.backgroundColor = backgroundColor;
			
			return event;
		}
	}
}