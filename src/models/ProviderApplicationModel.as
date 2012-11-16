package models
{
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

	public class ProviderApplicationModel extends ApplicationModel
	{
		public var appointmentsDataService:HTTPService;
		public var patientsDataService:HTTPService;
		public var providersDataService:HTTPService;
		
		[Bindable] public var patients:ArrayCollection = new ArrayCollection();			//data provider for the Plot Chart
		
		[Bindable] public var providersModel:ProvidersModel;
		
		public function ProviderApplicationModel()
		{
			super();
			
			appointmentsDataService = new HTTPService();
			patientsDataService = new HTTPService();
			providersDataService = new HTTPService();
			
			providersModel = new ProvidersModel();
			
			preferences = new UserPreferences();
		}
	}
}