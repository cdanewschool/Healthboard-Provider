package components.itemrenderers
{
	import controllers.AppointmentsController;
	
	import models.Appointment;
	
	import mx.charts.chartClasses.ChartLabel;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	
	import spark.components.HGroup;
	import spark.components.Label;
	
	public class WeeklyCustomChartLabel extends ChartLabel
	{
		private var appointments:ArrayCollection;
		
		private var dirty:Boolean;
		private var hgroup:HGroup = new HGroup();
		
		public function WeeklyCustomChartLabel()
		{
			super();
			
			height = 83;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			hgroup = new HGroup();
			hgroup.name = "providerLabels";
			hgroup.percentWidth = 100;
			addChild( hgroup );
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if( dirty )
			{
				while(hgroup.numChildren) hgroup.removeChildAt(0);
				
				var p:Array = [];
				for(var i:int=0;i<appointments.length;i++)
				{
					var a:Appointment = Appointment(appointments[i]);
					
					if( p.indexOf(a.provider.id) == -1 )
					{
						var label:Label = new Label();
						label.text = a.provider.lastName;
						label.styleName = "white12SemiBold";
						//label.rotation = 90;
						hgroup.addElement( label );
						
						p.push( a.provider.id );
					}
				}
				dirty = false;
			}
		}
		override public function set data(value:Object):void
		{
			super.data = value;
			
			var date:Date = new Date();
			date.setTime( Date.parse( value.value ) );
			
			appointments = AppointmentsController.getInstance().getAppointments(-1,null,date);
			dirty = true;
			
			invalidateProperties();
		}
		
		override protected function measure():void
		{
			super.measure();
			
			measuredHeight = 83;
		}
	}
}