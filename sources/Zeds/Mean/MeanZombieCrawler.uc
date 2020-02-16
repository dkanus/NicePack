class MeanZombieCrawler extends NiceZombieCrawler;
#exec OBJ LOAD FILE=MeanZedSkins.utx
simulated function PostBeginPlay() {
    super.PostBeginPlay();
    PounceSpeed = Rand(221)+330;
    MeleeRange = Rand(41)+50;
}
/**
 * Copied from ZombieCrawler.Bump() but changed damage type
 * to be the new poison damage type
 */
event Bump(actor Other) {
    if(bPouncing && KFHumanPawn(Other) != none)       Poison(KFHumanPawn(Other));
    super.Bump(Other);
}
function bool MeleeDamageTarget(int hitdamage, vector pushdir) {
    local bool result;
    result= super.MeleeDamageTarget(hitdamage, pushdir);
    if(result && KFHumanPawn(Controller.Target) != none)       Poison(KFHumanPawn(Controller.Target));
    return result;
}
function Poison(KFHumanPawn poisonedPawn){
    local Inventory I;
    local bool bFoundPoison;
    if(poisonedPawn.Inventory != none){       for(I = poisonedPawn.Inventory; I != none; I = I.Inventory)           if(I != none && MeanPoisonInventory(I) != none){               bFoundPoison = true;               MeanPoisonInventory(I).poisonStartTime = Level.TimeSeconds;           }
    }
    if(!bFoundPoison){       I = Controller.Spawn(class<Inventory>(DynamicLoadObject("NicePack.MeanPoisonInventory", Class'Class')));       MeanPoisonInventory(I).poisonStartTime = Level.TimeSeconds;       I.GiveTo(poisonedPawn);
    }
}
defaultproperties
{    GroundSpeed=190.000000    WaterSpeed=175.000000    MenuName="Mean Crawler"    Skins(0)=Combiner'MeanZedSkins.crawler_cmb'
}
