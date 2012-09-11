package events
{
	import models.ProviderModel;
	
	import flash.events.Event;
	
	public class ProviderEvent extends Event
	{
		public static const SELECT:String = "ProviderEvent.SELECT";
		public static const SAVE:String = "ProviderEvent.SAVE";
		
		public var provider:ProviderModel;
		
		public function ProviderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, provider:ProviderModel = null)
		{
			super(type, bubbles, cancelable);
			
			this.provider = provider;
		}
	}
}