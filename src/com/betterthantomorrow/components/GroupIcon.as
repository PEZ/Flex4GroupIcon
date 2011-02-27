package com.betterthantomorrow.components {
	import com.betterthantomorrow.components.groupicon.Avatar;
	import com.betterthantomorrow.components.groupicon.IGroupIconItem;
	import com.betterthantomorrow.components.groupicon.RenderDoneEvent;
	import com.betterthantomorrow.utils.AvatarUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
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
	
	[Style(name="borderPrecentWeight", type="Number", inherit="yes")]

	[Style(name="showGridlines", type="Boolean", inherit="yes")]
	[Style(name="gridlinesWeight", type="Number", format="Length", inherit="yes")]
	[Style(name="gridlinesPercentWeight", type="Number", inherit="yes")]
	[Style(name="gridlinesColor", type="Number", format="Color", inherit="yes")]
	[Style(name="gridlinesAlpha", type="Number", inherit="yes")]

	[Style(name="mainIconPercentSize", type="Number", inherit="yes")]
	[Style(name="showMainIconBorder", type="Boolean", inherit="yes")]
	[Style(name="mainIconBorderWeight", type="Number", format="Length", inherit="yes")]
	[Style(name="mainIconBorderPrecentWeight", type="Number", inherit="yes")]
	[Style(name="mainIconBorderColor", type="Number", format="Color", inherit="yes")]
	[Style(name="mainIconBorderAlpha", type="Number", inherit="yes")]
	[Style(name="mainIconBackgroundColor", type="Number", format="Color", inherit="yes")]
	[Style(name="mainIconBackgroundAlpha", type="Number", inherit="yes")]

	[Event(name="renderDone", type="com.betterthantomorrow.components.groupicon.RenderDoneEvent")]
	
	public class GroupIcon extends UIComponent {
		
		private static const DEFAULT_MAX_AVATARS:Number = 100;

		private static const DEFAULT_BORDER_VISIBLE:Boolean = false;
		private static const DEFAULT_BORDER_WEIGHT:Number = 1;
		private static const DEFAULT_BORDER_PERCENT_WEIGHT:Number = 0;
		private static const DEFAULT_BORDER_COLOR:Number = 0x7f7f7f;
		private static const DEFAULT_BORDER_ALPHA:Number = 1.0;
		private static const DEFAULT_CORNER_RADIUS:Number = 0;
		private static const DEFAULT_BACKGROUND_COLOR:Number = 0xffffff;
		private static const DEFAULT_BACKGROUND_ALPHA:Number = 1.0;

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

		[Bindable] private var _mainIconURL:String = new String();
		private var _mainIcon:Image;
		[Bindable] private var _avatarItems:ArrayCollection;
		private static var _requestedAvatars:Dictionary = new Dictionary();
		private var _croppedAvatars:Dictionary;
		private var _resultComponent:UIComponent;
		private var _borderShape:Shape;
		private var _resultMask:Shape;
		private var _avatarSize:Number;
		private var _maxAvatars:uint = DEFAULT_MAX_AVATARS;
		private var _avatarSizeBleed:Number;
		private var _mainIconSize:Number;
		private var _mainIconComponent:UIComponent;
		private var _oldWidth:Number;
		
		public function GroupIcon() {
			super();
		}

		private static var classConstructed:Boolean = classConstruct();
		private static function classConstruct():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.betterthantomorrow.components.GroupIcon")) {
				var myStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				myStyles.defaultFactory = function():void {
					this.borderVisible = DEFAULT_BORDER_VISIBLE;
					this.borderWeight = DEFAULT_BORDER_WEIGHT;
					this.borderPercentWeight = DEFAULT_BORDER_PERCENT_WEIGHT;
					this.borderColor = DEFAULT_BORDER_COLOR;
					this.borderAlpha = DEFAULT_BORDER_ALPHA;
					this.cornerRadius = DEFAULT_CORNER_RADIUS;
					this.backgroundColor = DEFAULT_BACKGROUND_COLOR;
					this.backgroundAlpha = DEFAULT_BACKGROUND_ALPHA;

					this.showGridlines = DEFAULT_SHOW_GRIDLINES;
					this.gridlinesWeight = DEFAULT_GRIDLINES_WEIGHT;
					this.gridlinesPercentWeight = DEFAULT_GRIDLINES_PERCENT_WEIGHT;
					this.gridlinesColor = DEFAULT_GRIDLINES_COLOR;
					this.gridlinesAlpha = DEFAULT_GRIDLINES_ALPHA;

					this.mainIconPercentSize = DEFAULT_MAIN_ICON_PERCENT_SIZE;
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

		private function _calculateBorderWeight(isVisible:Boolean, styleName:String,
												percentValue:Number, defaultValue:Number):Number {
			if (isVisible) {
				if (percentValue > 0) {
					return percentValue * width / 100;
				}
				else {
					return !isNaN(getStyle(styleName)) ?
						getStyle(styleName) : defaultValue;
				}
			}
			else {
				return 0;
			}
		}
		
		private function get _borderVisible():Boolean {
			return getStyle("borderVisible");
		}

		private function get _borderPercentWeight():Number {
			return _borderVisible && !isNaN(getStyle("borderPercentWeight")) ?
				getStyle("borderPercentsWeight") : DEFAULT_BORDER_PERCENT_WEIGHT;
		}
		
		private function get _borderWeight():Number {
			return _calculateBorderWeight(_borderVisible, "borderWeight", _borderPercentWeight, DEFAULT_BORDER_WEIGHT);
		}
		
		private function get _borderColor():Number {
			return !isNaN(getStyle("borderColor")) ?
				getStyle("borderColor") : DEFAULT_BORDER_COLOR;
		}
		
		private function get _borderAlpha():Number {
			return !isNaN(getStyle("borderAlpha")) ?
				getStyle("borderAlpha") : DEFAULT_BORDER_ALPHA;
		}
		
		private function get _backgroundColor():Number {
			return !isNaN(getStyle("backgroundColor")) ?
				getStyle("backgroundColor") : DEFAULT_BACKGROUND_COLOR;
		}
		
		private function get _backgroundAlpha():Number {
			return !isNaN(getStyle("backgroundAlpha")) ?
				getStyle("backgroundAlpha") : DEFAULT_BACKGROUND_ALPHA;
		}
		
		private function get _cornerRadius():Number {
			return !isNaN(getStyle("cornerRadius")) ?
				getStyle("cornerRadius") : DEFAULT_CORNER_RADIUS;
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
			return _calculateBorderWeight(_showGridlines, "gridlinesWeight", _gridlinesPercentWeight, DEFAULT_GRIDLINES_WEIGHT);
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
				getStyle("mainIconBorderPercentsWeight") : DEFAULT_MAIN_ICON_BORDER_PERCENT_WEIGHT;
		}
		
		private function get _mainIconBorderWeight():Number {
			return _calculateBorderWeight(_showMainIconBorder, "mainIconBorderWeight",
				_mainIconBorderPercentWeight, DEFAULT_MAIN_ICON_BORDER_WEIGHT);
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

		override protected function createChildren():void {
			super.createChildren();
			_mainIconComponent = new UIComponent();
			_resultComponent = new UIComponent();
			_resultMask = new Shape();
			_borderShape = new Shape();
			addChild(_resultComponent);
			addChild(_resultMask);
			addChild(_borderShape);
			_resultComponent.mask = _resultMask;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			includeInLayout = false;

			measure();
			configureResultImage();
			configureResultMask();

			var numLoaded:int = 0;
			for each (var item:Object in _avatarItems) {
				if (item.url in _requestedAvatars && _requestedAvatars[item.url].isLoaded) {
					numLoaded++;
					if (!(item.url in _croppedAvatars)) {
						var avatarImage:Image = new Image();
						avatarImage.addChild(AvatarUtils.squareCrop(_requestedAvatars[item.url].bitmap, _avatarSize));
						_croppedAvatars[item.url] = avatarImage;	
						_resultComponent.addChild(avatarImage);
					}
				}
			}
			if (numLoaded > 0) {
				placeAvatars();
			}
			addMainIcon();
			if (_borderVisible) {
				_borderShape.graphics.lineStyle(_borderWeight, _borderColor, _borderAlpha);
				_borderShape.graphics.drawRoundRect(_borderWeight / 2, _borderWeight / 2,
					width - _borderWeight, height - _borderWeight,
					_cornerRadius * 2, _cornerRadius * 2);
			}
		}
		
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
						invalidateDisplayList();
					});
				loader.load(new URLRequest(_mainIconURL));
			}
		}

		private function loadAvatar(avatar:Object):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function oc(e:Event):void {
					loader.removeEventListener(Event.COMPLETE, oc);
					var li:LoaderInfo = e.currentTarget as LoaderInfo;
					avatar.bitmap = li.content as Bitmap;
					invalidateDisplayList();
				});
			loader.load(new URLRequest(avatar.url));
		}

		private function loadAvatars():void {
			prepareFullRedraw();
			var numRequestedActiveAvatars:uint = 0;
			for each (var avatarItem:Object in _avatarItems) {
				if (avatarItem.url in _requestedAvatars) {
					numRequestedActiveAvatars++;
				}
			}
			for each (avatarItem in _avatarItems) {
				if (!(avatarItem.url in _requestedAvatars)) {
					if (!avatarItem.isRequested && numRequestedActiveAvatars < _maxAvatars){
						avatarItem.isRequested = true;
						numRequestedActiveAvatars++;
						_requestedAvatars[avatarItem.url] = avatarItem;
						loadAvatar(avatarItem);
					}
				}
				if (avatarItem.isRequested && !avatarItem.isLoaded) {
					avatarItem.addEventListener(Event.COMPLETE,
						function ec(e:Event):void {
							avatarItem.removeEventListener(Event.COMPLETE, ec);
							invalidateDisplayList();
						});
				}
			}
			invalidateDisplayList();
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
		
		private function clearComponent(component:UIComponent):void {
			if (component != null) {
				for (var i:uint = component.numChildren; i > 0; i--) {
					component.removeChildAt(i - 1);
				}
			}			
		}

		private function prepareFullRedraw():void {
			clearComponent(_resultComponent);
			clearComponent(_mainIconComponent);

			_croppedAvatars = new Dictionary();
		}

		public function set maxAvatars(v:uint):void {
			if (v != _maxAvatars) {
				_maxAvatars = v;
				prepareFullRedraw();
				invalidateDisplayList();
			}
		}

		private function configureResultImage():void {
			_resultComponent.width = width + _avatarSizeBleed / 2;
			_resultComponent.height = height + _avatarSizeBleed / 2;
			_resultComponent.x = -_avatarSizeBleed / 2;
			_resultComponent.y = -_avatarSizeBleed / 2;
			_resultComponent.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			_resultComponent.graphics.drawRect(0, 0, width, height);
			_resultComponent.graphics.endFill();
		}

		private function configureResultMask():void {
			_resultMask.graphics.beginFill(0xff0000);
			_resultMask.graphics.drawRoundRect(_borderWeight / 2, _borderWeight / 2,
				width - _borderWeight, height - _borderWeight,
				_cornerRadius * 2);
			_resultMask.graphics.endFill();
			_resultMask.visible = false;
		}

		override public function styleChanged(styleProp:String):void {
			super.styleChanged(styleProp);
			
			invalidateDisplayList();
		}

		override protected function measure():void {
			if (_mainIcon != null) {
				_mainIconSize = width * _mainIconPercentSize / 100;
			}
			if (_numAvatars > 0) {
				if (_numAvatars < 4) {
					_avatarSize = Math.ceil(width / 2);
					_avatarSizeBleed = _avatarSize * 2 - width;
				}
				else {
					var c:uint = Math.floor(Math.sqrt(Math.min(_numAvatars, _maxAvatars)));
					_avatarSize = Math.ceil(width / c);
					_avatarSizeBleed = _avatarSize * c - width;
				}
			}
		}

		override public function set width(v:Number):void {
			if (v != _oldWidth) {
				_oldWidth = width;
				super.width = v;
				super.height = v;
				prepareFullRedraw();
				invalidateDisplayList();
			}
		}

		private function addMainIcon():void {
			if (_mainIcon != null) {
				if (_resultComponent.contains(_mainIconComponent)) {
					_resultComponent.removeChild(_mainIconComponent);
					_resultComponent.addChild(_mainIconComponent);
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
					_resultComponent.addChild(_mainIconComponent);
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
			var _avatars:Array = new Array();
			for each (var item:Object in _avatarItems) {
				if (item.url in _croppedAvatars) {
					_avatars.push(_croppedAvatars[item.url]);
				}
			}
			if (_avatars != null && _avatars.length > 1) {
				var grid:Image = new Image();
				grid.width = _resultComponent.width;
				grid.height = _resultComponent.height;
				grid.graphics.lineStyle(_gridlinesWeight, _gridlinesColor, _gridlinesAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				var i:int;
				if (_numAvatars == 2 && _avatars.length > 1) {
					_avatars[0].x = _avatarSize;
					_avatars[1].y = _avatarSize;
				}
				else if (_numAvatars == 3 && _avatars.length > 2) {
					_avatars[1].x = _avatarSize;					
					_avatars[2].y = _avatarSize;					
				}
				else {
					var c:uint = Math.floor(Math.sqrt(Math.min(_numAvatars, _maxAvatars)));
					for (i = 0; i < c * c && i < _avatars.length; i++) {
						_avatars[i].x = (i % c) * _avatarSize;
						_avatars[i].y = Math.floor(i / c) * _avatarSize;
					}
					if (_showGridlines) {
						for (var g:int = 1; g < c; g++) {
							drawGridCross(grid, _avatarSize * g, _avatarSize * g);
						}
					}
				}
				if (_showGridlines) {
					_resultComponent.addChild(grid);
				}
			}
		}
	}
}