package models
{
	public class PatientModel extends UserModel
	{
		public var dob:String;
		
		public var photo:String;
		public var ssn:String;
		public var sponsorSSN:String;
		
		public var serviceBranch:String;
		public var rank:String;
		public var occupation:String;
		
		public var lastVisit:String;
		
		public var urgency:String;
		public var bloodType:String;
		public var race:String;
		public var healthConditions:String;
		
		public function PatientModel()
		{
			super(TYPE_PATIENT);
		}
		
		public static function fromObj( data:Object ):PatientModel
		{
			var val:PatientModel = new PatientModel();
			
			for (var prop:String in data)
			{
				if( val.hasOwnProperty( prop ) )
				{
					val[prop] = data[prop];
				}
			}
			
			return val;
		}
	}
}