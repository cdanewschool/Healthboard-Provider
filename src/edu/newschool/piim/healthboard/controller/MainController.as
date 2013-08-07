package edu.newschool.piim.healthboard.controller
{
	import edu.newschool.piim.healthboard.Constants;
	import edu.newschool.piim.healthboard.ProviderConstants;
	import edu.newschool.piim.healthboard.components.AutoComplete;
	import edu.newschool.piim.healthboard.components.home.ViewPatient;
	import edu.newschool.piim.healthboard.components.modules.TeamModule;
	import edu.newschool.piim.healthboard.components.popups.InactivityAlertPopup;
	import edu.newschool.piim.healthboard.components.popups.UserContextMenu;
	import edu.newschool.piim.healthboard.components.popups.VerifyCredentialsPopup;
	import edu.newschool.piim.healthboard.components.popups.preferences.PreferencesPopup;
	import edu.newschool.piim.healthboard.components.provider.EditProvider;
	import edu.newschool.piim.healthboard.enum.RiskLevel;
	import edu.newschool.piim.healthboard.enum.UrgencyType;
	import edu.newschool.piim.healthboard.enum.ViewModeType;
	import edu.newschool.piim.healthboard.events.ApplicationDataEvent;
	import edu.newschool.piim.healthboard.events.ApplicationEvent;
	import edu.newschool.piim.healthboard.events.AuthenticationEvent;
	import edu.newschool.piim.healthboard.events.AutoCompleteEvent;
	import edu.newschool.piim.healthboard.events.ProfileEvent;
	import edu.newschool.piim.healthboard.model.Chat;
	import edu.newschool.piim.healthboard.model.ChatSearch;
	import edu.newschool.piim.healthboard.model.Message;
	import edu.newschool.piim.healthboard.model.ModuleMappable;
	import edu.newschool.piim.healthboard.model.PatientAlert;
	import edu.newschool.piim.healthboard.model.PatientModel;
	import edu.newschool.piim.healthboard.model.PatientsModel;
	import edu.newschool.piim.healthboard.model.Preferences;
	import edu.newschool.piim.healthboard.model.ProviderApplicationModel;
	import edu.newschool.piim.healthboard.model.ProviderModel;
	import edu.newschool.piim.healthboard.model.ProvidersModel;
	import edu.newschool.piim.healthboard.model.SavedSearch;
	import edu.newschool.piim.healthboard.model.TeamAppointmentsModel;
	import edu.newschool.piim.healthboard.model.UserModel;
	import edu.newschool.piim.healthboard.model.UserPreferences;
	import edu.newschool.piim.healthboard.model.module.MedicationsModel;
	import edu.newschool.piim.healthboard.model.module.MessagesModel;
	import edu.newschool.piim.healthboard.model.modules.advisories.PatientAdvisoryStatus;
	import edu.newschool.piim.healthboard.model.modules.advisories.PublicHealthAdvisoriesModel;
	import edu.newschool.piim.healthboard.model.modules.advisories.PublicHealthAdvisory;
	import edu.newschool.piim.healthboard.model.modules.decisionsupport.RiskFactor;
	import edu.newschool.piim.healthboard.model.modules.decisionsupport.RiskFactorUpdate;
	import edu.newschool.piim.healthboard.util.DateFormatters;
	import edu.newschool.piim.healthboard.util.DateUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.INavigatorContent;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import net.flexwiz.blog.tabbar.plus.TabBarPlus;
	
	import spark.components.DropDownList;
	import spark.events.IndexChangeEvent;

	[Bindable]
	public class MainController extends Controller
	{
		public var advisoryController:PublicHealthAdvisoriesController;
		public var chatController:ChatController;
		public var decisionSupportController:DecisionSupportController;
		public var teamAppointmentsController:TeamAppointmentsController;
		
		private var autocompleteCallback:Function;
		private var autocomplete:AutoComplete;
		
		private var userContextMenu:UserContextMenu;
		private var userContextMenuTimer:Timer;
		
		private var authenticationPopup:VerifyCredentialsPopup;
		private var inactivityAlert:InactivityAlertPopup;
		private var editProfilePopup:EditProvider;
		
		public function MainController()
		{
			super();
			
			model = new ProviderApplicationModel();
			
			userContextMenuTimer = new Timer( 2000, 1 );
			userContextMenuTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onUserMenuDelay );
			
			advisoryController = new PublicHealthAdvisoriesController();
			chatController = new ChatController();
			decisionSupportController = new DecisionSupportController();
			exerciseController = new ProviderExerciseController();
			immunizationsController = new ProviderImmunizationsController();
			medicalRecordsController = new ProviderMedicalRecordsController();
			medicationsController = new ProviderMedicationsController();
			nutritionController = new ProviderNutritionController();
			patientsController = new ProviderPatientsController();
			
			teamAppointmentsController = new TeamAppointmentsController();
			
			advisoryController.model.addEventListener( ApplicationDataEvent.LOADED, onAdvisoriesLoaded );
			
			var lastSynced:Date = new Date( model.today.fullYear, model.today.month, model.today.date );;
			lastSynced.time -= DateUtil.DAY * Math.random();
			
			model.settings = new ArrayCollection
				( 
					[ 
						{id:"user_profile", label:"User Profile", tooltip:"Set and modify personal information."}, 
						{id:"preferences", label:"Preferences", tooltip:"Set preferences for general settings, notifications and modules."}, 
						{id:"",label: "---------------------------------------------------", enabled:false }, 
						{id:"sync_status", label: "Last synced " + DateFormatters.syncTime.format( lastSynced ), enabled:false }, 
						{id:"sync", label:"Sync Now"} 
					] 
				);
			
			model.addEventListener( ApplicationDataEvent.LOADED, onAlertsLoaded );
			medicationsController.model.addEventListener( ApplicationDataEvent.LOADED, onMedicationsLoaded );
		
			appointmentsController.model.addEventListener( ApplicationDataEvent.LOADED, onAppointmentsLoaded );
			patientsController.model.addEventListener( ApplicationDataEvent.LOADED, onPatientsLoaded );
			providersController.model.addEventListener( ApplicationDataEvent.LOADED, onProvidersLoaded );
			
			application.addEventListener( AuthenticationEvent.PROMPT, onPromptForAuthentication );
			application.addEventListener( AutoCompleteEvent.SHOW, onShowAutoComplete );
			application.addEventListener( AutoCompleteEvent.HIDE, onHideAutoComplete );
			application.addEventListener( ProfileEvent.SHOW_CONTEXT_MENU, onShowContextMenu );
			
			patientsController.model.addEventListener( ApplicationDataEvent.LOADED, onPatientsLoaded );
			
			loadStyles();
		}
		
		override protected function onInitialized():void
		{
			if( !initialized ) return;
			
			if( Constants.DEBUG ) 
			{
				for each(var provider:UserModel in ProvidersModel(providersController.model).providers)
				{
					if( provider.id == ProviderConstants.DEBUG_USER_ID ) 
					{
						provider.available = UserPreferences(model.preferences).chatShowAsAvaiableOnLogin ? "A" : "U";	//	TODO: change to boolean
						
						model.user = provider;
						
						application.dispatchEvent( new AuthenticationEvent( AuthenticationEvent.SUCCESS, true ) );
						
						break;
					}
				}
			}
		}
		
		override public function validateUser( username:String, password:String ):UserModel
		{
			for each(var provider:UserModel in ProvidersModel(providersController.model).providers)
			{
				if( provider.username == username && provider.password == password ) 
				{
					return provider;
				}
			}
			
			return null;
		}
		
		override public function getDefaultUser():UserModel
		{
			for each(var provider:UserModel in ProvidersModel(providersController.model).providers)
			{
				if( provider.id == ProviderConstants.DEBUG_USER_ID ) 
				{
					return provider;
				}
			}
			
			return null;
		}
		
		override public function showPreferences():UIComponent
		{
			var popup:PreferencesPopup = PopUpManager.createPopUp( application, PreferencesPopup ) as PreferencesPopup;
			popup.preferences = model.preferences.clone() as UserPreferences;
			PopUpManager.centerPopUp( popup );
			
			return popup;
		}
		
		override protected function loadPreferences():void
		{
			if( persistentData 
				&& persistentData.data.hasOwnProperty('preferences') )
			{
				model.preferences = UserPreferences.fromObj( persistentData.data['preferences'] );
			}
			else
			{
				model.preferences = new UserPreferences();
				savePreferences( model.preferences );
			}
			
			processPreferences();
		}
		
		override public function savePreferences( preferences:Preferences ):void
		{
			super.savePreferences(preferences);
			
			persistentData.data['preferences'] = preferences;
			persistentData.flush();
		}
		
		override protected function processPreferences( preferences:Preferences = null ):void
		{
			if( preferences == null ) preferences  = model.preferences;
			
			super.processPreferences( preferences );
			
			if( preferences 
				&& preferences.viewMode != model.preferences.viewMode )
			{
				var state:String = preferences.viewMode == ViewModeType.WIDGET ? Constants.STATE_WIDGET_VIEW : Constants.STATE_LOGGED_IN;
				state = Constants.STATE_LOGGED_IN;	//	widget view not supported yet
				
				application.dispatchEvent( new ApplicationEvent( ApplicationEvent.SET_STATE, true, false, state) );
			}
		}
		
		override protected function onAuthenticated(event:AuthenticationEvent):void
		{
			if( !controllersInitialized )
			{
				advisoryController.init();
				chatController.init();
				decisionSupportController.init();
				teamAppointmentsController.init();
				
				onAdvisoriesLoaded();
				
				initChatHistory();
			}
			
			super.onAuthenticated(event);
		}
		
		override protected function showHome():void
		{
			setState( Constants.STATE_LOGGED_IN );
		}
		
		protected function onPromptForAuthentication( event:AuthenticationEvent ):void
		{
			if( authenticationPopup
				&& authenticationPopup.parent )
			{
				PopUpManager.removePopUp( authenticationPopup );
			}
			
			authenticationPopup = PopUpManager.createPopUp( application, VerifyCredentialsPopup ) as VerifyCredentialsPopup;
			authenticationPopup.callback = event.onAuthenticatedCallback;
			authenticationPopup.callbackArgs = event.onAuthenticatedCallbackArgs;
			
			authenticationPopup.user = model.user;
			authenticationPopup.addEventListener( AuthenticationEvent.SUCCESS, onAuthenticationCheckSuccess );
			PopUpManager.centerPopUp( authenticationPopup );
		}
		
		protected function onAuthenticationCheckSuccess( event:AuthenticationEvent ):void
		{
			if( authenticationPopup
				&& authenticationPopup.callback != null )
			{
				authenticationPopup.callbackArgs ? 
					authenticationPopup.callback( authenticationPopup.callbackArgs ) :
					authenticationPopup.callback();
			}
		}
		
		public function getUser( id:int, type:String = null ):UserModel
		{
			var user:UserModel;
			var users:ArrayCollection = ( type == UserModel.TYPE_PROVIDER ? ProvidersModel(providersController.model).providers : PatientsModel(patientsController.model).patients );
			
			for each(user in users) if( user.id == id ) return user;
			
			return null;
		}
		
		override public function selectSetting( event:IndexChangeEvent ):void
		{
			super.selectSetting(event);
			
			var item:Object = model.settings.getItemAt( event.newIndex );
			var evt:AuthenticationEvent;
			
			if( item.id == "user_profile" )
			{
				showEditProfile();
			}
			else if( item.id == "preferences" )
			{
				evt = new AuthenticationEvent( AuthenticationEvent.PROMPT, true );
				evt.onAuthenticatedCallback = showPreferences;
				application.dispatchEvent( evt );
			}
			else if( item.id == "sync" )
			{
				item.enabled = false;
				
				for each(item in model.preferences)
				{
					if( item.id == "sync_status" )
					{
						item.label = "All information up to date";
					}
				}
			}
			
			DropDownList(event.currentTarget).selectedItem = null;
		}
		
		public function showEditProfile():void
		{
			var evt:AuthenticationEvent = new AuthenticationEvent( AuthenticationEvent.PROMPT, true );
			evt.onAuthenticatedCallback = editProfile;
			application.dispatchEvent( evt );
		}
		
		private function editProfile():void
		{
			editProfilePopup = PopUpManager.createPopUp( application, EditProvider, true ) as EditProvider;
			editProfilePopup.provider = ProviderModel(model.user).clone() as ProviderModel;
			editProfilePopup.addEventListener( ProfileEvent.SAVE, onEditProfileSave );
			
			PopUpManager.centerPopUp( editProfilePopup );
		}
		
		private function onEditProfileSave( event:ProfileEvent ):void
		{
			ProviderModel(model.user).copy( event.user as ProviderModel );
			
			PopUpManager.removePopUp(editProfilePopup);
		}
		
		/**
		 * Autocomplete
		 */
		private function onShowAutoComplete( event:AutoCompleteEvent ):void
		{
			if( !autocomplete )
			{
				autocomplete = new AutoComplete();
				autocomplete.addEventListener( Event.CHANGE, onAutocompleteSelect );
				autocomplete.addEventListener( AutoCompleteEvent.HIDE, onHideAutoComplete );
			}
			
			autocomplete.targetField = event.targetField;
			autocomplete.callbackFunction = event.callbackFunction;
			autocomplete.labelFunction = event.labelFunction;
			autocomplete.dataProvider = event.dataProvider;
			autocomplete.width = event.desiredWidth ? event.desiredWidth : event.targetField.width;
			
			PopUpManager.addPopUp( autocomplete, application );
		}
		
		private function onHideAutoComplete( event:AutoCompleteEvent = null ):void
		{
			if( autocomplete )
			{
				PopUpManager.removePopUp( autocomplete );
			}
		}
		
		private function onAutocompleteSelect( event:IndexChangeEvent ):void
		{
			autocomplete.callbackFunction( event );
		}
		
		/**
		 * User context menu
		 */
		private function onShowContextMenu(event:ProfileEvent):void 
		{
			if( userContextMenu ) hideContextMenu();
			
			userContextMenu = new UserContextMenu();
			userContextMenu.user = event.user;
			userContextMenu.addEventListener( ProfileEvent.VIEW_PROFILE, onUserAction );
			userContextMenu.addEventListener( ProfileEvent.VIEW_APPOINTMENTS, onUserAction );
			userContextMenu.addEventListener( ProfileEvent.SEND_MESSAGE, onUserAction );
			userContextMenu.addEventListener( ProfileEvent.START_CHAT, onUserAction );
			
			userContextMenu.x = application.stage.mouseX;
			userContextMenu.y = application.stage.mouseY;
			
			PopUpManager.addPopUp( userContextMenu, DisplayObject(mx.core.FlexGlobals.topLevelApplication) );
			
			userContextMenuTimer.reset();
			userContextMenuTimer.start();
		}
		
		private function hideContextMenu():void
		{
			if( !userContextMenu ) return;
			
			userContextMenu.removeEventListener( ProfileEvent.VIEW_PROFILE, onUserAction );
			userContextMenu.removeEventListener( ProfileEvent.VIEW_APPOINTMENTS, onUserAction );
			userContextMenu.removeEventListener( ProfileEvent.SEND_MESSAGE, onUserAction );
			userContextMenu.removeEventListener( ProfileEvent.START_CHAT, onUserAction );
			
			PopUpManager.removePopUp( userContextMenu );
		}
		
		private function onUserAction( event:ProfileEvent ):void
		{
			var evt:ApplicationEvent;
			
			if( event.type == ProfileEvent.VIEW_PROFILE )
			{
				if( event.user is ProviderModel )
				{
					evt = new ApplicationEvent( ApplicationEvent.NAVIGATE, true );
					evt.data = ProviderConstants.MODULE_TEAM_PROFILE;
					application.dispatchEvent( evt );
					
					TeamModule( Main(application).viewStackProviderModules.getChildByName( ProviderConstants.MODULE_TEAM_PROFILE ) ).showTeamMember( event.user );
				}
				else
				{
					ProviderPatientsController(patientsController).showPatient( event.user as PatientModel );
				}
			}
			else if( event.type == ProfileEvent.VIEW_APPOINTMENTS )
			{
				if( TeamAppointmentsModel( teamAppointmentsController.model ).selectedProviders.getItemIndex( event.user ) == -1 )
				{
					TeamAppointmentsModel( teamAppointmentsController.model ).selectedProviders.addItem( event.user );
				}
				
				evt = new ApplicationEvent( ApplicationEvent.SET_STATE, true );
				evt.data = ProviderConstants.MODULE_TEAM_APPOINTMENTS;
				application.dispatchEvent( evt );
			}
			else if( event.type == ProfileEvent.SEND_MESSAGE )
			{
				var message:Message = new Message();
				message.recipients = [ event.user ];
				
				evt = new ApplicationEvent( ApplicationEvent.SET_STATE, true );
				evt.data = Constants.MODULE_MESSAGES;
				evt.message = message;
				application.dispatchEvent( evt );
			}
			else if( event.type == ProfileEvent.START_CHAT )
			{
				chatController.chat( model.user, event.user );
			}
			
			hideContextMenu();
		}
		
		private function onUserMenuDelay( event:TimerEvent ):void
		{
			if( userContextMenu 
				&& userContextMenu.parent )
			{
				if( !userContextMenu.hitTestPoint( application.stage.mouseX, application.stage.mouseY )
					&& (!userContextMenu.chatModes || !userContextMenu.chatModes.hitTestPoint( application.stage.mouseX, application.stage.mouseY )) )
				{
					hideContextMenu();
				}
				else
				{
					userContextMenuTimer.reset();
					userContextMenuTimer.start();
				}
			}
		}
		
		override protected function onSetState( event:ApplicationEvent ):void
		{
			var child:DisplayObject;
			
			if( event.message )
			{
				if( event.message.recipients ) MessagesModel(messagesController.model).pendingRecipients = event.message.recipients;
				if( event.message.recipientType ) MessagesModel(messagesController.model).pendingRecipientType = event.message.recipientType;
				if( event.message.subject ) MessagesModel(messagesController.model).pendingSubject = event.message.subject;
				if( event.message.body ) MessagesModel(messagesController.model).pendingBody = event.message.body;
				if( event.message.urgency ) MessagesModel(messagesController.model).pendingUrgency = event.message.urgency;
			}
			
			var modPrefix:String = 'mod';
			
			if( event.data != null && event.data.indexOf( modPrefix ) > -1 )
			{
				var id:String = event.data.substr( event.data.indexOf( modPrefix ) + modPrefix.length ).toLowerCase();
				
				if( model.preferences.getPasswordRequiredForModule( id ) )
				{
					var evt:AuthenticationEvent = new AuthenticationEvent( AuthenticationEvent.PROMPT, true );
					evt.onAuthenticatedCallback = setState;
					evt.onAuthenticatedCallbackArgs = event.data;
					application.dispatchEvent( evt );
					
					return;
				}
			}
			
			if( Main(application).viewStackMain ) Main(application).viewStackMain.verticalScrollPosition = 0;
			if( Main(application).viewStackProviderModules ) Main(application).viewStackProviderModules.verticalScrollPosition = 0;
			
			super.onSetState(event);
		}
		
		override protected function setState(state:String):Boolean
		{
			var stateSet:Boolean = super.setState(state);
			
			if( stateSet ) return true;
			
			var child:DisplayObject;
				
			//	show relevant application module if valid
			if( Main(application).viewStackProviderModules
				&& (child = Main(application).viewStackProviderModules.getChildByName( state ) ) != null )
			{
				Main(application).viewStackProviderModules.selectedChild = child as INavigatorContent;
				
				if( Main(application).viewStackMain.selectedIndex != 0 )
				{
					Main(application).viewStackMain.selectedIndex = 0;
				}
				
				return true;
			}
				
			//	show relevant patient module if valid
			else if( Main(application).viewStackMain.selectedChild is ViewPatient )
			{
				(Main(application).viewStackMain.selectedChild as ViewPatient).showModule( state );
				
				return true;
			}
			
			return false;
		}
		
		override protected function onTabClose( event:ListEvent ):void
		{
			super.onTabClose(event);
			
			if( TabBarPlus( event.target.owner).dataProvider is IList )
			{
				var dataProvider:IList = TabBarPlus( event.target.owner).dataProvider as IList;
				var index:int = event.rowIndex;
				
				if( application.currentState == Constants.MODULE_MEDICATIONS ) 
				{
					medicationsController.model.openTabs.splice(index-1,1);
				}
				else if( application.currentState == model.viewMode ) 
				{
					if( dataProvider == Main(application).viewStackMain ) 
					{
						PatientsModel(patientsController.model).openTabs.splice(index-1,1);
					}
				}
			}
			else 
			{
				trace("Bad data provider");
			}
		}
		
		override protected function onNavigate(event:ApplicationEvent):void
		{
			super.onNavigate(event);
			
			var module:INavigatorContent;
			
			if( event.data is int )
			{
				Main(application).viewStackProviderModules.selectedIndex = event.data;
				
				module = Main(application).viewStackProviderModules.selectedChild;
			}
			else if( event.data is String )
			{
				if( application.currentState == Constants.STATE_LOGGED_IN ) 
				{
					var moduleName:String = event.data.toString();
					
					if( Main(application).viewStackProviderModules.getChildByName( moduleName ) ) 
					{
						module = Main(application).viewStackProviderModules.getChildByName( moduleName ) as INavigatorContent;
						
						Main(application).viewStackProviderModules.selectedChild = module;
						
						if( Main(application).viewStackMain.selectedIndex != 0 )
						{
							Main(application).viewStackMain.selectedIndex = 0;
						}
					}
				}
			}
			
			Main(application).viewStackMain.verticalScrollPosition = 0;
			Main(application).viewStackProviderModules.verticalScrollPosition = 0;
			
			onHideAutoComplete();
		}
		
		override protected function showInactivityTimeout():void
		{
			if( inactivityAlert && inactivityAlert.parent ) return;
			
			inactivityAlert = PopUpManager.createPopUp( application, InactivityAlertPopup, true ) as InactivityAlertPopup;
			inactivityAlert.addEventListener( CloseEvent.CLOSE, onInactivityAlertClose );
			PopUpManager.centerPopUp( inactivityAlert );
		}
		
		override public function logout():void
		{
			for each(var patient:PatientModel in PatientsModel(patientsController.model).openTabs)
			{
				var viewPatient:ViewPatient =  Main(application).viewStackMain.getChildByName(  "patient" + patient.id ) as ViewPatient;
				Main(application).viewStackMain.removeChild(  viewPatient );
			}
			
			PatientsModel(patientsController.model).openTabs = [];
			
			super.logout();
		}
		
		private function onInactivityAlertClose( event:CloseEvent ):void
		{
			lastActivity = getTimer();
			
			PopUpManager.removePopUp( inactivityAlert );
		}
		
		private function onAlertsLoaded(event:ApplicationDataEvent):void
		{
			model.removeEventListener( ApplicationDataEvent.LOADED, onAlertsLoaded );
			
			syncMeds();
		}
		
		private function onMedicationsLoaded(event:ApplicationDataEvent):void
		{
			medicationsController.model.removeEventListener( ApplicationDataEvent.LOADED, onMedicationsLoaded );
			
			syncMeds();
		}
		
		private function syncMeds():void
		{
			var model:ProviderApplicationModel = ProviderApplicationModel(model);
			
			if( !model.patientAlertsLoaded || !medicationsController.model.dataLoaded ) return;
			
			//	for all renewal requests, make sure status of corresponding medication is set to pending
			//	should probably be the other way around?
			for each(var alert:Object in model.patientAlerts)
			{
				var type:String = alert.type;
				var alertType:String = alert.alert;
				
				if( type == "Medications" 
					&& alertType == "Renewal Request" )
				{
					var medicationName:String = alert.description;
					
					var medications:ArrayCollection = MedicationsModel(AppProperties.getInstance().controller.medicationsController.model).medicationsData;
					
					for each(var medication:Object in medications)
					{
						if( medication.name == medicationName )
						{
							medication.renewalStatus = "Pending";
						}
					}
				}
			}
		}
		
		override protected function onPatientsLoaded(event:ApplicationDataEvent):void 
		{
			super.onPatientsLoaded(event);
			
			var patients:ArrayCollection = PatientsModel(patientsController.model).patients;
			
			for each(var patient:PatientModel in patients)
			{
				for each(var riskFactor:RiskFactor in patient.riskFactorGroups)
				{
					for each(var riskFactorSubType:RiskFactor in riskFactor.types)
					{
						if( riskFactorSubType.updates 
							&& riskFactorSubType.updates.length )
						{
							var update:RiskFactorUpdate = riskFactorSubType.updates.getItemAt(0) as RiskFactorUpdate;
							
							if( update.riskLevel == RiskLevel.HIGH )
							{
								var alert:PatientAlert = new PatientAlert( "High Risk", update.date, riskFactor.name, "Decision Support", UrgencyType.URGENT );
								model.patientAlerts.addItem( alert );
								
								break;
							}
						}	
					}
				}
			}
			
			ChatSearch( chatController.model ).patients = patients;
		}
		
		override protected function onProvidersLoaded(event:ApplicationDataEvent):void 
		{
			super.onProvidersLoaded(event);
			
			if( model.user
				&& persistentData 
				&& persistentData.data.hasOwnProperty('savedSearches') )
			{
				var savedSearches:ArrayCollection = new ArrayCollection();
				
				for each(var search:Object in persistentData.data.savedSearches)
				{
					savedSearches.addItem( SavedSearch.fromObj( search ) );
				}
				
				ProviderModel( model.user ).savedSearches = savedSearches;
			}
			
			ChatSearch( chatController.model ).providers = ProvidersModel(providersController.model).providers;
			
			onInitialized();
		}
		
		private function onAdvisoriesLoaded( event:ApplicationDataEvent = null ):void
		{
			if( !advisoryController.model.dataLoaded && patientsController.model.dataLoaded ) return;
			
			for each(var patient:PatientModel in PatientsModel(patientsController.model).patients)
			{
				for each(var advisoryStatus:PatientAdvisoryStatus in patient.advisories)
				{
					var advisory:PublicHealthAdvisory = advisoryController.getAdvisoryById( advisoryStatus.advisoryId );
					
					if( advisory )
					{
						if( advisoryStatus.riskLevel == RiskLevel.LOW || advisoryStatus.riskLevel == RiskLevel.HIGH )
						{
							advisory.update.addAtRiskInNetwork( patient );
						}
						else if( advisoryStatus.riskLevel == RiskLevel.AFFECTED )
						{
							advisory.update.addAffectedInNetwork( patient );
						}
					}
				}
			}
		}
		
		private function initChatHistory():void
		{
			if( !ChatSearch( chatController.model ).providers 
				|| !ChatSearch( chatController.model ).patients ) return;
			
			var user:UserModel = ChatSearch(chatController.model).getUser( AppProperties.getInstance().controller.model.user.id, UserModel.TYPE_PROVIDER );
			
			var today:Date = model.today;
			var time:Number = today.getTime();
			
			var defs:Array = 
				[ 
					{time: time - (DateUtil.DAY * 1 + DateUtil.DAY * .7 * Math.random()), id: 123, type: UserModel.TYPE_PATIENT},
					{time: time - (DateUtil.DAY * 3 + DateUtil.DAY * .7 * Math.random()), id: 123, type: UserModel.TYPE_PATIENT},
					{time: time - (DateUtil.MONTH * .9 + DateUtil.DAY * .7 * Math.random()), id: 123, type: UserModel.TYPE_PATIENT},
					{time: time - (DateUtil.MONTH * 4 + DateUtil.DAY * 3 + DateUtil.DAY * .7 * Math.random()), id: 1, type: UserModel.TYPE_PROVIDER}
				];
			
			for each(var def:Object in defs)
			{
				var start:Date = new Date();
				start.setTime( def.time );
				
				var end:Date = new Date();
				end.setTime( start.time + (DateUtil.HOUR * Math.random()) );
				
				chatController.saveChat( user, new Chat( user, ChatSearch(chatController.model).getUser( def.id, def.type ), start, end ) );
			}
			
			teamAppointmentsController.model.dataService.send();
		}
		
		override public function getModuleTitle(module:String):String
		{
			var title:String = super.getModuleTitle(module);
			
			if( module == ProviderConstants.MODULE_DECISION_SUPPORT ) return "Decision Support";
			if( module == ProviderConstants.MODULE_TEAM_PROFILE ) return "Team Profile";
			
			return title;
		}
		
		//	TODO: call a load() method on these controllers vs. calling send(), so they can defer loading
		//	until a dependency has been loaded
		override public function loadData( id:String ):Boolean
		{
			if( id == PublicHealthAdvisoriesModel.ID )
			{
				if( !advisoryController.model.dataLoaded ) 
				{
					advisoryController.model.dataService.send();
					
					return true;
				}
			}
			else if( id == TeamAppointmentsModel.ID )
			{
				if( !teamAppointmentsController.model.dataLoaded )
				{
					teamAppointmentsController.model.dataService.send();
					
					return true;
				}
			}
			
			return super.loadData( id );
		}
		
		override public function processModuleMappable( item:ModuleMappable ):void
		{
			super.processModuleMappable(item);
			
			var module:String;
			
			if( item.area == TeamAppointmentsModel.ID )
				module = ProviderConstants.MODULE_TEAM_APPOINTMENTS;
			else if( item.area == "teamprofile" )
				module = ProviderConstants.MODULE_TEAM_PROFILE;
			
			if( module )
			{
				var evt:ApplicationEvent = new ApplicationEvent( ApplicationEvent.SET_STATE, true, false, module );
				application.dispatchEvent( evt );
			}
		}
		
		override protected function get id():String
		{
			return 'Main';
		}
	}
}
