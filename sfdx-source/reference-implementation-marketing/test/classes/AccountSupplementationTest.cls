@IsTest
class AccountSupplementationTest
{
    @IsTest
    static void test()
    {
        Account acct = new Account();
        TestDataSupplementer.supplement(new List<Account> {acct});

        System.assertEquals('Hello world!', acct.Slogan__c);
    }
}
