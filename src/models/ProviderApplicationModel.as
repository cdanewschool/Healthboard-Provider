package models
{
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

	public class ProviderApplicationModel extends ApplicationModel
	{
		public var appointmentsDataService:HTTPService;
		public var providersDataService:HTTPService;
		
		[Bindable] public var providersModel:ProvidersModel;
		
		public function ProviderApplicationModel()
		{
			super();
			
			appointmentsDataService = new HTTPService();
			providersDataService = new HTTPService();
			
			providersModel = new ProvidersModel();
			
			preferences = new UserPreferences();
		}
	}
}