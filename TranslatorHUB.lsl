/**
    @name: TranslatorHUB
    @title: Neuralyzer

    @author: Zai Dium
    @license: by-nc-sa [https://creativecommons.org/licenses/by-nc-sa/4.0/]

    @updated: "2024-10-22 23:58:56"
    @version: 1.7x
    @revision: 669

    @localfile: ?defaultpath\MIB_Neuralyzer\?@name.lsl
*/
integer open = FALSE;
integer aim = FALSE;
float openPercent = 0.8;
float closePercent = 0.19;

flash()
{
    llParticleSystem([
        PSYS_PART_FLAGS,
            PSYS_PART_INTERP_COLOR_MASK
            | PSYS_PART_INTERP_SCALE_MASK
            | PSYS_PART_EMISSIVE_MASK
//            | PSYS_PART_FOLLOW_VELOCITY_MASK
//            | PSYS_PART_WIND_MASK
            ,
        PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_ANGLE,
        PSYS_SRC_BURST_RADIUS,      0,

        PSYS_SRC_MAX_AGE,           0.2,

        PSYS_PART_MAX_AGE,          1,
        PSYS_SRC_BURST_RATE,        1,
        PSYS_SRC_BURST_PART_COUNT,  1,

        //PSYS_SRC_TEXTURE,            llGetInventoryKey((string)S),
        //PSYS_SRC_TEXTURE,           TEXTURE_BLANK,
        PSYS_SRC_BURST_SPEED_MIN,   0,
        PSYS_SRC_BURST_SPEED_MAX,   0,

        PSYS_SRC_ACCEL,             <0.0, 0.0, 0.0>,
        PSYS_SRC_OMEGA,             <0.0, 0.0, 0.0>,

        PSYS_SRC_ANGLE_BEGIN,       0,
        PSYS_SRC_ANGLE_END,         2*PI,

        PSYS_PART_START_COLOR,      <1,1,1>,
        PSYS_PART_END_COLOR,        <1,1,1>,

        PSYS_PART_START_GLOW,       1,
        PSYS_PART_END_GLOW,         1,

        PSYS_PART_START_ALPHA,      0.8,
        PSYS_PART_END_ALPHA,        0.5,

        PSYS_PART_START_SCALE,      <20, 20, 0.0>,
        PSYS_PART_END_SCALE,        <20, 20, 0.0>

    ]);
    llSleep(1);
    llParticleSystem([]);
}

integer dialog_channel;
integer dialog_listen_id;
integer cur_page;

list getCommands(key id)
{
    list l;
    if (!aim)
       l += "Aim";
    else
        l += ["UnAim"];

    l += ["Open", "Close"];

    if (open)
        l = l + ["Flash"];
    return l;
}

showDialog(key id)
{
    if (dialog_channel ==0)
        dialog_channel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
    string s = "Select your action:";
    llDialog(id, s, getCommands(id), dialog_channel);
    dialog_listen_id = llListen(dialog_channel, "", id, "");
}

integer processDialog(key id, string message)
{
    if (message == "---")
    {
        cur_page = 0;
        showDialog(id);
    }
    else if (message == "<--")
    {
        if (cur_page > 0)
            cur_page--;
        showDialog(id);
    }
    else if (message == "-->")
    {
        integer max_limit = (llGetListLength(getCommands(id))-1) / 9;
        if (cur_page < max_limit)
            cur_page++;
        showDialog(id);
    }
    else
        return FALSE;
    return TRUE;
}

switch(integer openIt)
{
    open = openIt;
    integer link = osGetLinkNumber("light");
    if (link>=0)
    {
        vector size = llList2Vector(llGetLinkPrimitiveParams(link,[PRIM_SIZE]), 0);
        float shift;
        if (openIt)
            shift = size.z * openPercent;
        else
            shift = size.z * closePercent;

        llSetLinkPrimitiveParams(link, [PRIM_POS_LOCAL, <0.0, 0.0, shift>]);
    }
}

default
{
    state_entry()
    {
        if (llGetAttached())
            llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
        switch(FALSE);
    }

    touch_start(integer num_detected)
    {
        if (llGetOwner()!=llDetectedKey(0))
            return;
        key id = llDetectedKey(0);
        showDialog(id);
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == dialog_channel)
        {
            message = llToLower(message);
            if (!processDialog(id, message))
            {
                if (message == "aim")
                {
                    aim = TRUE;
                    if (llGetAttached())
                        llStartAnimation("Catch");
                    showDialog(id);
                }
                if (message == "unaim")
                {
                    aim = FALSE;
                    if (llGetAttached())
                        llStopAnimation("Catch");
                    showDialog(id);
                }
                else if (message == "open")
                {
                    switch(TRUE);
                    showDialog(id);
                }
                else if (message == "close")
                {
                    switch(FALSE);
                    showDialog(id);
                }
                else if (message == "flash")
                {
                    flash();
                    showDialog(id);
                }
            }
        }

    }

    on_rez(integer number)
    {
        llResetScript();
    }

}
