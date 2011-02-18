package com.betterthantomorrow.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class AvatarUtils {
		public function AvatarUtils() {
		}
		
		public static function crop(_x:Number, _y:Number, _width:Number, _height:Number, bm:Bitmap):Bitmap {
			var cropArea:Rectangle = new Rectangle(0, 0, _width, _height);
			var croppedBitmap:Bitmap = new Bitmap(new BitmapData( _width, _height ), PixelSnapping.ALWAYS, true);
			var scaling:Point = scaleRatios(bm, _width);
			var m:Matrix = new Matrix(scaling.x, 0, 0, scaling.y, _x, _y);
			croppedBitmap.bitmapData.draw(bm, m, null, null, cropArea, true);
			return croppedBitmap;
		}
		
		public static function squareCrop(bm:Bitmap, size:Number):Bitmap {
			var cropping:Point = squareCropCoords(bm, size);
			return crop(cropping.x, cropping.y, size, size, bm);
		}

		private static function squareCropCoords(bm:Bitmap, size:Number):Point {
			var cropX:Number = 0;
			var cropY:Number = 0;
			var ratio:Number = bm.height / bm.width;
			if (bm.width > bm.height) {
				cropX = -(size / bm.height) * (bm.width - bm.height) / 2;
			}
			
			return new Point(cropX, cropY);
		}
		
		private static function scaleRatios(bm:Bitmap, size:Number):Point {
			var ratio:Number = bm.height / bm.width;
			var xScale:Number;
			var yScale:Number;
			if (bm.width > bm.height) {
				xScale = size / bm.width / ratio; 
				yScale = size / bm.height;
			}
			else {
				xScale = size / bm.width;
				yScale = ratio * size / bm.height; 
			}
			return new Point(xScale, yScale);
		}
	}
}