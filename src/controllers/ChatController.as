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

	public class ChatController
	{
		private static var __instance:ChatController;
		
		private var popup:IFlexDisplayObject;
		
		public var model:ChatSearch;
		
		private var connectionTimer:Timer;
		
		public function ChatController( enforcer:SingletonEnforcer )
		{
			model = new ChatSearch();
			model.addEventListener( ChatEvent.STATE_CHANGE, onStateChange );
			
			connectionTimer = new Timer(1000,1);
			connectionTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onConnectionTimerComplete);
		}
		
		public static function getInstance():ChatController
		{
			if( !__instance ) __instance = new ChatController( new SingletonEnforcer() );
			
			return __instance;
		}
		
		public function chat( user:UserModel, targetUser:UserModel ):void
		{
			if( popup) PopUpManager.removePopUp( popup );
			
			model.user = user;
			model.targetUser = targetUser;
			
			popup = new VerifyCredentialsPopup();
			VerifyCredentialsPopup(popup).user = user;
			popup.addEventListener( Event.CANCEL, onPopupCancel );
			popup.addEventListener( AuthenticationEvent.SUCCESS, onAuthenticationSuccess );
			
			PopUpManager.addPopUp( popup, DisplayObject(mx.core.FlexGlobals.topLevelApplication), true );
			PopUpManager.centerPopUp( popup );
		}
		
		private function onConnectionTimerComplete(event:TimerEvent):void
		{
			if( !model.targetUser ) return;
			
			if( model.targetUser.available == UserModel.STATE_AVAILABLE )
			{
				model.state = ChatSearch.STATE_CONNECTED;
				
				var chat:Chat = new Chat( model.user, model.targetUser, new Date() );
				chat.mode = model.mode;
				
				popup = new ChatPopup();
				ChatPopup(popup).chat = chat;
				ChatPopup(popup).user = model.user;
				popup.addEventListener( ApplicationEvent.VIEW_FILE, onViewAttachment );
				popup.addEventListener( CloseEvent.CLOSE, onPopupClose );
				
				PopUpManager.addPopUp( popup, DisplayObject(mx.core.FlexGlobals.topLevelApplication), false );
			}
			else
			{
				//	show "communication request denied" popup
				if( popup) PopUpManager.removePopUp( popup );
				
				popup = new ChatRequestDeniedPopup();
				ChatRequestDeniedPopup(popup).user = model.targetUser;
				popup.addEventListener( CloseEvent.CLOSE, onPopupClose );
				
				PopUpManager.addPopUp( popup, DisplayObject(mx.core.FlexGlobals.topLevelApplication), true );
				PopUpManager.centerPopUp( popup );
			}
		}
		
		private function onStateChange(event:Event):void
		{
			if( model.state == ChatSearch.STATE_CONNECTING )
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
			model.state = ChatSearch.STATE_DEFAULT;
			model.user = null;
			model.targetUser = null;
		}
		
		private function onAuthenticationSuccess(event:AuthenticationEvent):void
		{
			model.state = ChatSearch.STATE_CONNECTING;
		}
	}
}
internal class SingletonEnforcer
{
}