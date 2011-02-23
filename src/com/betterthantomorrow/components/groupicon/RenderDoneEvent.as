package com.betterthantomorrow.components.groupicon {
	import flash.events.Event;
	
	public class RenderDoneEvent extends Event {
		public static const RENDER_DONE:String = "renderDone";

		public function RenderDoneEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}