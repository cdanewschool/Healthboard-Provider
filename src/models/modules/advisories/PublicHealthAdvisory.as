package models.modules.advisories
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.utils.ObjectProxy;
	
	import spark.collections.SortField;
	
	import util.DateUtil;

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
		
		public var arrStats:ArrayCollection;
		public var arrStatsDetailed:ArrayCollection;
		
		public var selectionCriteria:ArrayCollection;
		
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
			
			if( data.startDate )
			{
				val.startDate = new Date( DateUtil.modernizeDate(data.startDate) );
			}
			
			if( data.hasOwnProperty('selection_criteria') 
				&& data.selection_criteria.criterion )
			{
				val.selectionCriteria = new ArrayCollection();
				
				var items:ArrayCollection = data.selection_criteria.criterion is ArrayCollection ? data.selection_criteria.criterion : new ArrayCollection( [data.selection_criteria.criterion] );
				
				for each(var item:Object in items) 
					val.selectionCriteria.addItem( PublicHealthAdvisorySelectionCriteria.fromObj(item) );
			}
			
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
				
				val.update = PublicHealthAdvisoryUpdate( val.updates.getItemAt(0) );
			}
			
			if(data.stats && data.stats.week) val.arrStats = data.stats.week is ArrayCollection ? data.stats.week : new ArrayCollection(data.stats.week);
			if(data.stats && data.stats.half_week) val.arrStatsDetailed = data.stats.half_week is ArrayCollection ? data.stats.half_week : new ArrayCollection(data.stats.half_week);
			
			return val;
		}
	}
}