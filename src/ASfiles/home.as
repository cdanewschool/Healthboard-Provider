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
import flashx.textLayout.elements.BreakElement;

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

//THE FOLLOWING TWO ARE MONSTER FUNCTIONS THAT PREVENT THE DROPDOWN FROM CLOSING WHEN CLICKING ON THE CALENDAR
//SEE http://www.blastanova.com/blog/2010/06/23/a-custom-multi-selection-spark-dropdownlist/ FOR REFERENCE
protected function dropDownCalendar_openHandler(event:DropDownEvent):void 
{
	if( patientBirthDateChooser ) patientBirthDateChooser.addEventListener(MouseEvent.MOUSE_DOWN, stopPropagation, false, 0, true);
	if( advBirthDateChooser ) advBirthDateChooser.addEventListener(MouseEvent.MOUSE_DOWN, stopPropagation, false, 0, true);
}

protected function stopPropagation(event:Event):void 
{
	event.stopImmediatePropagation();
}

protected function dateChooser_changeHandler(event:CalendarLayoutChangeEvent):void 
{
	txtPatientBirthDay.text = patientBirthDateChooser.selectedDate.date < 10 ? '0' + patientBirthDateChooser.selectedDate.date : String(patientBirthDateChooser.selectedDate.date);
	txtPatientBirthMonth.text = patientBirthDateChooser.displayedMonth < 9 ? '0' + (patientBirthDateChooser.displayedMonth + 1) : String(patientBirthDateChooser.displayedMonth + 1);
	txtPatientBirthYear.text = String(patientBirthDateChooser.displayedYear);
	dropDownCalendar.closeDropDown(true);					
}

protected function advDateChooser_changeHandler(event:CalendarLayoutChangeEvent):void 
{
	txtAdvBirthDay.text = advBirthDateChooser.selectedDate.date < 10 ? '0' + advBirthDateChooser.selectedDate.date : String(advBirthDateChooser.selectedDate.date);
	txtAdvBirthMonth.text = advBirthDateChooser.displayedMonth < 9 ? '0' + (advBirthDateChooser.displayedMonth + 1) : String(advBirthDateChooser.displayedMonth + 1);
	txtAdvBirthYear.text = String(advBirthDateChooser.displayedYear);
	dropDownAdvCalendar.closeDropDown(true);					
}

protected function dgPatients_itemClickHandler(event:ListEvent):void 
{
	var user:PatientModel = PatientModel( event.itemRenderer.data );
	MainController(controller).showPatient( user );
}

protected function onPatientProfileClick(event:ProfileEvent):void
{
	var user:PatientModel = PatientModel( event.user );
	MainController(controller).showPatient( user );
}

protected function onPatientNameClick(event:MouseEvent):void 
{
	var user:PatientModel = PatientModel( LinkButton(event.currentTarget).data );
	MainController(controller).showPatient( user );
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
		else if( this.currentState == Constants.MODULE_MEDICATIONS ) 
		{
			controller.medicationsController.model.openTabs.splice(index-1,1);
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
