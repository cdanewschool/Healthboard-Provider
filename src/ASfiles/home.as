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
import models.ChatSearch;
import models.Message;
import models.PatientModel;
import models.ProviderApplicationModel;
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
[Bindable] public var model:ProviderApplicationModel;
[Bindable] public var medicalRecordsController:MainController;

[Bindable] public var chartStyles:ChartStyles;

private function init():void
{
	AppProperties.getInstance().controller = controller = new MainController();
	
	model = controller.model as ProviderApplicationModel;
	
	model.chartStyles = chartStyles = new ChartStyles();
	model.patientVitalSigns = arrVitalSigns;	//	temp
	
	if( ProviderConstants.DEBUG ) this.currentState = Constants.STATE_LOGGED_IN;

	BindingUtils.bindProperty( controller.exerciseController.model, 'fullName', model, 'fullname');	//	temp
	BindingUtils.bindProperty( model.chartStyles, 'horizontalFill', this, 'myHorizontalFill');
	BindingUtils.bindProperty( model.chartStyles, 'horizontalAlternateFill', this, 'myHorizontalAlternateFill');
	
	//	eventually this should go in maincontroller
	this.addEventListener( TabPlus.CLOSE_TAB_EVENT, onTabClose );
	
	ProviderApplicationModel(model).patientsDataService.send();
	ProviderApplicationModel(model).providersDataService.send();
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

protected function dgPatients_itemClickHandler(event:ListEvent):void 
{
	var myData:PatientModel = PatientModel( event.itemRenderer.data );
	
	MainController(controller).showPatient( myData );
}

private function patientsSearchFilter():void 
{
	ProviderApplicationModel(model).patients.filterFunction = filterPatientsSearch;
	ProviderApplicationModel(model).patients.refresh();
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
		else if( this.currentState == Constants.STATE_LOGGED_IN ) 
		{		//aka PROVIDER PORTAL!
			if( dataProvider == viewStackMain) 
				controller.arrOpenPatients.splice(index-1,1);
		}
	}
	else 
	{
		trace("Bad data provider");
	}
}
