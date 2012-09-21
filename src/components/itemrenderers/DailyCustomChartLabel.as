package components.itemrenderers
{
	import controllers.AppointmentsController;
	
	import events.AppointmentEvent;
	import events.MessageEvent;
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	import mx.charts.AxisLabel;
	import mx.charts.AxisRenderer;
	import mx.charts.CategoryAxis;
	import mx.charts.chartClasses.ChartLabel;
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.managers.CursorManager;
	
	import spark.components.DropDownList;
	import spark.components.List;
	import spark.components.PopUpAnchor;
	import spark.events.IndexChangeEvent;
	
	public class DailyCustomChartLabel extends ChartLabel
	{
		private var button:Button;
		private var anchor:PopUpAnchor;
		private var list:List;
		
		private var options:ArrayCollection = new ArrayCollection( ['Message All','Cancel All'] );
		
		[Embed(source="images/smallArrowGray.png")]
		private var iconClass:Class;
		
		public function DailyCustomChartLabel()
		{
			super();
			
			setStyle('paddingLeft',5);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			button = new Button();
			button.width = 18;
			button.styleName = "iconButon";
			button.setStyle('icon',iconClass)
			button.setStyle('cornerRadius',0);
			button.setStyle('highlightAlphas',[0,0]);
			button.setStyle('fillAlphas',[1,1,1,1]);
			button.setStyle('fillColors',['#ffffff', '#ffffff', '#ffffff', '#ffffff']);
			button.setStyle('borderColor','#ffffff');
			button.setStyle('themeColor','#ffffff');
			button.addEventListener( MouseEvent.CLICK, onClick );
			addChild( button );
			
			list = new List();
			list.setStyle('chromeColor','0xffffff');
			list.setStyle('chromeBackgroundColor','0xffffff');
			list.setStyle('color','0x333333');
			list.dataProvider = options;
			list.width = 80;
			list.height = 50;
			list.addEventListener( IndexChangeEvent.CHANGE, onItemSelect );
			
			anchor = new PopUpAnchor();
			anchor.width = 20;
			anchor.height = 20;
			anchor.popUp = list;
			anchor.popUpPosition = "below";
			anchor.setStyle('chromeColor','0xffffff');
			addChild( anchor );
			
			getChildAt(0).addEventListener( MouseEvent.CLICK, onLabelClick );
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void 
		{
			super.updateDisplayList(w, h);
			
			getChildAt(0).x = getStyle('paddingLeft');
			
			button.x = anchor.x = w - button.width;
			button.height = h;
			
			anchor.y = button.y;
			
			var g:Graphics = graphics; 
			g.clear();  
			
			g.lineStyle(0,0x86888A);
			g.beginFill(0x4D4D4D,1);
			g.drawRect(0,0,w,h);
			g.endFill();
		}
		
		override protected function measure():void
		{
			super.measure();
			
			var parent:AxisRenderer = AxisRenderer(parent);
			
			measuredWidth = ( ( parent.width - parent.gutters.left + parent.gutters.right ) / CategoryAxis(parent.axis).dataProvider.length) - 6;
			measuredHeight = 23;
		}
		
		private function onClick( event:MouseEvent ):void
		{
			anchor.displayPopUp = !anchor.displayPopUp;
		}
		
		private function onItemSelect( event:IndexChangeEvent ):void
		{
			if( event.newIndex == 0 )
			{
				dispatchEvent( new MessageEvent( MessageEvent.MESSAGE_ALL, true ) );
			}
			else if( event.newIndex == 1 )
			{
				dispatchEvent( new AppointmentEvent( AppointmentEvent.CANCEL_ALL, true ) );
			}
		}
		
		private function onLabelClick( event:MouseEvent ):void
		{
			event.stopPropagation();
			
			var evt:AppointmentEvent = new AppointmentEvent( AppointmentEvent.VIEW_PROVIDER, true );
			evt.data = AxisLabel(data).value;
			dispatchEvent( evt );
		}
	}
}