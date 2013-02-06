package edu.newschool.piim.healthboard.events
{
	import flash.events.Event;
	
	import edu.newschool.piim.healthboard.model.SavedSearch;
	
	public class PatientSearchEvent extends Event
	{
		public static const SAVE_TAB:String = "PatientSearchEvent.SAVE_TAB";
		public static const NEW_TAB:String = "PatientSearchEvent.NEW_TAB";
		
		public var search:SavedSearch;
		
		public function PatientSearchEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event:PatientSearchEvent = new PatientSearchEvent(type, bubbles, cancelable);
			return event;
		}
	}
}