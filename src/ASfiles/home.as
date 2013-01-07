import controllers.MainController;

import flash.events.MouseEvent;

import models.ProviderApplicationModel;
import models.UserModel;

import mx.controls.LinkButton;
import mx.core.FlexGlobals;

import styles.ChartStyles;

[Bindable] public var controller:MainController;
[Bindable] public var model:ProviderApplicationModel;
[Bindable] public var medicalRecordsController:MainController;

[Bindable] public var chartStyles:ChartStyles;

private function init():void
{
	controller = AppProperties.getInstance().controller as MainController;
	model = controller.model as ProviderApplicationModel;
	
	model.chartStyles = chartStyles = new ChartStyles();
}

private function onResize():void
{
	if( !this.stage ) return;
	
	FlexGlobals.topLevelApplication.height = this.stage.stageHeight;
}

private function toggleAvailability(event:MouseEvent):void
{
	var button:LinkButton = LinkButton(event.currentTarget);
	
	var user:UserModel = controller.model.user;
	
	user.available = user.available == UserModel.STATE_AVAILABLE ? UserModel.STATE_UNAVAILABLE : UserModel.STATE_AVAILABLE;
	
	button.setStyle('color',user.available == UserModel.STATE_AVAILABLE ? 0xCCCC33 : 0xB3B3B3 );
}

public function falsifyWidget(widget:String):void 
{
}
