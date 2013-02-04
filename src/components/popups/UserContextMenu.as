package components.popups
{
	import controllers.ChatController;
	import controllers.MainController;
	
	import events.ProfileEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import models.ChatSearch;
	import models.UserModel;
	
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.controls.Spacer;
	import mx.controls.ToolTip;
	import mx.core.BitmapAsset;
	
	import spark.components.BorderContainer;
	import spark.components.ButtonBar;
	import spark.components.HGroup;
	import spark.components.PopUpAnchor;
	import spark.components.VGroup;
	import spark.components.supportClasses.ButtonBarHorizontalLayout;
	import spark.effects.Fade;
	import spark.events.IndexChangeEvent;
	
	public class UserContextMenu extends BorderContainer
	{
		[Embed('/images/tooltip/profile.png')]
		private var profileIcon:Class;
		
		[Embed('/images/tooltip/message.png')]
		private var messageIcon:Class;
		
		[Embed('/images/tooltip/appointments.png')]
		private var appointmentsIcon:Class;
		
		[Embed('/images/tooltip/chat.png')]
		private var chatIcon:Class;
		
		private var _user:UserModel;
		
		private var rows:VGroup;
		
		private var statusLabel:Label;
		public var chatModes:ButtonBar;
		private var anchor:PopUpAnchor;
		private var chatBtnsContainer:BorderContainer;
		
		public function UserContextMenu()
		{
			super();
			
			var fade:Fade = new Fade(this);
			fade.alphaFrom = 0;
			fade.alphaTo = 1;
			fade.duration = 300;
			
			setStyle("addedEffect", fade );
			
			setStyle("backgroundColor", 0x4D4D4D);
			setStyle("borderColor", 0xBDBCBC);
			setStyle("cornerRadius", 0);
			
			setStyle('paddingLeft',7);
			setStyle('paddingTop',7);
			setStyle('paddingRight',7);
			setStyle('paddingBottom',7);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			rows = new VGroup();
			rows.gap = 1;
			addElement( rows );
			
			var row:HGroup;
			var label:Label;
			var icon:Image;
			var button:LinkButton;
			var pad:Spacer;
			
			row = new HGroup();
			row.gap = 1;
			row.verticalAlign = "center";
			rows.addElement( row );
			
			//	status
			label = new Label();
			label.text = "Status:";
			label.styleName = "white11";
			row.addElement( label );
			
			statusLabel = new Label();
			statusLabel.styleName = "yellow11";
			statusLabel.text = "Status";
			row.addElement( statusLabel );
			
			row = new HGroup();
			row.gap = 1;
			row.verticalAlign = "middle";
			rows.addElement( row );
			
			icon = new Image();
			icon.source = new profileIcon();
			row.addElement( icon );
			
			pad = new Spacer();
			pad.width = 1;
			row.addElement( pad );
			
			button = new LinkButton();
			button.label = "View profile";
			button.styleName = "linkBtnYellow";
			button.setStyle("fontSize",11);
			button.addEventListener(MouseEvent.CLICK,onViewProfileClick);
			row.addElement( button );
			
			row = new HGroup();
			row.gap = 1;
			row.verticalAlign = "middle";
			rows.addElement( row );
			
			icon = new Image();
			icon.source = new appointmentsIcon();
			row.addElement( icon );
			
			button = new LinkButton();
			button.label = "View appointments";
			button.styleName = "linkBtnYellow";
			button.setStyle("fontSize",11);
			button.addEventListener(MouseEvent.CLICK,onViewAppointmentsClick);
			row.addElement( button );
			
			if(AppProperties.getInstance().controller.model.user.id != user.id) {		//this IF block prevents the user from sending a message or starting a chat with himself/herself
			
				row = new HGroup();	
				row.gap = 1;
				row.verticalAlign = "middle";
				rows.addElement( row );
				
				icon = new Image();
				icon.source = new messageIcon();
				row.addElement( icon );
				
				button = new LinkButton();
				button.label = "Send a message";
				button.styleName = "linkBtnYellow";
				button.setStyle("fontSize",11);
				button.addEventListener(MouseEvent.CLICK,onSendMessageClick);
				row.addElement( button );
				
				row = new HGroup();
				row.gap = 1;
				row.verticalAlign = "middle";
				rows.addElement( row );
			
				pad = new Spacer();
				pad.width = 1;
				row.addElement( pad );
				
				icon = new Image();
				icon.source = new chatIcon();
				icon.setStyle('paddingLeft',3);
				row.addElement( icon );
				
				var layout:ButtonBarHorizontalLayout = new ButtonBarHorizontalLayout();
				layout.gap = 5;
				
				chatModes = new ButtonBar();
				chatModes.layout = layout;
				chatModes.styleName = "chatModes";	//for some reason this does not affect style at all
				chatModes.setStyle('paddingLeft',10);
				chatModes.width = 73;
				chatModes.height = 24;
				chatModes.iconField = "icon";
				chatModes.dataProvider = ChatSearch.MODES;
				chatModes.addEventListener( IndexChangeEvent.CHANGE, onSelectChatMode );
				chatModes.x = 5;
				chatModes.y = 5;
				
				chatBtnsContainer = new BorderContainer();
				chatBtnsContainer.width = 84;
				chatBtnsContainer.height = 34;
				chatBtnsContainer.setStyle('backgroundColor', 0x4D4D4D);
				chatBtnsContainer.setStyle('borderVisible',false);
				chatBtnsContainer.addElement(chatModes);
				
				anchor = new PopUpAnchor();
				anchor.popUp = chatBtnsContainer;
				anchor.popUpPosition = "below";
				anchor.height = 20;
				row.addElement( anchor );	
				
				button = new LinkButton();
				button.label = "Start chat";
				button.styleName = "linkBtnYellow";
				button.setStyle("fontSize",11);
				button.addEventListener(MouseEvent.CLICK,onStartChatClick);
				row.addElement( button );	
				
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if( user )
			{
				statusLabel.text = user.available == "A" ? 'Available' : 'Unavailable';
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			rows.x = getStyle('paddingLeft');
			rows.y = getStyle('paddingTop');
			
			rows.width = unscaledWidth - getStyle('paddingLeft') - getStyle('paddingRight');
			rows.height = unscaledHeight - getStyle('paddingTop') - getStyle('paddingBottom');
		}
		
		override protected function measure():void
		{
			measuredWidth = 130;
			measuredHeight = AppProperties.getInstance().controller.model.user.id != user.id ? 121 : 77;
		}

		private function onSelectChatMode(event:IndexChangeEvent):void
		{
			ChatSearch( MainController( AppProperties.getInstance().controller ).chatController.model ).mode = ButtonBar(event.currentTarget).selectedItem.data;
			
			dispatchAction( ProfileEvent.START_CHAT );
		}
		
		private function onViewProfileClick(event:MouseEvent):void { dispatchAction( ProfileEvent.VIEW_PROFILE ); }
		private function onViewAppointmentsClick(event:MouseEvent):void { dispatchAction( ProfileEvent.VIEW_APPOINTMENTS ); }
		private function onSendMessageClick(event:MouseEvent):void { dispatchAction( ProfileEvent.SEND_MESSAGE ); }
		private function onStartChatClick(event:MouseEvent):void { anchor.displayPopUp = true; }
		
		private function dispatchAction( type:String ):void
		{
			var evt:ProfileEvent = new ProfileEvent( type );
			evt.user = user;
			dispatchEvent( evt );
		}
		
		public function get user():UserModel
		{
			return _user;
		}

		public function set user(value:UserModel):void
		{
			_user = value;
			
			invalidateProperties();
		}

	}
}