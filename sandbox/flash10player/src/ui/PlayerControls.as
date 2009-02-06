package ui {	import flash.display.Bitmap;	import flash.display.Sprite;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.geom.Rectangle;	import flash.utils.Timer;    	/**     * @author bram     */    public class PlayerControls extends Sprite implements IButtonObserver    {    	private var _observers : Vector.<IPlayerControlsObserver>;        private var _hidingSprite : Sprite;                [Embed(source='../../media/icon_background.png')]        private var BackgroundImage : Class;                [Embed(source='../../media/play_pause_icon.png')]        private var PlayButtonImage : Class;        private var _playButton : ImageButton;        [Embed(source='../../media/stop_icon.png')]        private var StopButtonImage : Class;        private var _stopButton : ImageButton;        [Embed(source='../../media/waveform_spectral_icon.png')]        private var SpectralButtonImage : Class;        private var _spectralButton : ImageButton;        [Embed(source='../../media/loop_icon.png')]        private var LoopButtonImage : Class;        private var _loopButton : ImageButton;                [Embed(source='../../media/measure_icon.png')]        private var MeasureButtonImage : Class;        private var _measureButton : ImageButton;        private var _maxHeight:int = 0;        private var _maxWidth:int = 0;        private var _targetAlpha:Number;        private var _attack:Number;        private var _release:Number;        public function PlayerControls()        {        	_observers = new Vector.<IPlayerControlsObserver>();            _hidingSprite = new Sprite();        	_hidingSprite.alpha = 0;            _targetAlpha = 0.0;            _attack = 0.7;            _release = 0.98;            addChild(_hidingSprite);                        _playButton = new ImageButton(new PlayButtonImage(), 6, true);            _playButton.addButtonObserver(this);            _playButton.x = 0;            _playButton.y = 0;            addChild(_playButton);                        var padding:int = 2;            			var background:Bitmap = new BackgroundImage();			background.x = -100;            _hidingSprite.addChild(background);            _stopButton = new ImageButton(new StopButtonImage(), 4, false);            _stopButton.addButtonObserver(this);            _stopButton.x = _playButton.x + _playButton.getSize().width + padding;            _stopButton.y = 0;            _hidingSprite.addChild(_stopButton);            _spectralButton = new ImageButton(new SpectralButtonImage(), 6, true);            _spectralButton.addButtonObserver(this);            _spectralButton.x = _stopButton.x + _stopButton.getSize().width + padding;            _spectralButton.y = 0;            _hidingSprite.addChild(_spectralButton);            _loopButton = new ImageButton(new LoopButtonImage(), 4, true);            _loopButton.addButtonObserver(this);            _loopButton.x = _spectralButton.x + _spectralButton.getSize().width + padding;            _loopButton.y = 0;            _hidingSprite.addChild(_loopButton);                        _measureButton = new ImageButton(new MeasureButtonImage(), 4, true);            _measureButton.addButtonObserver(this);            _measureButton.x = _loopButton.x + _loopButton.getSize().width + padding;            _measureButton.y = 0;            _hidingSprite.addChild(_measureButton);            _maxHeight = Math.max(_playButton.getSize().height, _loopButton.getSize().height, _spectralButton.getSize().height, _stopButton.getSize().height);            _maxWidth = _measureButton.x + _measureButton.getSize().width + 10;            var timer:Timer = new Timer(20);            timer.addEventListener(TimerEvent.TIMER, function (e:TimerEvent) : void {            	if (Math.abs(_targetAlpha - _hidingSprite.alpha) < 0.01) return;            	            	if (_targetAlpha >= alpha) // show            		_hidingSprite.alpha = _hidingSprite.alpha*_attack + _targetAlpha*(1.0 - _attack);            	else            		_hidingSprite.alpha = _hidingSprite.alpha*_release + _targetAlpha*(1.0 - _release);            });            timer.start();            addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent) : void { _targetAlpha = 1.0; });            addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent) : void { _targetAlpha = 0.0; });        }        public function setPlayButtonState(playing:Boolean) : void        {            _playButton.setState(playing);        }        public function addPlayerControlsObserver(observer:IPlayerControlsObserver):void        {        	_observers.push(observer);        }                public function getMaxHeight():int        {        	return _maxHeight;        }                public function getMaxWidth():int        {			return _maxWidth;        }                public function onButtonDown(button : IButton) : void        {        	for each (var observer:IPlayerControlsObserver in _observers)        	{	            switch (button)	            {	                case _playButton: observer.playClicked(this); break;	                case _stopButton: observer.stopClicked(this); break;	                case _spectralButton: observer.spectralClicked(this); break;			        case _loopButton: observer.loopOnClicked(this); break;                    case _measureButton: observer.measureOnClicked(this); break;	            }        	}        }                public function onButtonUp(button:IButton):void        {        	for each (var observer:IPlayerControlsObserver in _observers)        	{	            switch (button)	            {	                case _playButton: observer.pauseClicked(this); break;	                case _spectralButton: observer.waveformClicked(this); break;			        case _loopButton: observer.loopOffClicked(this); break;                    case _measureButton: observer.measureOffClicked(this); break;	            }        	}        }    }}