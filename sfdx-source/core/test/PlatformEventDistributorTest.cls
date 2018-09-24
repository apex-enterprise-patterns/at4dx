@IsTest
public class PlatformEventDistributorTest
{
    @IsTest
    static void EventAndCategoryTest()
    {
        Event__e platformEventbus = new Event__e();

        platformEventbus.EventName__c = 'Account_Slogan_Has_Changed';
        platformEventbus.Category__c = Account.getSObjectType().getDescribe().getName();
        platformEventbus.Payload__c = json.serialize(new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType)});

        PlatformEventDistributor ped = new PlatformEventDistributor();

        Test.startTest();
        ped.triggerHandler(new List<Event__e> {platformEventbus});
        Test.stopTest();

        System.assertNotEquals(null, ped.jobIdList);
        System.assertEquals(1, ped.jobIdList.size());
    }

    @isTest
    private static void basicTestToActivateCodeCoverage() 
    {
        Event__e platformEventbus = new Event__e();

        platformEventbus.EventName__c = 'bluefish';
        platformEventbus.Category__c = Account.getSObjectType().getDescribe().getName();
        platformEventbus.Payload__c = json.serialize( new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType ) } );

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(platformEventbus);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }
}
