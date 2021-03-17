public with sharing class TestDataFactoryFSMI {
    public inherited sharing class SelectBySloganSelectorMethod
    extends AbstractSelectorMethodInjectable
    implements ISelectorMethodInjectable
    {
        public List<SObject> selectQuery()
        {
            TestDataFactoryFSMI.Parameters params = (
                TestDataFactoryFSMI.Parameters
            )getParams(); 

            Set<String> sloganNameSet = 
                params.sloganNameSet;

            return Database.query( 
                newQueryFactory().setCondition( 
                Account.Slogan__c + ' in :sloganNameSet').toSOQL() 
            );
        }
    }

    public class Parameters
        implements ISelectorMethodParameterable
    {
        public Set<String> sloganNameSet;
    }

    public static List<Account> createTestAccountsWithSlogan(Integer numAccts, String slogan){
        List<Account> accts = new List<Account>();

        for(Integer i=0;i<numAccts;i++) {
            Account a  = new Account(
                Name='TestAccount' + i,
                Slogan__c=slogan
            );
            accts.add(a);
        }
        insert accts;
        return accts;
    }

    public static List<Account> createTestAccounts(Integer numAccts){
        List<Account> accts = new List<Account>();

        for(Integer i=0;i<numAccts;i++) {
            Account a  = new Account(
                Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        return accts;
    }
}
