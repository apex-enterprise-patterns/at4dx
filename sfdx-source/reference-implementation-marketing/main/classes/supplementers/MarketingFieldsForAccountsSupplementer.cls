@IsTest
public class MarketingFieldsForAccountsSupplementer
    implements ITestDataSupplement
{
    public void supplement(List<SObject> accountSObjectList)
    {
        for (Account acct : (List<Account>) accountSObjectList)
        {
            acct.Slogan__c = 'Hello world!';
        }
    }
}
