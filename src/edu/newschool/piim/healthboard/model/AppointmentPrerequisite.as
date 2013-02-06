package edu.newschool.piim.healthboard.model
{
	import edu.newschool.piim.healthboard.Constants;
	
	import edu.newschool.piim.healthboard.controller.Controller;
	import edu.newschool.piim.healthboard.controller.MainController;
	
	import edu.newschool.piim.healthboard.util.DateUtil;

	public class AppointmentPrerequisite
	{
		private static const IMAGE_PATH:String = "images/diagnostic/{ID}.jpg";
		
		public var id:String;	//	used to find image (images/diagnostics/[patient_last_name]/[id].jpg)
		public var title:String;
		public var path:String;
		public var date:Date;
		private var _patient:UserModel;
		public var orderedBy:UserModel;
		public var interpretedBy:String;
		
		public function AppointmentPrerequisite()
		{
		}
		
		public function toString():String
		{
			var parts:Array = [];
			
			if( date ) parts.push( 'Taken on '  + Constants.DAYS[ date.day ] + ' ' + Constants.MONTHS[date.month] + ' ' + date.date + ', ' + date.fullYear + ', at ' + DateUtil.formatTimeFromDate( date ) + ' hrs' );
			if( orderedBy ) parts.push( 'Ordered by ' + orderedBy.fullName );
			if( interpretedBy ) parts.push( 'Interpreted by ' + interpretedBy );
			
			return parts.join(';\n');
		}
		
		public static function fromObj( data:Object ):AppointmentPrerequisite
		{
			var val:AppointmentPrerequisite = new AppointmentPrerequisite();
			
			for (var prop:String in data)
			{
				if( prop == "date" ) continue;
				
				if( val.hasOwnProperty( prop ) )
				{
					val[prop] = data[prop];
				}
			}
			
			val.date = new Date();
			val.date.setTime( Date.parse( data.date ) );
			
			val.orderedBy = MainController(AppProperties.getInstance().controller).getUser( data.ordered_by_id, UserModel.TYPE_PROVIDER );
			
			val.interpretedBy = data.interpreted_by;
			
			return val;
		}

		public function get patient():UserModel
		{
			return _patient;
		}

		public function set patient(value:UserModel):void
		{
			_patient = value;
			
			if( patient )
			{
				var path:String = IMAGE_PATH.replace( /{PATIENT_NAME}/, patient.lastName.toLowerCase() );
				path = path.replace( /{ID}/, id );
				this.path = path;
			}
		}

	}
}