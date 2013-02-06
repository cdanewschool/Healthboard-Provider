package edu.newschool.piim.healthboard.controller
{
	import edu.newschool.piim.healthboard.model.ProviderNutritionModel;
	import edu.newschool.piim.healthboard.model.module.nutrition.FoodPlan;
	
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