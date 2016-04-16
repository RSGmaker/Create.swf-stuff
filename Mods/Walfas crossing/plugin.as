//The .swf must be compiled as actionscript 1 or 2, to be compatible with create.swf.
//This plugin only works on create.swf extended.

//Walfas crossing by RSGmaker
//The container for all objects on the create.swf stage.
var theStage = _root.stage;

//The container of the stage and background, used to pan and scale for camera controls.
/*var camera = _root.STG;
	
	var theBackground = _root.bg;*/

var spawntimer = 0;

var points = 0;

//if false, then we've gotten a game over.
var running = true;

//the interval between bounces(the stepping animation).
var maxbounce = 8;

//list of all character presets.
var presets = new Array();

//speeds up the gameplay.
var spdmult = 1.2;

//current number of lives.
var power = 4;

var off=100;

//score text bubble
var bubble;

var lives = new Array();

var XM = 0;
var YM = 0;

var direction = (random(100)>50);

var Data = new Object();
if (theStage)
{
	_root.GameData.Menus.Functions.Clear(_root,"Characters");
	_root.GameData.Menus.Functions.Clear(_root,"Clusters");
	_root.GameData.Menus.Functions.Clear(_root,"Objects");
	_root.GameData.Menus.Functions.Clear(_root,"Bubbles");
	_root.GameData.Menus.Functions.Clear(_root,"Rain");
	//_root.GameData.Menus.Functions.Clear(_root,"Screenshots");
	_root.Interface._visible = false;

	//rebuild the array so we can expose the names.
	for (var id:String in _root.GameData.Presets) 
	{
		presets.push(id);
	}
	
	//make our lives.
	_root.makeObject(52);
	var power = theStage["Object"+(_root.GameData.ObjID-1)];
	power._x = 20;
	power._y = 30;
	lives.push(power);
	
	_root.makeObject(52);
	power = theStage["Object"+(_root.GameData.ObjID-1)];
	power._x = 100;
	power._y = 30;
	lives.push(power);
	
	_root.makeObject(52);
	power = theStage["Object"+(_root.GameData.ObjID-1)];
	power._x = 180;
	power._y = 30;
	lives.push(power);
	
	_root.makeObject(52);
	power = theStage["Object"+(_root.GameData.ObjID-1)];
	power._x = 260;
	power._y = 30;
	lives.push(power);
	
	//make score text bubble.
	_root.makeSpeechBubble(3);
	bubble = theStage["Bubble"+(_root.GameData.BubbleID-1)];
	bubble._x = 400;
	bubble._y = 120;
	bubble.D.text = "Score:0";
	
	//adjust the bubble itself to fit the text better.
	bubble.Bubble._yscale = 20;
	bubble.Bubble._xscale = 70;
	bubble.Bubble._y -= 70;
}

//searches for power objects(lives).
function removelife(){
	var ok = false;
	for (Name in theStage) {
		var object = theStage[Name];
		if (_root.GameData.Objects[Name])
		{
			if (object._currentframe==53 && validlife(object)>=0)
			{
				if (!ok)
				{
					_root.Delete(object);
					ok = true;
				}
			}
		}
	}
	if (ok)
	{
		_root.playSound("Graze");
	}
}

//Can be used to see if a powerup item was cheated in.
function validlife(object)
{
	var i = 0;
	while (i < lives.length)
	{
		if (lives[i] == object)
		{
			return i;
		}
		i++;
	}
	return -1;
}



onEnterFrame = function () {
	
	//make sure TheStage exists, if it's not, then we're not loaded into create.swf extended, also check if the interface is visible, if it is then don't run this way we get a pause functionality.
	if (theStage && !_root.Interface._visible)
	{
		update();
	}
	else if (!running)
	{
		//if a game over has occured, delete this plugin, and show a final message.
		
		//find the last screenshot, as it is likely our plugin.
		var N = "";
		for (Name in theStage) {
			if (_root.GameData.Screenshots[Name])
			{
				N = Name;
			}
		}
		_root.Sys("Game Over! Score:"+points,"Death");
		_root.Delete(theStage[N]);
		
	}
	else
	{
		//create.swf was not detected
	}
	
};

function update(){
	bubble.D.text = "Score:"+points;
	XM = theStage._xmouse;
	YM = theStage._ymouse;
	//the maximum speed for the spawn timer multiplier.
	var st = 10;
	if (spdmult<st)
	{
		st = spdmult;
	}
	spawntimer-=st;
	SpinText.text = ""+spawntimer;
	//character spawner.
	if (spawntimer <= 0 && running)
	{
		var char = presets[Math.floor(random(presets.length))];
		_root.makeChar(char);
		var N = "Char"+(_root.GameData.CharID-1);
		var C = theStage[N];
		
		Data[N] = new Object();
		//characters get a speed boost once frightened(mouse drawing near).
		Data[N].boost = false;
		//scales the character's scale and speed to scale with the size of the window(550 is the default width of the window).
		Data[N].spd = Stage.width / 550;
		Data[N].ospd = Data[N].spd;
		//bounce speed
		Data[N].bspd = Data[N].spd * 1.5;
		Data[N].bounce = random(maxbounce);
		Data[N].char = char;
		//sets the scale.
		C._xscale = Data[N].spd * 20;
		C._yscale = C._xscale;
		
		Data[N].spd *= spdmult;
		if (direction)
		{
			C._x = -off;
			Data[N].goal = 1;
		}
		else
		{
			C._x = Stage.width+off;
			Data[N].goal = -1;
			C.XFace *= -1;
			C._xscale *= -1;
		}
		C._y = (Stage.height*0.25)+random(Stage.height*0.70);
		
		spawntimer = 30 + random(15);
	}
	
	power = 0;
	//Iterate through all the objects on stage.
	for (Name in theStage) {
		//Stage objects are MovieClips, AS2 documention: http://help.adobe.com/en_US/as2/reference/flashlite/WS5b3ccc516d4fbf351e63e3d118cd9b5f6e-7898.html 
		var object = theStage[Name];
		
		if (_root.GameData.Objects[Name])
		{
			//this is one of our lives.(power item)
			if (object._currentframe==53)
			{
				if (validlife(object)>=0)
				{
					power++;
				}
			}
			//explosion
			if (object._currentframe==492)
			{
				updateExplosion(object);
			}
			//point item
			if (object._currentframe==52)
			{
				updatePoint(object);
			}
		}
		if (_root.GameData.Characters[Name])
		{
			updateCharacter(object);
		}
	}
	if (power <= 0)
	{
		if (running)
		{
			_root.Interface._visible = true;
		}
		running = false;
	}
	
};

function updatePoint(object){
	var spd = Math.abs(object._xscale)*0.5;
	var D = Data[Name];
	if (D.collectpause>0)
	{
		D.collectpause--;
	}
	else
	{
		
		
		var P = new flash.geom.Point(XM-object._x,YM-object._y);
		if (P.length<=spd)
		{
			object._x = XM;
			object._y = YM;
		}
		else
		{
			P.normalize(spd);
			object._x += P.x;
			object._y += P.y;
		}
		if (object._x == XM && object._y == YM)
		{
			_root.Delete(object);
			points++;
			spdmult *= 1.006;
			spdmult += 0.0015;
			//play point collect sound
			_root.GameData.Sounds["ItemGet"].setVolume(50);
			_root.playSound("ItemGet");
		}
		//
	}
};

function updateExplosion(object){
	object._xscale += 15;
	object._yscale = object._xscale;
	if (object._xscale>70)
	{
		var Pause = 8;
		//spawns a point item.
		_root.makeObject(51);
		var N = "Object"+(_root.GameData.ObjID-1);
		var point = theStage[N];
		point._xscale = (Stage.width / 550) * 20;
		point._yscale = point._xscale;
		point._x = object._x;
		point._y = object._y;
		_root.SendToBack(point);
		Data[N] = new Object();
		Data[N].collectpause = Pause;
		
		//spawns 3 point items
		/*_root.makeObject(51);
		var N = "Object"+(_root.GameData.ObjID-1);
		var point = theStage[N];
		point._xscale = (Stage.width / 550) * 23;
		point._yscale = point._xscale;
		point._x = object._x-50;
		point._y = object._y-25;
		Data[N] = new Object();
		Data[N].collectpause = Pause;
						
						
		_root.makeObject(51);
		var N = "Object"+(_root.GameData.ObjID-1);
		var point = theStage[N];
		point._xscale = (Stage.width / 550) * 23;
		point._yscale = point._xscale;
		point._x = object._x+50;
		point._y = object._y-25;
		Data[N] = new Object();
		Data[N].collectpause = Pause;
					
						
		_root.makeObject(51);
		var N = "Object"+(_root.GameData.ObjID-1);
		var point = theStage[N];
		point._xscale = (Stage.width / 550) * 23;
		point._yscale = point._xscale;
		point._x = object._x;
		point._y = object._y+25;
		Data[N] = new Object();
		Data[N].collectpause = Pause;*/
		
		
		_root.Delete(object);
	}
};

function updateCharacter(object){
	var D = Data[Name];
	/*if (!running)
	{
		//victory facial expression.
		_root.RootPartSwap(object.eyes,"Eyes","95");
		_root.RootPartSwap(object.mouth,"Mouth","7");
	}*/
	if (!D)
	{
		//delete any invalid characters.
		_root.Delete(object);
	}
	else if (running && D)
	{
		object._x += object.XFace * D.spd;
		var scl = 1.5 * Math.abs(object._xscale);
		var X = Math.abs(object._x - XM);
		var Y = Math.abs(object._y - YM);
		//if mouse is near, and character is still calm.
		if (!D.boost && X<(scl) && Y<(scl))
		{
			//activate panic.
			D.boost = true;
			D.spd *= 1.4;
			
			//panic facial expression.
			_root.RootPartSwap(object.eyes,"Eyes","3");
			_root.RootPartSwap(object.mouth,"Mouth","9");
			
			//gives a small chance to turn around when panicing.(turned around enemies can't take away lives when they escape)
			if (random(100)<30)
			{
				object._xscale *= -1;
				object.XFace *= -1;
			}
		}
		
		//Makes the character bounce as it moves
		D.bounce--;
		if (D.bounce < 5)
		{
			if (D.bounce <= 0)
			{
				D.bounce = maxbounce;
			}
			else
			{
				if (D.bounce < 3)
				{
					object._y+=(D.bspd);
				}
				else
				{
					object._y-=(D.bspd);
				}
			}
		}
		if ((object.XFace<0 && object._x<-off) || (object.XFace>0 && object._x>Stage.width+off))
		{
			//The character has gone out of bounds
			if ((D.goal>0 && object.XFace>0) || (D.goal<0 && object.XFace<0))
			{
				//The character has succeeded in crossing.
				removelife();
			}
			_root.Delete(object);
		}
		else if (_root.GameData.Target == object && X<(scl*3.0) && Y<(scl*3.0))
		{
			//the character has been selected, and the mouse is nearby, thus it is likely that the user has clicked on it.
			
			//make explosion
			_root.makeObject(491);
			var ex = theStage["Object"+(_root.GameData.ObjID-1)];
			ex._xscale = 15;
			ex._yscale = ex._xscale;
			ex._x = object._x;
			ex._y = object._y;
			_root.SendToBack(ex);
			_root.Delete(object);
		}
	}
};