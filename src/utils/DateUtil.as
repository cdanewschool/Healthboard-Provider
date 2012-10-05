package utils
{
	import ASclasses.Constants;
	
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	import flash.globalization.LocaleID;
	
	import utils.StringUtil;
	
	public class DateUtil
	{
		public static const SECOND:Number = 1000;
		public static const MINUTE:Number = SECOND * 60;
		public static const HOUR:Number = MINUTE * 60;
		public static const DAY:Number = HOUR * 24;
		public static const WEEK:Number = DAY * 7;
		public static const MONTH:Number = WEEK * 4;
		public static const YEAR:Number = MONTH * 12;
		
		public static var DATE_FORMATTER_DAY:DateTimeFormatter = new DateTimeFormatter( LocaleID.DEFAULT, DateTimeStyle.MEDIUM, DateTimeStyle.NONE );
		
		DATE_FORMATTER_DAY.setDateTimePattern('EEE, MMM dd');
		
		public static function compareDates(date1:Date, date2:Date):Number
		{
			return date1.time - date2.time;
		}
		
		public static function getDate(date:String):String 
		{
			if(date.charAt(1) == '/') date = '0' + date;									// 3/4/2012
			if(date.charAt(4) == '/') date = date.substr(0,3) + '0' + date.substr(-6);		// 03/4/2012
			return Constants.MONTHS[uint(date.substr(0,2))-1] + ' ' + uint(date.substr(3,2)) + ', ' + date.substr(-4);
		}
		
		public static function formatTime( ms:int ):String
		{
			var parts:Array = [];
			
			var hours:int = Math.floor( ms/HOUR );
			ms -= (hours * HOUR);
			
			var minutes:int = Math.floor( ms/MINUTE );
			ms -= (minutes * MINUTE);
			
			var seconds:int = Math.floor( ms/SECOND );
			ms -= (seconds * SECOND);
			
			parts.push( StringUtil.leftPad(hours.toString()) );
			parts.push( StringUtil.leftPad(minutes.toString()) );
			parts.push( StringUtil.leftPad(seconds.toString()) );
			
			return parts.join( ':' );
		}
		
		public static function formatTimeFromDate( date:Date, includeSeconds:Boolean = true, includeColon:Boolean = true ):String
		{
			var parts:Array = [];
			
			parts.push( StringUtil.leftPad(date.hours.toString()) );
			parts.push( StringUtil.leftPad(date.minutes.toString()) );
			
			if( includeSeconds )
			{
				parts.push( StringUtil.leftPad(date.seconds.toString()) );
			}
			
			return parts.join( includeColon?':':'');
		}
	}
}