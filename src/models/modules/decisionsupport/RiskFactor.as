package models.modules.decisionsupport
{
	import models.Location;
	
	import mx.collections.ArrayCollection;
	
	import spark.collections.Sort;

	[Bindable]
	public class RiskFactor
	{
		public var dual:Boolean;
		public var location:Location;
		public var meanValue:*;
		public var name:String;
		public var quantifiable:Boolean;
		
		public var issues:ArrayCollection;
		public var experts:ArrayCollection;
		public var treatments:ArrayCollection;
		public var types:ArrayCollection;
		public var updates:ArrayCollection;
		
		public var maximized:Boolean;
		
		public function RiskFactor()
		{
		}
		
		public function get id():String
		{
			return name.toLowerCase().replace( /\s+/, '_' );
		}
		
		public static function fromObj( data:Object ):RiskFactor
		{
			var val:RiskFactor = new RiskFactor();
			val.issues = new ArrayCollection();
			val.experts = new ArrayCollection();
			val.treatments = new ArrayCollection();
			val.types = new ArrayCollection();
			val.updates = new ArrayCollection();
			
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
			
			var obj:Object;
			
			if( data.type )
			{
				var types:Object = data.type is ArrayCollection ? data.type : new ArrayCollection( [ data.type ] );
				
				for each(obj in types) 
					val.types.addItem( RiskFactor.fromObj( obj ) );
			}
			
			if( data.location )
			{
				var location:Location = new Location( data.location.latitude, data.location.longitude );
				location.country = data.location.country;
				
				val.location = location;
			}
			
			if( data.update )
			{
				var udpates:Object = data.update is ArrayCollection ? data.update : new ArrayCollection( [ data.update ] );
				
				for each(obj in udpates) 
					val.updates.addItem( RiskFactorUpdate.fromObj( obj ) );
				
				function sortCompare(a:RiskFactorUpdate, b:RiskFactorUpdate, fields:Array = null):int
				{
					var n1:Number = a.date.time;
					var n2:Number = b.date.time;
					
					if( n1 == n2 ) return 0;
					
					return n1>n2 ? -1 : 1;
				}
				
				var sort:Sort = new Sort();
				sort.compareFunction = sortCompare;
				
				val.updates.sort = sort;
				val.updates.refresh();
			}
			
			if( data.issues
				&& data.issues.issue )
			{
				val.issues = data.issues.issue is ArrayCollection ? data.issues.issue : new ArrayCollection( [ data.issues.issue ] );
			}
			
			if( data.experts
				&& data.experts.expert )
			{
				val.experts = data.experts.expert is ArrayCollection ? data.experts.expert : new ArrayCollection( [ data.experts.expert ] );
			}
			
			if( data.treatments
				&& data.treatments.treatment )
			{
				var treatments:ArrayCollection = data.treatments.treatment is ArrayCollection ? data.treatments.treatment : new ArrayCollection( [ data.treatments.treatment ] );
				
				for each(obj in treatments) 
					val.treatments.addItem( RiskFactorRecommendedTreatment.fromObj( obj ) );
			}
			
			return val;
		}
	}
}