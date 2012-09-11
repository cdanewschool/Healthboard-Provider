package models
{
	import ASclasses.Constants;
	
	import mx.collections.ArrayCollection;
	
	import utils.DateUtil;

	[Bindable]
	public class Chat
	{
		public static const MODE_TEXT:String = "text";
		public static const MODE_VOICE:String = "voice";
		public static const MODE_VIDEO:String = "video";
		
		public static const MODES:ArrayCollection = new ArrayCollection
			( 
				[
					{label:"Text",icon:"images/button_icons/text.png",data:MODE_TEXT},
					{label:"Voice",icon:"images/button_icons/voice.png",data:MODE_VOICE},
					{label:"Video",icon:"images/button_icons/video.png",data:MODE_VIDEO}
				] 
			);
		
		public var startTime:Date;
		public var endTime:Date;
		
		public var sourceUser:UserModel;
		public var targetUser:UserModel;
		
		public var messages:ArrayCollection;
		
		public var mode:String = MODE_TEXT;
		
		public function Chat( sourceUser:UserModel, targetUser:UserModel = null, startTime:Date = null, endTime:Date = null )
		{
			this.sourceUser = sourceUser;
			this.targetUser = targetUser;
			
			this.startTime = startTime;
			this.endTime = endTime;
		}
		
		public function addMessage( message:ChatMessage ):void
		{
			if( !messages ) messages = new ArrayCollection();
			
			messages.addItem( message );
		}
		
		public function get log():String
		{
			var log:Array = [];
			
			for each(var message:ChatMessage in messages)
			{
				log.push( message.toString() );
			}
			
			return log.join('\n');
		}
		
		public function get elapsed():String
		{
			var elapsedMS:int = DateUtil.compareDates( new Date(), startTime );
			
			return DateUtil.formatTime( elapsedMS );
		}
		
		public function get label():String
		{
			return "" + (startTime.hours + ':' + startTime.minutes) + '-' + (endTime.hours + ':' + endTime.minutes) + ', ' + (Constants.MONTHS[endTime.month] + ' ' + endTime.date + ', ' + endTime.fullYear ) + ' - ' + targetUser.fullName;
		}
		
		public static function getModeIndex( mode:String ):int
		{
			for(var i:int=0;i<MODES.length;i++)
			{
				if( MODES[i].data == mode )
				{
					return i;
				}
			}
			return -1;
		}
	}
}