package models
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import spark.collections.SortField;

	[Bindable]
	public class AppointmentsModel
	{
		private var _appointments:ArrayCollection;
		
		public function AppointmentsModel()
		{
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