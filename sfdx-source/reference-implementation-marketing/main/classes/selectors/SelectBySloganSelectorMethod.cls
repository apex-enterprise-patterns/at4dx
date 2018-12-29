public inherited sharing class SelectBySloganSelectorMethod
    extends AbstractSelectorMethodInjectable
    implements ISelectorMethodInjectable
{
    public List<SObject> selectQuery()
    {
        SelectBySloganSelectorMethod.Parameters params = (SelectBySloganSelectorMethod.Parameters)getParams(); 

        Set<String> sloganNameSet = params.sloganNameSet;

        return Database.query( newQueryFactory().setCondition( Account.Slogan__c + ' in :sloganNameSet').toSOQL() );
    }

    public class Parameters
        implements ISelectorMethodParameterable
    {
        public Set<String> sloganNameSet;
    }
}
