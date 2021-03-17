@IsTest
public with sharing class AbstractSelectorMethodInjectionTest {
    @IsTest
    static void AbstractSelectorMethodInjectionTest() {
        String slogan = 'fishy';

        List<Account> acctsWithSlogan = TestDataFactoryFSMI.createTestAccountsWithSlogan(2, slogan);
        List<Account> acctsWithoutSlogan = TestDataFactoryFSMI.createTestAccounts(2);

        TestDataFactoryFSMI.Parameters queryParams = 
            new TestDataFactoryFSMI.Parameters();

        queryParams.sloganNameSet = 
            new Set<String>{ slogan };
        
        test.startTest();
        List<Account> acctsReturned = 
            AccountsSelector.newInstance().selectInjection( 
                TestDataFactoryFSMI.SelectBySloganSelectorMethod.class, queryParams  
        );
        test.stopTest();

        System.assertEquals( 
            acctsWithSlogan.size(),
            acctsReturned.size(),
            'Number of accounts with Slogan not equal'
        );
    }
}
