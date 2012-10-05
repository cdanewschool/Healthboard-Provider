import ASclasses.Constants;

import ASfiles.ProviderConstants;

import components.AutoComplete;
import components.home.ViewPatient;
import components.modules.TeamModule;
import components.popups.UserContextMenu;

import controllers.AppointmentsController;
import controllers.ChatController;
import controllers.MainController;

import events.ApplicationDataEvent;
import events.ApplicationEvent;
import events.AutoCompleteEvent;
import events.ProfileEvent;

import external.TabBarPlus.plus.TabBarPlus;
import external.TabBarPlus.plus.TabPlus;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import models.ApplicationModel;
import models.Chat;
import models.Message;
import models.PatientModel;
import models.ProviderModel;
import models.ProvidersModel;
import models.UserModel;

import mx.binding.utils.BindingUtils;
import mx.charts.chartClasses.CartesianDataCanvas;
import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.controls.LinkButton;
import mx.core.FlexGlobals;
import mx.core.INavigatorContent;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.ListEvent;
import mx.graphics.SolidColorStroke;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import spark.events.DropDownEvent;
import spark.events.IndexChangeEvent;

import styles.ChartStyles;

import utils.DateUtil;

[Bindable] public var controller:MainController;
[Bindable] public var medicalRecordsController:MainController;

[Bindable] public var chartStyles:ChartStyles;

private function init():void
{
	AppProperties.getInstance().controller = controller = new MainController();
	
	populateDatesForWidget();	//	this popuplates the 'appointments' array
	
	var model:ApplicationModel = new ApplicationModel();
	model.chartStyles = chartStyles = new ChartStyles();
	model.patientVitalSigns = arrVitalSigns;
	model.patientExercises = exerciseData;
	model.patientExercisesWidget = arrExerciseForWidget;
	model.patientAppointments = new ArrayCollection( appointments );
	model.patientAppointmentIndex = currentAppt;
	controller.model = model;
	
	if( ProviderConstants.DEBUG ) this.currentState = "providerHome";

	userContextMenuTimer = new Timer( 2000, 1 );
	userContextMenuTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onUserMenuDelay);
	
	updateExercisePAIndices();
	
	BindingUtils.bindProperty( model.chartStyles, 'horizontalFill', this, 'myHorizontalFill');
	BindingUtils.bindProperty( model.chartStyles, 'horizontalAlternateFill', this, 'myHorizontalAlternateFill');
	
	this.addEventListener( AutoCompleteEvent.SHOW, onShowAutoComplete );
	this.addEventListener( AutoCompleteEvent.HIDE, onHideAutoComplete );
	this.addEventListener( ApplicationDataEvent.LOAD, onLoadDataRequest );
	this.addEventListener( ApplicationEvent.NAVIGATE, onNavigate );
	this.addEventListener( ProfileEvent.SHOW_CONTEXT_MENU, onShowContextMenu );
	this.addEventListener( TabPlus.CLOSE_TAB_EVENT, onTabClose );
	
	patientsXMLdata.send();
	providersXMLdata.send();
}

private function onResize():void
{
	if( !this.stage ) return;
	
	FlexGlobals.topLevelApplication.height = this.stage.stageHeight;
}

public function get bgeMedications():Array { return chartStyles.bgeMedications; }
public function get bgeMedicationsWidget():Array { return chartStyles.bgeMedicationsWidget; }
public function get canvasMed():CartesianDataCanvas { return chartStyles.canvasMed; }
public function get canvasMedWidget():CartesianDataCanvas { return chartStyles.canvasMedWidget; }
public function get medicationsVerticalGridLine():SolidColorStroke { return chartStyles.medicationsVerticalGridLine; }

[Bindable] public var fullname:String;
[Bindable] private var registeredUserID:String = "thisValueWillBeReplaced";
[Bindable] private var registeredPassword:String = "thisValueWillBeReplaced";
protected function btnLogin_clickHandler(event:MouseEvent):void {
	if(userID.text == 'popo' || (userID.text == 'piim' && password.text == 'password') || (userID.text == 'gregory' && password.text == 'berg')) {
		this.currentState='providerHome';
		
		if(userID.text == 'popo' || (userID.text == 'piim' && password.text == 'password')) fullname = "Dr. Gregory Berg";
		else if(userID.text == 'gregory' && password.text == 'berg') fullname = "Dr. Gregory Berg";
		//else, fullname will contain the name the user indicated at registration.
		
		clearValidationErrorsLogin();
		bcLogin.height = 328;
	}
	else {
		usernameValidator.validate('');		//here we are forcing the userID and password text fields to show red borders, by validating them as if they had empty values.
		passwordValidator.validate('');
		hgLoginFail.visible = hgLoginFail.includeInLayout = true;
		bcLogin.height = 346;
		//this.currentState='default';
	}
}

protected function bar_initializeHandlerMain():void {
	// Set first tab as non-closable
	tabsMain.setTabClosePolicy(0, false);
}

//THE FOLLOWING TWO ARE MONSTER FUNCTIONS THAT PREVENT THE DROPDOWN FROM CLOSING WHEN CLICKING ON THE CALENDAR
//SEE http://www.blastanova.com/blog/2010/06/23/a-custom-multi-selection-spark-dropdownlist/ FOR REFERENCE
protected function dropDownCalendar_openHandler(event:DropDownEvent):void {
	patientBirthDateChooser.addEventListener(MouseEvent.MOUSE_DOWN, stopPropagation, false, 0, true);
}
protected function stopPropagation(event:Event):void {
	event.stopImmediatePropagation();
}

protected function dateChooser_changeHandler(event:CalendarLayoutChangeEvent):void {
	txtPatientBirthDay.text = String(patientBirthDateChooser.selectedDate.date);
	txtPatientBirthMonth.text = String(patientBirthDateChooser.displayedMonth + 1);
	txtPatientBirthYear.text = String(patientBirthDateChooser.displayedYear);
	dropDownCalendar.closeDropDown(true);					
}

[Bindable] public var patientsData:ArrayCollection = new ArrayCollection();			//data provider for the Plot Chart
private function patientsResultHandler(event:ResultEvent):void {
	/*if(event.result.autnresponse.responsedata.clusters.cluster is ObjectProxy ) {
	= new ArrayCollection( [event.result.autnresponse.responsedata.clusters.cluster] );
	}
	else {
	clusterData = event.result.autnresponse.responsedata.clusters.cluster;	
	}*/
	
	var results:ArrayCollection = event.result.patients.patient;
	
	var patients:ArrayCollection = new ArrayCollection();
	
	for each(var result:Object in results)
	{
		var patient:PatientModel = PatientModel.fromObj(result);
		patients.addItem( patient );
	}
	
	patientsData = patients;
	
	controller.patients = ChatController.getInstance().model.patients = patientsData;

	initChatHistory();
}

public var arrOpenPatients:Array = new Array();
protected function dgPatients_itemClickHandler(event:ListEvent):void {
	var myData:PatientModel = PatientModel( event.itemRenderer.data );
	var isPatientAlreadyOpen:Boolean = false;
	for(var i:uint = 0; i < arrOpenPatients.length; i++) {
		if(arrOpenPatients[i] == myData) {
			isPatientAlreadyOpen = true;
			viewStackMain.selectedIndex = i + 1;		//+1 because in arrOpenTabs we don't include the "inbox" tab
			break;
		}
	}				
	if(!isPatientAlreadyOpen) 
	{		
		var viewPatient:ViewPatient = new ViewPatient();
		viewPatient.patient = myData;		//acMessages[event.rowIndex];
		viewPatient.selectedAppointment = appointments[currentAppt];
		viewStackMain.addChild(viewPatient);
		tabsMain.selectedIndex = viewStackMain.length - 1;
		arrOpenPatients.push(myData);	
		//myData.status = "read";
		/*for(var i:uint = 0; i < myData.messages.length; i++) {
			myData.messages[i].status = "read";
		}
		btnInbox.label = "Inbox"+getUnreadMessagesCount();
		if(getUnreadMessagesCount() == '') {
			lblMessagesNumber.text = "no";
			lblMessagesNumber.setStyle("color","0xFFFFFF");
			lblMessagesNumber.setStyle("fontWeight","normal");
			lblMessagesNumber.setStyle("paddingLeft",-3);
			lblMessagesNumber.setStyle("paddingRight",-3);
		}
		else lblMessagesNumber.text = getUnreadMessagesCount().substr(2,1);*/
		//dgMessages.invalidateList();
	}
}

private function patientsSearchFilter():void {
	patientsData.filterFunction = filterPatientsSearch;
	patientsData.refresh();
}

private function filterPatientsSearch(item:Object):Boolean {
	var pattern:RegExp = new RegExp("[^]*"+patientSearch.text+"[^]*", "i");
	var searchFilter:Boolean = (patientSearch.text == 'Search' || patientSearch.text == '') ? true : (pattern.test(item.lastName) || pattern.test(item.firstName));

	var birthDayFilter:Boolean = (txtPatientBirthDay.text == 'dd' || txtPatientBirthDay.text == '') ? true : item.dob.substr(3,2) == txtPatientBirthDay.text;
	var birthMonthFilter:Boolean = (txtPatientBirthMonth.text == 'mm' || txtPatientBirthMonth.text == '') ? true : item.dob.substr(0,2) == txtPatientBirthMonth.text;
	var birthYearFilter:Boolean = (txtPatientBirthYear.text == 'year' || txtPatientBirthYear.text == '') ? true : item.dob.substr(6,4) == txtPatientBirthYear.text;
	
	var genderFilter:Boolean = dropPatientsSex.selectedIndex == 0 ? true : item.sex == dropPatientsSex.selectedItem.label;

	var notifFilter:Boolean = showPatientsAll.selected ? true : item.urgency != "Not urgent";
	
	return searchFilter && birthDayFilter && birthMonthFilter && birthYearFilter && genderFilter && notifFilter;
}

[Bindable] public var providersModel:ProvidersModel = new ProvidersModel();

private function providersResultHandler(event:ResultEvent):void {
	
	var results:ArrayCollection = event.result.providers.provider;
	
	var teams:Array = [ {label:"All",value:-1} ];
	
	var providers:ArrayCollection = new ArrayCollection();
	
	for each(var result:Object in results)
	{
		var provider:ProviderModel = ProviderModel.fromObj(result);
		provider.id = providers.length;
		providers.addItem( provider );
		
		if( provider.id == ProviderConstants.USER_ID ) controller.user = provider;
		
		var team:Object = {label:"Team " + provider.team, value: provider.team};
		if( teams[provider.team] == null ) teams[provider.team] = team;
	}
	
	providersModel.providers = providers;
	providersModel.providerTeams = new ArrayCollection( teams );
	
	controller.providers = ChatController.getInstance().model.providers = providers;
	
	initChatHistory();
}

private var autocompleteCallback:Function;
private var autocomplete:AutoComplete;

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
	
	PopUpManager.addPopUp( autocomplete, this );
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

private function initChatHistory():void
{
	if( !ChatController.getInstance().model.providers || !ChatController.getInstance().model.patients ) return;
	
	var user:UserModel = controller.getUser( ProviderConstants.USER_ID, UserModel.TYPE_PROVIDER );
	
	var today:Date = controller.today;
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
		
		user.addChat( new Chat( user, controller.getUser( def.id, def.type ), start, end ) );
	}
	
	appointmentsXMLdata.send();
}

private function onLoadDataRequest(event:ApplicationDataEvent):void
{
	if( event.data === Constants.MEDICATIONS 
		&& !controller.medicationsController.model.dataLoaded )
	{
		medicationsXMLdataForWidget.send();
	}
	else if( event.data === Constants.MEDICAL_RECORDS
		&& !controller.medicalRecordsController.model.dataLoaded )
	{
		medicalRecordsXMLdata.send();
	}
}

private function onNavigate(event:ApplicationEvent):void
{
	var module:INavigatorContent;
	
	if( event.data is int )
	{
		viewStackProviderModules.selectedIndex = event.data;
		
		module = viewStackProviderModules.selectedChild;
	}
	else if( event.data is String )
	{
		if( this.currentState == 'providerHome' ) 
		{
			var moduleName:String = event.data.toString();
			
			if( this.viewStackProviderModules.getChildByName( moduleName ) ) 
			{
				module = this.viewStackProviderModules.getChildByName( moduleName ) as INavigatorContent;
				
				this.viewStackProviderModules.selectedChild = module;
				
				if( event.data == ProviderConstants.MODULE_MESSAGES )
				{
					createNewMessage( 1 );
					
					viewStackMessages.selectedIndex = viewStackMessages.length - 2;
				}
				
				if( this.viewStackMain.selectedIndex != 0 )
				{
					this.viewStackMain.selectedIndex = 0;
				}
			}
		}
	}
	
	onHideAutoComplete();
}

private function toggleAvailability(event:MouseEvent):void
{
	var button:LinkButton = LinkButton(event.currentTarget);
	
	var user:UserModel = controller.user;
	
	user.available = user.available == UserModel.STATE_AVAILABLE ? UserModel.STATE_UNAVAILABLE : UserModel.STATE_AVAILABLE;
	
	button.setStyle('color',user.available == UserModel.STATE_AVAILABLE ? 0xCCCC33 : 0xB3B3B3 );
}

public function falsifyWidget(widget:String):void 
{
}

/**
 * User context menu
*/
private var userContextMenu:UserContextMenu;
private var userContextMenuTimer:Timer;

private function onShowContextMenu(event:ProfileEvent):void 
{
	if( userContextMenu ) hideContextMenu();
	
	userContextMenu = new UserContextMenu();
	userContextMenu.user = event.user;
	userContextMenu.addEventListener( ProfileEvent.VIEW_PROFILE, onUserAction );
	userContextMenu.addEventListener( ProfileEvent.VIEW_APPOINTMENTS, onUserAction );
	userContextMenu.addEventListener( ProfileEvent.SEND_MESSAGE, onUserAction );
	userContextMenu.addEventListener( ProfileEvent.START_CHAT, onUserAction );
	
	userContextMenu.x = this.stage.mouseX;
	userContextMenu.y = this.stage.mouseY;
	
	PopUpManager.addPopUp( userContextMenu, DisplayObject(mx.core.FlexGlobals.topLevelApplication) );
	
	userContextMenuTimer.reset();
	userContextMenuTimer.start();
}

private function hideContextMenu():void
{
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
		evt = new ApplicationEvent( ApplicationEvent.NAVIGATE, true );
		evt.data = ProviderConstants.MODULE_TEAM;
		this.dispatchEvent( evt );
		
		TeamModule(viewStackProviderModules.getChildByName( ProviderConstants.MODULE_TEAM )).showTeamMember( event.user );
	}
	else if( event.type == ProfileEvent.VIEW_APPOINTMENTS )
	{
		if( AppointmentsController.getInstance().model.selectedProviders.getItemIndex( event.user ) == -1 )
		{
			AppointmentsController.getInstance().model.selectedProviders.addItem( event.user );
		}
		
		evt = new ApplicationEvent( ApplicationEvent.NAVIGATE, true );
		evt.data = ProviderConstants.MODULE_APPOINTMENTS;
		this.dispatchEvent( evt );
	}
	else if( event.type == ProfileEvent.SEND_MESSAGE )
	{
		var message:Message = new Message();
		message.recipients = [ event.user ];
		
		evt = new ApplicationEvent( ApplicationEvent.NAVIGATE, true );
		evt.data = ProviderConstants.MODULE_MESSAGES;
		evt.message = message;
		this.dispatchEvent( evt );
	}
	else if( event.type == ProfileEvent.START_CHAT )
	{
		ChatController.getInstance().chat( controller.user, event.user );
	}
	
	hideContextMenu();
}

private function onUserMenuDelay( event:TimerEvent ):void
{
	if( userContextMenu 
		&& userContextMenu.parent )
	{
		if( !userContextMenu.hitTestPoint(this.stage.mouseX,this.stage.mouseY)
			&& !userContextMenu.chatModes.hitTestPoint(this.stage.mouseX,this.stage.mouseY) )
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

protected function onTabClose( event:ListEvent ):void
{
	if( TabBarPlus( event.target.owner).dataProvider is IList )
	{
		var dataProvider:IList = TabBarPlus( event.target.owner).dataProvider as IList;
		var index:int = event.rowIndex;
		
		if( dataProvider == viewStackMessages ) 
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
		}
		/*
		else if( this.currentState == "modImmunizations" ) 
		{
			arrOpenTabsIM.splice(index-1,1);
		}
		*/
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
}
