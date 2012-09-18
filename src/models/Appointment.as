package models
{
	import controllers.ApplicationController;
	
	import mx.collections.ArrayCollection;

	public class Appointment
	{
		public static const RECUR_TYPE_DAY:String = "day";
		public static const RECUR_TYPE_WEEK:String = "week";
		public static const RECUR_TYPE_MONTH_ONE:String = "month";
		public static const RECUR_TYPE_MONTH_THREE:String = "monthsThree";
		public static const RECUR_TYPE_MONTH_SIX:String = "monthsSix";
		public static const RECUR_TYPE_YEAR:String = "year";
		
		public static const RECUR_TYPES:ArrayCollection = new ArrayCollection
			( 
				[ 
					{ label: "d", value: RECUR_TYPE_DAY }, { label: "w", value: RECUR_TYPE_DAY }, { label: "m", value: RECUR_TYPE_MONTH_ONE }, 
					{ label: "3m", value: RECUR_TYPE_MONTH_THREE }, { label: "6m", value: RECUR_TYPE_MONTH_SIX }, { label: "1y", value: RECUR_TYPE_YEAR }, 
				]
			);
		public static const TYPE_VISIT:String = "visit";
		public static const TYPE_CONFERENCE_WEB:String = "conferenceWeb";
		public static const TYPE_CONFERENCE_PHONE:String = "conferencePhone";
		public static const TYPE_OTHER:String = "other";
		public static const TYPE_PENDING:String = "pending";
		
		public static const APPOINTMENT_TYPES:ArrayCollection = new ArrayCollection
			( 
				[ 
					{ label: "Visits", value: TYPE_VISIT, colors:['0x09557F','0x096980','0x095580'] }, 
					{ label: "Web Conference", value: TYPE_CONFERENCE_WEB, colors:['0x004F27','0x006127','0x004F27'] }, 
					{ label: "Telephone Conference", value: TYPE_CONFERENCE_PHONE, colors:['0x006361','0x05948F','0x006361'] }, 
					{ label: "Others", value: TYPE_OTHER, colors:['0x542D91','0x702D91','0x542D91'] }, 
					{ label: "Pending", value: TYPE_PENDING, colors:['0xD66E30','0xED8722','0xD66E30'] }
				]
			);
		
		public var patient:UserModel;
		public var provider:UserModel;
		
		public var from:Date;
		public var to:Date;
		
		public var isRecurring:Boolean;
		public var recurUnit:String;
		
		public var type:String;
		public var typeReason:String;
		
		public function Appointment()
		{
		}
		
		public static function fromObj( data:Object ):Appointment
		{
			var val:Appointment = new Appointment();
			
			for (var prop:String in data)
			{
				if( prop == "from" || prop == "to" ) continue;
				
				if( val.hasOwnProperty( prop ) )
				{
					val[prop] = data[prop];
				}
			}
			
			val.from = new Date();
			val.from.setTime( Date.parse( data.from ) );
			
			val.to = new Date();
			val.to.setTime( Date.parse( data.to ) );
			
			val.patient = ApplicationController.getInstance().getUser( data.patient_id, UserModel.TYPE_PATIENT );
			val.provider = ApplicationController.getInstance().getUser( data.provider_id, UserModel.TYPE_PROVIDER );
			
			return val;
		}
	}
}