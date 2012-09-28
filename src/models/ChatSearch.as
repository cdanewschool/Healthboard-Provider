package models
{
	import events.ChatEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	[Bindable] 
	public class ChatSearch extends EventDispatcher
	{
		public static const STATE_DEFAULT:String = "default";
		public static const STATE_CONNECTED:String = "connected";
		public static const STATE_CONNECTING:String = "connecting";
		public static const STATE_DECLINED:String = "declined";
		
		public static const SEARCH_PLACEHOLDER:String = "Search name";
		
		public var chatGroups:ArrayCollection = new ArrayCollection( ["All","Patients","Providers"] );
		
		private var _providers:ArrayCollection;
		private var _patients:ArrayCollection;
		private var _selectedChatGroup:int = 0;
		private var _searchText:String;
		
		public var dataProvider:ArrayCollection;
		
		private var _state:String;
		
		public var user:UserModel;
		public var targetUser:UserModel;
		
		public var mode:String;
		
		public function ChatSearch()
		{
			super();	
		}

		public function getUser( id:int, type:String = null ):UserModel
		{
			var user:UserModel;
			var users:ArrayCollection = (type==UserModel.TYPE_PROVIDER?providers:patients);
			
			for each(user in users) if( user.id == id ) return user;
			
			return null;
		}
		
		private function updateDataProvider():void
		{
			if( !providers || !patients ) return;
			
			if( selectedChatGroup == 0 )
				dataProvider = new ArrayCollection( providers.source.slice().concat( patients.source.slice() ) );
			else if( selectedChatGroup == 1 )
				dataProvider = new ArrayCollection( patients.source );
			else if( selectedChatGroup == 2 )
				dataProvider = new ArrayCollection( providers.source );
			
			filter();
		}
		
		private function filter():void 
		{
			dataProvider.filterFunction = filterFunction;
			dataProvider.refresh();
		}
		
		private function filterFunction(item:Object):Boolean 
		{
			var valid:Boolean = true;
			
			var search:String = searchText ? searchText.toLowerCase() : "";
			if( valid && search != "" && search != SEARCH_PLACEHOLDER ) valid = item.firstName.toLowerCase().indexOf( search ) > -1 || item.lastName.toLowerCase().indexOf( search ) > -1;
			
			return valid;
		}
		
		public function get selectedChatGroup():int
		{
			return _selectedChatGroup;
		}

		public function set selectedChatGroup(value:int):void
		{
			_selectedChatGroup = value;
			updateDataProvider();
		}

		public function get searchText():String
		{
			return _searchText;
		}

		public function set searchText(value:String):void
		{
			_searchText = value;
			filter();
		}

		public function get providers():ArrayCollection
		{
			return _providers;
		}

		public function set providers(value:ArrayCollection):void
		{
			_providers = value;
			updateDataProvider();
		}

		public function get patients():ArrayCollection
		{
			return _patients;
		}

		public function set patients(value:ArrayCollection):void
		{
			_patients = value;
			updateDataProvider();
		}

		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			var changed:Boolean = value != _state;
			_state = value;
			
			if( changed )
			{
				dispatchEvent( new ChatEvent( ChatEvent.STATE_CHANGE ) );
				
				if( state == STATE_DEFAULT )
				{
					dispatchEvent( new ChatEvent( ChatEvent.CANCEL ) );
				}
			}
		}


	}
}