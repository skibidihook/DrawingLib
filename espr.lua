local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local Camera=Workspace.CurrentCamera
local LocalPlayer=Players.LocalPlayer
local g=getgenv
local ESPPlayers=g()._ESPplayers or{}
local ESPConnections=g()._ESPConnections or{}
g()._ESPplayers=ESPPlayers
g()._ESPConnections=ESPConnections
for _,c in ipairs(ESPConnections)do c:Disconnect()end
 table.clear(ESPConnections)
for _,d in pairs(ESPPlayers)do if d.Objects then for _,o in ipairs(d.Objects)do o.Visible=false end end if d.Highlight then d.Highlight.Enabled=false d.Highlight:Destroy()end end
 table.clear(ESPPlayers)
local Pool={Line={},Text={},Square={},Triangle={},Circle={}}
local Types={}
local function st(o,t)Types[o]=t end
local function gt(o)return Types[o]end
local function ct(o)Types[o]=nil end
local function gf(t,c)
 local p=Pool[t]
 if#p>0 then return table.remove(p)end
 local o=c();st(o,t)return o
end
local function rt(o)o.Visible=false local t=gt(o)if t then table.insert(Pool[t],o)end end
local function nLine()return gf("Line",function()local o=Drawing.new("Line")o.Thickness=2;o.Transparency=1;o.Color=Color3.new(1,1,1)return o end)end
local function nText()return gf("Text",function()local o=Drawing.new("Text")o.Center=true;o.Outline=true;o.Font=3;o.Size=18;o.Color=Color3.new(1,1,1);o.Transparency=1;return o end)end
local function nSquare(f)local s=gf("Square",function()local o=Drawing.new("Square")o.Thickness=1;o.Transparency=1;o.Filled=false;o.Color=Color3.new(1,1,1)return o end)s.Filled=f==true;return s end
local function nTriangle()return gf("Triangle",function()local t=Drawing.new("Triangle")t.Transparency=1;t.Color=Color3.new(1,1,1);return t end)end
local function nCircle()return gf("Circle",function()local c=Drawing.new("Circle")c.Transparency=1;c.Color=Color3.new(1,1,1);c.Thickness=1;return c end)end
local CONFIG={ESPEnabled=false,AliveCheck=false,TeamCheck=false,TeamColorToggle=false,Boxes=false,Skeletons=false,NameTag=false,HealthText=false,DistanceText=false,ViewAngle=false,HealthBar=false,OffScreenArrows=false,Chams=false,ToolESP=false,VelocityTag=false,LineTracer=false,RadarEnabled=false,WallCheck=false,HealthColorDynamic=false,MaxBoxDistance=1000,MaxSkeletonDistance=1000,ArrowSize=15,ArrowRadius=200,ArrowColor=Color3.fromRGB(255,0,0),RadarSize=100,RadarX=120,RadarY=400,RadarScale=0.2,BoxColor=Color3.fromRGB(255,255,255),BoxThickness=2,UpdateInterval=0.01}
local RadarBase=nCircle()RadarBase.Filled=false;RadarBase.NumSides=30;RadarBase.Thickness=2;RadarBase.Color=Color3.new(1,1,1);RadarBase.Visible=false
local LocalRadarDot=nCircle()LocalRadarDot.Radius=4;LocalRadarDot.Color=Color3.new(0,1,0);LocalRadarDot.Visible=false
local R15={{"LeftHand","LeftLowerArm"},{"LeftLowerArm","LeftUpperArm"},{"LeftUpperArm","UpperTorso"},{"RightHand","RightLowerArm"},{"RightLowerArm","RightUpperArm"},{"RightUpperArm","UpperTorso"},{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LeftFoot","LeftLowerLeg"},{"LeftLowerLeg","LeftUpperLeg"},{"LeftUpperLeg","LowerTorso"},{"RightFoot","RightLowerLeg"},{"RightLowerLeg","RightUpperLeg"},{"RightUpperLeg","LowerTorso"}}
local R6={{"Head","Torso"},{"Left Arm","Torso"},{"Right Arm","Torso"},{"Left Leg","Torso"},{"Right Leg","Torso"}}
local function w2s(p)local q,on=Camera:WorldToViewportPoint(p)return Vector2.new(q.X,q.Y),on,q.Z end
local function hc(r)if r>=0.66 then return Color3.new(0,1,0)elseif r>=0.33 then return Color3.new(1,1,0)else return Color3.new(1,0,0)end end
local function hide(d)if not d or not d.Objects then return end for _,o in ipairs(d.Objects)do o.Visible=false end if d.Highlight then d.Highlight.Enabled=false end end
local function rem(plr)local d=ESPPlayers[plr.UserId]if d then if d.Objects then for _,o in ipairs(d.Objects)do rt(o)ct(o)end end if d.Highlight then d.Highlight.Enabled=false d.Highlight:Destroy()end ESPPlayers[plr.UserId]=nil end end
local function hl(char,c)local h=Instance.new("Highlight")h.Enabled=true;h.FillColor=c;h.FillTransparency=0.5;h.OutlineColor=Color3.new(0,0,0);h.OutlineTransparency=0;h.Adornee=char;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=gethui();return h end
local function build(plr,isR15)local d={Player=plr,IsR15=isR15,Objects={},SkelLines={},RadarDot=nCircle(),TracerLine=nLine()}table.insert(d.Objects,d.RadarDot)table.insert(d.Objects,d.TracerLine)d.NameText=nText()d.HealthText=nText()d.DistanceText=nText()d.VelocityText=nText()table.insert(d.Objects,d.NameText)table.insert(d.Objects,d.HealthText)table.insert(d.Objects,d.DistanceText)table.insert(d.Objects,d.VelocityText)d.Box={}for _,c in ipairs{"TL1","TL2","TR1","TR2","BL1","BL2","BR1","BR2"}do local l=nLine()d.Box[c]=l;table.insert(d.Objects,l)end local refs=isR15 and R15 or R6 for _=1,#refs do local l=nLine()table.insert(d.SkelLines,l)table.insert(d.Objects,l)end d.HBOut=nSquare(true)d.HB=nSquare(true)table.insert(d.Objects,d.HBOut)table.insert(d.Objects,d.HB)d.ViewAngleLine=nLine()table.insert(d.Objects,d.ViewAngleLine)d.OffscreenArrow=nTriangle()table.insert(d.Objects,d.OffscreenArrow)d.Highlight=hl(plr.Character or{},CONFIG.BoxColor)return d end
local function gp(c,n)local p=c:FindFirstChild(n)return p and p:IsA("BasePart") and p.Position or nil end
local function char(plr,ch)task.wait(0.1)local isR15=ch:FindFirstChild("UpperTorso")~=nil rem(plr)ESPPlayers[plr.UserId]=build(plr,isR15)end
local function add(plr)if plr==LocalPlayer then return end table.insert(ESPConnections,plr.CharacterAdded:Connect(function(c)char(plr,c)end))table.insert(ESPConnections,plr.CharacterRemoving:Connect(function()rem(plr)end))if plr.Character then char(plr,plr.Character)end end
local function cr(l,f,t,v,c)l.From=f;l.To=t;l.Color=c;l.Visible=v end
local function upd(b,tl,tr,bl,br,c,v,o)cr(b.TL1,tl,tl+Vector2.new(o,0),v,c)cr(b.TL2,tl,tl+Vector2.new(0,o),v,c)cr(b.TR1,tr,tr+Vector2.new(0,o),v,c)cr(b.TR2,tr,tr-Vector2.new(o,0),v,c)cr(b.BL1,bl,bl+Vector2.new(o,0),v,c)cr(b.BL2,bl,bl-Vector2.new(0,o),v,c)cr(b.BR1,br,br-Vector2.new(o,0),v,c)cr(b.BR2,br,br-Vector2.new(0,o),v,c)end
local function wc(s,e,ch)local p=RaycastParams.new()p.FilterType=Enum.RaycastFilterType.Exclude;p.FilterDescendantsInstances={LocalPlayer.Character or nil,ch}local r=Workspace:Raycast(s,(e-s),p)return not(r and r.Instance)end
local function uskel(d,ch,c,s)local refs=d.IsR15 and R15 or R6 for i,pair in ipairs(refs)do local a=gp(ch,pair[1])local b=gp(ch,pair[2])local l=d.SkelLines[i]if a and b and l then local sa,oa=w2s(a)local sb,ob=w2s(b)if oa and ob then l.From=sa;l.To=sb;l.Color=c;l.Visible=s else l.Visible=false end elseif l then l.Visible=false end end end
local function uhb(d,tl,bl,h)if CONFIG.HealthBar and h then local r=math.clamp(h.Health/h.MaxHealth,0,1)local hgt=(bl.Y-tl.Y)*r local w,g,out=4,2,1 d.HBOut.Position=Vector2.new(tl.X-g-w-out*2,tl.Y-out)d.HBOut.Size=Vector2.new(w+out*2,(bl.Y-tl.Y)+out*2)d.HBOut.Color=Color3.new(0,0,0)d.HBOut.Visible=true local bx=d.HBOut.Position.X+out local by=bl.Y-hgt d.HB.Position=Vector2.new(bx,by)d.HB.Size=Vector2.new(w,hgt)d.HB.Visible=true if r>=0.66 then d.HB.Color=Color3.new(0,1,0)elseif r>=0.33 then d.HB.Color=Color3.new(1,1,0)else d.HB.Color=Color3.new(1,0,0)end else d.HBOut.Visible=false d.HB.Visible=false end end
local function utt(d,p,h,r,dist)if CONFIG.NameTag then d.NameText.Position=r-Vector2.new(0,40)d.NameText.Text=p.Name;d.NameText.Visible=true else d.NameText.Visible=false end if CONFIG.HealthText and h then d.HealthText.Position=r+Vector2.new(40,-20)d.HealthText.Text=math.floor(h.Health).." HP";d.HealthText.Visible=true else d.HealthText.Visible=false end if CONFIG.DistanceText and dist then d.DistanceText.Position=r+Vector2.new(0,20)d.DistanceText.Text=string.format("%.0f studs",dist)d.DistanceText.Visible=true else d.DistanceText.Visible=false end end
local function uvt(d,hrp)if CONFIG.VelocityTag and hrp then local v=hrp.AssemblyLinearVelocity local m=v.Magnitude local s=w2s(hrp.Position)d.VelocityText.Position=s-Vector2.new(0,60)d.VelocityText.Text=string.format("Vel: %.1f",m)d.VelocityText.Visible=true else d.VelocityText.Visible=false end end
local function uva(d,head,c)if CONFIG.ViewAngle then local hs,on=w2s(head)if on and d.Player.Character and d.Player.Character:FindFirstChild("Head")then local cf=CFrame.lookAt(head,head+(d.Player.Character.Head.CFrame.LookVector*8))local ep=head+cf.LookVector*12 local es,eon=w2s(ep)if eon then d.ViewAngleLine.From=hs;d.ViewAngleLine.To=es;d.ViewAngleLine.Color=c;d.ViewAngleLine.Visible=true return end end end d.ViewAngleLine.Visible=false end
local function ubc(d,cf,hrp,x,y,c,dist)local function off(a,b,z)local p=(cf*CFrame.new(a,b,z)).Position return w2s(p)end local tl,on1=off(x,y,0)local tr,on2=off(-x,y,0)local bl,on3=off(x,-y,0)local br,on4=off(-x,-y,0)if tl and tr and bl and br and on1 and on2 and on3 and on4 then local show=(dist<CONFIG.MaxBoxDistance) and CONFIG.Boxes local o=math.clamp(1/dist*750,2,300)upd(d.Box,tl,tr,bl,br,c,show,o)return tl,tr,bl,br else for _,l in pairs(d.Box)do l.Visible=false end end end
local function gtname(ch)for _,k in ipairs(ch:GetChildren())do if k:IsA("Tool")then return k.Name end end return nil end
local function onscreen(p)local x,y=Camera.ViewportSize.X,Camera.ViewportSize.Y return p.X>=0 and p.X<=x and p.Y>=0 and p.Y<=y end
local function uarrow(d,spos,hrp)if not CONFIG.OffScreenArrows then d.OffscreenArrow.Visible=false return end local res=Camera.ViewportSize local sc=Vector2.new(res.X/2,res.Y/2)local dir=(spos-sc).Unit local r=CONFIG.ArrowRadius local size=CONFIG.ArrowSize if onscreen(spos) then d.OffscreenArrow.Visible=false return end local np=sc+(dir*r)local perp=Vector2.new(-dir.Y,dir.X)local p1=np local p2=np-dir*size+perp*(size/2)local p3=np-dir*size-perp*(size/2)local a=d.OffscreenArrow a.PointA=p2;a.PointB=p3;a.PointC=p1;a.Color=CONFIG.ArrowColor;a.Visible=true end
local function utl(d,rpos)if CONFIG.LineTracer then local sc=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)d.TracerLine.From=sc;d.TracerLine.To=rpos;d.TracerLine.Visible=true else d.TracerLine.Visible=false end end
local function urd(d,hrp)local lhrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")if not CONFIG.RadarEnabled or not lhrp then d.RadarDot.Visible=false return end local off=hrp-localHRPPos local dir=Vector2.new(off.X,off.Z)*CONFIG.RadarScale local center=Vector2.new(CONFIG.RadarX,CONFIG.RadarY)local pos=center+dir d.RadarDot.Position=pos;d.RadarDot.Radius=3;d.RadarDot.Color=Color3.new(1,0,0);d.RadarDot.Visible=true end
local function uch(d,vis,h)if not CONFIG.Chams or not d.Highlight or not h then if d.Highlight then d.Highlight.Enabled=false end return end d.Highlight.Enabled=true if CONFIG.WallCheck then d.Highlight.FillColor=vis and Color3.new(0,0.764706,1)or Color3.new(1,0,0.784314)else d.Highlight.FillColor=Color3.new(1,1,1)end if CONFIG.HealthColorDynamic then local r=h.Health/h.MaxHealth d.Highlight.FillColor=hc(r)end end
local function utool(d,rpos,ch)if CONFIG.ToolESP then local n=gtname(ch)if n then d.NameText.Text=d.NameText.Text.." ["..n.."]" end end end
local function uplayer(d,cf,cpos,lppos)if not d or not CONFIG.ESPEnabled then hide(d)return end local plr=d.Player local ch=plr.Character if not ch then hide(d)return end local hrp=ch:FindFirstChild("HumanoidRootPart")local h=ch:FindFirstChildWhichIsA("Humanoid")if not hrp or(CONFIG.AliveCheck and(not h or h.Health<=0))then hide(d)return end if CONFIG.TeamCheck and plr.Team==LocalPlayer.Team then hide(d)return end local rpos,ons=w2s(hrp.Position)if not ons then urd(d,hrp.Position)uarrow(d,rpos,hrp.Position)hide(d)d.OffscreenArrow.Visible=CONFIG.OffScreenArrows;d.RadarDot.Visible=CONFIG.RadarEnabled;return end local dist=(cpos-hrp.Position).Magnitude local vis=true if CONFIG.WallCheck then local head=ch:FindFirstChild("Head")if head then vis=wc(cpos,head.Position,ch)end end local col=CONFIG.BoxColor if CONFIG.TeamColorToggle and plr.Team then col=plr.Team.TeamColor.Color end if CONFIG.HealthColorDynamic and h then col=hc(math.clamp(h.Health/h.MaxHealth,0,1))end if CONFIG.WallCheck and not vis then col=col:lerp(Color3.new(0.5,0.5,0.5),0.5)end urd(d,hrp.Position)uarrow(d,rpos,hrp.Position)utl(d,rpos)local sx=hrp.Size.X local sy=hrp.Size.Y*1.4 local tl,tr,bl,br=ubc(d,CFrame.new(hrp.Position,cf.Position),hrp.Position,sx,sy,col,dist)uskel(d,ch,col,(dist<CONFIG.MaxSkeletonDistance)and CONFIG.Skeletons)if tl and bl then uhb(d,tl,bl,h)end utt(d,plr,h,rpos,lppos and(lppos-hrp.Position).Magnitude)uvt(d,hrp)local head=ch:FindFirstChild("Head")if head then uva(d,head.Position,col)else d.ViewAngleLine.Visible=false end utool(d,rpos,ch)uch(d,vis,h)end
for _,p in ipairs(Players:GetPlayers())do add(p)end
table.insert(ESPConnections,Players.PlayerAdded:Connect(add))
table.insert(ESPConnections,Players.PlayerRemoving:Connect(rem))
local last=0
local function render()local now=os.clock()if now-last<CONFIG.UpdateInterval then return end last=now if not CONFIG.ESPEnabled then for _,i in pairs(ESPPlayers)do hide(i)end RadarBase.Visible=false;LocalRadarDot.Visible=false return end if CONFIG.RadarEnabled then RadarBase.Visible=true;RadarBase.Position=Vector2.new(CONFIG.RadarX,CONFIG.RadarY);RadarBase.Radius=CONFIG.RadarSize local lhrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")if lhrp then LocalRadarDot.Visible=true;LocalRadarDot.Position=Vector2.new(CONFIG.RadarX,CONFIG.RadarY)else LocalRadarDot.Visible=false end else RadarBase.Visible=false;LocalRadarDot.Visible=false end local cf=Camera.CFrame local cpos=cf.Position local lhrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")local lp=lhrp and lhrp.Position for _,info in pairs(ESPPlayers)do uplayer(info,cf,cpos,lp)end end
table.insert(ESPConnections,RunService.RenderStepped:Connect(render))
local ESP={}
function ESP:Enable()CONFIG.ESPEnabled=true end
function ESP:Disable()CONFIG.ESPEnabled=false end
function ESP:Toggle()CONFIG.ESPEnabled=not CONFIG.ESPEnabled end
function ESP:Set(o,v)if CONFIG[o]~=nil then CONFIG[o]=v end end
function ESP:Get(o)return CONFIG[o]end
function ESP:Unload()CONFIG.ESPEnabled=false for _,c in ipairs(ESPConnections)do c:Disconnect()end table.clear(ESPConnections)for _,i in pairs(ESPPlayers)do rem(i.Player)end RadarBase.Visible=false;LocalRadarDot.Visible=false end
return ESP
