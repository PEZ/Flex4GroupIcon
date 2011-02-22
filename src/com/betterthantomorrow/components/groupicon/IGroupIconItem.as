package com.betterthantomorrow.components.groupicon {
	import flash.display.Bitmap;
	
	import mx.controls.Image;

	public interface IGroupIconItem {
		function get avatarURL():String;
		function set bitmap(v:Bitmap):void;
		function get bitmap():Bitmap;
		function get isLoaded():Boolean;
	}
}