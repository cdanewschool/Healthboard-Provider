package models
{
	import models.modules.advisories.PatientAdvisoryStatus;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	
	import util.DateFormatters;

	[Bindable]
	public class PatientModel extends UserModel
	{
		//public var photo:String;
		
		//	personal
		public var race:String;
		public var ssn:String;
		public var sponsorSSN:String;
		
		public var serviceBranch:String;
		public var serviceRank:String;
		public var occupation:String;
		
		//	medical
		public var urgency:int;
		public var bloodType:String;
		
		public var conditions:String;
		public var lastVisit:Date;
		
		public var advisories:ArrayCollection;
		public var advisoriesLastUpdated:Date;
		
		public var relations:ArrayCollection;
		
		public function PatientModel()
		{
			super(TYPE_PATIENT);
		}
		
		public function get lastVisitLabel():String
		{
			return DateFormatters.dateOnlyBackslashDelimited.format( lastVisit );
		}
		
		public function getAdvisoryStatusById( advisoryId:int ):PatientAdvisoryStatus
		{
			for each(var status:PatientAdvisoryStatus in advisories)
			{
				if( status.advisoryId == advisoryId ) return status;
			}
			
			return null;
		}
		
		public static function fromObj( data:Object ):PatientModel
		{
			var val:PatientModel = new PatientModel();
			
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
			
			val.birthdate = new Date( data.birthdate );
			
			var advisories:Object = data.advisories;
			var contact:Object = data.contact;
			var location:Object = data.location;
			var medical:Object = data.medical;
			var occupation:Object = data.occupation;
			var relations:Object = data.relations;
			
			var obj:Object;
			
			if( contact )
			{
				val.email = contact.email;
				val.phone = contact.phone;
			}
			
			if( location )
			{
				val.city = location.city;
				val.latitude = location.latitude;
				val.longitude = location.longitude;
				val.state = location.state;
			}
			
			if( medical )
			{
				val.bloodType = medical.bloodType;
				val.urgency = medical.urgency;
				val.conditions = medical.conditions;
				val.lastVisit = new Date( medical.lastVisit );
				val.team = medical.team;
			}
			
			if( occupation )
			{
				val.occupation = occupation.professionalTitle;
				val.serviceRank = occupation.serviceRank;
				val.serviceBranch = occupation.serviceBranch;
			}
			
			if( advisories )
			{
				val.advisoriesLastUpdated = new Date( advisories.updated );
				val.advisories = new ArrayCollection();
				
				var advisoriesObjects:ArrayCollection = advisories.advisory is ArrayCollection ? advisories.advisory : new ArrayCollection( [ advisories.advisory ] );
				
				for each(obj in advisoriesObjects)
				{
					val.advisories.addItem( PatientAdvisoryStatus.fromObj( obj ) );
				}
			}
			
			if( relations )
			{
				val.relations = new ArrayCollection();
				
				var relationsObjects:ArrayCollection = relations.relation is ArrayCollection ? relations.relation : new ArrayCollection( [ relations.relation ] );
				
				for each(obj in relationsObjects)
				{
					val.relations.addItem( RelationModel.fromObj( obj ) );
				}
			}
			
			return val;
		}
	}
}