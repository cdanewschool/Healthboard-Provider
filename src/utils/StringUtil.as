package utils
{
	public class StringUtil
	{
		public static function leftPad( value:String, places:int = 2, fillValue:String = "0" ):String
		{
			if( value.length < places )
			{
				while( value.length < places )
				{
					value = fillValue + value;
				}
			}
			
			return value;
		}
	}
}