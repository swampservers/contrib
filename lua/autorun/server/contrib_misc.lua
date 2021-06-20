util.AddNetworkString("setcntry")

net.Receive("setcntry", function(len, ply)
    if ply:GetNWString("cntry", "UNSET") == "UNSET" then
        st = net.ReadString()

        if string.len(st) == 2 then
            ply:SetNWString("cntry", st)
        end
    end
end)