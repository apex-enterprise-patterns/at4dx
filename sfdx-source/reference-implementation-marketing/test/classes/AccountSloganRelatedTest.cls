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
}
