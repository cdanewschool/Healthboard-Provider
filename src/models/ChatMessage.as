package models
{
	import ASfiles.ProviderConstants;
	
	import mx.collections.ArrayCollection;
	
	import utils.DateUtil;

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
			
			header += (user.id == ProviderConstants.USER_ID ? "Me" : user.fullName);
			
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