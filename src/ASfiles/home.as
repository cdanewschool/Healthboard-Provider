import ASfiles.ProviderConstants;

import components.AutoComplete;
import components.home.ViewPatient;

import controllers.ApplicationController;
import controllers.ChatController;

import events.ApplicationEvent;
import events.AutoCompleteEvent;
import events.EnhancedTitleWindowEvent;

import external.collapsibleTitleWindow.components.enhancedtitlewindow.EnhancedTitleWindow;

import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Point;

import models.Chat;
import models.ChatSearch;
import models.PatientModel;
import models.ProviderModel;
import models.ProvidersModel;
import models.UserModel;

import mx.collections.ArrayCollection;
import mx.containers.ApplicationControlBar;
import mx.controls.LinkButton;
import mx.core.INavigatorContent;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import spark.events.DropDownEvent;
import spark.events.IndexChangeEvent;

private var controller:ApplicationController = ApplicationController.getInstance();

private function init():void
{
	patientsXMLdata.send();
	providersXMLdata.send();
	
	if( ProviderConstants.DEBUG ) this.currentState = "providerHome";
	
	this.addEventListener( AutoCompleteEvent.SHOW, onShowAutoComplete );
	this.addEventListener( AutoCompleteEvent.HIDE, onHideAutoComplete );
}

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
	var myData:Object = event.itemRenderer.data;
	var isPatientAlreadyOpen:Boolean = false;
	for(var i:uint = 0; i < arrOpenPatients.length; i++) {
		if(arrOpenPatients[i] == myData) {
			isPatientAlreadyOpen = true;
			viewStackMain.selectedIndex = i + 1;		//+1 because in arrOpenTabs we don't include the "inbox" tab
			break;
		}
	}				
	if(!isPatientAlreadyOpen) {
		var viewPatient:ViewPatient = new ViewPatient();
		viewPatient.patient = myData;		//acMessages[event.rowIndex];
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
	
	var teams:Array = [ {label:"Show All",value:-1} ];
	
	var providers:ArrayCollection = new ArrayCollection();
	
	for each(var result:Object in results)
	{
		var provider:ProviderModel = ProviderModel.fromObj(result);
		provider.id = providers.length;
		providers.addItem( provider );
		
		if( provider.id == ProviderConstants.USER_ID ) ApplicationController.getInstance().user = provider;
		
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
	if( autocomplete 
		&& autocomplete.parent 
		&& autocomplete.targetField == event.targetField 
		&& autocomplete.dataProvider == event.dataProvider )
		return;
	
	if( !autocomplete )
	{
		autocomplete = new AutoComplete();
		autocomplete.width = event.desiredWidth ? event.desiredWidth : event.targetField.width;
		autocomplete.addEventListener( Event.CHANGE, onAutocompleteSelect );
		autocomplete.addEventListener( AutoCompleteEvent.HIDE, onHideAutoComplete );
	}
	
	autocomplete.targetField = event.targetField;
	autocomplete.callbackFunction = event.callbackFunction;
	autocomplete.labelFunction = event.labelFunction;
	autocomplete.dataProvider = event.dataProvider;
	
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
	
	user.addChat( new Chat( user, controller.getUser( 123, UserModel.TYPE_PATIENT ), new Date(2012,09,1,17,35),new Date(2012,09,1,17,45) ) );
	user.addChat( new Chat( user, controller.getUser( 123, UserModel.TYPE_PATIENT ), new Date(2012,09,23,17,28),new Date(2012,09,23,17,33) ) );
	user.addChat( new Chat( user, controller.getUser( 123, UserModel.TYPE_PATIENT ), new Date(2012,10,1,17,30),new Date(2012,10,1,17,35) ) );
	user.addChat( new Chat( user, controller.getUser( 1, UserModel.TYPE_PROVIDER ), new Date(2012,10,11,17,31),new Date(2012,10,11,17,42) ) );
	
	appointmentsXMLdata.send();
}

private function navigate(event:ApplicationEvent):void
{
	if( event.data is int )
	{
		viewStackProviderModules.selectedIndex = event.data;
	}
	else if( event.data is String )
	{
		if( this.currentState == 'providerHome' ) 
		{
			var module:String = event.data.toString();
			
			if( this.viewStackProviderModules.getChildByName( module ) ) 
				this.viewStackProviderModules.selectedChild = this.viewStackProviderModules.getChildByName( module ) as INavigatorContent;
		}
	}
}

private function toggleAvailability(event:MouseEvent):void
{
	var button:LinkButton = LinkButton(event.currentTarget);
	
	var user:UserModel = ApplicationController.getInstance().user;
	
	user.available = user.available == UserModel.STATE_AVAILABLE ? UserModel.STATE_UNAVAILABLE : UserModel.STATE_AVAILABLE;
	
	button.setStyle('color',user.available == UserModel.STATE_AVAILABLE ? 0xCCCC33 : 0xB3B3B3 );
}

public function falsifyWidget(widget:String):void 
{
}

