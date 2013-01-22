package models
{
	import enum.UrgencyType;
	
	import util.DateUtil;

	public class PatientAlert
	{
		public var alert:String;
		public var completed:Boolean;
		public var date:Date;
		public var description:String;
		public var status:String;
		public var type:String;
		public var urgency:int;
		
		public function PatientAlert( alert:String = null, date:Date = null, description:String = null, type:String = null, urgency:int = UrgencyType.NOT_URGENT, status:String = "active", completed:Boolean = false )
		{
			this.alert = alert;
			this.date = date;
			this.description = description;
			this.status = status;
			this.type = type;
			this.urgency = urgency;
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