package models
{
	import enum.AppContext;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

	public class ProviderApplicationModel extends ApplicationModel
	{
		public var appointmentsDataService:HTTPService;
		public var providersDataService:HTTPService;
		
		public function ProviderApplicationModel()
		{
			super( AppContext.PROVIDER );
			
			appointmentsDataService = new HTTPService();
			providersDataService = new HTTPService();
			
			preferences = new UserPreferences();
		}
	}
}