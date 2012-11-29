package models
{
	[Bindable]
	public class Location
	{
		public var country:String;
		
		public var latitude:Number;
		public var longitude:Number;
		
		public var value:*;
		
		function Location( latitude:Number, longitude:Number, value:* = null ):void
		{
			this.latitude = latitude;
			this.longitude = longitude;
			
			this.value = value;
		}
	}
}