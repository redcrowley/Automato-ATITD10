-- potteryAuto.lua
-- by Rhaom - v1.0 added August 21, 2019

dofile("common.inc");
dofile("settings.inc");

-- times are in minutes.  They are converted to ms and daffy/teppy time is also adjusted later
jugTimer = 1;
mortarTimer = 1;
cookpotTimer = 1;
duckTeppyOffset = 10; -- How many extra seconds to add (to each real-life minute) to compensate for game time
timer = 0;   -- Just a default to prevent error
arrangeWindows = true;

askText = "Mould Jugs or Clay Mortars, without the mouse being used.\n\nPin up windows manually or select the arrange windows checkbox.";


function doit()
	askForWindow(askText);
	config();
		if(arrangeWindows) then
			arrangeInGrid(nil, nil, nil, nil,nil, 10, 40);
		end
	unpinOnExit(start);
end

function start()
	for i=1, potteryPasses do
		-- refresh windows
		srReadScreen();
		this = findAllImages("ThisIs.png");
		checkBreak();
		for i=1,#this do
			safeClick(this[i][0], this[i][1]);
			lsSleep(75);
			if jug then
				srReadScreen();
				local wetJug = findAllImages("pottery/mouldJug.png")
					for i=#wetJug, 1, -1 do
						safeClick(wetJug[i][0], wetJug[i][1]);
						lsSleep(75);
					end
	    elseif mortar then
				srReadScreen();
				local clayMortar = findAllImages("pottery/mouldMortar.png")
					for i=#clayMortar, 1, -1 do
						safeClick(clayMortar[i][0], clayMortar[i][1]);
						lsSleep(75);
					end
			elseif cookpot then
				srReadScreen();
				local clayCookpot = findAllImages("pottery/mouldCookpot.png")
					for i=#clayCookpot, 1, -1 do
						safeClick(clayCookpot[i][0], clayCookpot[i][1]);
					end
	    end
		end
		closePopUp();  --If you don't have enough cuttable stones in inventory, then a popup will occur. We don't want these, so check.
		sleepWithStatus(adjustedTimer, "Waiting for " .. product .. " to finish", nil, 0.7);
	end
	lsPlaySound("Complete.wav");
end

function config()
  scale = 0.8;

  local z = 0;
  local is_done = nil;
	-- Edit box and text display
	while not is_done do
		checkBreak("disallow pause");
		lsPrint(10, 10, z, scale, scale, 0xFFFFFFff, "Configure Pottery Wheel");
		local y = 40;

		potteryPasses = readSetting("potteryPasses",potteryPasses);
		lsPrint(10, y, z, scale, scale, 0xffffffff, "Passes:");
		is_done, potteryPasses = lsEditBox("potteryPasses", 100, y, z, 50, 30, scale, scale,
									   0x000000ff, potteryPasses);
		if not tonumber(potteryPasses) then
		  is_done = nil;
		  lsPrint(10, y+30, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
		  potteryPasses = 1;
		end

		potteryPasses = tonumber(potteryPasses);
		writeSetting("potteryPasses",potteryPasses);
		y = y + 35;

		arrangeWindows = readSetting("arrangeWindows",arrangeWindows);
		arrangeWindows = CheckBox(10, y, z, 0xFFFFFFff, "Arrange windows", arrangeWindows, 0.65, 0.65);
		writeSetting("arrangeWindows",arrangeWindows);
		y = y + 32;

		unpinWindows = readSetting("unpinWindows",unpinWindows);
		unpinWindows = CheckBox(10, y, z, 0xFFFFFFff, "Unpin windows on exit", unpinWindows, 0.65, 0.65);
		writeSetting("unpinWindows",unpinWindows);
		y = y + 32;

		if jug then
      jugColor = 0x80ff80ff;
    else
      jugColor = 0xffffffff;
    end
    if mortar then
      mortarColor = 0x80ff80ff;
    else
      mortarColor = 0xffffffff;
    end
		if mortar then
      cookpotColor = 0x80ff80ff;
    else
      cookpotColor = 0xffffffff;
    end

    jug = readSetting("jug",jug);
    mortar = readSetting("mortar",mortar);
		cookpot = readSetting("cookpot",cookpot);

    if not mortar and not cookpot then
      jug = CheckBox(15, y, z+10, jugColor, " Mould a Jug",
                           jug, 0.65, 0.65);
      y = y + 32;
    else
      jug = false
    end

    if not jug and not cookpot then
      mortar = CheckBox(15, y, z+10, mortarColor, " Mould a Clay Mortar",
                              mortar, 0.65, 0.65);
      y = y + 32;
    else
      mortar = false
    end

		if not jug and not mortar then
      cookpot = CheckBox(15, y, z+10, cookpotColor, " Mould a Cookpot",
                              cookpot, 0.65, 0.65);
      y = y + 32;
    else
      cookpot = false
    end

    writeSetting("jug",jug);
    writeSetting("mortar",mortar);
		writeSetting("cookpot",cookpot);

	if jug then
		product = "Wet Clay Jug";
	  timer = jugTimer;
  elseif mortar then
	  product = "Wet Clay Mortar";
	  timer = mortarTimer;
	elseif cookpot then
		product = "Wet Clay Cookpot";
		timer = cookpotTimer;
	end

    timerTeppyDuckOffset = (duckTeppyOffset * timer) * 1000 -- Add extra time to compensate for duck/teppy time
	adjustedTimer = timer + timerTeppyDuckOffset;

    if jug or mortar or cookpot then
    lsPrintWrapped(15, y, z+10, lsScreenX - 20, 0.7, 0.7, 0xd0d0d0ff,
                   "Uncheck box to see more options!\n\n A " .. product .. " requires " .. timer .. "m per pass\n\n" .. timer .. "m = " .. timer .. " ms\n" .. "+ Game Time Offset: " ..  timerTeppyDuckOffset .. " ms\n= " .. timer + timerTeppyDuckOffset .. " ms per pass");

      if lsButtonText(10, lsScreenY - 30, z, 100, 0xFFFFFFff, "Begin") then
        is_done = 1;
      end
    end

	if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff,
                    "End script") then
      error "Clicked End Script button";
    end

	lsDoFrame();
	lsSleep(tick_delay);
	end

	if(unpinWindows) then
		setCleanupCallback(cleanup);
	end;
end

function closePopUp()
  while 1 do
    srReadScreen()
    local ok = srFindImage("OK.png")
    if ok then
      statusScreen("Found and Closing Popups ...", nil, 0.7);
      srClickMouseNoMove(ok[0]+5,ok[1],1);
      lsSleep(100);
    else
      break;
    end
  end
end
