package models.modules.advisories
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.utils.ObjectProxy;
	
	import spark.collections.SortField;

	[Bindable]
	public class PublicHealthAdvisory
	{
		public var id:int;
		
		//	date the outbreak started
		public var startDate:Date;
		
		public var title:String;
		public var active:Boolean;
		
		public var update:PublicHealthAdvisoryUpdate;
		public var updates:ArrayCollection;
		
		public function PublicHealthAdvisory()
		{
		}
		
		public static function fromObj( data:Object ):PublicHealthAdvisory
		{
			var val:PublicHealthAdvisory = new PublicHealthAdvisory();
			
			for (var prop:String in data)
			{
				if( val.hasOwnProperty( prop ) )
				{
					try
					{
						val[prop] = data[prop];
					}
					catch(e:Error){};
				}
			}
			
			val.startDate = new Date( data.startDate );
			
			var results:ArrayCollection = data.updates.update is ArrayCollection ? data.updates.update : new ArrayCollection( [data.updates.update] );
			var updates:ArrayCollection = new ArrayCollection();
			
			for each(var result:Object in results)
			{
				var update:PublicHealthAdvisoryUpdate = PublicHealthAdvisoryUpdate.fromObj(result);
				updates.addItem( update );
			}
			
			val.updates = updates;
			
			if( val.updates
				&& val.updates.length )
			{
				var sort:Sort = new Sort();
				sort.fields = [ new SortField('date',true,true) ];
				
				val.updates.sort = sort;
				val.updates.refresh();
				
				val.update = PublicHealthAdvisoryUpdate( updates.getItemAt(0) );
			}
			
			return val;
		}
	}
}