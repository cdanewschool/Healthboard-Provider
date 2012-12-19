package events
{
	import flash.events.Event;
	
	import models.modules.nutrition.Meal;
	import models.modules.nutrition.MealCategory;
	
	public class MealEvent extends Event
	{
		public static const DUPLICATE:String = "MealEvent.DUPLICATE";
		public static const EDIT:String = "MealEvent.EDIT";
		public static const REMOVE:String = "MealEvent.REMOVE";
		
		public var meal:Meal;
		public var mealCategory:MealCategory;
		
		public function MealEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event:MealEvent = new MealEvent(type, bubbles, cancelable);
			return event;
		}
	}
}