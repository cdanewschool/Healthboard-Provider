/**
 * Adapted from http://blastanova.com/labs/multiselectdropdown/srcview/index.html
*/
package edu.newschool.piim.healthboard.components
{
	import edu.newschool.piim.healthboard.components.itemrenderers.selectable.SelectableItemRenderer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ItemWrapper;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.events.DropDownEvent;
	
	[Event(name="selectionChange", type="flash.events.Event")]
	
	public class MultiSelectDropDownList extends DropDownList
	{
		private var _placeholderText:String = "Select all";
		private var _placeholderTextPartial:String = "{n} selected";
		
		private var showAll:Boolean = true;
		
		/** selected check boxes */
		protected var currentlySelectedCheckBoxes:Array = new Array();
		
		/**
		 * constructor
		 */
		public function MultiSelectDropDownList()
		{
			super();
			
			setStyle("horizontalScrollPolicy", "off");
			
			this.addEventListener(DropDownEvent.OPEN, onOpen, false, 0, true);
		}
		
		/**
		 *  handler for opening the dropdown
		 *  
		 *  @param dropdown event
		 */ 
		public function onOpen(event:DropDownEvent):void 
		{
			activateAllCheckBoxes();
		}        
		
		/**
		 * selected views getter (inclusive of check boxes on item renderer)
		 * 
		 * @return array
		 */
		[Bindable("selectionChange")]
		public function get selectedViews():Array 
		{
			var multiSelect:Array = selectedCheckboxes;
			
			if (multiSelect.length > 0) {
				return multiSelect;
			} else {
				return [selectedItem];
			}
		}
		
		/**
		 * selected views setter (does nothing)
		 * 
		 * @param array
		 */
		public function set selectedViews(value:Array):void {}
		
		/**
		 * item mouse down handler
		 * 
		 * @param mouse event
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void 
		{
			/*
			if (selectedCheckboxes.length == 0) 
			{
				super.item_mouseDownHandler(event); 
				
				dispatchEvent(new Event("selectionChange"));
			}
			*/
		}
		
		/**
		 *  @private
		 *  Event handler for the <code>dropDownController</code> 
		 *  <code>DropDownEvent.CLOSE</code> event. Updates the skin's state.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected override function dropDownController_closeHandler(event:DropDownEvent):void
		{
			if ( currentlySelectedCheckBoxes.length > 0 ) 
			{
				// if checkboxes are selected prevent the default behavior,
				// which is to set a selection index
				event.preventDefault();
			}
			
			super.dropDownController_closeHandler(event);
		}
		
		/**
		 * turn on all check boxes
		 */
		protected function activateAllCheckBoxes():void 
		{
			if( !dataGroup ) return;
			
			for (var c:int = 0; c < dataGroup.numElements; c++) 
			{
				var obj:SelectableItemRenderer = dataGroup.getElementAt(c) as SelectableItemRenderer;
				
				if (obj) 
				{
					obj.checkbox.addEventListener(MouseEvent.MOUSE_DOWN, mouseCheckBox, false, 0, true);
					obj.checkbox.addEventListener(MouseEvent.MOUSE_UP, mouseCheckBox, false, 0, true);
					obj.checkbox.addEventListener(Event.CHANGE, changeCheckBoxSelection, false, 0, true);
				}
			}
			
			updateLabel();
		}
		
		/**
		 * deselect all check boxes
		 */
		protected function selectAllCheckBoxes():void 
		{
			for each(var item:Object in dataProvider)
			{
				if ( item && item && item.hasOwnProperty('selected') ) 
				{
					item['selected'] = true;
				}
			}
			
			for (var c:int = 0; c < dataGroup.numElements; c++) 
			{
				var obj:SelectableItemRenderer = dataGroup.getElementAt(c) as SelectableItemRenderer;
				
				if (obj && (!showAll || (showAll && c > 0) ) ) 
				{
					obj.checkbox.selected = true;
				}
			}
		}
		
		/**
		 * get array of selected checkboxes
		 * 
		 * @return array of selected checkboxes
		 */
		private function get selectedCheckboxes():Array
		{
			var selected:Array = new Array();
			
			for each(var item:Object in dataProvider)
			{
				if ( item && item && item.hasOwnProperty('selected') && item['selected'] == true
					&& (!showAll || dataProvider.getItemIndex( item ) > 0 ) ) 
				{
					selected.push( item );
				}
			}
			
			return selected;
		}
		
		/**
		 * on click checkbox (stop event from going to underlying item renderer)
		 * 
		 * @param change event
		 */
		protected function mouseCheckBox(event:Event):void 
		{

		}
		
		/**
		 * on change checkbox
		 * 
		 * @param change event
		 */
		protected function changeCheckBoxSelection(event:Event):void 
		{
			if( showAll )
			{
				var checkbox:CheckBox = event.currentTarget as CheckBox;
				
				if( dataGroup.getElementIndex( checkbox.parent as IVisualElement ) == 0 
					&& checkbox.selected )
				{
					dataProvider.getItemAt(0).selected = true;
					
					selectAllCheckBoxes();
				}
				else if( selectedCheckboxes.length < dataProvider.length )
				{
					dataProvider.getItemAt(0).selected = false;
					
					if( dataGroup.getElementAt(0) )
					{
						(dataGroup.getElementAt(0) as SelectableItemRenderer).checkbox.selected = false;
					}
				}
			}
			
			currentlySelectedCheckBoxes = selectedCheckboxes;
			
			checkbox = (event.currentTarget as CheckBox);
			
			if( checkbox.parent.hasOwnProperty('data')
				&& checkbox.parent['data'].hasOwnProperty('selected') )
			{
				checkbox.parent['data'].selected = checkbox.selected;
			}
			
			// turn on multi-view mode
			if (event.currentTarget.selected == true ) 
			{
				selectedIndex = -1;
			}
			
			updateLabel();
			
			dispatchEvent( new Event("selectionChange") );
		}
		
		override public function set dataProvider(value:IList):void
		{
			if( value && showAll )
			{
				if( value is ArrayCollection )
				{
					value = new ArrayCollection( ArrayCollection(value).source.slice() );
				}
				
				value.addItemAt( { label: 'Show All' }, 0 );
			}
			
			super.dataProvider = value;
			
			updateLabel();
		}
		
		protected function updateLabel():void
		{
			var selected:Array = selectedCheckboxes;
			
			var showingAll:Boolean = showAll ? selected.length == dataProvider.length - 1 : selected.length == dataProvider.length;
			
			if ( showingAll ) 
			{
				prompt = placeholderTextPartial.replace( /%n%/, 'All' );
			}
			else
			{
				prompt = placeholderTextPartial.replace( /%n%/, selected.length );
			}
		}

		public function get placeholderText():String
		{
			return _placeholderText;
		}

		public function set placeholderText(value:String):void
		{
			_placeholderText = prompt = value;
		}

		public function get placeholderTextPartial():String
		{
			return _placeholderTextPartial;
		}

		public function set placeholderTextPartial(value:String):void
		{
			_placeholderTextPartial = value;
		}


	}
}