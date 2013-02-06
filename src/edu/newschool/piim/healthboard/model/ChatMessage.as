package edu.newschool.piim.healthboard.model
{
	import edu.newschool.piim.healthboard.ProviderConstants;
	
	import mx.collections.ArrayCollection;
	
	import edu.newschool.piim.healthboard.util.DateUtil;

	public class ChatMessage
	{
		public var text:String;
		
		public var time:Date;
		public var user:UserModel;
		
		public var attachments:ArrayCollection;
		
		public function ChatMessage()
		{
		}
		
		public function toString():String
		{
			var header:String = "";
			
			if( UserPreferences(AppProperties.getInstance().controller.model.preferences).chatEnableTimeStamp )
			{
				header += "[<font color='#666666'>" + DateUtil.formatTime( time.time ) + "</font>] ";
			}
			
			header += (user.id == AppProperties.getInstance().controller.model.user.id ? "Me" : user.fullName);
			
			var message:String = text;
			var files:Array = [];
			
			for each(var attachment:FileUpload in attachments)
			{
				files.push( attachment.name );
			}
			
			return header + ": " + message + " " + files.join(", ");
		}
	}
}