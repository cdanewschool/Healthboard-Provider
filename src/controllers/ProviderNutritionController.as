package controllers
{
	import models.ProviderNutritionModel;
	import models.modules.nutrition.FoodPlan;
	
	import mx.collections.ArrayCollection;

	public class ProviderNutritionController extends NutritionController
	{
		public function ProviderNutritionController()
		{
			super();
			
			model = new ProviderNutritionModel();
		}
		
		override public function init():void
		{
			super.init();
			
			ProviderNutritionModel(model).mealActions = new ArrayCollection( [ 'Edit', 'Delete', 'Dupiclate' ] );
			ProviderNutritionModel(model).mealPlanTemplates = new ArrayCollection( [ FoodPlan.AVERAGE] );
		}
	}
}