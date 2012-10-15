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

//used by the Patients datagrid
private function lblPatientsAge(item:Object, column:DataGridColumn):String {
	var now:Date = new Date();
	var dob:Date = new Date(item.dob);
	
	var years:Number = now.getFullYear() - dob.getFullYear();
	if (dob.month > now.month || (dob.month == now.month && dob.date > now.date)) years--;
	
	return String(years);
}

//same as previous function, used by the Patient Search filter
private function calculateAge(birthdate:String):uint {
	var now:Date = new Date();
	var dob:Date = new Date(birthdate);
	
	var years:uint = now.getFullYear() - dob.getFullYear();
	if (dob.month > now.month || (dob.month == now.month && dob.date > now.date)) years--;
	
	return years;
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
	patientModuleSearch.text = 'First Name, Last Name, or ID Number';
	for each(var obj1:Object in arrUrgencies.source) obj1.selected = true;
	for each(var obj2:Object in arrModules.source) obj2.selected = true;
	for each(var obj3:Object in arrTeams.source) obj3.selected = true;
	txtAdvFirstLast.text = 'e.g., Arthur Adams';
	txtAdvBirthDay.text = 'dd';
	txtAdvBirthMonth.text = 'mm';
	txtAdvBirthYear.text = 'year';
	for each(var obj4:Object in arrSexes.source) obj4.selected = true;
	txtAdvAgeFrom.text = txtAdvAgeTo.text = '##';
	for each(var obj5:Object in arrFamilyPrefixes.source) obj5.selected = true;
	txtAdvID.text = '#########';
	txtAdvSSN.text = txtAdvSponsorSSN.text = '###-##-####';	
	
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

[Bindable] private var arrUrgencies:ArrayCollection = new ArrayCollection([{label: 'Urgent', selected: true},{label: 'Somewhat urgent', selected: true},{label: 'Not urgent', selected: true}]);
[Bindable] private var arrModules:ArrayCollection = new ArrayCollection([{label: 'Exercise', selected: true},{label: 'Immunizations', selected: true},{label: 'Medications', selected: true},{label: 'Nutrition', selected: true},{label: 'Vital Signs', selected: true}]);
[Bindable] private var arrTeams:ArrayCollection = new ArrayCollection([{label: 'Team 1', selected: true},{label: 'Team 2', selected: true},{label: 'Team 3', selected: true},{label: 'Team 4', selected: true},{label: 'Team 5', selected: true},{label: 'Team 6', selected: true}]);
[Bindable] private var arrSearchParameters:ArrayCollection = new ArrayCollection([{label: 'First and/or Last Name', selected: true},{label: 'DOB', selected: true},{label: 'Sex', selected: true},{label: 'Marital Status', selected: false},{label: 'Age Range', selected: true},{label: 'Blood Type', selected: false},{label: 'Family Prefix', selected: true},{label: 'ID Number', selected: true},{label: 'Patient\'s SSN', selected: true},{label: 'Sponsor\'s SSN', selected: true},{label: 'Race', selected: false},{label: 'Address', selected: false},{label: 'Service Branch', selected: false},{label: 'Status', selected: false},{label: 'Rank', selected: false},{label: 'Occupation', selected: false},{label: 'Years of Service', selected: false},{label: 'Stationed / Deployment', selected: false},{label: 'Last Visit Range', selected: false},{label: 'Case Number', selected: false},{label: 'Special Health Conditions', selected: false}]);
[Bindable] private var arrSexes:ArrayCollection = new ArrayCollection([{label: 'Male', selected: true},{label: 'Female', selected: true}]);
[Bindable] private var arrFamilyPrefixes:ArrayCollection = new ArrayCollection([{label: '01', selected: true},{label: '02', selected: true},{label: '03', selected: true},{label: '04', selected: true},{label: '05', selected: true},{label: '06', selected: true},{label: '07', selected: true},{label: '08', selected: true},{label: '09', selected: true},{label: '10', selected: true},{label: '11', selected: true},{label: '12', selected: true},{label: '13', selected: true},{label: '14', selected: true},{label: '15', selected: true},{label: '16', selected: true},{label: '17', selected: true},{label: '18', selected: true},{label: '19', selected: true},{label: '20', selected: true},{label: '22', selected: true},{label: '22', selected: true},{label: '23', selected: true},{label: '24', selected: true},{label: '25', selected: true},{label: '26', selected: true},{label: '27', selected: true},{label: '28', selected: true},{label: '29', selected: true},{label: '30', selected: true},{label: '33', selected: true},{label: '32', selected: true},{label: '33', selected: true},{label: '34', selected: true},{label: '35', selected: true},{label: '36', selected: true},{label: '37', selected: true},{label: '38', selected: true},{label: '39', selected: true}]);