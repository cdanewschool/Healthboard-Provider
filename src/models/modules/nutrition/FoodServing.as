package models.modules.nutrition
{
	import enum.DietClassQuantifier;

	public class FoodServing
	{
		public static const ALCOHOL:FoodServing = new FoodServing( 'Alochol', 'drinks' );
		public static const DAIRY:FoodServing = new FoodServing( 'Dairy' );
		public static const FATS_AND_OILS:FoodServing = new FoodServing( 'Fats & Oils' );
		public static const FRUITS:FoodServing = new FoodServing( 'Fruits' );
		public static const GRAINS:FoodServing = new FoodServing( 'Grains' );
		public static const PROTEINS:FoodServing = new FoodServing( 'Fruits' );
		public static const SODIUM:FoodServing = new FoodServing( 'Sodium', 'milligrams' );
		public static const SUGARS:FoodServing = new FoodServing( 'Sugars' );
		public static const VEGETABLES:FoodServing = new FoodServing( 'Vegetables' );
		public static const WATER:FoodServing = new FoodServing( 'Water', 'cups' );
		
		public var listMinMax:Boolean;
		public var quantifier:String;
		public var servingSize:String;
		public var title:String;
		public var unit:String;
		
		public function FoodServing( title:String, unit:String = 'servings', quantifier:String = null, servingSize:String = '1', listMinMax:Boolean = false )
		{
			this.title = title;
			this.unit = unit;
			this.quantifier = quantifier ? quantifier : DietClassQuantifier.EXACTLY;
			this.servingSize = servingSize;
			this.listMinMax = listMinMax;
		}
	}
}