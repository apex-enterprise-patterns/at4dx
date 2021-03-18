@IsTest
public with sharing class AbstractSelectorMethodInjectionTest {
    @IsTest
    static void verifyAbstractSelectorMethodInjection() {
        String keyName = 'fishy';

        List<Account> acctList = new List<Account> {
			new Account(Name=keyName),
			new Account(Name='TestAccount1') 
        };		
		insert acctList;

        Parameters queryParams = new Parameters();
        queryParams.nameSet = new Set<String>{ keyName };
        
        TestApplication_SObjectSelector testAppSOSelector =
            new TestApplication_SObjectSelector(); 

        test.startTest(); 
        List<Account> acctsReturned = 
            testAppSOSelector.selectInjection( 
                SelectByNameSelectorTestMethod.class, 
                queryParams  
        );
        test.stopTest();
        
        System.assertEquals(
            1,
            acctsReturned.size(),
            'Incorrect Amount of Records Returned'
        );

        Account acctToCheck = acctsReturned[0];
        System.assertEquals( 
            keyName,
            acctToCheck.Name,
            'Account Name Not Equal'
        );
    }

    private class SelectByNameSelectorTestMethod
    extends AbstractSelectorMethodInjectable
    implements ISelectorMethodInjectable
    {
        public List<SObject> selectQuery()
        {
            Parameters params = (
                Parameters
            )getParams(); 
            
            Set<String> nameSet = params.nameSet;
            
            return Database.query( 
                newQueryFactory().setCondition( 
                    Account.Name+ ' in :nameSet').toSOQL() 
            );
        }
    }
        
    public class Parameters
        implements ISelectorMethodParameterable
    {
        public Set<String> nameSet;
    }

    private class TestApplication_SObjectSelector extends ApplicationSObjectSelector
	{
		public TestApplication_SObjectSelector()
		{
			super();
		}

        public List<Schema.SObjectField> getAdditionalSObjectFieldList()
            {
                return new List<Schema.SObjectField> {
                    Account.Name
                };
            }

		public Schema.SObjectType getSObjectType()
		{
			return Account.sObjectType;
		}
	}
}
