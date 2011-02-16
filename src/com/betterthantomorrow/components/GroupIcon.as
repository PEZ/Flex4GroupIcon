package com.betterthantomorrow.components {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.BorderContainer;
	
	[Style(name="mainIconPercentSize", type="Number", inherit = "yes")]
	
	public class GroupIcon extends BorderContainer {
		private static const DEFAULT_MAIN_ICON_PERCENT_SIZE:Number = 45;
		
		private static const DEFAULT_MAX_AVATARS:Number = 9;

		public function GroupIcon() {
			super();
		}

		private static var classConstructed:Boolean = classConstruct();
		private static function classConstruct():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.betterthantomorrow.components.GroupIcon")) {
				var myStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				myStyles.defaultFactory = function():void {
					this.mainIconPercentSize = DEFAULT_MAIN_ICON_PERCENT_SIZE;
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.betterthantomorrow.components.GroupIcon", myStyles, true);
			}
			return true;
		}
		
		[Bindable] private var _mainIconURL:String = new String();
		private var _mainIcon:Image;
		[Bindable] private var _avatarItems:ArrayCollection;
		private var _avatarSize:Number;
		private var _avatarSizeBleed:Number;
		private var _mainIconSize:Number;
		private var _oldWidth:Number;
		
		public function set mainIconURL(v:String):void {
			if (_mainIconURL != v) {
				_mainIconURL = v;
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
					function oc(e:Event):void {
						loader.removeEventListener(Event.COMPLETE, oc);
						var li:LoaderInfo = e.currentTarget as LoaderInfo;
						_mainIcon = new Image();
						_mainIcon.smoothBitmapContent = true;
						_mainIcon.source = li.content;
						_mainIcon.width = li.content.width;
						_mainIcon.height = li.content.height;
						updateSizes(0);
						var resultImage:Image = createResultImage();
						addMainIcon(resultImage);
						removeAllElements();
						addElement(resultImage);
					});
				loader.load(new URLRequest(_mainIconURL));
			}
		}

		public function set avatars(v:ArrayCollection):void {
			if (_avatarItems != v) {
				_avatarItems = v;
				_avatarItems.addEventListener(CollectionEvent.COLLECTION_CHANGE,
					function avatarsUpdated(event:CollectionEvent):void {
						var c:ArrayCollection = event.currentTarget as ArrayCollection;
						if (event.kind != CollectionEventKind.RESET) {
							loadAvatars();
						}
					});
				loadAvatars();
			}
		}
		
		private function createResultImage():Image {
			var resultImage:Image = new Image();
			resultImage.width = width;
			resultImage.height = height;
			resultImage.x = -_borderWeight - _avatarSizeBleed / 2;
			resultImage.y = -_borderWeight - _avatarSizeBleed / 2;
			return resultImage;
		}
		
		override public function set width(v:Number):void {
			if (v != _oldWidth) {
				_oldWidth = width;
				super.width = v;
				super.height = v;
			}
		}
		
		private function get _borderWeight():Number {
			return getStyle("borderVisible") && !isNaN(getStyle("borderWeight")) ? getStyle("borderWeight") : 0;
		}

		private function get _cornerRadius():Number {
			return !isNaN(getStyle("cornerRadius")) ? getStyle("cornerRadius") : 0;
		}

		private function createMask():UIComponent {
			var maskShape:UIComponent = new UIComponent();
			maskShape.graphics.beginFill(0xff0000);
			maskShape.graphics.drawRoundRect(-0.5, -0.5,
				width - _borderWeight * 2 + 1, height - _borderWeight * 2 + 1,
				_cornerRadius * 2);
			maskShape.graphics.endFill();
			maskShape.visible = false;
			return maskShape;
		}

		private function loadAvatars():void {
			updateSizes(_avatarItems.length);
			var avatars:Dictionary = new Dictionary();
			var numAvatars:Number = 0;
			for each (var avatarItem:IGroupIconItem in _avatarItems) {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
					function oc(e:Event):void {
						loader.removeEventListener(Event.COMPLETE, oc);
						var li:LoaderInfo = e.currentTarget as LoaderInfo;
						if (!(li.url in avatars) && numAvatars++ < DEFAULT_MAX_AVATARS) {
							var avatar:Bitmap = li.content as Bitmap;
							avatar.smoothing = true;
							var cropping:Point = squareCropCoords(avatar, _avatarSize);
							var avatarImage:Image = new Image();
							avatarImage.addChild(crop(cropping.x, cropping.y, _avatarSize, _avatarSize, avatar));
							avatars[li.url] = avatarImage;
							var resultImage:Image = createResultImage();
							addAvatars(avatars, resultImage);
							addMainIcon(resultImage);
							removeAllElements();
							addElement(resultImage);
							var resultMask:UIComponent = createMask();
							addElement(resultMask);
							resultImage.mask = resultMask;
						}
					});
				loader.load(new URLRequest(avatarItem.avatarURL));
			}
		}
		
		private function updateSizes(numAvatars:int):void {
			var w:Number = width;
			if (_mainIcon != null) {
				_mainIconSize = w * getStyle("mainIconPercentSize") / 100;
			}
			if (numAvatars > 0) {
				if (_avatarItems.length < 3) {
					_avatarSize = Math.ceil(w / numAvatars);
					_avatarSizeBleed = _avatarSize * numAvatars - width;
				}
				else if (numAvatars < 9) {
					_avatarSize = Math.ceil(w / 2);
					_avatarSizeBleed = _avatarSize * 2 - width;
				}
				else {
					_avatarSize = Math.ceil(w / 3);
					_avatarSizeBleed = _avatarSize * 3 - width;
				}
			}
		}

		private function crop(_x:Number, _y:Number, _width:Number, _height:Number, bm:Bitmap):Bitmap {
			var cropArea:Rectangle = new Rectangle(0, 0, _width, _height);
			var croppedBitmap:Bitmap = new Bitmap(new BitmapData( _width, _height ), PixelSnapping.ALWAYS, true);
			var scaling:Point = scaleRatios(bm, _width);
			var m:Matrix = new Matrix(scaling.x, 0, 0, scaling.y, _x, _y);
			croppedBitmap.bitmapData.draw(bm, m, null, null, cropArea, true);
			return croppedBitmap;
		}

		private function squareCropCoords(bm:Bitmap, size:Number):Point {
			var cropX:Number = 0;
			var cropY:Number = 0;
			var ratio:Number = bm.height / bm.width;
			if (bm.width > bm.height) {
				cropX = -(size / bm.height) * (bm.width - bm.height) / 2;
			}

			return new Point(cropX, cropY);
		}
		
		private function scaleRatios(bm:Bitmap, size:Number):Point {
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

		private function addAvatars(avatars:Dictionary, resultImage:Image):void {
			for each (var avatar:Image in avatars) {
				resultImage.addChild(avatar);
			}
			placeAvatars(avatars);
		}

		private function addMainIcon(resultImage:Image):void {
			if (_mainIcon != null) {
				resultImage.addChild(_mainIcon);
			}
			placeMainIcon();
		}
		
		private function placeAvatars(avatars:Dictionary):void {
			var _avatars:Array = new Array();
			for each (var a:Image in avatars) {
				_avatars.push(a);
			}
			if (_avatars != null && _avatars.length > 0) {
				var i:int;
				if (_avatars.length == 1) {
					_avatars[0].x = (width - _avatars[0].width) / 2;
					_avatars[0].y = (height - _avatars[0].height) / 2;
				}
				if (_avatars.length == 2) {
					_avatars[0].x = _avatarSize;
					_avatars[1].y = _avatarSize;
				}
				else if (_avatars.length == 3) {
					_avatars[1].x = _avatarSize;
					_avatars[2].x = _avatars[2].y = _avatarSize;
				}
				else if (_avatars.length < 9) {
					for (i = 0; i < 4 && i < _avatars.length; i++) {
						_avatars[i].x = (i % 2) * _avatarSize;
						_avatars[i].y = Math.floor(i / 2) * _avatarSize;
					}
				}
				else {
					for (i = 0; i < DEFAULT_MAX_AVATARS && i < _avatars.length; i++) {
						_avatars[i].x = (i % 3) * _avatarSize;
						_avatars[i].y = Math.floor(i / 3) * _avatarSize;
					}
				}
			}
		}
		
		private function placeMainIcon():void {
			if (_mainIcon != null) {
				//var ratio = _mainIcon.width / _mainIcon.height;
				_mainIcon.width = _mainIconSize;
				_mainIcon.height = _mainIconSize;
				_mainIcon.x = (width - _mainIconSize) / 2;
				_mainIcon.y = (height - _mainIconSize) / 2;
			}
		}
	}
}