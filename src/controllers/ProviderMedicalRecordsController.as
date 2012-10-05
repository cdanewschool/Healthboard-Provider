package controllers
{
	import models.modules.MedicalRecordsModel;
	
	import mx.rpc.events.ResultEvent;

	public class ProviderMedicalRecordsController extends MedicalRecordsController
	{
		public function ProviderMedicalRecordsController()
		{
			super();
		}
		
		override public function updateMedRecHeightAndColors():void 
		{
			var model:MedicalRecordsModel = model as MedicalRecordsModel;
			
			AppProperties.getInstance().controller.model.chartStyles.myMedRecHorizontalAlternateFill = model.medicalRecordsCategories.length % 2 == 1 ? 0x303030 : 0x4A4A49;
			AppProperties.getInstance().controller.model.chartStyles.myMedRecHorizontalFill = model.medicalRecordsCategories.length % 2 == 1 ? 0x4A4A49 : 0x303030;
		}
	}
}