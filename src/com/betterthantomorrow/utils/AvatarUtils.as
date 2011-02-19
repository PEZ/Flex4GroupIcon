package com.betterthantomorrow.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class AvatarUtils {
		public function AvatarUtils() {
		}
		
		public static function crop(_x:Number, _y:Number, _width:Number, _height:Number, obj:DisplayObject):Bitmap {
			var cropArea:Rectangle = new Rectangle(0, 0, _width, _height);
			var croppedBitmap:Bitmap = new Bitmap(new BitmapData( _width, _height ), PixelSnapping.ALWAYS, true);
			var scaling:Point = scaleRatios(obj, _width);
			var m:Matrix = new Matrix(scaling.x, 0, 0, scaling.y, _x, _y);
			croppedBitmap.bitmapData.draw(obj, m, null, null, cropArea, true);
			return croppedBitmap;
		}
		
		public static function squareCrop(obj:DisplayObject, size:Number):Bitmap {
			var cropping:Point = squareCropCoords(obj, size);
			return crop(cropping.x, cropping.y, size, size, obj);
		}

		private static function squareCropCoords(obj:DisplayObject, size:Number):Point {
			var cropX:Number = 0;
			var cropY:Number = 0;
			var ratio:Number = obj.height / obj.width;
			if (obj.width > obj.height) {
				cropX = -(size / obj.height) * (obj.width - obj.height) / 2;
			}
			
			return new Point(cropX, cropY);
		}
		
		private static function scaleRatios(obj:DisplayObject, size:Number):Point {
			var ratio:Number = obj.height / obj.width;
			var xScale:Number;
			var yScale:Number;
			if (obj.width > obj.height) {
				xScale = size / obj.width / ratio; 
				yScale = size / obj.height;
			}
			else {
				xScale = size / obj.width;
				yScale = ratio * size / obj.height; 
			}
			return new Point(xScale, yScale);
		}
	}
}