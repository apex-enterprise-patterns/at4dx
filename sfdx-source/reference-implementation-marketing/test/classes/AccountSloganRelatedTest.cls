@isTest 
private class AccountSloganRelatedTest 
{
    @isTest 
    static void givenNewAccountWhenCreatedWithFishNameThenSloganIsDefaulted()
    {
        // given

        // when
        Test.startTest();
        Account bluefishAccount = new Account();

        bluefishAccount.name = 'bluefish';
        
        insert bluefishAccount;

        Test.stopTest();

        // then
        
        list<Account> accountRecordsQueried = AccountsSelector.newInstance().selectById( new Set<id>{ bluefishAccount.Id } );

        System.assert( ! accountRecordsQueried.isEmpty() );
        System.assert( accountRecordsQueried.size() == 1 );

        Account accountRecordQueried = accountRecordsQueried[0];

        System.assert( String.isNotBlank( accountRecordQueried.Slogan__c ) );
        
    }

    @isTest 
    static void givenNewAccountWhenCreatedWithFishNameThenSelectorMethodInjection()
    {
        // given
        String slogan = 'The Big Blue Fish is a fishy business';

        Account bluefishAccount = new Account();

        bluefishAccount.Id = fflib_IDGenerator.generate( Account.SObjectType );
        bluefishAccount.name = 'bluefish';
        bluefishAccount.slogan__c = slogan;

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock( IAccountsSelector.class );

        mocks.startStubbing();

        SelectBySloganSelectorMethod.Parameters queryParams = new SelectBySloganSelectorMethod.Parameters();

        queryParams.sloganNameSet = new Set<String>{ slogan };






        // when
        Test.startTest();
        
        system.debug( AccountsSelector.newInstance().selectInjection( SelectBySloganSelectorMethod.class, queryParams) );

        Test.stopTest();

        // then
        
        // list<Account> accountRecordsQueried = AccountsSelector.newInstance().selectById( new Set<id>{ bluefishAccount.Id } );

        // System.assert( ! accountRecordsQueried.isEmpty() );
        // System.assert( accountRecordsQueried.size() == 1 );

        // Account accountRecordQueried = accountRecordsQueried[0];

        // System.assert( String.isNotBlank( accountRecordQueried.Slogan__c ) );
    }



}
