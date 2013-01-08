package models.modules.advisories
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class PublicHealthAdvisorySelectionCriteria
	{
		public var title:String;
		public var values:ArrayCollection;
		
		public function PublicHealthAdvisorySelectionCriteria()
		{
		}
		
		public static function fromObj( data:Object ):PublicHealthAdvisorySelectionCriteria
		{
			var val:PublicHealthAdvisorySelectionCriteria = new PublicHealthAdvisorySelectionCriteria();
			
			val.title = data.title;
			
			if( data.hasOwnProperty('values') 
				&& data.values.value )
			{
				val.values = data.values.value is ArrayCollection ? data.values.value : new ArrayCollection( [data.values.value] );
			}
			
			return val;
		}
	}
}