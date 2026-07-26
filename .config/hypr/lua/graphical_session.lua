-- SYSTEMD UNIT NEEDS TO EXIST --
-- Add it for this to work:
-- systemctl --user edit --full --force hyprland-session.target
--
-- [Unit]
-- Description=Hyprland session
-- BindsTo=graphical-session.target
-- Wants=graphical-session-pre.target
-- After=graphical-session-pre.target
-- PropagatesStopTo=graphical-session.target

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprland-session.target")
end)

hl.on("hyprland.shutdown", function()
    os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
    -- uses a blocking exec function and sleeps a bit to give things time to close
    -- you might also want to kill troublesome/crashing non-systemd background services here:
    -- os.execute("pkill wallpaperthing; systemctl --user stop hyprland-session.target && sleep 0.1")
end)
