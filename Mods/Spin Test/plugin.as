//The .swf must be compiled as actionscript 1 or 2, to be compatible with create.swf.
//This plugin only works on create.swf extended.

//Spin plugin test by RSGmaker


//There is no documentation on create.swf's code, if there's something you need to know you'll need to decompile it yourself to figure it out.
onEnterFrame = function () {
	//makes this object blink(it's a bit of debugging used to make sure script is still functioning)
	var debugBlink = true;
	if (debugBlink)
	{
		_alpha -= 2;
		if (_alpha<=0)
		{
			_alpha = 100;
		}
	}
	//The container for all objects on the create.swf stage.
	var theStage = _root.stage;
	
	//The container of the stage and background, used to pan and scale for camera controls.
	var camera = _root.STG;
	
	var theBackground = _root.bg;
	
	//make sure TheStage exists, if it's not, then we're not loaded into create.swf extended
	if (theStage)
	{
		//Iterate through all the objects on stage.
		for (Name in theStage) {
			//Stage objects are MovieClips, AS2 documention: http://help.adobe.com/en_US/as2/reference/flashlite/WS5b3ccc516d4fbf351e63e3d118cd9b5f6e-7898.html 
			var object = theStage[Name];
			
			//What type of object this is.("Character","Screenshot","Cluster","Rain","SpeechBubble","Object")
			var objectType = object.Type;
			
			//Spins the object.
			object._rotation += 5;
		}
		
		//Hide the plugin's graphic when the interface is hidden(aka theatre mode).
		_visible = _root.Interface._visible;
	}
	else
	{
		//rotate counter clockwise if create.swf was not detected.
		_rotation -= 2.5;
		
	}
	
};