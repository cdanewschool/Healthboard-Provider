package controllers
{
	import components.popups.ChatPopup;
	import components.popups.ChatRequestDeniedPopup;
	import components.popups.VerifyCredentialsPopup;
	import components.popups.ViewAttachmentPopup;
	
	import events.ApplicationEvent;
	import events.AuthenticationEvent;
	import events.ChatEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Chat;
	import models.ChatSearch;
	import models.FileUpload;
	import models.UserModel;
	
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import utils.DateUtil;

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
			
			if( ChatSearch(model).targetUser.available == UserModel.STATE_AVAILABLE )
			{
				ChatSearch(model).state = ChatSearch.STATE_CONNECTED;
				
				var chat:Chat = new Chat( ChatSearch(model).user, ChatSearch(model).targetUser, new Date() );
				
				popup = new ChatPopup();
				ChatPopup(popup).chat = chat;
				ChatPopup(popup).user = ChatSearch(model).user;
				popup.addEventListener( ApplicationEvent.VIEW_FILE, onViewAttachment );
				popup.addEventListener( CloseEvent.CLOSE, onPopupClose );
				
				PopUpManager.addPopUp( popup, DisplayObject(mx.core.FlexGlobals.topLevelApplication), false );
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
		
		private function onPopupCancel( event:Event ):void
		{
			reset();
		}
		
		private function onPopupClose( event:CloseEvent ):void
		{
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