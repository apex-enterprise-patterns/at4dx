trigger PlatformEvents on Event__e 
    (after insert) 
{
    PlatformEventDistributor.triggerHandler();
}