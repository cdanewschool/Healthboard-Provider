package controllers
{
	import components.home.ViewPatient;
	
	import enum.RiskLevel;
	import enum.UrgencyType;
	
	import models.ApplicationModel;
	import models.ChatSearch;
	import models.PatientModel;
	import models.PatientsModel;
	import models.UserModel;
	import models.modules.AppointmentsModel;
	import models.modules.decisionsupport.RiskFactor;
	import models.modules.decisionsupport.RiskFactorUpdate;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.rpc.events.ResultEvent;
	
	import spark.collections.SortField;
	import spark.components.Application;

	public class ProviderPatientsController extends PatientsController
	{
		public function ProviderPatientsController()
		{
			super();
		}
		
		override public function init():void
		{
			super.init();
			
			var model:PatientsModel = model as PatientsModel;
			
			model.searchParameters = new ArrayCollection
				(
					[
						{id:"fullname", label: 'First and/or Last Name', selected: true},
						{id:"birthday", label: 'DOB', selected: true},
						{id:"sex", label: 'Sex', selected: true},
						{id:"maritalstatus", label: 'Marital Status', selected: false},
						{id:"agerange", label: 'Age Range', selected: true},
						{id:"bloodtype", label: 'Blood Type', selected: false},
						{id:"familyprefix", label: 'Family Prefix', selected: true},
						
						{id:"idnumber", label: 'ID Number', selected: true},
						{id:"patientssn", label: 'Patient\'s SSN', selected: true},
						{id:"sponsorssn", label: 'Sponsor\'s SSN', selected: true},
						{id:"race", label: 'Race', selected: false},
						{id:"address", label: 'Address', selected: false},
						
						{id:"servicebranch", label: 'Service Branch', selected: false},
						{id:"servicestatus", label: 'Status', selected: false},
						{id:"rank", label: 'Rank', selected: false},
						{id:"occupation", label: 'Occupation', selected: false},
						
						{id:"deploymentrange", label: 'Years of Service', selected: false},
						{id:"stationed", label: 'Stationed / Deployment', selected: false},
						
						{id:"visitrange", label: 'Last Visit Range', selected: false},
						{id:"casenumber", label: 'Case Number', selected: false},
						{id:"healthconditions", label: 'Special Health Conditions', selected: false}
					]
				);
			
			model.optionsBloodType = new ArrayCollection
				( 
					[ 
						{label: 'A+', data:"a+", selected: true}, 
						{label: 'B+', data:'b+', selected: true}, 
						{label: 'O+', data:'o+', selected: true},
						{label: 'AB+', data:'ab+', selected: true}, 
						{label: 'A-', data:"a-", selected: true}, 
						{label: 'B-', data:'b-', selected: true}, 
						{label: 'O-', data:'o-', selected: true},
						{label: 'AB-', data:'ab-', selected: true}
					] 
				);
			
			model.optionsFamilyPrefixes = new ArrayCollection
				(
					[
						{label: '01', selected: true},
						{label: '02', selected: true},
						{label: '03', selected: true},
						{label: '04', selected: true},
						{label: '05', selected: true},
						{label: '06', selected: true},
						{label: '07', selected: true},
						{label: '08', selected: true},
						{label: '09', selected: true},
						{label: '10', selected: true},
						{label: '11', selected: true},
						{label: '12', selected: true},
						{label: '13', selected: true},
						{label: '14', selected: true},
						{label: '15', selected: true},
						{label: '16', selected: true},
						{label: '17', selected: true},
						{label: '18', selected: true},
						{label: '19', selected: true},
						{label: '20', selected: true},
						{label: '22', selected: true},
						{label: '22', selected: true},
						{label: '23', selected: true},
						{label: '24', selected: true},
						{label: '25', selected: true},
						{label: '26', selected: true},
						{label: '27', selected: true},
						{label: '28', selected: true},
						{label: '29', selected: true},
						{label: '30', selected: true},
						{label: '33', selected: true},
						{label: '32', selected: true},
						{label: '33', selected: true},
						{label: '34', selected: true},
						{label: '35', selected: true},
						{label: '36', selected: true},
						{label: '37', selected: true},
						{label: '38', selected: true},
						{label: '39', selected: true}
					]
				);
			
			model.optionsMaritalStatus = new ArrayCollection( [ {label: 'Single', data:'single', selected: true}, {label: 'Married', data:'married', selected: true} ] );
			
			model.optionsModules = new ArrayCollection
				(
					[
						{label: 'Exercise', selected: true},
						{label: 'Immunizations', selected: true},
						{label: 'Medications', selected: true},
						{label: 'Nutrition', selected: true},
						{label: 'Vital Signs', selected: true}
					]
				);
			
			model.optionsRace = new ArrayCollection
				( 
					[ 
						{label: 'Caucasion', data:'caucasian', selected: true},
						{label: 'African American', data:"african american", selected: true},
						{label: 'Native American', data:"native american", selected: true},
						{label: 'Alaskan Native', data:"alaskan native", selected: true},
						{label: 'Asian-Pacific Islander', data:'asian-pacific islander', selected: true}, 
						{label: 'Latino/Hispanic', data:'latino', selected: true}
					] 
				);
			
			model.optionsServiceBranch = new ArrayCollection
				( 
					[ 
						{label: 'Air Force', data:"airforce", selected: true}, 
						{label: 'Army', data:"army", selected: true}, 
						{label: 'Coast Guard', data:'coastguard', selected: true},
						{label: 'Marine Corps', data:'marinecorps', selected: true}, 
						{label: 'Navy', data:'navy', selected: true}
					] 
				);
			
			model.optionsServiceStatus = new ArrayCollection
				( 
					[ 
						{label: 'Commissioned', data:"commissioned", selected: true}, 
						{label: 'Non-commissioned', data:"non-commissioned", selected: true}
					] 
				);
			
			model.optionsSex = new ArrayCollection( [ {label: 'Male', data:1, selected: true},{label: 'Female', data:0, selected: true} ] );
			
			model.optionsTeams = new ArrayCollection
				(
					[
						{label: 'Team 1', data: '1', selected: true},
						{label: 'Team 2', data: '2', selected: true},
						{label: 'Team 3', data: '3', selected: true},
						{label: 'Team 4', data: '4', selected: true},
						{label: 'Team 5', data: '5', selected: true},
						{label: 'Team 6', data: '6', selected: true}
					]
				);
			
			model.optionsUrgencies = new ArrayCollection
				(
					[
						{label: 'Urgent', icon: UrgencyType.iconUrgent, data: UrgencyType.URGENT, selected: true},
						{label: 'Somewhat urgent', icon: UrgencyType.iconSomewhatUrgent, data: UrgencyType.SOMEWHAT_URGENT, selected: true},
						{label: 'Not urgent', data: UrgencyType.NOT_URGENT, selected: true}
					]
				);
			
			model.displayedFields =  new ArrayCollection
				( 
					['urgency', 'idNumber', 'team', 'lastName', 'firstName', 'serviceRank', 'sexLabel', 'lastVisitLabel', 'age', 'birthdateLabel', 'conditions'] 
				);
			
			model.dataService.send();
		}
		
		public function showPatient( patient:PatientModel ):void
		{
			var isPatientAlreadyOpen:Boolean = false;
			var viewPatient:ViewPatient;
			
			for(var i:uint = 0; i < model.openTabs.length; i++) 
			{
				if( model.openTabs[i] == patient ) 
				{
					isPatientAlreadyOpen = true;
					
					break;
				}
			}
			
			if( !isPatientAlreadyOpen ) 
			{
				var appointmentsModel:AppointmentsModel = AppProperties.getInstance().controller.appointmentsController.model as AppointmentsModel;
				var application:Application = AppProperties.getInstance().controller.application;
				
				viewPatient = new ViewPatient();
				viewPatient.name = "patient" + patient.id;
				viewPatient.patient = patient;		//acMessages[event.rowIndex];
				viewPatient.selectedAppointment = appointmentsModel.appointments[ appointmentsModel.currentAppointmentIndex ];
				visualDashboardProvider( application ).viewStackMain.addChild(viewPatient);
				visualDashboardProvider( application ).tabsMain.selectedIndex = visualDashboardProvider(application).viewStackMain.length - 1;
				
				model.openTabs.push(patient);	
			}
			else
			{
				viewPatient = visualDashboardProvider(application).viewStackMain.getChildByName(  "patient" + patient.id ) as ViewPatient;
				viewPatient.currentState = ViewPatient.STATE_DEFAULT;
				
				visualDashboardProvider(application).viewStackMain.selectedIndex = visualDashboardProvider(application).viewStackMain.getChildIndex( viewPatient );
			}
		}
		
		override public function dataResultHandler(event:ResultEvent):void 
		{
			super.dataResultHandler(event);
			
			var model:PatientsModel = model as PatientsModel;
			
			var sort:Sort = new Sort();
			sort.fields = [ new SortField( 'urgency', true, true ) ];
			
			model.patients.sort = sort;
			model.patients.refresh();
			
			updateUrgency();
		}
		
		override protected function parsePatient( data:Object):UserModel
		{
			return PatientModel.fromObj(data);
		}
		
		private function updateUrgency():void
		{
			var model:PatientsModel = model as PatientsModel;
			
			var urgentPatientCount:int = 0;
			
			for each(var patient:PatientModel in model.patients)
			{
				if( patient.urgency > UrgencyType.NOT_URGENT )
				{
					urgentPatientCount++;
				}
			}
			
			model.urgentPatientCount = urgentPatientCount;
		}
	}
}