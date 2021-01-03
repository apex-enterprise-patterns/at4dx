public inherited sharing class TestSelectorMethod
    extends AbstractSelectorMethodInjectable
    implements ISelectorMethodInjectable
{
    public List<SObject> selectQuery()
    {
        TestSelectorMethod.Parameters params = (TestSelectorMethod.Parameters)getParams(); 

        Set<String> accountNumberSet = params.accountNumberSet;

        return Database.query( newQueryFactory().setCondition( Account.AccountNumber + ' in :accountNumberSet').toSOQL() );
    }

    public class Parameters
        implements ISelectorMethodParameterable
    {
        public Set<String> accountNumberSet;
    }
}
