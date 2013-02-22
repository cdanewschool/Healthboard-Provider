package edu.newschool.piim.healthboard.model
{
	import edu.newschool.piim.healthboard.events.ChatEvent;
	import edu.newschool.piim.healthboard.model.module.ModuleModel;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import spark.collections.SortField;

	[Bindable] 
	public class ChatSearch extends ModuleModel
	{
		public static const ID:String = "chat";
		
		public static const STATE_DEFAULT:String = "default";
		public static const STATE_CONNECTED:String = "connected";
		public static const STATE_CONNECTING:String = "connecting";
		public static const STATE_DECLINED:String = "declined";
		
		public static const MODE_TEXT:String = "text";
		public static const MODE_VOICE:String = "voice";
		public static const MODE_VIDEO:String = "video";
		
		public static const MODES:ArrayCollection = new ArrayCollection
			( 
				[
					{label:"Text",icon:"assets/images/button_icons/text.png",data:MODE_TEXT},
					{label:"Voice",icon:"assets/images/button_icons/voice.png",data:MODE_VOICE},
					{label:"Video",icon:"assets/images/button_icons/video.png",data:MODE_VIDEO}
				] 
			);
		
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
			
			mode = MODE_TEXT;
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
			
			//	remove logged-in user
			var loggedInUser:UserModel = AppProperties.getInstance().controller.model.user;
			
			for(var i:int=0;i<dataProvider.length;i++)
			{
				if( (dataProvider.getItemAt(i) as UserModel).userType == loggedInUser.userType 
					&& (dataProvider.getItemAt(i) as UserModel).id == loggedInUser.id )
				{
					dataProvider.removeItemAt(i);
					break;
				}
			}
			
			var sort:Sort = new Sort();
			sort.fields = [ new SortField('lastName') ];
			
			dataProvider.filterFunction = filterFunction;
			dataProvider.sort = sort;
			
			filter();
		}
		
		private function filter():void 
		{
			dataProvider.refresh();
		}
		
		private function filterFunction(item:Object):Boolean 
		{
			var valid:Boolean = true;
			
			var search:String = searchText ? searchText.toLowerCase() : "";
			if( valid && search != "" && search != SEARCH_PLACEHOLDER ) valid = item.fullName.toLowerCase().indexOf( search ) > -1;
			
			return valid;
		}
		
		public static function getModeIndex( mode:String ):int
		{
			for(var i:int=0;i<MODES.length;i++)
			{
				if( MODES[i].data == mode )
				{
					return i;
				}
			}
			return -1;
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