class NiceM249SAW extends NiceHeavyGun;
simulated function Notify_ShowBullets(){
    SetBoneScale (0, 1.0, 'Bullet01b');
    SetBoneScale (1, 1.0, 'Bullet02b');
    SetBoneScale (2, 1.0, 'Bullet03b');
    SetBoneScale (3, 1.0, 'Bullet04b');
    SetBoneScale (4, 1.0, 'Bullet05b');
    SetBoneScale (5, 1.0, 'Bullet06b');
    SetBoneScale (6, 1.0, 'Bullet07b');
    SetBoneScale (7, 1.0, 'Bullet08b');
    SetBoneScale (8, 1.0, 'Bullet09b');
    SetBoneScale (9, 1.0, 'Bullet10b');
}
simulated function Notify_HideBullets(){
    if(MagAmmoRemaining == 0){
    }
    else if(MagAmmoRemaining == 1){
    }
    else if(MagAmmoRemaining == 2){
    }
    else if(MagAmmoRemaining == 3){
    }
    else if(MagAmmoRemaining == 4){
    }
    else if(MagAmmoRemaining == 5){
    }
    else if(MagAmmoRemaining == 6){
    }
    else if(MagAmmoRemaining == 7){
    }
    else if(MagAmmoRemaining == 8){
    }
    else if(MagAmmoRemaining == 9){
    }
    else{
    }
}
defaultproperties
{
    Weight=7.000000
}