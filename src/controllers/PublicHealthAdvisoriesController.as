package controllers
{
	import components.popups.Confirmation;
	import components.popups.healthadvisory.AdvisoryCaseReportPopup;
	
	import events.ApplicationDataEvent;
	import events.AuthenticationEvent;
	
	import models.modules.advisories.CaseReport;
	import models.modules.advisories.PublicHealthAdvisoriesModel;
	import models.modules.advisories.PublicHealthAdvisory;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;

	public class PublicHealthAdvisoriesController extends BaseModuleController
	{
		private var pendingCaseReport:CaseReport;
		
		public function PublicHealthAdvisoriesController()
		{
			super();
			
			model = new PublicHealthAdvisoriesModel();
			model.dataService.url = "data/advisories.xml";
			model.dataService.addEventListener( ResultEvent.RESULT, dataResultHandler );
		}
		
		override public function dataResultHandler(event:ResultEvent):void 
		{
			var model:PublicHealthAdvisoriesModel = model as PublicHealthAdvisoriesModel;
			
			var advisories:ArrayCollection = new ArrayCollection();
			
			var results:ArrayCollection = event.result.advisories.advisory;
			
			for each(var result:Object in results)
			{
				var advisory:PublicHealthAdvisory = PublicHealthAdvisory.fromObj(result);
				advisories.addItem( advisory );
			}
			
			var sort:Sort = new Sort();
			sort.compareFunction = sortCompare;
			
			model.advisories = advisories;
			model.advisories.filterFunction = filter;
			model.advisories.sort = sort;
			model.advisories.refresh();
			
			model.activeAdvisories = new ArrayCollection( model.advisories.source );
			model.activeAdvisories.filterFunction = filterByActive;
			model.activeAdvisories.sort = sort;
			model.activeAdvisories.refresh();
			
			model.inactiveAdvisories = new ArrayCollection( model.advisories.source );
			model.inactiveAdvisories.filterFunction = filterByInactive;
			model.inactiveAdvisories.sort = sort;
			model.inactiveAdvisories.refresh();
			
			super.dataResultHandler(event);
		}
		
		override public function init():void
		{
			super.init();
			
			var model:PublicHealthAdvisoriesModel = model as PublicHealthAdvisoriesModel;
			
			model.patientFilters = new ArrayCollection
				( 
					[
						{data:PublicHealthAdvisoriesModel.PATIENT_FITLER_MODE_ALL, value:'All'},
						{data:PublicHealthAdvisoriesModel.PATIENT_FITLER_MODE_AFFECTED, value:'Affected'},
						{data:PublicHealthAdvisoriesModel.PATIENT_FITLER_MODE_ATRISK, value:'At risk'},
					]
				);
			
			model.sortModes = new ArrayCollection
				( 
					[
						{data:PublicHealthAdvisoriesModel.SORT_MODE_UPDATED, value:'Last Updated'},
						{data:PublicHealthAdvisoriesModel.SORT_MODE_AFFECTED, value:'Affected (My Patients)'},
						{data:PublicHealthAdvisoriesModel.SORT_MODE_ATRISK, value:'At risk (My Patients)'},
						{data:PublicHealthAdvisoriesModel.SORT_MODE_DEATHS, value:'Deaths (My Patients)'},
						{data:PublicHealthAdvisoriesModel.SORT_MODE_AFFECTED_TOTAL, value:'Affected (Total)'},
						{data:PublicHealthAdvisoriesModel.SORT_MODE_ATRISK_TOTAL, value:'At risk (Total)'},
						{data:PublicHealthAdvisoriesModel.SORT_MODE_DEATHS_TOTAL, value:'Deaths (Total)'},
					]
				);
			
			model.patientFilter = model.patientFilters.getItemAt(0);
			model.sortMode = model.sortModes.getItemAt(0);
		}
		
		public function getAdvisoryById( id:int ):PublicHealthAdvisory
		{
			for each(var advisory:PublicHealthAdvisory in PublicHealthAdvisoriesModel(model).advisories)
			{
				if( advisory.id == id )
				{
					return advisory;
				}
			}
			
			return null;
		}
		
		public function sortCompare(a:PublicHealthAdvisory, b:PublicHealthAdvisory, fields:Array = null):int
		{
			var model:PublicHealthAdvisoriesModel = model as PublicHealthAdvisoriesModel;
			var sortField:String = model.sortMode.data;
			
			var n1:Number = 0;
			var n2:Number = 0;
			
			if( !(a.update && b.update) ) return 0;
			
			if( sortField == PublicHealthAdvisoriesModel.SORT_MODE_UPDATED )
			{
				n1 = a.update.date.time;
				n2 = b.update.date.time;
			}
			else if( sortField == PublicHealthAdvisoriesModel.SORT_MODE_AFFECTED )
			{
				n1 = !isNaN( a.update.affectedCountNetwork ) ? a.update.affectedCountNetwork : 0;
				n2 = !isNaN( b.update.affectedCountNetwork ) ? b.update.affectedCountNetwork : 0;
			}
			else if( sortField == PublicHealthAdvisoriesModel.SORT_MODE_ATRISK )
			{
				n1 = !isNaN( a.update.atRiskCountNetwork ) ? a.update.atRiskCountNetwork : 0;
				n2 = !isNaN( b.update.atRiskCountNetwork ) ? b.update.atRiskCountNetwork : 0;
			}
			else if( sortField == PublicHealthAdvisoriesModel.SORT_MODE_DEATHS )
			{
				n1 = !isNaN( a.update.deathCountNetwork ) ? a.update.deathCountNetwork : 0;
				n2 = !isNaN( b.update.deathCountNetwork ) ? b.update.deathCountNetwork : 0;
			}
			else if( sortField == PublicHealthAdvisoriesModel.SORT_MODE_AFFECTED_TOTAL )
			{
				n1 = !isNaN( a.update.affectedCount ) ? a.update.affectedCount : 0;
				n2 = !isNaN( b.update.affectedCount ) ? b.update.affectedCount : 0;
			}
			else if( sortField == PublicHealthAdvisoriesModel.SORT_MODE_ATRISK_TOTAL )
			{
				n1 = !isNaN( a.update.atRiskCount ) ? a.update.atRiskCount : 0;
				n2 = !isNaN( b.update.atRiskCount ) ? b.update.atRiskCount : 0;
			}
			else if( sortField == PublicHealthAdvisoriesModel.SORT_MODE_DEATHS_TOTAL )
			{
				n1 = !isNaN( a.update.deathCount ) ? a.update.deathCount : 0;
				n2 = !isNaN( b.update.deathCount ) ? b.update.deathCount : 0;
			}
			
			if( n1 == n2 ) return 0;
			
			return n1>n2 ? -1 : 1;
		}
		
		public function showCaseReport():void
		{
			var popup:AdvisoryCaseReportPopup = PopUpManager.createPopUp( AppProperties.getInstance().controller.application, AdvisoryCaseReportPopup ) as AdvisoryCaseReportPopup;
			PopUpManager.centerPopUp( popup );
		}
		
		public function submitCaseReport( report:CaseReport ):void
		{
			var event:AuthenticationEvent = new AuthenticationEvent( AuthenticationEvent.PROMPT );
			event.onAuthenticatedCallback = doSubmitCaseReport;
			AppProperties.getInstance().controller.application.dispatchEvent( event );
		}
		
		private function doSubmitCaseReport():void
		{
			pendingCaseReport = null;
			
			var confirmation:Confirmation = PopUpManager.createPopUp( AppProperties.getInstance().controller.application, Confirmation ) as Confirmation;
			confirmation.confirmationText = "Your case report has been submitted";
			PopUpManager.centerPopUp( confirmation );
		}
		
		private function filter(item:PublicHealthAdvisory):Boolean
		{
			var model:PublicHealthAdvisoriesModel = model as PublicHealthAdvisoriesModel;
			
			var valid:Boolean = true;
			
			if( valid && model.searchText && model.searchText != '' && item.update ) 
				valid = item.update.text.match( new RegExp( model.searchText, "g/i" ) ).length > 0;
			if( valid && model.minDate != null && item.update ) 
				valid = item.update.date.time > model.minDate.time;
			if( valid && model.maxDate != null && item.update ) 
				valid = item.update.date.time < model.maxDate.time;
			
			return valid;
		}
		
		private function filterByActive(item:PublicHealthAdvisory):Boolean
		{
			var valid:Boolean = filter(item);
			return valid && item.active;
		}
		
		private function filterByInactive(item:PublicHealthAdvisory):Boolean
		{
			var valid:Boolean = filter(item);
			return valid && !item.active;
		}
	}
}