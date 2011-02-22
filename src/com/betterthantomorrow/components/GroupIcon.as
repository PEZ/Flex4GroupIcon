package com.betterthantomorrow.components {
	import com.betterthantomorrow.components.groupicon.Avatar;
	import com.betterthantomorrow.utils.AvatarUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
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
	import mx.graphics.ImageSnapshot;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.BorderContainer;
	
	[Style(name="mainIconPercentSize", type="Number", inherit="yes")]
	[Style(name="showGridlines", type="Boolean", inherit="yes")]
	[Style(name="gridlinesWeight", type="Number", format="Length", inherit="yes")]
	[Style(name="gridlinesPercentWeight", type="Number", inherit="yes")]
	[Style(name="gridlinesColor", type="Number", format="Color", inherit="yes")]
	[Style(name="gridlinesAlpha", type="Number", inherit="yes")]
	[Style(name="showMainIconBorder", type="Boolean", inherit="yes")]
	[Style(name="mainIconBorderWeight", type="Number", format="Length", inherit="yes")]
	[Style(name="mainIconBorderPrecentWeight", type="Number", inherit="yes")]
	[Style(name="mainIconBorderColor", type="Number", format="Color", inherit="yes")]
	[Style(name="mainIconBorderAlpha", type="Number", inherit="yes")]
	[Style(name="mainIconBackgroundColor", type="Number", format="Color", inherit="yes")]
	[Style(name="mainIconBackgroundAlpha", type="Number", inherit="yes")]
	
	public class GroupIcon extends BorderContainer {
		
		private static const DEFAULT_MAX_AVATARS:Number = 100;

		private static const DEFAULT_SHOW_GRIDLINES:Boolean = false;
		private static const DEFAULT_GRIDLINES_WEIGHT:Number = 2;
		private static const DEFAULT_GRIDLINES_PERCENT_WEIGHT:Number = 0;
		private static const DEFAULT_GRIDLINES_COLOR:Number = 0x7f7f7f;
		private static const DEFAULT_GRIDLINES_ALPHA:Number = 1.0;

		private static const DEFAULT_SHOW_MAIN_ICON_BORDER:Boolean = false;
		private static const DEFAULT_MAIN_ICON_PERCENT_SIZE:Number = 40;
		private static const DEFAULT_MAIN_ICON_BORDER_WEIGHT:Number = 2;
		private static const DEFAULT_MAIN_ICON_BORDER_PERCENT_WEIGHT:Number = 0;
		private static const DEFAULT_MAIN_ICON_BORDER_COLOR:Number = 0x7f7f7f;
		private static const DEFAULT_MAIN_ICON_BORDER_ALPHA:Number = 1.0;
		private static const DEFAULT_MAIN_ICON_BACKGROUND_COLOR:Number = 0xffffff;
		private static const DEFAULT_MAIN_ICON_BACKGROUND_ALPHA:Number = 1.0;

		public function GroupIcon() {
			super();
		}

		private static var classConstructed:Boolean = classConstruct();
		private static function classConstruct():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.betterthantomorrow.components.GroupIcon")) {
				var myStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				myStyles.defaultFactory = function():void {
					this.mainIconPercentSize = DEFAULT_MAIN_ICON_PERCENT_SIZE;
					this.showGridlines = DEFAULT_SHOW_GRIDLINES;
					this.gridlinesWeight = DEFAULT_GRIDLINES_WEIGHT;
					this.gridlinesPercentWeight = DEFAULT_GRIDLINES_PERCENT_WEIGHT;
					this.gridlinesColor = DEFAULT_GRIDLINES_COLOR;
					this.gridlinesAlpha = DEFAULT_GRIDLINES_ALPHA;
					this.showMainIconBorder = DEFAULT_SHOW_MAIN_ICON_BORDER;
					this.mainIconBorderWeight = DEFAULT_MAIN_ICON_BORDER_WEIGHT;
					this.mainIconBorderPercentWeight = DEFAULT_MAIN_ICON_BORDER_PERCENT_WEIGHT;
					this.mainIconBorderColor = DEFAULT_MAIN_ICON_BORDER_COLOR;
					this.mainIconBorderAlpha = DEFAULT_MAIN_ICON_BORDER_ALPHA;
					this.mainIconBackgroundColor = DEFAULT_MAIN_ICON_BACKGROUND_COLOR;
					this.mainIconBackgroundAlpha = DEFAULT_MAIN_ICON_BACKGROUND_ALPHA;
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.betterthantomorrow.components.GroupIcon", myStyles, true);
			}
			return true;
		}
		
		[Bindable] private var _mainIconURL:String = new String();
		private var _mainIcon:Image;
		[Bindable] private var _avatarItems:ArrayCollection;
		private static var _loadedAvatars:Dictionary = new Dictionary();
		private var _croppedAvatars:Dictionary;
		private var _resultImage:Image;
		private var _resultMask:UIComponent;
		private var _avatarSize:Number;
		private var _maxAvatars:uint = DEFAULT_MAX_AVATARS;
		private var _avatarSizeBleed:Number;
		private var _mainIconSize:Number;
		private var _mainIconComponent:UIComponent;
		private var _oldWidth:Number;
		
		public function set mainIconURL(v:String):void {
			if (_mainIconURL != v) {
				_mainIconURL = v;
				prepareFullRedraw();
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
						fullRedraw();
					});
				loader.load(new URLRequest(_mainIconURL));
			}
		}

		private function loadAvatar(avatar:Avatar):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function oc(e:Event):void {
					loader.removeEventListener(Event.COMPLETE, oc);
					var li:LoaderInfo = e.currentTarget as LoaderInfo;
					avatar.bitmap = li.content as Bitmap;
					fullRedraw();
				});
			loader.load(new URLRequest(avatar.url));
		}

		private function loadAvatars():void {
			prepareFullRedraw();
			for each (var avatarItem:Object in _avatarItems) {
				if (!(avatarItem.avatarURL in _loadedAvatars)) {
					_loadedAvatars[avatarItem.avatarURL] = new Avatar(avatarItem.avatarURL);
					if (avatarItem.isLoaded) {
						_loadedAvatars[avatarItem.avatarURL].bitmap = avatarItem.bitmap;
					}
					else {
						loadAvatar(_loadedAvatars[avatarItem.avatarURL]);
					}
				}
				if (!_loadedAvatars[avatarItem.avatarURL].isLoaded) {
					_loadedAvatars[avatarItem.avatarURL].addEventListener(Event.COMPLETE,
						function ec(e:Event):void {
							_loadedAvatars[avatarItem.avatarURL].removeEventListener(Event.COMPLETE, ec);
							fullRedraw();
						});
				}
			}
			fullRedraw();
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
		
		private function prepareFullRedraw():void {
			measure();
			_mainIconComponent = new UIComponent();
			_croppedAvatars = new Dictionary();
			_resultImage = createResultImage();
			_resultMask = createMask();
			_resultImage.mask = _resultMask;
		}

		private function fullRedraw():void {
			includeInLayout = false;
			measure();
			var numLoaded:int = 0;
			for each (var item:Object in _avatarItems) {
				if (item.avatarURL in _loadedAvatars && _loadedAvatars[item.avatarURL].isLoaded) {
					numLoaded++;
					if (!(item.avatarURL in _croppedAvatars)) {
						var avatarImage:Image = new Image();
						avatarImage.addChild(AvatarUtils.squareCrop(_loadedAvatars[item.avatarURL].bitmap, _avatarSize));
						_croppedAvatars[item.avatarURL] = avatarImage;	
						_resultImage.addChild(avatarImage);
					}
				}
			}
			if (numLoaded > 0) {
				placeAvatars();
			}
			addMainIcon(_resultImage);
			removeAllElements();
			addElement(_resultImage);
			addElement(_resultMask);
		}

		public function set maxAvatars(v:uint):void {
			if (v != _maxAvatars) {
				_maxAvatars = v;
				prepareFullRedraw();
				fullRedraw();
			}
		}

		private function createResultImage():Image {
			var resultImage:Image = new Image();
			resultImage.width = width + _avatarSizeBleed / 2;
			resultImage.height = height + _avatarSizeBleed / 2;
			resultImage.x = -_borderWeight - _avatarSizeBleed / 2;
			resultImage.y = -_borderWeight - _avatarSizeBleed / 2;
			return resultImage;
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

		override protected function measure():void {
			var w:Number = width;
			if (_mainIcon != null) {
				_mainIconSize = w * _mainIconPercentSize / 100;
			}
			if (_numAvatars > 0) {
				if (_numAvatars < 3) {
					_avatarSize = Math.ceil(w / _numAvatars);
					_avatarSizeBleed = _avatarSize * _numAvatars - width;
				}
				else {
					for each (var c:uint in [2, 3, 4, 5, 6, 7, 8, 9, 10]) {
						if (_numAvatars < Math.pow(c + 1, 2) || _maxAvatars < Math.pow(c + 1, 2)) {
							_avatarSize = Math.ceil(w / c);
							_avatarSizeBleed = _avatarSize * c - width;
							break;
						}
					}
				}
			}
		}

		override public function set width(v:Number):void {
			if (v != _oldWidth) {
				_oldWidth = width;
				super.width = v;
				super.height = v;
				prepareFullRedraw();
				fullRedraw();
			}
		}
		
		private function get _borderWeight():Number {
			return getStyle("borderVisible") && !isNaN(getStyle("borderWeight")) ?
				getStyle("borderWeight") : 0;
		}

		private function get _cornerRadius():Number {
			return !isNaN(getStyle("cornerRadius")) ?
				getStyle("cornerRadius") : 0;
		}

		private function get _mainIconPercentSize():Number {
			return !isNaN(getStyle("mainIconPercentSize")) ? getStyle("mainIconPercentSize") : DEFAULT_MAIN_ICON_PERCENT_SIZE;
		}

		private function get _showGridlines():Boolean {
			return getStyle("showGridlines");
		}
		
		private function get _gridlinesPercentWeight():Number {
			return _showGridlines && !isNaN(getStyle("gridlinesPercentWeight")) ?
				getStyle("gridlinesPercentWeight") : DEFAULT_GRIDLINES_PERCENT_WEIGHT;
		}

		private function get _gridlinesWeight():Number {
			if (_gridlinesPercentWeight > 0) {
				return _gridlinesPercentWeight * width / 100;
			}
			else {
				return _showGridlines && !isNaN(getStyle("gridlinesWeight")) ?
					getStyle("gridlinesWeight") : DEFAULT_GRIDLINES_WEIGHT;
			}
		}
		
		private function get _gridlinesColor():Number {
			return _showGridlines && !isNaN(getStyle("gridlinesColor")) ?
				getStyle("gridlinesColor") : DEFAULT_GRIDLINES_COLOR;
		}
		
		private function get _gridlinesAlpha():Number {
			return _showGridlines && !isNaN(getStyle("gridlinesAlpha")) ?
				getStyle("gridlinesAlpha") : DEFAULT_GRIDLINES_ALPHA;
		}

		private function get _showMainIconBorder():Boolean {
			return getStyle("showMainIconBorder");
		}
		
		private function get _mainIconBorderPercentWeight():Number {
			return _showMainIconBorder && !isNaN(getStyle("mainIconBorderPercentWeight")) ?
				getStyle("mainIconBorderPercentsWeight") : DEFAULT_GRIDLINES_PERCENT_WEIGHT;
		}
		
		private function get _mainIconBorderWeight():Number {
			if (_mainIconBorderPercentWeight > 0) {
				return _mainIconBorderPercentWeight * width / 100;
			}
			else {
				return _showMainIconBorder && !isNaN(getStyle("mainIconBorderWeight")) ?
					getStyle("mainIconBorderWeight") : DEFAULT_GRIDLINES_WEIGHT;
			}
		}
		
		private function get _mainIconBorderColor():Number {
			return _showMainIconBorder && !isNaN(getStyle("mainIconBorderColor")) ?
				getStyle("mainIconBorderColor") : DEFAULT_MAIN_ICON_BORDER_COLOR;
		}
		
		private function get _mainIconBorderAlpha():Number {
			return _showMainIconBorder && !isNaN(getStyle("mainIconBorderAlpha")) ?
				getStyle("mainIconBorderAlpha") : DEFAULT_MAIN_ICON_BORDER_ALPHA;
		}
		
		private function get _mainIconBackgroundColor():Number {
			return !isNaN(getStyle("mainIconBackgroundColor")) ?
				getStyle("mainIconBackgroundColor") : DEFAULT_MAIN_ICON_BACKGROUND_COLOR;
		}
		
		private function get _mainIconBackgroundAlpha():Number {
			return !isNaN(getStyle("mainIconBackgroundAlpha")) ?
				getStyle("mainIconBackgroundAlpha") : DEFAULT_MAIN_ICON_BACKGROUND_ALPHA;
		}

		private function get _numAvatars():uint {
			return _avatarItems != null ? _avatarItems.length : 0;
		}

		private function addMainIcon(resultImage:Image):void {
			if (_mainIcon != null) {
				if (resultImage.contains(_mainIconComponent)) {
					resultImage.removeChild(_mainIconComponent);
					resultImage.addChild(_mainIconComponent);
				}
				else {
					_mainIconComponent = new UIComponent();
					_mainIconComponent.width = _mainIconComponent.height = _mainIconSize;
					_mainIconComponent.x = _mainIconComponent.y = (width - _mainIconSize) / 2;
					if (_showMainIconBorder) {
						_mainIconComponent.graphics.lineStyle(_mainIconBorderWeight, _mainIconBorderColor, _mainIconBorderAlpha);
					}
					_mainIconComponent.graphics.beginFill(_mainIconBackgroundColor, _mainIconBackgroundAlpha);
					_mainIconComponent.graphics.drawCircle(_mainIconSize / 2, _mainIconSize / 2, _mainIconSize / 2);
					_mainIconComponent.graphics.endFill();
					var ratio:Number = _mainIconComponent.width / _mainIconComponent.height;
					_mainIcon.width = Math.sqrt(_mainIconSize * _mainIconSize / 2) - _mainIconBorderWeight * 2;
					_mainIcon.height = _mainIcon.width / ratio;
					_mainIconComponent.addChild(_mainIcon);
					_mainIcon.x = (_mainIconSize - _mainIcon.width) / 2;
					_mainIcon.y = (_mainIconSize - _mainIcon.height) / 2;
					resultImage.addChild(_mainIconComponent);
				}
			}
		}
		
		private function drawGridCross(grid:Image, _x:Number, _y:Number):void {
			grid.graphics.moveTo(_x, 0);
			grid.graphics.lineTo(_x, grid.height);
			grid.graphics.moveTo(0, _y);
			grid.graphics.lineTo(grid.width, _y);			
		}

		private function placeAvatars():void {
			var numAvatars:int = _numAvatars;
			var _avatars:Array = new Array();
			for each (var item:Object in _avatarItems) {
				if (item.avatarURL in _croppedAvatars) {
					_avatars.push(_croppedAvatars[item.avatarURL]);
				}
			}
			if (_avatars != null && _avatars.length > 1) {
				var grid:Image = new Image();
				grid.width = _resultImage.width;
				grid.height = _resultImage.height;
				grid.graphics.lineStyle(_gridlinesWeight, _gridlinesColor, _gridlinesAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				var i:int;
				if (_numAvatars == 2 && _avatars.length > 1) {
					_avatars[0].x = _avatarSize;
					_avatars[1].y = _avatarSize;
				}
				else {
					for each (var c:uint in [2, 3, 4, 5, 6, 7, 8, 9, 10]) {
						if (numAvatars < Math.pow(c + 1, 2) || _maxAvatars < Math.pow(c + 1, 2)) {
							for (i = 0; i < c * c && i < _avatars.length; i++) {
								_avatars[i].x = (i % c) * _avatarSize;
								_avatars[i].y = Math.floor(i / c) * _avatarSize;
							}
							if (_showGridlines) {
								for (var g:int = 1; g < c; g++) {
									drawGridCross(grid, _avatarSize * g, _avatarSize * g);
								}
							}
							break;
						}
					}
				}
				if (_showGridlines) {
					_resultImage.addChild(grid);
				}
			}
		}
	}
}