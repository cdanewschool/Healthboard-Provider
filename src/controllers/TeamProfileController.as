package controllers
{
	import models.TeamProfileModel;

	public class TeamProfileController extends BaseModuleController
	{
		public function TeamProfileController()
		{
			super();
			
			model = new TeamProfileModel();
		}
	}
}