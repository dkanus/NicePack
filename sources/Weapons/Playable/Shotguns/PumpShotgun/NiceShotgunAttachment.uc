class NiceShotgunAttachment extends NiceAttachment;
var Actor TacShine;
var  Effects TacShineCorona;
var bool bBeamEnabled;
simulated event ThirdPersonEffects(){
    if(FiringMode == 1)
    super.ThirdPersonEffects();
}
simulated function Destroyed()
{
    if(TacShineCorona != none)
    if (TacShine != none)
    super.Destroyed();
}
simulated function UpdateTacBeam( float Dist ){
    local vector Sc;
    if(!bBeamEnabled){
    }
    Sc = TacShine.DrawScale3D;
    Sc.Y = FClamp(Dist/90.f,0.02,1.f);
    if(TacShine.DrawScale3D != Sc)
}
simulated function TacBeamGone(){
    if(bBeamEnabled){
    }
}
defaultproperties
{
}