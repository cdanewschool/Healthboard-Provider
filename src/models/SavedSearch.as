package models
{
	public class SavedSearch
	{
		public var name:String;
		public var values:Object;
		
		public function SavedSearch()
		{
		}
		
		public static function fromObj( data:Object ):SavedSearch
		{
			var val:SavedSearch = new SavedSearch();
			
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
			
			return val;
		}
	}
}