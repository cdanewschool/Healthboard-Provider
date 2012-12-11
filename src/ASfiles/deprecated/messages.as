import mx.collections.ArrayCollection;
import mx.events.ListEvent;

[Bindable] public var acMessages:ArrayCollection = new ArrayCollection([
	{status: "unread", correspondent: "Isaac Goodman", prefix: "", date: "Aug 25 2011 02:31:00 PM", subject: "Low glucose levels", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "You", date: "Aug 24 2011 04:45:00 PM", text: "Hi Doctor,\n\nI was looking at my blood test results and realized my glucose levels where low. I sometimes feel nervous and weak, and I was reading on WebMD.com that these are symptoms of hypoglycemia.\n\nShould I come in for a check?", imageAttachments: null, nonImageAttachments: null, urgency: "Somewhat urgent", status: "read"},
		{sender: "Isaac Goodman", date: "Aug 25 2011 02:31:00 PM", text: "Hi,\n\nAn actual diagnosis of hypoglycemia requires satisfying the \"Whipple triad.\" These three criteria include:\n\n1. Documented low glucose levels (less than 40 mg/dL (2.2 mmol/L), often tested along with insulin levels and sometimes with C-peptide levels)\n2. Symptoms of hypoglycemia when the blood glucose level is abnormally low\n3. Reversal of the symptoms when blood glucose levels are returned to normal\n\nPrimary hypoglycemia is rare and often diagnosed in infancy. People may have symptoms of hypoglycemia without really having low blood sugar. In such cases, dietary changes such as eating frequent small meals and several snacks a day and choosing complex carbohydrates over simple sugars may be enough to ease symptoms.\n\nBottom line: I don't think you have anything to worry about, but let me know if you'd like to come in.", imageAttachments: null, nonImageAttachments: null, urgency: "Not urgent", status: "unread"}
	]
	},
	{status: "unread", correspondent: "Isaac Goodman", prefix: "", date: "Aug 22 2011 05:45:00 PM", subject: "Chronic pain", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "Isaac Goodman", date: "Aug 22 2011 03:45:00 PM", text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip...", imageAttachments: null, nonImageAttachments: null, urgency: "Urgent", status: "read"},
		{sender: "You", date: "Aug 22 2011 04:45:00 PM", text: "Reply number 1...", imageAttachments: null, nonImageAttachments: null, urgency: "Somewhat urgent", status: "read"},
		{sender: "Isaac Goodman", date: "Aug 22 2011 05:45:00 PM", text: "3rd messageeeeee", imageAttachments: null, nonImageAttachments: null, urgency: "Not urgent", status: "unread"}
	]
	},
	{status: "read", correspondent: "Administration", prefix: "", date: "Aug 21 2011 01:03:54 AM", subject: "Problem sleeping more than a few hours", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "Administration", date: "Aug 21 2011 01:03:54 AM", text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip...", imageAttachments: null, nonImageAttachments: null, urgency: "Somewhat urgent", status: "read"}
	]
	},
	{status: "unread", correspondent: "Front Desk", prefix: "", date: "Feb 2 2011 01:03:54 AM", subject: "Persistent cough", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "Front Desk", date: "Feb 2 2011 01:03:54 AM", text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip...", imageAttachments: null, nonImageAttachments: null, urgency: "Urgent", status: "unread"}
	]
	},
	{status: "read", correspondent: "Nurse", prefix: "a ", date: "Jan 15 2011 01:03:54 AM", subject: "Your recovery", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "Nurse", date: "Jan 15 2011 01:03:54 AM", text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip...", imageAttachments: null, nonImageAttachments: null, urgency: "Somewhat urgent", status: "read"}
	]
	},
	{status: "read", correspondent: "Administration", prefix: "", date: "Apr 15 2011 01:03:54 AM", subject: "Billing", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "You", date: "Apr 15 2011 01:03:54 AM", text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip...", imageAttachments: null, nonImageAttachments: null, urgency: "Somewhat urgent", status: "read"}
	]
	},
	{status: "read", correspondent: "Nurse", prefix: "a ", date: "Mar 15 2011 01:03:54 AM", subject: "Feeling better", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "You", date: "Mar 15 2011 01:03:54 AM", text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip...", imageAttachments: null, nonImageAttachments: null, urgency: "Somewhat urgent", status: "read"}
	]
	},
	{status: "read", correspondent: "Physician", prefix: "a ", date: "Jan 15 2011 01:03:54 AM", subject: "Headache", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "You", date: "Jan 15 2011 01:03:54 AM", text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip...", imageAttachments: null, nonImageAttachments: null, urgency: "Somewhat urgent", status: "read"}
	]
	},
	{status: "read", correspondent: "Physician", prefix: "a ", date: "Dec 24 2010 01:03:54 AM", subject: "Thanks", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "You", date: "Dec 24 2010 01:03:54 AM", text: "Hi Doctor,\n\nIt's been a month since my sinus surgery, and I still get periodical nose bleeding. Should I have this checked?", imageAttachments: new ArrayCollection([{filename: 'bloodyNose.jpg', image: myPic}]), nonImageAttachments: null, urgency: "Not urgent", status: "read"}
	]
	},
	{status: "read", correspondent: "Front Desk", prefix: "", date: "Nov 29 2010 01:03:54 AM", subject: "Rescheduling checkup", isDraft: false, checkboxSelection: false,  messages: [
		{sender: "You", date: "Nov 29 2010 01:03:54 AM", text: "Would it be possible to reschedule tomorrow's appointment to sometime next week?", imageAttachments: null, nonImageAttachments: null, urgency: "Urgent", status: "unread"}
	]
	}
]);	

protected function bar_initializeHandler():void {
	// Set first and last tabs as non-closable
	tabsMessages.setTabClosePolicy(0, false);
	tabsMessages.setTabClosePolicy(1, false);	//tabsMessages.setTabClosePolicy(viewStackMessages.length - 1, false);	
	
	/*if(howToHandleMessageTabs == "viewWidgetMessage") {
		viewMessage(myMsgToOpen);
		tabsMessages.selectedIndex = viewStackMessages.length - 2;
	}else if(howToHandleMessageTabs == "createApptsMessage") {
		var recipient:uint = monthView.selectedApptType == "appointment" ? 1 : 2;
		createNewMessage(recipient);
		tabsMessages.selectedIndex = viewStackMessages.length - 2;
	}
	else howToHandleMessageTabs = "already created";*/
}

//called from the WIDGET view
public var myMsgToOpen:Object;
public function openMessage(event:ListEvent):void {
	viewStackProviderModules.selectedIndex = 2;
	viewMessage(event.itemRenderer.data);
	tabsMessages.selectedIndex = viewStackMessages.length - 2;
	acMessagesToDisplay.refresh();	//so the read/unread styles are refreshed on the widget
}