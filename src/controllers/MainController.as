package controllers
{
	import ASfiles.ProviderConstants;
	
	import components.AutoComplete;
	import components.home.ViewPatient;
	import components.modules.TeamModule;
	import components.popups.UserContextMenu;
	
	import events.ApplicationEvent;
	import events.AutoCompleteEvent;
	import events.ProfileEvent;
	
	import external.TabBarPlus.plus.TabBarPlus;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.ApplicationModel;
	import models.Message;
	import models.PatientModel;
	import models.ProviderApplicationModel;
	import models.ProviderModel;
	import models.TeamAppointmentsModel;
	import models.UserModel;
	import models.modules.AppointmentsModel;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.INavigatorContent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import spark.events.IndexChangeEvent;

	public class MainController extends Controller
	{
		public var providers:ArrayCollection;
		public var patients:ArrayCollection;
		
		public var chatController:ChatController;
		
		public var today:Date;
		
		//	TODO: move to model
		[Bindable] public var user:UserModel;	//	logged-in user, i.e. Dr. Berg
		
		private var autocompleteCallback:Function;
		private var autocomplete:AutoComplete;
		
		private var userContextMenu:UserContextMenu;
		private var userContextMenuTimer:Timer;
		
		public var arrOpenPatients:Array = new Array();	//	TODO: move
		
		public function MainController()
		{
			super();
			
			today = new Date( 2012, 09, 12 );			//	simulate october 12th
			
			model = new ProviderApplicationModel();
			
			userContextMenuTimer = new Timer( 2000, 1 );
			userContextMenuTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onUserMenuDelay );
			
			chatController = new ChatController();
			exerciseController = new ProviderExerciseController();
			immunizationsController = new ProviderImmunizationsController();
			medicalRecordsController = new ProviderMedicalRecordsController();
			medicationsController = new ProviderMedicationsController();
			
			application.addEventListener( AutoCompleteEvent.SHOW, onShowAutoComplete );
			application.addEventListener( AutoCompleteEvent.HIDE, onHideAutoComplete );
			application.addEventListener( ProfileEvent.SHOW_CONTEXT_MENU, onShowContextMenu );
		}
		
		public function getUser( id:int, type:String = null ):UserModel
		{
			var user:UserModel;
			var users:ArrayCollection = (type==UserModel.TYPE_PROVIDER?providers:patients);
			
			for each(user in users) if( user.id == id ) return user;
			
			return null;
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
					evt.data = ProviderConstants.MODULE_TEAM;
					application.dispatchEvent( evt );
					
					TeamModule( visualDashboardProvider(application).viewStackProviderModules.getChildByName( ProviderConstants.MODULE_TEAM ) ).showTeamMember( event.user );
				}
				else
				{
					showPatient( event.user as PatientModel );
				}
			}
			else if( event.type == ProfileEvent.VIEW_APPOINTMENTS )
			{
				if( TeamAppointmentsController.getInstance().model.selectedProviders.getItemIndex( event.user ) == -1 )
				{
					TeamAppointmentsController.getInstance().model.selectedProviders.addItem( event.user );
				}
				
				evt = new ApplicationEvent( ApplicationEvent.NAVIGATE, true );
				evt.data = ProviderConstants.MODULE_APPOINTMENTS;
				application.dispatchEvent( evt );
			}
			else if( event.type == ProfileEvent.SEND_MESSAGE )
			{
				var message:Message = new Message();
				message.recipients = [ event.user ];
				
				evt = new ApplicationEvent( ApplicationEvent.NAVIGATE, true );
				evt.data = ProviderConstants.MODULE_MESSAGES;
				evt.message = message;
				application.dispatchEvent( evt );
			}
			else if( event.type == ProfileEvent.START_CHAT )
			{
				chatController.chat( user, event.user );
			}
			
			hideContextMenu();
		}
		
		private function onUserMenuDelay( event:TimerEvent ):void
		{
			if( userContextMenu 
				&& userContextMenu.parent )
			{
				if( !userContextMenu.hitTestPoint( application.stage.mouseX, application.stage.mouseY )
					&& !userContextMenu.chatModes.hitTestPoint( application.stage.mouseX, application.stage.mouseY ) )
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
		
		private function showPatient( patient:PatientModel ):void
		{
			var isPatientAlreadyOpen:Boolean = false;
			var viewPatient:ViewPatient;
			
			for(var i:uint = 0; i < arrOpenPatients.length; i++) 
			{
				if(arrOpenPatients[i] == patient) 
				{
					isPatientAlreadyOpen = true;
					break;
				}
			}
			
			if( !isPatientAlreadyOpen ) 
			{
				viewPatient = new ViewPatient();
				viewPatient.name = "patient" + patient.id;
				viewPatient.patient = patient;		//acMessages[event.rowIndex];
				viewPatient.selectedAppointment = AppointmentsModel(appointmentsController.model).appointments[ AppointmentsModel(appointmentsController.model).currentAppointmentIndex ];
				visualDashboardProvider(application).viewStackMain.addChild(viewPatient);
				visualDashboardProvider(application).tabsMain.selectedIndex = visualDashboardProvider(application).viewStackMain.length - 1;
				arrOpenPatients.push(patient);	
			}
			else
			{
				viewPatient = visualDashboardProvider(application).viewStackMain.getChildByName(  "patient" + patient.id ) as ViewPatient;
				viewPatient.currentState = ViewPatient.STATE_DEFAULT;
				
				visualDashboardProvider(application).viewStackMain.selectedIndex = visualDashboardProvider(application).viewStackMain.getChildIndex( viewPatient );
			}
		}
		
		override protected function onTabClose( event:ListEvent ):void
		{
			super.onTabClose(event);
			
			/*
			
			TODO: fix
			if( TabBarPlus( event.target.owner).dataProvider is IList )
			{
				var dataProvider:IList = TabBarPlus( event.target.owner).dataProvider as IList;
				var index:int = event.rowIndex;
				
				if( dataProvider == visualDashboardProvider(application).viewStackMessages ) 
				{
					//	this array will hold the index values of each "NEW" message in arrOpenTabs. Its purpose is to know which "NEW" message we're closing (if it is in fact a new message)
					var arrNewMessagesInOpenTabs:Array = new Array(); 
					
					for(var i:uint = 0; i < arrOpenTabs.length; i++) 
					{
						if( arrOpenTabs[i] == "NEW") arrNewMessagesInOpenTabs.push(i);
					}
					
					if( arrOpenTabs[index-1] == "NEW" ) 
						arrNewMessages.splice( arrNewMessagesInOpenTabs.indexOf(index-1), 1 );
					
					arrOpenTabs.splice(index-1,1);
					viewStackMessages.selectedIndex--;
				}
				else if( this.currentState == ProviderConstants.MODULE_MEDICATIONS ) 
				{
					arrOpenTabsME.splice(index-1,1);
				{
				else if( this.currentState == ProviderConstants.STATE_PROVIDER_HOME ) 
				{		//aka PROVIDER PORTAL!
					if( dataProvider == viewStackMain) 
						arrOpenPatients.splice(index-1,1);
				}
			}
			else 
			{
				trace("Bad data provider");
			}
			*/
		}
		
		override protected function onNavigate(event:ApplicationEvent):void
		{
			super.onNavigate(event);
			
			var module:INavigatorContent;
			
			if( event.data is int )
			{
				visualDashboardProvider(application).viewStackProviderModules.selectedIndex = event.data;
				
				module = visualDashboardProvider(application).viewStackProviderModules.selectedChild;
			}
			else if( event.data is String )
			{
				if( application.currentState == ProviderConstants.STATE_PROVIDER_HOME ) 
				{
					var moduleName:String = event.data.toString();
					
					if( visualDashboardProvider(application).viewStackProviderModules.getChildByName( moduleName ) ) 
					{
						module = visualDashboardProvider(application).viewStackProviderModules.getChildByName( moduleName ) as INavigatorContent;
						
						visualDashboardProvider(application).viewStackProviderModules.selectedChild = module;
						
						if( event.data == ProviderConstants.MODULE_MESSAGES )
						{
							//createNewMessage( 1 );	//TODO fix
							
							visualDashboardProvider(application).viewStackMessages.selectedIndex = visualDashboardProvider(application).viewStackMessages.length - 2;
						}
						
						if( visualDashboardProvider(application).viewStackMain.selectedIndex != 0 )
						{
							visualDashboardProvider(application).viewStackMain.selectedIndex = 0;
						}
					}
				}
			}
			
			onHideAutoComplete();
		}
	}
}