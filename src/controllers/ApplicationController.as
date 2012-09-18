package controllers
{
	import models.UserModel;
	
	import mx.collections.ArrayCollection;

	public class ApplicationController
	{
		private static var __instance:ApplicationController;
		
		public var providers:ArrayCollection;
		public var patients:ArrayCollection;
		
		public var today:Date;
		public function ApplicationController( enforcer:SingletonEnforcer )
		{
			today = new Date( 2012, 09, 12 );			//	simulate october 12th
		}
		
		public static function getInstance():ApplicationController
		{
			if( !__instance ) __instance = new ApplicationController( new SingletonEnforcer() );
			
			return __instance;
		}
		
		public function getUser( id:int, type:String = null ):UserModel
		{
			var user:UserModel;
			var users:ArrayCollection = (type==UserModel.TYPE_PROVIDER?providers:patients);
			
			for each(user in users) if( user.id == id ) return user;
			
			return null;
		}
	}
}
internal class SingletonEnforcer
{
}