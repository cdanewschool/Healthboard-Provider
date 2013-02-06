package edu.newschool.piim.healthboard.model
{
	import edu.newschool.piim.healthboard.enum.UrgencyType;
	
	import edu.newschool.piim.healthboard.util.DateUtil;

	public class PatientAlert
	{
		public var alert:String;
		public var completed:Boolean;
		public var date:Date;
		public var description:String;
		public var status:String;
		public var type:String;
		public var urgency:int;
		
		public function PatientAlert( alert:String = null, date:Date = null, description:String = null, type:String = null, urgency:int = -1, status:String = "active", completed:Boolean = false )
		{
			this.alert = alert;
			this.date = date;
			this.description = description;
			this.status = status;
			this.type = type;
			this.urgency = urgency > -1 ? urgency : UrgencyType.NOT_URGENT;
			this.completed = completed;
		}
		
		public static function fromObj( data:Object ):PatientAlert
		{
			var val:PatientAlert = new PatientAlert();
			
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
			
			val.date = new Date( DateUtil.modernizeDate( data.date ) )
			
			return val;
		}
	}
}