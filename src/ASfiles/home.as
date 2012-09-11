import components.home.ViewPatient;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.ListEvent;
import mx.rpc.events.ResultEvent;

import spark.events.DropDownEvent;

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
	
	patientsData = event.result.patients.patient;	
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
