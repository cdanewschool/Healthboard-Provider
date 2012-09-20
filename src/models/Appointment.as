package models
{
	import ASclasses.Constants;
	
	import controllers.ApplicationController;
	
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	
	import utils.DateUtil;

	[Bindable]
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
					{ label: "day", labelShort: "d", value: RECUR_TYPE_DAY }, 
					{ label: "week", labelShort: "w", value: RECUR_TYPE_DAY }, 
					{ label: "month", labelShort: "m", value: RECUR_TYPE_MONTH_ONE }, 
					{ label: "three months", labelShort: "3m", value: RECUR_TYPE_MONTH_THREE }, 
					{ label: "six months", labelShort: "6m", value: RECUR_TYPE_MONTH_SIX }, 
					{ label: "year", labelShort: "1y", value: RECUR_TYPE_YEAR }, 
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
					{ label: "Visit", value: TYPE_VISIT, colors:['0x09557F','0x096980','0x095580'] }, 
					{ label: "Web Conference", value: TYPE_CONFERENCE_WEB, colors:['0x004F27','0x006127','0x004F27'] }, 
					{ label: "Telephone Conference", value: TYPE_CONFERENCE_PHONE, colors:['0x006361','0x05948F','0x006361'] }, 
					{ label: "Other", value: TYPE_OTHER, colors:['0x542D91','0x702D91','0x542D91'] }, 
					{ label: "Pending", value: TYPE_PENDING, colors:['0xD66E30','0xED8722','0xD66E30'] }
				]
			);
		
		public static const REASONS:ArrayCollection = new ArrayCollection
			(
				[ 'General Consultation', 'Physical Examination', 'Follow-up', 'Flu Vaccination', 'Common RFV #5', 'Common RFV #6', 'Common RFV #7', 'Common RFV #8' ]
			);
		
		public var patient:UserModel;
		public var provider:UserModel;
		
		public var from:Date;
		public var to:Date;
		
		public var isPending:Boolean;
		
		public var isRecurring:Boolean;
		public var recurUnit:String;
		
		public var type:String;
		
		public var reason:String;
		public var prerequisite:String;
		
		public var location:String;
		
		public function Appointment()
		{
			location = "The New York Clinic\n99 Main St.\nNew York, NY 11111";	//	temp
			
			var today:Date = ApplicationController.getInstance().today;
			
			from = new Date( today.fullYear, today.month, today.date, 10 );
			to = new Date( today.fullYear, today.month, today.date, 11 );
			
			type = TYPE_VISIT;
		}
		
		public function fromDateString():String{ return getAppointmentTime( from ); }
		public function toDateString():String{ return getAppointmentTime( to ); }
		
		public function getAppointmentTime( date:Date ):String
		{
			return Constants.MONTHS_ABBR[ date.month ] + ' ' + date.date + ', ' +  date.fullYear + ' at ' + DateUtil.formatTimeFromDate( date ); 
		}
		
		public function toString():String
		{
			var str:String = from.month + '/' + from.date + '/' + from.fullYear + ' ';
			str += 'appointment at ' + DateUtil.formatTimeFromDate( from ) + ' with ' + patient.fullName;
			if( prerequisite ) str += '\nPrerequisite: ' + prerequisite;
			
			return str;
		}
		
		public function clone():Appointment
		{
			var val:Appointment = new Appointment();
			
			var definition:XML = describeType(this);
			
			for each(var prop:XML in definition..accessor)
			{
				if( prop.@access == "readonly" ) continue;
				
				val[prop.@name] = this[prop.@name];
			}
			
			return val;
		}
		
		public function copy( from:Appointment ):void
		{
			var definition:XML = describeType(this);
			
			for each(var prop:XML in definition..accessor)
			{
				if( prop.@access == "readonly" ) continue;
				
				this[prop.@name] = from[prop.@name];
			}
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
			
			val.isPending = String(data.is_pending) == 'true';
			
			return val;
		}
		
		public static function getTypeByKey( key:String ):Object
		{
			for each(var type:Object in APPOINTMENT_TYPES)
			{
				if( type.value == key )
				{
					return type;
				}
			}
			
			return null;
		}
	}
}