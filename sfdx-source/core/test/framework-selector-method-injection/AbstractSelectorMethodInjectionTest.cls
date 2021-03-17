@IsTest
public with sharing class AbstractSelectorMethodInjectionTest {
    @IsTest
    static void verifyAbstractSelectorMethodInjection() {
        String keyName = 'fishy';

        //TODO Create 2 accounts with 2 differant names one with keyName

        TestDataFactoryFSMI.Parameters queryParams = 
            new TestDataFactoryFSMI.Parameters();

        queryParams.sloganNameSet = 
            new Set<String>{ keyName };
        
        //Update selector to new created slected from Application S object Selector
         
        test.startTest();
        List<Account> acctsReturned = 
            //Udpate ->AccountsSelector<-.newInstance().selectInjection( 
                TestDataFactoryFSMI.SelectBySloganSelectorMethod.class, queryParams  
        );
        test.stopTest();

        System.assertEquals( 
            acctsWithKeyName.getName(),
            acctsReturned.[0], // Or what ever expected place in list that holds record with keyName
            'Account Name Not Equal'
        );
    }

    //TODO imbed vanilla selector method for 

    
    private class SelectByNameSelectorTestMethod
    extends AbstractSelectorMethodInjectable
    implements ISelectorMethodInjectable
    {
        public List<SObject> selectQuery()
        {
            TestDataFactoryFSMI.Parameters params = (
                AbstractSelectorMethodInjectionTest.Parameters
            )getParams(); 
            
            Set<String> nameSet = 
                params.nameSet;
            
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
}
