package models
{
	import util.DateUtil;

	public class RecentActivity extends ModuleMappable
	{
		public var summary:String;
		public var date:String;
		
		public function RecentActivity()
		{
			super();
		}
		
		public static function fromObj( data:Object ):RecentActivity
		{
			var val:RecentActivity = new RecentActivity();
			
			for (var prop:String in data)
			{
				if( val.hasOwnProperty( prop ) )
				{
					try
					{
						val[prop] = data[prop];
					}
					catch(e:Error){}
				}
			}
			
			val.date = DateUtil.modernizeDate( data.date );
			
			return val;
		}
	}
}