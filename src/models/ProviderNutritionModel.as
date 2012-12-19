package models
{
	import models.modules.NutritionModel;
	
	import mx.collections.ArrayCollection;
	
	public class ProviderNutritionModel extends NutritionModel
	{
		[Bindable] public var mealActions:ArrayCollection;
		[Bindable] public var mealPlanTemplates:ArrayCollection;
		
		public function ProviderNutritionModel()
		{
			super();
		}
	}
}