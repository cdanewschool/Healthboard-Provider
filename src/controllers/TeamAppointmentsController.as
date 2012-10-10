package controllers
{
	import components.popups.ViewAttachmentPopup;
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import models.Appointment;
	import models.AppointmentPrerequisite;
	import models.AppointmentsModel;
	import models.ImageReference;
	import models.UserModel;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.graphics.GradientEntry;
	import mx.graphics.IFill;
	import mx.graphics.LinearGradient;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;

	[Bindable]
	public class TeamAppointmentsController
	{
		private static var __instance:TeamAppointmentsController;
		
		public var model:AppointmentsModel;
		
		private var fillCache:Dictionary;
		
		public function TeamAppointmentsController( enforcer:SingletonEnforcer )
		{
			model = new AppointmentsModel;
			
			fillCache = new Dictionary();
		}
		
		public static function getInstance():TeamAppointmentsController
		{
			if( !__instance ) __instance = new TeamAppointmentsController( new SingletonEnforcer() );
			
			return __instance;
		}
		
		public function getAppointments( id:int = -1, type:String = null, date:Date = null ):ArrayCollection
		{
			var results:ArrayCollection = new ArrayCollection();
			
			for each(var appointment:Appointment in model.appointments)
			{
				var valid:Boolean = true;
				
				if( id > -1 && type != null )
				{
					if( ( type == UserModel.TYPE_PATIENT && appointment.patient.id != id ) 
						|| ( type == UserModel.TYPE_PROVIDER && appointment.provider.id != id ) )
					{
						valid = false;
					}
				}
				
				if( date != null 
					&& ( appointment.from.fullYear != date.fullYear 
						|| appointment.from.month != date.month
						|| appointment.from.date != date.date ) )
				{
						valid = false;
				}
				
				if( valid ) results.addItem( appointment );
			}
			
			return results;
		}
		
		public function showPrerequisites( appointment:Appointment ):void
		{
			var images:Vector.<ImageReference> = new Vector.<ImageReference>;
			
			for each(var pre:AppointmentPrerequisite in appointment.prerequisites)
			{
				var image:ImageReference = new ImageReference();
				image.filePath = pre.path;
				image.caption = pre.toString();
				images.push( image );
			}
			
			var popup:ViewAttachmentPopup = new ViewAttachmentPopup();
			ViewAttachmentPopup(popup).fileReferences = images;
			
			PopUpManager.addPopUp( popup, DisplayObject(FlexGlobals.topLevelApplication), true );
			PopUpManager.centerPopUp( popup );
		}
		
		public function getFill( type:String ):IFill
		{
			if( fillCache[type] ) return fillCache[type];

			var colors:Array = [];
			
			for each(var typeDef:Object in Appointment.APPOINTMENT_TYPES)
			{
				if( typeDef.value == type )
				{
					colors = typeDef.colors;
					break;
				}
			}
			
			var fill:LinearGradient = new LinearGradient();
			fill.entries = [ new GradientEntry( colors[0] ), new GradientEntry( colors[1], .5215 ), new GradientEntry( colors[2], 1 ) ];
			fillCache[type] = fill;
			
			return fill;
		}
		
		public function resultHandler(event:ResultEvent):void {
			
			var results:ArrayCollection = event.result.appointments.appointment;
			
			var appointments:ArrayCollection = new ArrayCollection();
			
			for each(var result:Object in results)
			{
				var appointment:Appointment = Appointment.fromObj(result);
				appointments.addItem( appointment );
			}
			
			model.appointments = appointments;
		}
	}
}
internal class SingletonEnforcer
{
}