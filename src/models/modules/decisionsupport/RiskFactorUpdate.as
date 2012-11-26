package models.modules.decisionsupport
{
	import enum.RiskLevel;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class RiskFactorUpdate
	{
		public var date:Date;
		public var details:ArrayCollection;
		public var meanValue:*;
		public var type:String;
		public var reason:String;
		public var riskLevel:String;
		public var value:*;
		public var value2:*;
		
		public function RiskFactorUpdate()
		{
			riskLevel = RiskLevel.NONE;
		}
		
		public function get valueDisplay():String
		{
			var val:String = value2 ? value + '/' + value2 : value;
			return val;
		}
		
		public function getDifferenceDisplay( compare:RiskFactorUpdate ):String
		{
			var change:Number = value - compare.value;
			
			if( value2 
				&& compare.value2 )	
			{
				var change2:Number = value2 - compare.value2;
				
				return (change >= 0 ? '+' + change : '-' + change) + '/' + (change2 >= 0 ? '+' + change2 : '-' + change2)
			}
			
			return (change >= 0 ? '+' + change : '-' + change);
		}
		
		public static function fromObj( data:Object ):RiskFactorUpdate
		{
			var val:RiskFactorUpdate = new RiskFactorUpdate();
			
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
			
			val.date = new Date( data.date );
			val.type = data.type && data.type == 'patient' ? 'patient' : 'provider';
			
			if( data.detail )
			{
				val.details = data.detail is ArrayCollection ? data.detail : new ArrayCollection( [ data.detail ] );
			}
			
			return val;
		}
	}
}