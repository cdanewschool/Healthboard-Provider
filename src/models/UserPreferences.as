package models
{
	import enum.ColorSchemeType;
	import enum.ControlAlign;
	import enum.DateFormatType;
	import enum.SummaryType;
	import enum.TimeFormatType;
	import enum.UnitType;
	import enum.ViewModeType;
	
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class UserPreferences extends Preferences
	{
		//	notifications
		public var summariesActivated:Boolean = false;
		public var summariesType:String = SummaryType.EMAIL;
		public var summariesFrequencyPerUnit:int = 1;
		public var summariesFrequencyUnit:String = "day";
		//	notifications -> alerts (health focus)
		public var alertsShowPinnedItems:Boolean = true;
		//	notifications -> appointments
		public var appointmentsAllowConfirmationBySpecifiedUsers:Boolean = false;
		public var appointmentsShowRequests:Boolean = true;
		public var appointmentsShowClassReservations:Boolean = false;
		public var appointmentsShowCancellations:Boolean = false;
		public var appointmentsShowTeamAvailability:Boolean = true;
		//	notifications -> chat
		public var chatShowUpcomingActivity:Boolean = false;
		public var chatShowNewAppointments:Boolean = false;
		//	notifications -> exercise
		public var exerciseShowPRTPatients:Boolean = true;
		public var exerciseShowGoalActivity:Boolean = false;
		public var exerciseShowExerciseActivity:Boolean = false;
		public var exerciseShowSelfReportedResults:Boolean = false;
		//	notifications -> immunizations
		public var immunizationsShowOverdueVaccinations:Boolean = true;
		//	notifications -> medical records
		public var medicalRecordsShowCompletedNextSteps:Boolean = true;
		public var mecicalRecordsShowOtherNextSteps:Boolean = false;
		//	notifications -> medications
		public var medicationsShowRenewalRequests:Boolean = true;
		public var medicationsShowInteractionWarnings:Boolean = true;
		public var medicationsShowPatientsWhoHaventTakenMedication:Boolean = true;
		public var medicationsShowPatientsWhoHaventTakenMedicationFrequency:String = "day";
		public var medicationsShowPatientsWhoHaventTakenMedicationFrequencyPerUnit:int = 1;
		public var medicationsShowPatientAddedMedications:Boolean = false;
		public var medicationsShowNewPrescriptions:Boolean = false;
		//	notifications -> messages
		public var messagesShowInboxActivity:Boolean = true;
		public var messagesRestrictToUrgent:Boolean = true;
		//	notifications -> patient search
		public var patientSearchShowSearchActvity:Boolean = true;
		public var patientSearchRestrictToUrgent:Boolean = true;
		//	notifications -> public health advisory
		public var publicHealthAdvisoryShowNew:Boolean = true;
		public var publicHealthAdvisoryShowActive:Boolean = false;
		//	notifications -> vital signs
		public var vitalSignsShowRecentlyRecordedVitals:Boolean = true;
		public var vitalSignsShowPatientEnteredGoals:Boolean = false;
		public var vitalSignsShowRecentlyActivatedTrackers:Boolean = false;
		
		public var appointmentConfirmees:ArrayCollection = new ArrayCollection();
		
		public var chatPopupDefaultPosition:String = ControlAlign.BOTTOM_RIGHT;
		public var chatShowAsAvaiableOnLogin:Boolean = true;
		public var chatEnableVoiceChat:Boolean = true;
		public var chatEnableVideoChat:Boolean = true;
		public var chatEnableTimeStamp:Boolean = false;
		
		public var autoResponderActive:Boolean = false;
		public var autoResponderDateFrom:Date;
		public var autoResponderDateTo:Date;
		public var autoResponse:String;
		
		public var signatureActive:Boolean = false;
		public var signature:String;
		
		public function UserPreferences()
		{
		}
		
		public static function fromObj( data:Object ):UserPreferences
		{
			var val:UserPreferences = new UserPreferences();
			
			for (var prop:String in data)
			{
				if( val.hasOwnProperty( prop ) )
				{
					try
					{
						if( val[prop] is ArrayCollection )
						{
							val[prop] = data[prop] is ArrayCollection ? data[prop] : new ArrayCollection( [ data[prop] ] );
						}
						else
						{
							val[prop] = data[prop];
						}
					}
					catch(e:Error){}
				}
			}
			
			return val;
		}
	}
}