package components.modules
{
	import components.popups.nutrition.FoodPlanPopup;
	
	import flash.events.MouseEvent;
	
	import modules.NutritionModule;
	
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	
	public class ProviderNutritionModule extends NutritionModule
	{
		public function ProviderNutritionModule()
		{
			super();
			
			currentState = "provider";
		}
		
		override protected function onSetFoodPlanClick(event:MouseEvent):void
		{
			var popup:FoodPlanPopup = FoodPlanPopup( PopUpManager.createPopUp(AppProperties.getInstance().controller.application, FoodPlanPopup) as TitleWindow );
			PopUpManager.centerPopUp( popup );
		}
	}
}