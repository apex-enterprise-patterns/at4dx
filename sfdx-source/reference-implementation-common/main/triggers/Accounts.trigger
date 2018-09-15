trigger Accounts on Account 
    (after delete, after insert, after update, before delete, before insert, before update) 
{
    fflib_SObjectDomain.triggerHandler(Accounts.class);
}