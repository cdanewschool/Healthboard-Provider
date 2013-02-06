package edu.newschool.piim.healthboard.model.modules.decisionsupport
{
	import edu.newschool.piim.healthboard.enum.DateRanges;
	
	import edu.newschool.piim.healthboard.model.module.ModuleModel;
	
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