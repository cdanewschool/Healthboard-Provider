package edu.newschool.piim.healthboard.model.modules.decisionsupport
{
	import edu.newschool.piim.healthboard.model.ModuleMappable;

	public class RiskFactorRecommendedTreatment extends ModuleMappable
	{
		public var description:String;
		public var location:String;
		public var method:String;
		
		public function RiskFactorRecommendedTreatment()
		{
			super();
		}
		
		public static function fromObj( data:Object ):RiskFactorRecommendedTreatment
		{
			var val:RiskFactorRecommendedTreatment = new RiskFactorRecommendedTreatment();
			
			for (var prop:String in data)
			{
				if( val.hasOwnProperty( prop ) )
				{
					try
					{
						val[prop] = data[prop];
					}
					catch(e:Error){}
				}
			}
			
			return val;
		}
	}
}