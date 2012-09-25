import mx.controls.dataGridClasses.DataGridColumn;

private function lblPatientsAge(item:Object, column:DataGridColumn):String {
	var now:Date = new Date();
	var dob:Date = new Date(item.dob);
	
	var years:Number = now.getFullYear() - dob.getFullYear();
	if (dob.month > now.month || (dob.month == now.month && dob.date > now.date)) years--;
	
	return String(years);
}