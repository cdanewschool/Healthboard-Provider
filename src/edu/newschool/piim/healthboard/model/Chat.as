package edu.newschool.piim.healthboard.model
{
	import edu.newschool.piim.healthboard.Constants;
	
	import mx.collections.ArrayCollection;
	
	import edu.newschool.piim.healthboard.util.DateUtil;

	[Bindable]
	public class Chat
	{
		public var startTime:Date;
		public var endTime:Date;
		
		public var sourceUser:UserModel;
		public var targetUser:UserModel;
		
		public var messages:ArrayCollection;
		
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
			return DateUtil.formatTimeFromDate( startTime, false ) + '-' + DateUtil.formatTimeFromDate( endTime, false ) + ', ' + (Constants.MONTHS[endTime.month] + ' ' + endTime.date + ', ' + endTime.fullYear ) + ' - ' + targetUser.fullName;
		}
	}
}