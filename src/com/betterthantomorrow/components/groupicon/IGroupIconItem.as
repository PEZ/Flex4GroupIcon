package com.betterthantomorrow.components.groupicon {
	import flash.display.Bitmap;
	
	import mx.controls.Image;

	public interface IGroupIconItem {
		function get url():String;

		function set bitmap(v:Bitmap):void;
		function get bitmap():Bitmap;

		function get isLoaded():Boolean;

		function get isRequested():Boolean;
		function set isRequested(v:Boolean):void;
	}
}