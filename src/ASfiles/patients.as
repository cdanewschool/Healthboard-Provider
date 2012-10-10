import components.home.ViewPatient;
import components.popups.PatientsCustomizeTable;
import components.provider.ProviderProfile;

import controllers.ApplicationController;
import controllers.AppointmentsController;

import events.ProfileEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import models.PatientModel;
import models.UserModel;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.LinkButton;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.managers.PopUpManager;

[Bindable] private var showAdvancedSearch:Boolean = false;

private function lblPatientsAge(item:Object, column:DataGridColumn):String {
	var now:Date = new Date();
	var dob:Date = new Date(item.dob);
	
	var years:Number = now.getFullYear() - dob.getFullYear();
	if (dob.month > now.month || (dob.month == now.month && dob.date > now.date)) years--;
	
	return String(years);
}

[Bindable] public var colUrgency:Boolean = true;
[Bindable] public var colPhoto:Boolean = false;
[Bindable] public var colId:Boolean = true;
[Bindable] public var colTeam:Boolean = true;
[Bindable] public var colLastName:Boolean = true;
[Bindable] public var colFirstName:Boolean = true;
[Bindable] public var colBranch:Boolean = false;
[Bindable] public var colRank:Boolean = true;
[Bindable] public var colOccupation:Boolean = false;
[Bindable] public var colSex:Boolean = true;
[Bindable] public var colLastVisit:Boolean = true;
[Bindable] public var colAge:Boolean = true;
[Bindable] public var colDob:Boolean = true;
[Bindable] public var colBloodType:Boolean = false;
[Bindable] public var colRace:Boolean = false;
[Bindable] public var colHealthConditions:Boolean = true;

private function customizeTable():void {
	var myPatientsCustomizeTable:PatientsCustomizeTable = PatientsCustomizeTable(PopUpManager.createPopUp(this, PatientsCustomizeTable) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myPatientsCustomizeTable);
}

public var link:LinkButton;
private function update():void {
	patientsProfileList.removeAllElements();
	patientsLinks.removeAllElements();
	
	for each(var item:UserModel in ApplicationController.getInstance().patients) {
		var profile:ProviderProfile = new ProviderProfile();
		profile.title = "Patient Profile";
		profile.user = item;
		profile.setStyle('dropShadowVisible',false);
		profile.addEventListener( ProfileEvent.SELECT, onPatientProfileClick );
		patientsProfileList.addElement( profile );
		
		link = new LinkButton();
		link.data = item;
		link.label = item.firstName + ' ' + item.lastName;
		link.setStyle('paddingLeft',0);
		link.setStyle('fontSize',12);
		link.setStyle('color',"0xAEDEE4");
		link.setStyle("textRollOverColor","0xAEDEE4");
		link.setStyle("textSelectedColor","0xAEDEE4");
		link.setStyle("skin", null);
		//link.addEventListener(MouseEvent.ROLL_OVER,manageMouseOver);		//not working properly (it adds the underline to the last button only)
		//link.addEventListener(MouseEvent.ROLL_OUT,manageMouseOut);
		link.addEventListener( MouseEvent.CLICK, onPatientNameClick );
		patientsLinks.addElement( link );
	}
}

private function clearPatientSearch():void {
	patientModuleSearch.text = '';
	patientsModuleSearchFilter();
	searchResults.visible = false;
}

private function sortPatients(field:String):void {
	patientsData.sort = new Sort();
	patientsData.sort.fields = [new SortField(field)];
	patientsData.refresh();
	update();
	
	highlightSelectedSort(field);
}

private function highlightSelectedSort(field:String = "none"):void {
	btnSortUrgency.styleName = btnSortID.styleName = btnSortLastName.styleName = btnSortFirstName.styleName = btnSortAge.styleName = btnSortRank.styleName = btnSortBranch.styleName = btnSortSex.styleName = btnSortBloodType.styleName = btnSortLastVisit.styleName = "messageFolderNotSelected";
	if(field == "urgency") btnSortUrgency.styleName = "messageFolderSelected";
	else if(field == "id") btnSortID.styleName = "messageFolderSelected";
	else if(field == "lastName") btnSortLastName.styleName = "messageFolderSelected";
	else if(field == "firstName") btnSortFirstName.styleName = "messageFolderSelected";
	else if(field == "dob") btnSortAge.styleName = "messageFolderSelected";
	else if(field == "rank") btnSortRank.styleName = "messageFolderSelected";
	else if(field == "serviceBranch") btnSortBranch.styleName = "messageFolderSelected";
	else if(field == "sex") btnSortSex.styleName = "messageFolderSelected";
	else if(field == "bloodType") btnSortBloodType.styleName = "messageFolderSelected";
	else if(field == "lastVisit") btnSortLastVisit.styleName = "messageFolderSelected";
}

[Bindable] private var arrUrgencies:ArrayCollection = new ArrayCollection([{label: 'Not urgent', selected: true},{label: 'Somewhat urgent', selected: true},{label: 'Urgent', selected: true}]);