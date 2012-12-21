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
		public static const ID:String = "teamappointments";
		
		private var _appointments:ArrayCollection;
		
		private var _selectedProviders:ArrayCollection;
		
		public function TeamAppointmentsModel()
		{
			super();
			
			selectedProviders = new ArrayCollection();
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

		public function get selectedProviders():ArrayCollection
		{
			return _selectedProviders;
		}

		public function set selectedProviders(value:ArrayCollection):void
		{
			_selectedProviders = value;
		}


	}
}