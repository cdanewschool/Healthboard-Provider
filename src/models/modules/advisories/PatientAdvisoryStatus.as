package models.modules.advisories
{
	public class PatientAdvisoryStatus
	{
		public var advisoryId:int;
		public var riskLevel:String;
		
		public function PatientAdvisoryStatus()
		{
		}
		
		public static function fromObj( data:Object ):PatientAdvisoryStatus
		{
			var val:PatientAdvisoryStatus = new PatientAdvisoryStatus();
			
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