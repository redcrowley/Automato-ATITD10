dofile("common.inc");
dofile("settings.inc");

askText = "Simon v1.13\n\nSets up a list of points and then clicks on them in sequence.\n\nCan optionally add a timer to wait between each pass (ie project takes a few minutes to complete).\n\nOr will watch Stats Timer (red/black) for clicking.";

clickDelay = 150;
is_stats = true;
passDelay = 0;
refresh = true;

function getPoints()
  clickList = {};
  local was_shifted = lsShiftHeld();
  local is_done = false;
  local mx = 0;
  local my = 0;
  local z = 0;
  while not is_done do
    mx, my = srMousePos();
    local is_shifted = lsShiftHeld();
    if is_shifted and not was_shifted then
      clickList[#clickList + 1] = {mx, my};
    end
    was_shifted = is_shifted;

    checkBreak();
    lsPrint(10, 10, z, 1.0, 1.0, 0xFFFFFFff, "Adding Points (" .. #clickList .. ")");
    local y = 60;
    lsPrintWrapped(5, y, z, lsScreenX - 20, 0.7, 0.7, 0xFFFFFFff, "Hover mouse over a point (to click) and Tap Shift to add point.");
    y = y + 50;
    local start = math.max(1, #clickList - 20);
    local index = 0;
    for i=start,#clickList do
      local xOff = (index % 4) * 75;
      local yOff = (index - index%4)/2 * 7;
      lsPrint(10 + xOff, y + yOff, z, 0.5, 0.5, 0xffffffff,
        "(" .. clickList[i][1] .. ", " .. clickList[i][2] .. ")");
      index = index + 1;
    end

    if #clickList > 0 then -- Don't show Next button until at least one point is added
      if ButtonText(10, lsScreenY - 30, z, 80, 0xFFFFFFff, "Next") then
        is_done = 1;
      end

      if ButtonText(87, lsScreenY - 30, 0, 125, 0xFFFFFFff, "Reset Points") then
        getPoints();
      end
    end
    if ButtonText(200, lsScreenY - 30, 0, 110, 0xFFFFFFff,
      "End script") then
      error(quit_message);
    end
    lsDoFrame();
    lsSleep(10);
  end
end

function promptRun()
  local is_done = false;
  local count = 1;
  local scale = 0.7;
  while not is_done do
    checkBreak();
    lsPrint(10, 10, 0, scale, scale, 0xffffffff, "Configure Sequence");
    local y = 60;
    lsPrint(5, y, 0, scale, scale, 0xffffffff, "Passes:");
    count = readSetting("count",count);
    is_done, count = lsEditBox("count", 140, y-5, 0, 50, 30, scale, scale,
      0x000000ff, count);
    count = tonumber(count);
    if not count then
      is_done = false;
      lsPrint(10, y+30, 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
      count = 1;
    end
    writeSetting("count",count);
    y = y + 45;
    refresh = readSetting("refresh",refresh);
    lsPrint(145, y+2, 0, 0.6, 0.6, 0xffffffff, "(Click 'This Is' each pass)");
    refresh = CheckBox(10, y, 10, 0xffffffff, " Refresh Windows", refresh, 0.7, 0.7);
    writeSetting("refresh",refresh);
    y = y + 20;
    is_stats = readSetting("is_stats",is_stats);
    lsPrint(145, y+2, 0, 0.6, 0.6, 0xffffffff, "(I\'m Tired - Red/Black Stats)");
    is_stats = CheckBox(10, y, 10, 0xffffffff, " Wait for Stats", is_stats, 0.7, 0.7);
    writeSetting("is_stats",is_stats);
    y = y + 42;

    if not is_stats then
      lsPrint(5, y, 0, scale, scale, 0xffffffff, "Click Delay (ms):");
      clickDelay = readSetting("clickDelay",clickDelay);
      is_done, clickDelay = lsEditBox("delay", 140, y-5, 0, 90, 30, scale, scale,
        0x000000ff, clickDelay);
      clickDelay = tonumber(clickDelay);
      if not clickDelay then
        is_done = false;
        lsPrint(10, y+30, 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
        clickDelay = 150;
      end
      writeSetting("clickDelay",clickDelay);

      y = y + 28
      lsPrint(5, y, 0, scale, scale, 0xffffffff, "Pass Delay (s):");
      passDelay = readSetting("passDelay",passDelay);
      is_done, passDelay = lsEditBox("passDelay", 140, y, 0, 50, 30, scale, scale,
        0x000000ff, passDelay);
      passDelay = tonumber(passDelay);
      if not passDelay then
        is_done = false;
        lsPrint(10, y+30, 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
        passDelay = 0;
      end

      lsPrint(200, y+6, 0, 0.6, 0.6, 0xffffffff, math.floor(passDelay*1000) .. " (ms)");
      writeSetting("passDelay",passDelay);
      y = y + 48;
      lsPrintWrapped(5, y, z, lsScreenX - 20, 0.65, 0.65, 0xFFFFFFff, "Pass Delay: How long to wait, after each click sequence, before moving onto the next pass.");
    else
      lsPrintWrapped(10, 170, z, lsScreenX - 20, 0.67, 0.67, 0xFFFFFFff, "Unchecking 'Wait for Stats' checkbox will present options for Click Delay and Pass Delay");
    end

    if ButtonText(10, lsScreenY - 30, 0, 80, 0xFFFFFFff, "Begin") then
      is_done = 1;
    end
    if ButtonText(87, lsScreenY - 30, 0, 125, 0xFFFFFFff, "Reset Points") then
      getPoints();
    end
    if ButtonText(200, lsScreenY - 30, 0, 110, 0xFFFFFFff,
      "End script") then
      error(quit_message);
    end
    lsSleep(50);
    lsDoFrame();
  end
  return count;
end

function clickSequence(count)
  message = "";
  for i=1,count do
    clickedPoints = "";

    if refresh then
      refreshWindows();
    end

    for j=1,#clickList do
      checkBreak();
      safeClick(clickList[j][1], clickList[j][2]);
      clickedPoints = clickedPoints .. "Clicked " .. j .. "/" .. #clickList .. "  (" .. clickList[j][1] .. ", " .. clickList[j][2] .. ")\n";
      message = "Pass " .. i .. "/" .. count .. " -- ";
      message = message .. "Clicked " .. j .. "/" .. #clickList .. "\n\n"  .. clickedPoints;
      if is_stats then
        sleepWithStatus(150, message .. "\nWaiting between clicks", nil, 0.67);
        closePopUp(); -- Check for lag/premature click that might've caused a popup box (You're too tired, wait xx more seconds)
        waitForStats(message .. "Waiting For Stats");
      else
        sleepWithStatus(clickDelay, message .. "\nWaiting Click Delay", nil, 0.67);
      end
    end
    --if passDelay > 0 and not is_stats and (i < count) then  --Uncomment so you don't have to wait the full passDelay countdown on last pass; script exits on last pass immediately .
    if passDelay > 0 and not is_stats then -- No need for passDelay timer if it's 0 or we're using Wait for Stats option
      sleepWithStatus(math.floor(passDelay*1000), message .. "\nWaiting on Pass Delay: " .. passDelay .. "s  (" .. math.floor(passDelay*1000) .. " ms)" , nil, 0.67);
    end
  end
  lsPlaySound("Complete.wav");
end

function doit()
  askForWindow(askText);
  getPoints();

  local is_done = false;
  while not is_done do
    local count = promptRun();
    if count > 0 then
      askForFocus();
      clickSequence(count);
    else
      is_done = true;
    end
  end
end

function waitForStats(message)
  local stats = findStats();
  while not stats do
    sleepWithStatus(500, message, 0xff3333ff);
    stats = findStats();
  end
end

function findStats()
  srReadScreen();
  local endurance = srFindImage("stats/endurance.png");
  if endurance then
    return false;
  end
  local focus = srFindImage("stats/focus.png");
  if focus then
    return false;
  end
  local strength = srFindImage("stats/strength.png");
  if strength then
    return false;
  end
  return true;
end

function closePopUp()
  srReadScreen()
  local ok = srFindImage("OK.png")
  if ok then
    srClickMouseNoMove(ok[0]+5,ok[1],1);
  end
end

function refreshWindows()
  statusScreen("Refreshing Windows ...", nil, 0.7);
  srReadScreen();
  pinWindows = findAllImages("ThisIs.png");
  for i=1, #pinWindows do
    checkBreak();
    safeClick(pinWindows[i][0], pinWindows[i][1]);
    lsSleep(100);
  end
  lsSleep(500);
end
