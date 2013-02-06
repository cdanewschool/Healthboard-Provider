package edu.newschool.piim.healthboard.controller
{
	import edu.newschool.piim.healthboard.components.popups.ChatPopup;
	import edu.newschool.piim.healthboard.components.popups.ChatRequestDeniedPopup;
	import edu.newschool.piim.healthboard.components.popups.VerifyCredentialsPopup;
	import edu.newschool.piim.healthboard.components.popups.ViewAttachmentPopup;
	import edu.newschool.piim.healthboard.events.ApplicationEvent;
	import edu.newschool.piim.healthboard.events.AuthenticationEvent;
	import edu.newschool.piim.healthboard.events.ChatEvent;
	import edu.newschool.piim.healthboard.model.Chat;
	import edu.newschool.piim.healthboard.model.ChatSearch;
	import edu.newschool.piim.healthboard.model.FileUpload;
	import edu.newschool.piim.healthboard.model.UserModel;
	import edu.newschool.piim.healthboard.util.DateUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;

	public class ChatController extends BaseModuleController
	{
		private var popup:IFlexDisplayObject;
		
		private var connectionTimer:Timer;
		
		public function ChatController()
		{
			super();
			
			model = new ChatSearch();	//	TODO: rename ChatModel
			model.addEventListener( ChatEvent.STATE_CHANGE, onStateChange );
			
			connectionTimer = new Timer(1000,1);
			connectionTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onConnectionTimerComplete);
		}
		
		public function chat( user:UserModel, targetUser:UserModel ):void
		{
			if( popup) PopUpManager.removePopUp( popup );
			
			ChatSearch(model).user = user;
			ChatSearch(model).targetUser = targetUser;
			
			popup = new VerifyCredentialsPopup();
			VerifyCredentialsPopup(popup).user = user;
			popup.addEventListener( Event.CANCEL, onPopupCancel );
			popup.addEventListener( AuthenticationEvent.SUCCESS, onAuthenticationSuccess );
			
			PopUpManager.addPopUp( popup, DisplayObject(mx.core.FlexGlobals.topLevelApplication), true );
			PopUpManager.centerPopUp( popup );
		}
		
		private function onConnectionTimerComplete(event:TimerEvent):void
		{
			if( !ChatSearch(model).targetUser ) return;
			
			var application:visualDashboardProvider = AppProperties.getInstance().controller.application as visualDashboardProvider;
			
			if( ChatSearch(model).targetUser.available == UserModel.STATE_AVAILABLE )
			{
				ChatSearch(model).state = ChatSearch.STATE_CONNECTED;
				
				var chat:Chat = new Chat( ChatSearch(model).user, ChatSearch(model).targetUser, new Date() );
				
				popup = new ChatPopup();
				ChatPopup(popup).chat = chat;
				ChatPopup(popup).user = ChatSearch(model).user;
				popup.addEventListener( ApplicationEvent.VIEW_FILE, onViewAttachment );
				popup.addEventListener( CloseEvent.CLOSE, onPopupClose );
				
				application.stage.addEventListener( Event.RESIZE, onResize );
				
				PopUpManager.addPopUp( popup, application, false );
			}
			else
			{
				//	show "communication request denied" popup
				if( popup) PopUpManager.removePopUp( popup );
				
				popup = new ChatRequestDeniedPopup();
				ChatRequestDeniedPopup(popup).user = ChatSearch(model).targetUser;
				popup.addEventListener( CloseEvent.CLOSE, onPopupClose );
				
				PopUpManager.addPopUp( popup, DisplayObject(mx.core.FlexGlobals.topLevelApplication), true );
				PopUpManager.centerPopUp( popup );
			}
		}
		
		private function onResize(event:Event):void
		{
			if( popup 
				&& popup is ChatPopup )
			{
				ChatPopup(popup).invalidateDisplayList();
			}
		}
		
		private function onStateChange(event:Event):void
		{
			if( ChatSearch(model).state == ChatSearch.STATE_CONNECTING )
			{
				connectionTimer.reset();
				connectionTimer.delay = DateUtil.SECOND * Math.round( Math.random() * 5 );
				connectionTimer.start();
			}
		}
		
		private function onViewAttachment( event:ApplicationEvent ):void
		{
			if( event.data is FileUpload )
			{
				var attachment:FileUpload = FileUpload( event.data );
				
				popup = new ViewAttachmentPopup();
				ViewAttachmentPopup(popup).file = attachment;
				popup.addEventListener( CloseEvent.CLOSE, onPopupClose );
				
				PopUpManager.addPopUp( popup, DisplayObject(mx.core.FlexGlobals.topLevelApplication), true );
			}
		}
		
		public function saveChat( user:UserModel, chat:Chat ):void
		{
			if( !user.chatHistory ) user.chatHistory = new ArrayCollection();
			user.chatHistory.addItem( chat );
		}
		
		private function onPopupCancel( event:Event ):void
		{
			reset();
		}
		
		private function onPopupClose( event:CloseEvent ):void
		{
			var application:visualDashboardProvider = AppProperties.getInstance().controller.application as visualDashboardProvider;
			application.stage.removeEventListener( Event.RESIZE, onResize );
			
			reset();
		}
		
		private function reset():void
		{
			ChatSearch(model).state = ChatSearch.STATE_DEFAULT;
			ChatSearch(model).user = null;
			ChatSearch(model).targetUser = null;
		}
		
		private function onAuthenticationSuccess(event:AuthenticationEvent):void
		{
			ChatSearch(model).state = ChatSearch.STATE_CONNECTING;
		}
	}
}