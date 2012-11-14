package models.modules.advisories
{
	import enum.DateRanges;
	
	import models.modules.ModuleModel;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class PublicHealthAdvisoriesModel extends ModuleModel
	{
		public static const ID:String = "publicHealthAdvisory";
	
		public static const SORT_MODE_UPDATED:String = "updated";
		public static const SORT_MODE_AFFECTED:String = "affected";
		public static const SORT_MODE_ATRISK:String = "atrisk";
		public static const SORT_MODE_DEATHS:String = "deaths";
		public static const SORT_MODE_AFFECTED_TOTAL:String = "affected_total";
		public static const SORT_MODE_ATRISK_TOTAL:String = "atrisk_total";
		public static const SORT_MODE_DEATHS_TOTAL:String = "deaths_total";
		
		public static const PATIENT_FITLER_MODE_ALL:String = "all";
		public static const PATIENT_FITLER_MODE_AFFECTED:String = "affected";
		public static const PATIENT_FITLER_MODE_ATRISK:String = "atrisk";
		
		public var sortModes:ArrayCollection;
		public var sortMode:Object;
		
		public var patientFilters:ArrayCollection;
		public var patientFilter:Object;
		
		public var advisories:ArrayCollection;
		public var activeAdvisories:ArrayCollection;
		
		public var searchText:String;
		public var minDate:Date;
		public var maxDate:Date;
		
		public var dateRange:String = DateRanges.WEEK_TWO;
		
		public var pendingAdvisory:PublicHealthAdvisory;
		
		public function PublicHealthAdvisoriesModel()
		{
			super();
		}
		
		public function reset():void
		{
			minDate = null;
			maxDate = null;
			
			searchText = "";
		}
	}
}