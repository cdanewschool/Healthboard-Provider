package models.modules.advisories
{
	import models.ProviderModel;

	public class CaseReport
	{
		public static const STATUS_CONFIRMED:String = "confirmed";
		public static const STATUS_SUSPECTED:String = "suspected";
		
		public static const REASON_MANDATORY:String = "mandatory";
		public static const REASON_VOLUNTARY:String = "voluntary";
		
		public var sender:ProviderModel;
		public var title:String;
		public var caseStatus:String;
		public var reason:String;
		public var details:String;
		public var location:String;
		public var witness:String;
		public var assessmentDate:Date;
		public var caseDescription:String;
		public var lastAssessmentDate:Date;
		
		public function CaseReport()
		{
		}
	}
}