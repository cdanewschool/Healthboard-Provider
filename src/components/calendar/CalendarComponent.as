package components.calendar
{
	import ASclasses.Constants;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Label;
	import mx.controls.listClasses.ListItemRenderer;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.events.DateChooserEvent;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.components.VGroup;
	import spark.layouts.RowAlign;
	import spark.layouts.TileLayout;
	import spark.layouts.TileOrientation;
	
	import utils.DateUtil;
	
	[Event(name="change", type="mx.events.CalendarLayoutChangeEvent")]
	
	public class CalendarComponent extends VGroup
	{
		public static const MODE_WEEK:String = "CalendarComponent.MODE_WEEK";
		public static const MODE_MONTH:String = "CalendarComponent.MODE_MONTH";
		public static const MODE_DAY:String = "CalendarComponent.MODE_DAY";
		
		private var header:Group;
		private var content:List;
		
		private var _mode:String = MODE_MONTH;
		
		private var _selectedDate:Date;
		private var _displayedMonth:int = 0;
		private var _displayedYear:int = 0;
		
		private var _itemRenderer:Class;
		
		private var dirty:Boolean;
		
		public function CalendarComponent()
		{
			super();
			
			displayedMonth = new Date().month;
			displayedYear = new Date().fullYear;
			
			itemRenderer = ListItemRenderer;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var _layout:TileLayout;
			
			header = new Group();
			addElement( header );
			
			content = new List();
			content.setStyle('contentBackgroundAlpha',0);
			content.addEventListener( Event.CHANGE, onDateSelect );
			addElement( content );
			
			_layout = new TileLayout();
			_layout.rowAlign = RowAlign.JUSTIFY_USING_HEIGHT;
			_layout.orientation = TileOrientation.ROWS;
			_layout.horizontalGap = -1;
			header.layout = _layout;
			
			_layout = new TileLayout();
			_layout.rowAlign = RowAlign.JUSTIFY_USING_HEIGHT;
			_layout.orientation = TileOrientation.ROWS;
			_layout.horizontalGap = 0;
			_layout.verticalGap = 0;
			content.layout = _layout;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if( dirty )
			{
				content.itemRenderer = new ClassFactory( itemRenderer );
				
				if( mode == MODE_MONTH )
				{
					var dateStart:Date = new Date( displayedYear, displayedMonth );
					var dateEnd:Date = new Date( displayedYear, displayedMonth );
					
					dateStart.date = 1;
					dateStart.time -= (dateStart.day * DateUtil.DAY);
					
					dateEnd.month += 1;
					dateEnd.time -= DateUtil.DAY;
					dateEnd.time += (7-dateEnd.day) * DateUtil.DAY;
					
					header.removeAllElements();
					
					for(var i:int=0;i<7;i++)
					{
						var label:Label = new Label();
						label.text = Constants.DAYS[ i ];
						label.styleName = "white11";
						label.setStyle('textAlign','center');
						header.addElement( label );
					}
					
					var time:int = dateStart.getTime();
					var days:int = (dateEnd.time - dateStart.time ) / DateUtil.DAY;
					
					var data:ArrayCollection = new ArrayCollection();
					
					for(i=0;i<days;i++)
					{
						data.addItem( dateStart.time );
						
						dateStart.date += 1;
					}
					
					content.dataProvider = data;
					
					(content.layout as TileLayout).requestedColumnCount = 7;
					(content.layout as TileLayout).verticalGap = 0;
				}
				
				dirty = false;
			}
			
			content.selectedIndex = selectedDate && content.dataProvider ? content.dataProvider.getItemIndex( selectedDate.time ) : null;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			var gap:int = this.getStyle('verticalGap');
			
			if( mode == MODE_MONTH )
			{
				var _layout:TileLayout;
				_layout = (header.layout as TileLayout);
				_layout.columnWidth = (unscaledWidth - _layout.columnCount * _layout.horizontalGap) / _layout.columnCount;
				
				header.height = 20;
				
				_layout = (content.layout as TileLayout);
				_layout.columnWidth = (unscaledWidth - _layout.columnCount * _layout.horizontalGap) / _layout.columnCount;
				//_layout.rowHeight = (unscaledHeight - _layout.rowCount * _layout.verticalGap) / _layout.rowCount;
				
				content.height = unscaledHeight - header.height - gap;
			}
		}
		
		private function onDateSelect( event:Event ):void
		{
			var date:Date = new Date();
			date.time = content.selectedItem;
			
			selectedDate = date;
			
			var evt:CalendarLayoutChangeEvent = new CalendarLayoutChangeEvent( CalendarLayoutChangeEvent.CHANGE, true );
			dispatchEvent( evt );
		}
		
		public function get mode():String
		{
			return _mode;
		}

		public function set mode(value:String):void
		{
			_mode = value;
			
			dirty = true;
			
			invalidateProperties();
		}

		public function get displayedMonth():int
		{
			return _displayedMonth;
		}

		public function set displayedMonth(value:int):void
		{
			_displayedMonth = value;

			dirty = true;
			
			invalidateProperties();
		}

		public function get displayedYear():int
		{
			return _displayedYear;
		}

		public function set displayedYear(value:int):void
		{
			_displayedYear = value;
			
			dirty = true;
			
			invalidateProperties();
		}
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		public function set itemRenderer(value:Class):void
		{
			if( !value is IVisualElement ) 
			{
				throw new Error( 'itemRenderer must implement IVisualElement' );
			}
			
			_itemRenderer = value;
		}

		public function get selectedDate():Date
		{
			return _selectedDate;
		}

		public function set selectedDate(value:Date):void
		{
			_selectedDate = value;
			
			if( selectedDate )
			{
				displayedMonth = selectedDate.month;
				displayedYear = selectedDate.fullYear;
				
				invalidateProperties();
			}
		}


	}
}