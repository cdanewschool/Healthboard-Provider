package models
{
	import flash.utils.Dictionary;
	
	import models.modules.ModuleModel;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import spark.collections.SortField;

	[Bindable]
	public class TeamAppointmentsModel extends ModuleModel
	{
		private var _appointments:ArrayCollection;
		
		public var selectedProviders:ArrayCollection;
		
		public function TeamAppointmentsModel()
		{
			super();
		}
		
		public function addAppointment( appointment:Appointment ):void
		{
			if( !appointments ) appointments = new ArrayCollection();
			
			appointments.addItem( appointment );
		}
		
		public function get appointments():ArrayCollection
		{
			return _appointments;
		}

		public function set appointments(value:ArrayCollection):void
		{
			_appointments = value;
		}

	}
}