package models
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import spark.collections.SortField;

	[Bindable]
	public class TeamAppointmentsModel
	{
		private var _appointments:ArrayCollection;
		
		public var selectedProviders:ArrayCollection;
		
		public function TeamAppointmentsModel()
		{
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