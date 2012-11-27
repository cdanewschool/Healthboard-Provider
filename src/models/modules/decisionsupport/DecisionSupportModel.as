package models.modules.decisionsupport
{
	import enum.DateRanges;
	
	import models.modules.ModuleModel;
	
	[Bindable]
	public class DecisionSupportModel extends ModuleModel
	{
		public static const ID:String = "decisionsupport";
		
		public var minDate:Date;
		public var maxDate:Date;
		
		public var dateRange:String = DateRanges.MONTH_THREE;
		
		public function DecisionSupportModel()
		{
			super();
		}
	}
}