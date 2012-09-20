package components.itemrenderers
{
	import controllers.AppointmentsController;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import models.Appointment;
	import models.ProviderModel;
	
	import mx.charts.chartClasses.ChartLabel;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.core.IUITextField;
	import mx.core.IVisualElement;
	import mx.core.UITextField;
	import mx.events.CollectionEvent;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	
	public class WeeklyCustomChartLabel extends ChartLabel
	{
		private var dirty:Boolean;
		
		private var labels:Vector.<IUITextField>;
		
		public function WeeklyCustomChartLabel()
		{
			super();
			
			height = 83;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if( dirty )
			{
				while(numChildren>1) removeChildAt(1);
				
				var _label:IUITextField
				
				labels = new Vector.<IUITextField>;
				
				var providers:ArrayCollection = AppointmentsController.getInstance().model.selectedProviders;
				
				for(var i:int=0;i<providers.length;i++)
				{
					var p:ProviderModel = ProviderModel(providers[i]);
					
					_label = IUITextField(createInFontContext(UITextField));
					_label.multiline = false;
					_label.selectable = false;
					_label.autoSize = "left";
					_label.styleName = "blue11Bold";
					_label.text = p.lastName;
					_label.rotation = -90;
					addChild(DisplayObject(_label));
					
					labels.push( _label );
				}
				
				for(i=0;i<labels.length;i++)
				{
					_label = labels[i];
					
					_label.x = (width - (labels.length*20))/2 + (i*20);
					_label.y = height - 2;
				}
				
				dirty = false;
			}
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void 
		{
			super.updateDisplayList(w, h);
			
			var _label:IUITextField = IUITextField( getChildAt(0) );
			
			var y:int = _label.height + 5;
			
			var g:Graphics = graphics; 
			g.clear();  
			
			g.lineStyle(0,0x86888A);
			g.beginFill(0x4D4D4D,1);
			g.drawRect(0,y,w,h - y);
			g.endFill();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			var date:Date = new Date();
			date.setTime( Date.parse( value.value ) );
			
			AppointmentsController.getInstance().model.selectedProviders.addEventListener(CollectionEvent.COLLECTION_CHANGE, onProvidersChange );
			onProvidersChange();
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
		}
		
		override protected function measure():void
		{
			super.measure();
			
			measuredHeight = 83;
			measuredWidth = 75;
		}
		
		private function onProvidersChange(event:CollectionEvent=null):void
		{
			dirty = true;
			
			invalidateProperties();
		}
	}
}