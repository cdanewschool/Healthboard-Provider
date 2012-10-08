package controllers
{
	import models.ApplicationModel;
	import models.UserModel;
	
	import mx.collections.ArrayCollection;

	public class MainController extends Controller
	{
		public var providers:ArrayCollection;
		public var patients:ArrayCollection;
		
		public var today:Date;
		
		//	TODO: move to model
		[Bindable] public var user:UserModel;	//	logged-in user, i.e. Dr. Berg
		
		public function MainController()
		{
			super();
			
			today = new Date( 2012, 09, 12 );			//	simulate october 12th
			
			model = new ApplicationModel();
			
			exerciseController = new ProviderExerciseController();
			immunizationsController = new ProviderImmunizationsController();
			medicalRecordsController = new ProviderMedicalRecordsController();
			medicationsController = new ProviderMedicationsController();
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