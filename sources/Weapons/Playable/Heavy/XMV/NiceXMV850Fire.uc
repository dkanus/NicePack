class NiceXMV850Fire extends NiceHeavyFire;

simulated function HandleRecoil(float Rec)
{
    local float truncatedContLenght;
    local float recoilMod;
    truncatedContLenght = FMin(currentContLenght, 20.0);
    recoilMod = 1.0 - (truncatedContLenght / 20.0);
    super.HandleRecoil(Rec * recoilMod);
}

defaultproperties
{
    contBonusReset=false
}