package components.modules
{
	import components.popups.nutrition.AddFoodNotePopup;
	import components.popups.nutrition.FoodPlanPopup;
	
	import flash.events.MouseEvent;
	
	import models.PatientModel;
	import models.modules.nutrition.FoodPlan;
	
	import modules.NutritionModule;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	
	public class ProviderNutritionModule extends NutritionModule
	{
		private var _patient:PatientModel;
		
		public function ProviderNutritionModule()
		{
			super();
			
			currentState = "provider";
		}
		
		override protected function onSetFoodPlanClick(event:MouseEvent):void
		{
			var popup:FoodPlanPopup = FoodPlanPopup( PopUpManager.createPopUp(AppProperties.getInstance().controller.application, FoodPlanPopup) as TitleWindow );
			popup.patient = patient as PatientModel;
			PopUpManager.centerPopUp( popup );
		}
		
		override protected function onAddCommentsClick(event:MouseEvent):void
		{
			var popup:AddFoodNotePopup = AddFoodNotePopup( PopUpManager.createPopUp(AppProperties.getInstance().controller.application, AddFoodNotePopup) as TitleWindow );
			popup.addEventListener( CloseEvent.CLOSE, onAddNoteClose );
			PopUpManager.centerPopUp( popup );
		}
		
		private function onAddNoteClose(event:CloseEvent):void
		{
			var popup:AddFoodNotePopup = AddFoodNotePopup( event.currentTarget );
			
			if( event.detail == Alert.YES )
			{
				var note:Object = { note: popup.message.text, recommendation: popup.recommendation.selectedItem.label, urgency: popup.urgency.selectedItem.data, completed:false, removed:false };
				foodPlan.notes && foodPlan.notes.length ? foodPlan.notes.addItem( note ) : foodPlan.notes = new ArrayCollection( [ note ] );
			}
			
			PopUpManager.removePopUp( popup );
		}

		
		public function get patient():PatientModel
		{
			return _patient;
		}
		
		public function set patient(value:PatientModel):void
		{
			_patient = value;
			
			if( _patient 
				&& _patient.hasOwnProperty('foodPlan') )
				foodPlan = _patient['foodPlan'] as FoodPlan;
		}

	}
}