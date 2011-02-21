package com.betterthantomorrow.components.groupicon {
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Avatar extends EventDispatcher {
		private var _url:String;
		private var _bitmap:Bitmap;
		private var _isLoaded:Boolean;

		public function Avatar(url:String) {
			_url = url;
		}

		public function get url():String {
			return _url;
		}

		public function get bitmap():Bitmap {
			return _bitmap;
		}

		public function set bitmap(v:Bitmap):void {
			_bitmap = v;
			_isLoaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get isLoaded():Boolean {
			return _isLoaded;
		}
	}
}