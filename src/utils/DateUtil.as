package utils
{
	public class DateUtil
	{
		public static const SECOND:int = 1000;
		public static const MINUTE:int = SECOND * 60;
		public static const HOUR:int = MINUTE * 60;
		public static const DAY:int = HOUR * 24;
		public static const WEEK:int = DAY * 7;
		public static const MONTH:int = WEEK * 4;
		public static const YEAR:int = MONTH * 12;
		
		public static function compareDates(date1:Date, date2:Date):int
		{
			return date1.time - date2.time;
		}
		
		
		public static function formatTime( ms:int ):String
		{
			var hours:int = Math.floor( ms/HOUR );
			ms -= (hours * HOUR);
			
			var minutes:int = Math.floor( ms/MINUTE );
			ms -= (minutes * MINUTE);
			
			var seconds:int = Math.floor( ms/SECOND );
			ms -= (seconds * SECOND);
			
			return (hours<10?'0'+hours:hours) + ':' + (minutes<10?'0'+minutes:minutes) + ':' + (seconds<10?'0'+seconds:seconds);
		}
	}
}