package models.modules.advisories
{
	import models.Location;
	import models.PatientModel;
	
	import mx.collections.ArrayCollection;
	
	import util.DateUtil;

	[Bindable]
	public class PublicHealthAdvisoryUpdate
	{
		public var date:Date;
		public var source:String;
		public var text:String;
		
		public var affectedStatesCount:int;
		public var caseReportCount:int;
		
		public var affectedNetwork:ArrayCollection;
		public var atRiskNetwork:ArrayCollection;
		public var deathsNetwork:ArrayCollection;
		public var hospitalizationsNetwork:ArrayCollection;
		
		public var affected:ArrayCollection;
		public var atRisk:ArrayCollection;
		public var deaths:ArrayCollection;
		public var hospitalizations:ArrayCollection;
		
		public function PublicHealthAdvisoryUpdate()
		{
		}
		
		public function addAffectedInNetwork( patient:PatientModel ):void
		{
			if( !affectedNetwork ) affectedNetwork = new ArrayCollection();
			
			affectedNetwork.addItem( new Location( patient.latitude, patient.longitude ) );
		}
		
		public function addAtRiskInNetwork( patient:PatientModel ):void
		{
			if( !atRiskNetwork ) atRiskNetwork = new ArrayCollection();
			
			atRiskNetwork.addItem( new Location( patient.latitude, patient.longitude ) );
		}
		
		public function get affectedCountNetwork():int { return affectedNetwork ? affectedNetwork.length : NaN; }
		public function get atRiskCountNetwork():int { return atRiskNetwork ? atRisk.length : NaN; }
		public function get deathCountNetwork():int { return deathsNetwork ? deathsNetwork.length : NaN; }
		public function get hospitalizationsCountNetwork():int { return hospitalizationsNetwork ? hospitalizationsNetwork.length : NaN; }
		
		public function get affectedCount():int { return affected ? affected.length : NaN; }
		public function get atRiskCount():int { return atRisk ? atRisk.length : NaN; }
		public function get deathCount():int { return deaths ? deaths.length : NaN; }
		public function get hospitalizationsCount():int { return hospitalizations ? hospitalizations.length : NaN; }
		
		public static function fromObj( data:Object ):PublicHealthAdvisoryUpdate
		{
			var val:PublicHealthAdvisoryUpdate = new PublicHealthAdvisoryUpdate();
			
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
			
			var items:ArrayCollection;
			var item:Object;
			
			if( data.hasOwnProperty('deaths') 
				&& data.deaths.death )
			{
				val.deaths = new ArrayCollection();
				
				items = data.deaths.death is ArrayCollection ? data.deaths.death : new ArrayCollection( [data.deaths.death] );
				
				for each(item in items) 
					val.deaths.addItem( new Location( item.latitude, item.longitude ) );
			}
				
			
			if( data.hasOwnProperty('hospitalizations') 
				&& data.hospitalizations.hospitalization )
			{
				val.hospitalizations = new ArrayCollection();
				
				items = data.hospitalizations.hospitalization is ArrayCollection ? data.hospitalizations.hospitalization : new ArrayCollection( [data.hospitalizations.hospitalization] );
				
				for each(item in items) 
					val.hospitalizations.addItem( new Location( item.latitude, item.longitude ) );
			}
				
			if( data.date )
				val.date = new Date( DateUtil.modernizeDate(data.date) );
			
			return val;
		}
	}
}